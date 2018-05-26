import os
import boto3
import logging
import operator
from datetime import datetime
def lambda_handler(event, context):
  logger = logging.getLogger(__name__)
  logger.addHandler(logging.StreamHandler())
  logger.setLevel(logging.INFO)
  ec2_client = boto3.client('ec2')
  ssm_client = boto3.client('ssm')
  # response = ec2_client.describe_images(Owners=['amazon'], Filters=[{'Name': 'name', 'Values': ['amzn-ami-hvm-????.??.??.*-x86_64-gp2']}])
  # images = [{'ImageId':image['ImageId'], 'CreationDate': datetime.strptime(image['CreationDate'], '%Y-%m-%dT%H:%M:%S.%fZ')} for image in response['Images']]
  # images = sorted(images, reverse=True, key=operator.itemgetter('CreationDate'))
  # ami_id = images[0]['ImageId']
  #confirm  parameter exists before updating it
  response = ssm_client.describe_parameters(Filters=[{'Key': 'Name','Values': [os.environ['SourceAmiParameterName'],],},])
  if not response['Parameters']:
    print('No such parameter')
    return 'SSM parameter not found.'
  #if parameter has a Descrition field, update it PLUS the Value
  if 'Name' in response['Parameters'][0]:
    ami_id_response = ssm_client.get_parameters(Names=[response['Parameters'][0]['Name'],])
    #ami_id_response = ssm_client.get_parameters(Names=[response['Parameters'][0]['Name'],],WithDecryption=True)
    ami_id = ami_id_response['Parameters'][0]['Value']
    logger.info("ami-id: {}".format(ami_id))
    ssm_response = ssm_client.start_automation_execution(DocumentName=os.environ['DocumentName'],
      Parameters={
      'SourceAmiId': [ami_id,], \
      'InstanceIamRole': [os.environ['InstanceIamRole'],], \
      'AutomationAssumeRole': [os.environ['AutomationAssumeRole'],], \
      'TargetAmiName': [os.environ['TargetAmiName'],], \
      'InstanceType': [os.environ['InstanceType'],], \
      'PreUpdateScript': [os.environ['PreUpdateScript'],], \
      'PostUpdateScript': [os.environ['PostUpdateScript'],], \
      'IncludePackages': [os.environ['IncludePackages'],], \
      'ExcludePackages': [os.environ['ExcludePackages'],] \
      }
    )
    logger.info(ami_id_response)
    logger.info(ssm_response)
  logger.info(response)