import boto3
import time

ssm = boto3.client("ssm")


def lambda_handler(event, context):

    instance_id = event["instance_id"]

    # Patch Scan
    response = ssm.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunPatchBaseline",
        Parameters={
            "Operation": ["Scan"]
        }
    )

    command_id = response["Command"]["CommandId"]

    print(f"CommandId: {command_id}")

    # Wait for Scan completion
    while True:

        response = ssm.list_command_invocations(
            CommandId=command_id,
            InstanceId=instance_id
        )

        if not response["CommandInvocations"]:
            print("Command invocation is not ready yet.")
            time.sleep(5)
            continue

        status = response["CommandInvocations"][0]["Status"]

        print(f"Status: {status}")

        if status in [
            "Success",
            "Failed",
            "Cancelled",
            "TimedOut"
        ]:
            break

        time.sleep(5)

    if status != "Success":
        raise Exception(f"Patch scan failed: {status}")

    # Get structured patch compliance result
    patch_state_response = ssm.describe_instance_patch_states(
        InstanceIds=[instance_id]
    )

    patch_states = patch_state_response["InstancePatchStates"]

    if not patch_states:
        raise Exception("Patch state not found")

    patch_state = patch_states[0]

    missing_count = patch_state.get("MissingCount", 0)

    print(f"InstanceId: {instance_id}")
    print(f"MissingCount: {missing_count}")

    return {
        "instance_id": instance_id,
        "missing_count": missing_count
    }