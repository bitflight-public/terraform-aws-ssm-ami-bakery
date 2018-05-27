resource "aws_ssm_document" "document_linux" {
  count         = "${var.os_type == "linux" ? 1 : 0 }"
  name          = "${module.label.id}-linux-document"
  document_type = "Automation"

  content = <<DOC
{
  "schemaVersion": "0.3",
  "description": "Updates AMI with Linux distribution packages and Amazon software. For details,see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/sysman-ami-walkthrough.html",
  "assumeRole": "{{AutomationAssumeRole}}",
  "parameters": {
    "SourceAmiId": {
      "type": "String",
      "description": "(Required) The source Amazon Machine Image ID."
    },
    "SourceAmiParameterName": {
      "type": "String",
      "description": "(Required) The Parameter Store key where the AMI id is stored."
    },
    "SSMAmiLambdaFunctionName": {
      "type": "String",
      "description": "(Required) The Lambda function name that should be triggered at the end of the build."
    },
    "InstanceIamRole": {
      "type": "String",
      "description": "(Required) The name of the role that enables Systems Manager (SSM) to manage the instance.",
      "default": "ManagedInstanceProfile"
    },
    "AutomationAssumeRole": {
      "type": "String",
      "description": "(Required) The ARN of the role that allows Automation to perform the actions on your behalf.",
      "default": "arn:aws:iam::{{global:ACCOUNT_ID}}:role/AutomationServiceRole"
    },
    "TargetAmiName": {
      "type": "String",
      "description": "(Optional) The name of the new AMI that will be created. Default is a system-generated string including the source AMI id, and the creation time and date.",
      "default": "UpdateLinuxAmi_from_{{SourceAmiId}}_on_{{global:DATE_TIME}}"
    },
    "InstanceType": {
      "type": "String",
      "description": "(Optional) Type of instance to launch as the workspace host. Instance types vary by region. Default is t2.micro.",
      "default": "t2.micro"
    },
    "PreUpdateScript": {
      "type": "String",
      "description": "(Optional) URL of a script to run before updates are applied. Default (\"none\") is to not run a script.",
      "default": "none"
    },
    "PostUpdateScript": {
      "type": "String",
      "description": "(Optional) URL of a script to run after package updates are applied. Default (\"none\") is to not run a script.",
      "default": "none"
    },
    "IncludePackages": {
      "type": "String",
      "description": "(Optional) Only update these named packages. By default (\"all\"), all available updates are applied.",
      "default": "all"
    },
    "ExcludePackages": {
      "type": "String",
      "description": "(Optional) Names of packages to hold back from updates, under all conditions. By default (\"none\"), no package is excluded.",
      "default": "none"
    },
    "SSMAutomationUpdateAsg": {
      "type": "String",
      "description": "Lambda function name that updates the ASGs",
      "default": ""
    },
    "targetASG": {
      "type": "String",
      "description": "(Optional) Autoscaling group ARN to update to use the new AMI created",
      "default": ""
    },
    "ApprovalNotificationArn": {
      "type": "String",
      "description": "(Optional) ARN of an SNS topic which to watch for approval requests",
      "default": ""
    }
  },
  "mainSteps": [
    {
      "name": "launchInstance",
      "action": "aws:runInstances",
      "maxAttempts": 3,
      "timeoutSeconds": 1200,
      "onFailure": "Abort",
      "inputs": {
        "ImageId": "{{SourceAmiId}}",
        "InstanceType": "{{InstanceType}}",
        "UserData": "IyEvYmluL2Jhc2gNCg0KZnVuY3Rpb24gZ2V0X2NvbnRlbnRzKCkgew0KICAgIGlmIFsgLXggIiQod2hpY2ggY3VybCkiIF07IHRoZW4NCiAgICAgICAgY3VybCAtcyAtZiAiJDEiDQogICAgZWxpZiBbIC14ICIkKHdoaWNoIHdnZXQpIiBdOyB0aGVuDQogICAgICAgIHdnZXQgIiQxIiAtTyAtDQogICAgZWxzZQ0KICAgICAgICBkaWUgIk5vIGRvd25sb2FkIHV0aWxpdHkgKGN1cmwsIHdnZXQpIg0KICAgIGZpDQp9DQoNCnJlYWRvbmx5IElERU5USVRZX1VSTD0iaHR0cDovLzE2OS4yNTQuMTY5LjI1NC8yMDE2LTA2LTMwL2R5bmFtaWMvaW5zdGFuY2UtaWRlbnRpdHkvZG9jdW1lbnQvIg0KcmVhZG9ubHkgVFJVRV9SRUdJT049JChnZXRfY29udGVudHMgIiRJREVOVElUWV9VUkwiIHwgYXdrIC1GXCIgJy9yZWdpb24vIHsgcHJpbnQgJDQgfScpDQpyZWFkb25seSBERUZBVUxUX1JFR0lPTj0idXMtZWFzdC0xIg0KcmVhZG9ubHkgUkVHSU9OPSIke1RSVUVfUkVHSU9OOi0kREVGQVVMVF9SRUdJT059Ig0KDQpyZWFkb25seSBTQ1JJUFRfTkFNRT0iYXdzLWluc3RhbGwtc3NtLWFnZW50Ig0KIFNDUklQVF9VUkw9Imh0dHBzOi8vYXdzLXNzbS1kb3dubG9hZHMtJFJFR0lPTi5zMy5hbWF6b25hd3MuY29tL3NjcmlwdHMvJFNDUklQVF9OQU1FIg0KDQppZiBbICIkUkVHSU9OIiA9ICJjbi1ub3J0aC0xIiBdOyB0aGVuDQogIFNDUklQVF9VUkw9Imh0dHBzOi8vYXdzLXNzbS1kb3dubG9hZHMtJFJFR0lPTi5zMy5jbi1ub3J0aC0xLmFtYXpvbmF3cy5jb20uY24vc2NyaXB0cy8kU0NSSVBUX05BTUUiDQpmaQ0KDQppZiBbICIkUkVHSU9OIiA9ICJ1cy1nb3Ytd2VzdC0xIiBdOyB0aGVuDQogIFNDUklQVF9VUkw9Imh0dHBzOi8vYXdzLXNzbS1kb3dubG9hZHMtJFJFR0lPTi5zMy11cy1nb3Ytd2VzdC0xLmFtYXpvbmF3cy5jb20vc2NyaXB0cy8kU0NSSVBUX05BTUUiDQpmaQ0KDQpjZCAvdG1wDQpGSUxFX1NJWkU9MA0KTUFYX1JFVFJZX0NPVU5UPTMNClJFVFJZX0NPVU5UPTANCg0Kd2hpbGUgWyAkUkVUUllfQ09VTlQgLWx0ICRNQVhfUkVUUllfQ09VTlQgXSA7IGRvDQogIGVjaG8gQVdTLVVwZGF0ZUxpbnV4QW1pOiBEb3dubG9hZGluZyBzY3JpcHQgZnJvbSAkU0NSSVBUX1VSTA0KICBnZXRfY29udGVudHMgIiRTQ1JJUFRfVVJMIiA+ICIkU0NSSVBUX05BTUUiDQogIEZJTEVfU0laRT0kKGR1IC1rIC90bXAvJFNDUklQVF9OQU1FIHwgY3V0IC1mMSkNCiAgZWNobyBBV1MtVXBkYXRlTGludXhBbWk6IEZpbmlzaGVkIGRvd25sb2FkaW5nIHNjcmlwdCwgc2l6ZTogJEZJTEVfU0laRQ0KICBpZiBbICRGSUxFX1NJWkUgLWd0IDAgXTsgdGhlbg0KICAgIGJyZWFrDQogIGVsc2UNCiAgICBpZiBbWyAkUkVUUllfQ09VTlQgLWx0IE1BWF9SRVRSWV9DT1VOVCBdXTsgdGhlbg0KICAgICAgUkVUUllfQ09VTlQ9JCgoUkVUUllfQ09VTlQrMSkpOw0KICAgICAgZWNobyBBV1MtVXBkYXRlTGludXhBbWk6IEZpbGVTaXplIGlzIDAsIHJldHJ5Q291bnQ6ICRSRVRSWV9DT1VOVA0KICAgIGZpDQogIGZpIA0KZG9uZQ0KDQppZiBbICRGSUxFX1NJWkUgLWd0IDAgXTsgdGhlbg0KICBjaG1vZCAreCAiJFNDUklQVF9OQU1FIg0KICBlY2hvIEFXUy1VcGRhdGVMaW51eEFtaTogUnVubmluZyBVcGRhdGVTU01BZ2VudCBzY3JpcHQgbm93IC4uLi4NCiAgLi8iJFNDUklQVF9OQU1FIiAtLXJlZ2lvbiAiJFJFR0lPTiINCmVsc2UNCiAgZWNobyBBV1MtVXBkYXRlTGludXhBbWk6IFVuYWJsZSB0byBkb3dubG9hZCBzY3JpcHQsIHF1aXR0aW5nIC4uLi4NCmZp",
        "MinInstanceCount": 1,
        "MaxInstanceCount": 1,
        "IamInstanceProfileName": "{{InstanceIamRole}}"
      }
    },
    {
      "name": "updateOSSoftware",
      "action": "aws:runCommand",
      "maxAttempts": 3,
      "timeoutSeconds": 3600,
      "onFailure": "Abort",
      "inputs": {
        "DocumentName": "AWS-RunShellScript",
        "InstanceIds": [
          "{{launchInstance.InstanceIds}}"
        ],
        "Parameters": {
          "commands": [
            "set -e",
            "[ -x \"$(which wget)\" ] && get_contents='wget $1 -O -'",
            "[ -x \"$(which curl)\" ] && get_contents='curl -s -f $1'",
            "eval $get_contents https://aws-ssm-downloads-{{global:REGION}}.s3.amazonaws.com/scripts/aws-update-linux-instance > /tmp/aws-update-linux-instance",
            "chmod +x /tmp/aws-update-linux-instance",
            "/tmp/aws-update-linux-instance --pre-update-script '{{PreUpdateScript}}' --post-update-script '{{PostUpdateScript}}' --include-packages '{{IncludePackages}}' --exclude-packages '{{ExcludePackages}}' 2>&1 | tee /tmp/aws-update-linux-instance.log"
          ]
        }
      }
    },
    {
      "name": "stopInstance",
      "action": "aws:changeInstanceState",
      "maxAttempts": 3,
      "timeoutSeconds": 1200,
      "onFailure": "Abort",
      "inputs": {
        "InstanceIds": [
          "{{launchInstance.InstanceIds}}"
        ],
        "DesiredState": "stopped"
      }
    },
    {
      "name": "createImage",
      "action": "aws:createImage",
      "maxAttempts": 3,
      "onFailure": "Abort",
      "inputs": {
        "InstanceId": "{{launchInstance.InstanceIds}}",
        "ImageName": "{{TargetAmiName}}",
        "NoReboot": true,
        "ImageDescription": "AMI Generated by EC2 Automation on {{global:DATE_TIME}} from {{SourceAmiId}}"
      }
    },
    {
      "name": "terminateInstance",
      "action": "aws:changeInstanceState",
      "maxAttempts": 3,
      "onFailure": "Continue",
      "inputs": {
        "InstanceIds": [
          "{{launchInstance.InstanceIds}}"
        ],
        "DesiredState": "terminated"
      }
    },
    {
         "name":"updateSsmParam",
         "action":"aws:invokeLambdaFunction",
         "timeoutSeconds":1200,
         "maxAttempts":1,
         "onFailure":"Abort",
         "inputs":{
            "FunctionName":"{{SSMAmiLambdaFunctionName}}",
            "Payload":"{\"parameterName\":\"{{SourceAmiParameterName}}\", \"parameterValue\":\"{{createImage.ImageId}}\"}"
         }
      }
      ${local.approval_request},
      {
         "name":"updateASG",
         "action":"aws:invokeLambdaFunction",
         "timeoutSeconds":1200,
         "maxAttempts":1,
         "onFailure":"Abort",
         "inputs": {
            "FunctionName": "{{SSMAutomationUpdateAsg}}",
            "Payload": "{\"targetASG\":\"{{targetASG}}\", \"newAmiID\":\"{{createImage.ImageId}}\"}"
         }
      }
  ],
  "outputs": [
    "createImage.ImageId"
  ]
}
DOC
}

