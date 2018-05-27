# terraform-aws-ssm-ami-bakery

ThisTerraform Module creates AWS AMI's that can be easily kept up to date, automatically applying operating system (OS) patches to a Windows or Linux AMI that is already considered to be the most up-to-date or latest AMI. In the example, the default value of the parameter SourceAmiId is defined by a Systems Manager Parameter Store parameter called latestAmi. The value of latestAmi is updated by an AWS Lambda function invoked at the end of the Automation workflow. As a result of this Automation process, the time and effort spent patching AMIs is minimized because patching is always applied to the most up-to-date AMI.

## TODO:
- [x] Create Lambda functions
- [x] Create Automation documents
- [x] Test pipeline
- [x] Create a basic example
- [ ] Create a full README.md file
- [ ] Enable logging of the update processes to cloudwatch
- [ ] Provide inputs for specifying a subnet to launch in
- [ ] Provide inputs for security groups to attach
- [ ] Create output SNS queue, and write the queue arn to Parameter store, so that events can be chained together
- [ ] Import the file `linux-user-data.sh` append the variable `var.additional_userdata` to it, base64 encode it and update the SSM document
- [ ] Create Submodule: Allow setting expiry of old images
- [ ] Submodule: Look for launch configurations and launch templates with the old image and output them

## Simple Example

This will:
- Create a SSM automation document for linux
- Create appropriate roles and policies to run the process
- Create the lambda functions needed to trigger the process
- Create the Parameter Store Name `/cp/dev/amazon-linux/LatestAmi` and store the value of `ami` in it
- Provide parameters to the lambda function such as a name template name template "{namespace}-{stage}-{name}-{date}"
- Subscribe the lambda function to an SNS topic for it to be triggered as per [this aws example](http://docs.amazonaws.cn/en_us/AWSEC2/latest/UserGuide/amazon-linux-ami-basics.html#linux-ami-notifications)
 

When the lambda is triggered it will:
- Launch the specified AMI as a new instance
- Generate a new ami with the name template "{namespace}-{stage}-{name}-{date}" and in the example below the output template is `cp-dev-amazon-linux-{{global:DATE_TIME}}`
- Install the latest SSM agent on it if it is not installed already.
- Update all of the OS patches (`yum update -y`)
- Shut down the instance
- Terminate the instance
- Trigger the second lambda function to update the Parameter Store Name `/cp/dev/amazon-linux/LatestAmi` with the new AMI id.

```hcl
provider "aws" {
	region = "eu-west-2"
}

module "keep_ami_current" {
  source    = "git::git@github.com:bitflight-public/terraform-aws-ssm-ami-bakery.git"
  namespace = "cp"
  stage     = "dev"
  name      = "amazon-linux"
  ami       = "ami-dc2ecebb" // eu-west-2 amazon ami, but you would normally start with your own customised ami
}

# For Amazon Linux updates, they are only released in an SNS feed from us-east-1
# Pin a provider to us-east-1 to create a topic subscription to that SNS feed.
# Below we are subscribing the lambda function to this release notification, 
# This means that on each release from amazon, we will update our custom image to match.
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

resource "aws_sns_topic_subscription" "trigger_automation" {
  provider  = "aws.us-east-1"
  topic_arn = "arn:aws:sns:us-east-1:137112412989:amazon-linux-ami-updates"
  protocol  = "lambda"
  endpoint  = "${module.amazon_ami_bakery.lambda_endpoint_arn}"
}
```
