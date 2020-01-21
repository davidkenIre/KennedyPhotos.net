<# .SYNOPSIS
     The following is a sample set of steps to start an Amplify application in AWS and connect to Cognito
.DESCRIPTION
     
.NOTES     
#>



cd /Amplify
amplify configure
Username: tfs
Public: AKIA
Private: /0Tax
Profile: ampprofile

npx create-react-app ampone
cd ampone
npm install aws-amplify
npm install aws-sdk
npm install aws-amplify-react
npm install react-select

amplify init
                Environment: amplifyenv

Debug: npm start

amplify add hosting
                Bucket: ampone-20191202110343-hostingbucket
                amptwo-20191202151616-hostingbucket
amplify publish

amplify add auth
Replace src/aws-exports.js with
    "aws_project_region": "eu-west-1",
    "aws_cognito_identity_pool_id": "eu-west-1…. ",
    "aws_cognito_region": "eu-west-1",
    "aws_user_pools_id": "eu-west-1_ze3WDblle",
    "aws_user_pools_web_client_id": "4f2dfos31….",

AmazonSSMReadOnlyAccess 