locals {
  approval_request_format = {
    "NotificationArn"      = "{{ApprovalNotificationArn}}"
    "Message"              = "Please the Update of  this step of the Automation."
    "MinRequiredApprovals" = "${min(var.min_num_approvers, length(var.approvers_list))}"
    "Approvers"            = ["${var.approvers_list}"]
  }

  approval_request = "${var.require_approval_to_update_asg == "true" ? ",${jsonencode(local.approval_request_format)}" : ""}"
}

resource "aws_ssm_document" "document_windows" {
  count         = "${var.os_type == "windows" ? 1 : 0 }"
  name          = "${module.label.id}-windows-document"
  document_type = "Automation"

  content = <<DOC
{
   "description":"Systems Manager Automation – Patch AMI and Update SSM Param",
   "schemaVersion":"0.3",
   "assumeRole":"the role ARN you created",
   "parameters":{
      "sourceAMIid":{
         "type":"String",
         "description":"AMI to patch",
         "default":"{{ssm:latestAmi}}"
      },
      "targetAMIname":{
         "type":"String",
         "description":"Name of new AMI",
         "default":"patchedAMI-{{global:DATE_TIME}}"
      }
   },
   "mainSteps":[
      {
         "name":"startInstances",
         "action":"aws:runInstances",
         "timeoutSeconds":1200,
         "maxAttempts":1,
         "onFailure":"Abort",
         "inputs":{
            "ImageId":"{{ sourceAMIid }}",
            "InstanceType":"m3.large",
            "MinInstanceCount":1,
            "MaxInstanceCount":1,
            "IamInstanceProfileName":"${aws_iam_role.role.name}"
         }
      },
      {
         "name":"installMissingWindowsUpdates",
         "action":"aws:runCommand",
         "maxAttempts":1,
         "onFailure":"Continue",
         "inputs":{
            "DocumentName":"AWS-InstallMissingWindowsUpdates",
            "InstanceIds":[
               "{{ startInstances.InstanceIds }}"
            ],
            "Parameters":{
               "UpdateLevel":"Important"
            }
         }
      },
      {
         "name":"stopInstance",
         "action":"aws:changeInstanceState",
         "maxAttempts":1,
         "onFailure":"Continue",
         "inputs":{
            "InstanceIds":[
               "{{ startInstances.InstanceIds }}"
            ],
            "DesiredState":"stopped"
         }
      },
      {
         "name":"createImage",
         "action":"aws:createImage",
         "maxAttempts":1,
         "onFailure":"Continue",
         "inputs":{
            "InstanceId":"{{ startInstances.InstanceIds }}",
            "ImageName":"{{ targetAMIname }}",
            "NoReboot":true,
            "ImageDescription":"AMI created by EC2 Automation"
         }
      },
      {
         "name":"terminateInstance",
         "action":"aws:changeInstanceState",
         "maxAttempts":1,
         "onFailure":"Continue",
         "inputs":{
            "InstanceIds":[
               "{{ startInstances.InstanceIds }}"
            ],
            "DesiredState":"terminated"
         }
      },
      {
         "name":"updateSsmParam",
         "action":"aws:invokeLambdaFunction",
         "timeoutSeconds":1200,
         "maxAttempts":1,
         "onFailure":"Abort",
         "inputs":{
            "FunctionName":"Automation-UpdateSsmParam",
            "Payload":"{\"parameterName\":\"latestAmi\", \"parameterValue\":\"{{createImage.ImageId}}\"}"
         }
      }
   ],
   "outputs":[
      "createImage.ImageId"
   ]
}
DOC
}
