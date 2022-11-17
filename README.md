# eks

Note : We are creating EKS using Jenkins Job, to create a Jenkins job we first we need to set up Jenkins.

Jenkins Initial Setup: 

1.Get the Jenkins Url From Aws Ec2 bastion host public ip.  Access the jenkins with bastion host url
  Sample: 
    http://54.183.21.95:8080 . 
1.a) Create an ecr registry with the name : jenkins( this is ecr registery)  -- If this is not there Jenkins job will fail.

2.For initial jenkins prompts you to append password. This password can get from below path jenkins instance 
   Path:  /var/lib/jenkins/secrets/initial password

3.Select free defined plugins to install.

4.Create admin user and password.

After login:

1.Login with admin credentials.
2.Install required Plugins by going  to Manage Jenkins >> Plugin >> Manage Plugins >>  Available >> search for      below plugins and install.

  1.Pipeline Utility Steps
  2.Blue Ocean
  3.Pipeline

Note: Default region is us-west-1. To change region. Then updated region  value in below path in Eks Provision code.
# terraform/Environments/nonprod/nonprod.tfvars
   region    = "us-west-1" (existing)
   region    = "us-east-1"   

# terraform/Environments/nonprod/nonprod.tfvars
   region    = "us-west-1" (existing)
   region    = "us-east-1"  


Setup Jenkins Job for Eks creation:
    1.Click on New item in Jenkins dashboard.
    2. Provide Jenkins job name and select Pipeline.
    3. In configuration  go to Pipeline  and select Pipeline script from SCM under definition  >> Under SCM select Git.
       >> Provide Repository Url  >> Under Credentials  create github new credentials by selecting username
      and password.
    4. Create Aws credentials by selecting username and password. Provide username as Accesskey and password as secretkey and ID aws-key.
    5. Create Aws account credentails by selecting username and password. Provide username as awsaccount(345295232481), password as region(us-west-1) and ID account_creds
    5. Save the Configuration.

Jenkins Setup is completed. Click on Build now in Jenkins job to Provision Eks 


t2.large
