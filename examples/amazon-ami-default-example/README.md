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