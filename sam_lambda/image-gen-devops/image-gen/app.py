import json
import boto3
import base64
import random
import os
from botocore.exceptions import BotoCoreError, ClientError

# Set up the AWS clients
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")  # Bedrock only available in us-east-1
s3_client = boto3.client("s3")

# Get the S3 bucket name from environment variables
bucket_name = os.environ['S3_BUCKET_NAME']  # Bucket name should be passed via environment variables
model_id = "amazon.titan-image-generator-v1"  # Bedrock model ID for Titan image generation

def lambda_handler(event, context):
    try:
        # Parse the body of the incoming request to get the prompt
        body = json.loads(event['body'])
        prompt = body.get("prompt", "")

        if not prompt:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Prompt is required"})
            }

        # Generate a unique seed for the image
        seed = random.randint(0, 2147483647)

        # Define S3 image path using the candidate number as a prefix
        kandidatnummer = os.environ['KANDIDATNUMMER']  # Get the candidate number from environment variables
        s3_image_path = f"{kandidatnummer}/generated_images/titan_{seed}.png"

        # Prepare the request body for Bedrock's image generation API
        native_request = {
            "taskType": "TEXT_IMAGE",
            "textToImageParams": {"text": prompt},
            "imageGenerationConfig": {
                "numberOfImages": 1,
                "quality": "standard",
                "cfgScale": 8.0,
                "height": 1024,
                "width": 1024,
                "seed": seed,
            }
        }

        # Call Bedrock to generate the image
        response = bedrock_client.invoke_model(modelId=model_id, body=json.dumps(native_request))
        model_response = json.loads(response["body"].read())

        # Extract and decode the Base64 image data
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)

        # Upload the image data to S3
        s3_client.put_object(Bucket=bucket_name, Key=s3_image_path, Body=image_data)

        # Return the successful response
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Image generated and saved", "file_path": s3_image_path})
        }

    except (BotoCoreError, ClientError) as error:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Error: {str(error)}"})
        }

    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": f"Error processing request: {str(e)}"})
        }
#Handing in task 1b