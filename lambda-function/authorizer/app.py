import os

import boto3

USER_POOL_ID = os.environ['COGNITO_USER_POOL_ID']
APP_CLIENT_ID = os.environ['COGNITO_APP_CLIENT_ID']

cognito_client = boto3.client('cognito-idp')


def lambda_handler(event, context):
    authorization_header = event['headers'].get('Authorization')
    if not authorization_header:
        return False

    try:
        cognito_client.initiate_auth(AuthFlow='USER_PASSWORD_AUTH',
                                     ClientId=APP_CLIENT_ID,
                                     AuthParameters={'USERNAME': authorization_header})
        return True
    except cognito_client.exceptions.NotAuthorizedException:
        return False
    except Exception as e:
        print(e)
        return False
