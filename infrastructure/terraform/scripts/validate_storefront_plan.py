import copy
import json
import os
import subprocess
import sys


EXPECTED_ADDRESS = (
    'module.ecs_task_definition["storefront"].aws_ecs_task_definition.this'
)
EXPECTED_CONTAINER = "vendure-storefront"

CONFIG_FIELDS = [
    "family",
    "network_mode",
    "requires_compatibilities",
    "cpu",
    "memory",
    "execution_role_arn",
    "task_role_arn",
    "tags",
]


def fail(message, details=None):
    print(f"ERROR: {message}")

    if details is not None:
        print(json.dumps(details, indent=2, sort_keys=True))

    sys.exit(1)


if len(sys.argv) != 2:
    fail("Usage: validate_storefront_plan.py <terraform-plan>")

plan_path = sys.argv[1]

expected_image = os.environ.get("STOREFRONT_IMAGE_URI")

if not expected_image:
    fail("STOREFRONT_IMAGE_URI is not set")


result = subprocess.run(
    ["terraform", "show", "-json", plan_path],
    check=True,
    capture_output=True,
    text=True,
)

plan = json.loads(result.stdout)

changed_resources = []

for resource in plan.get("resource_changes", []):
    actions = resource.get("change", {}).get("actions", [])

    if actions not in (["no-op"], ["read"]):
        changed_resources.append(resource)


if len(changed_resources) != 1:
    fail(
        "Storefront plan must change exactly one resource",
        [
            {
                "address": resource.get("address"),
                "actions": resource.get("change", {}).get("actions"),
            }
            for resource in changed_resources
        ],
    )


resource = changed_resources[0]

if resource.get("address") != EXPECTED_ADDRESS:
    fail(
        "Unexpected Terraform resource change",
        {
            "address": resource.get("address"),
            "actions": resource.get("change", {}).get("actions"),
        },
    )


change = resource["change"]
actions = change.get("actions", [])

if set(actions) != {"create", "delete"}:
    fail(
        "Storefront task definition must be replaced",
        {"actions": actions},
    )


before = change.get("before")
after = change.get("after")

if not isinstance(before, dict) or not isinstance(after, dict):
    fail("Expected both before and after task-definition states")


for field in CONFIG_FIELDS:
    if before.get(field) != after.get(field):
        fail(
            f"Unexpected Storefront task-definition change: {field}",
            {
                "before": before.get(field),
                "after": after.get(field),
            },
        )


before_containers = json.loads(before["container_definitions"])
after_containers = json.loads(after["container_definitions"])


def find_primary_container(containers):
    matches = [
        container
        for container in containers
        if container.get("name") == EXPECTED_CONTAINER
    ]

    if len(matches) != 1:
        fail(
            f"Expected exactly one {EXPECTED_CONTAINER} container",
            containers,
        )

    return matches[0]


before_primary = find_primary_container(before_containers)
after_primary = find_primary_container(after_containers)

before_image = before_primary.get("image")
after_image = after_primary.get("image")


if after_image != expected_image:
    fail(
        "Storefront task definition does not reference the Jenkins-built image",
        {
            "expected": expected_image,
            "actual": after_image,
        },
    )


if before_image == after_image:
    fail("Storefront image did not change")


before_normalized = copy.deepcopy(before_containers)
after_normalized = copy.deepcopy(after_containers)

find_primary_container(before_normalized)["image"] = "__STOREFRONT_IMAGE__"
find_primary_container(after_normalized)["image"] = "__STOREFRONT_IMAGE__"


if before_normalized != after_normalized:
    fail(
        "Storefront container configuration changed beyond the image",
        {
            "before": before_normalized,
            "after": after_normalized,
        },
    )


print("Storefront Terraform plan safety check passed")
print(f"Allowed resource: {EXPECTED_ADDRESS}")
print("Allowed change: vendure-storefront image only")
