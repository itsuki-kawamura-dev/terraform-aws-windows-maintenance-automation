import boto3
import re
import time

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

    while True:
        result = ssm.get_command_invocation(
            CommandId=command_id,
            InstanceId=instance_id
        )

        status = result["Status"]

        if status in ["Success", "Failed", "Cancelled", "TimedOut"]:
            break

        time.sleep(5)

    if status != "Success":
        raise Exception(f"Patch scan failed: {status}")

    output = result["StandardOutputContent"]

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