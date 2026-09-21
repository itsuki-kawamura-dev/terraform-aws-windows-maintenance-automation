import boto3
import re
import time
from botocore.exceptions import ClientError

ssm = boto3.client("ssm")


def lambda_handler(event, context):

    instance_id = event["instance_id"]

    response = ssm.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunPatchBaseline",
        Parameters={
            "Operation": ["Scan"]
        }
    )

    command_id = response["Command"]["CommandId"]

    print(f"CommandId: {command_id}")

    while True:
        try:
            result = ssm.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id
            )

        except ssm.exceptions.InvocationDoesNotExist:
            print("Command invocation is not ready yet. Retrying...")
            time.sleep(5)
            continue

        status = result["Status"]
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
        print(f"Patch scan failed: {status}")
        print(f"StandardOutput: {result['StandardOutputContent']}")
        print(f"StandardError: {result['StandardErrorContent']}")
        print(f"Full result: {result}")

        raise Exception(f"Patch scan failed: {status}")

    output = result.get("StandardOutputContent", "")
    error = result.get("StandardErrorContent", "")

    match = re.search(r"MissingCount\s*:\s*(\d+)", output)

    if not match:
        raise Exception("MissingCount not found")

    missing_count = int(match.group(1))

    print(f"InstanceId: {instance_id}")
    print(f"MissingCount: {missing_count}")

    return {
        "instance_id": instance_id,
        "missing_count": missing_count
    }