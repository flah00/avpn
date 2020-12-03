# avpn

A simple VPN, which relies on S3, KMS, OpenVPN, and Flatcar

## Parameters

* **AMI** Flatcar Linux AMI
* **AZ** availability zone
* **Bucket** An s3 bucket you manage
* **EphemeralDockerPartition** If the instance type supports ephemeral storage, store docker data on it
* **EphemeralDeviceName** The /dev/ name of the ephemeral device
* **HostedZoneName** A route 53 zone you manage
* **IAMUser** An optional IAM user, permitted to use the KMS key
* **InstanceType** AWS EC2 instance type
* **Key** AWS EC2 key pair
* **RootVolumeSize** The size of the root volume, in GB
* **VPNHostname** The hostname of the VPN server

## Install 

1. `KEY_NAME=YOUR_KEY_NAME`
1. `ZONE=YOUR_HOSTED_ZONE`
1. `BUCKET=YOUR_BUCKET_NAME`
1. `AZ=YOUR_AVAILABILITY_ZONE`
1. `AMI=$(REGION=${AZ%[a-z]} CHANNEL=stable; curl -s https://$CHANNEL.release.flatcar-linux.net/amd64-usr/current/flatcar_production_ami_all.json | jq  -r ".amis[] | select(.name==\"$REGION\") .hvm")`
1. `aws ec2 create-key-pair --key-name $KEY_NAME`
1. `aws ec2 enable-ebs-encryption-by-default`
1. `aws s3 mb s3://$BUCKET`
1. If your domain is not registered with R53, create a hosted zone for it
1. Create the stack
  ```
  aws cloudformation create-stack \
    --stack-name avpn \
    --template-body file://cf.json \
    --capabilities CAPABILITY_IAM \
    --parameters \
      ParameterKey=AMI,ParameterValue=$AMI \
      ParameterKey=AZ,ParameterValue=$AZ \
      ParameterKey=Bucket,ParameterValue=$BUCKET \
      ParameterKey=HostedZoneName,ParameterValue=$ZONE \
      ParameterKey=VPNHostname,ParameterValue=$ZONE \
      ParameterKey=Key,ParameterValue=$KEY_NAME \
      ParameterKey=InstanceType,ParameterValue=t3.small \
      ParameterKey=IAMUser,ParameterValue="" \
      ParameterKey=RootVolumeSize,ParameterValue=10 \
      ParameterKey=EphemeralDockerPartition,ParameterValue=false
  ```
1. Encrypt the bucket, using the new KMS key
