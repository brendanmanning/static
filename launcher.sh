# Ensure a clean UI
clear;

# Ensure the AWS command line tool is installed
if ! foobar_loc="$(type -p "aws")" || [[ -z $foobar_loc ]]; then

  echo "--------------------------------------------------------"
  echo "                  AWS COMMAND LINE                      "
  echo "To access the wizard deployments, this program will have"
  echo "to connect to AWS. Please wait while the necessary items"
  echo "are downloaded. You may be asked to enter your password"
  echo "--------------------------------------------------------"

  # Download the latest version of the AWS CLI tool
  curl https://awscli.amazonaws.com/AWSCLIV2.pkg --output aws_cli_installer.pkg

  # Install it
  sudo installer -pkg aws_cli_installer.pkg -target /
  
  # Cleanup UI
  clear
fi

# Check if the AWS credentials file exists or not
if [ ! -f ~/.aws/credentials ]; then

  mkdir ~/.aws/;
  touch ~/.aws/credentials;

  #     echo "--------------------------------------------------------"
  #     echo "               DEFAULT AWS CREDENTIALS                  "
  #     echo "This is setting up the default AWS CLI account on your  "
  #     echo "        Mac since you don't already have one.           "
  #     echo "   This is NOT the credentials I sent you in Discord    "
  #     echo ""
  #     echo "Respond with the following:                             "
  #     echo "   • <ENTER> (nothing) "
  #     echo "   • <ENTER> (nothing) "
  #     echo "   • us-east-1 "
  #     echo "   • json "
  #     echo ""
  #     echo "There will be a 25 second sleep to give you time to read"

  #     sleep 25;

  #     aws configure;
fi

# Check if the access policy exists
if ! grep -Fxq "[wizard-cicd-readonly]" ~/.aws/credentials
then

  echo "--------------------------------------------------------"
  echo "                  AWS CREDENTIALS                       "
  echo "To protect the wizard, you will need to use the provided"
  echo "AWS credentials for the wizard-cicd-readonly AMI role"
  echo "--------------------------------------------------------"

  read -p "Enter aws_access_key_id: "  aws_access_key_id
  read -p "Enter aws_secret_access_key: "  aws_secret_access_key

  echo "" >> ~/.aws/credentials
  echo "[wizard-cicd-readonly]" >> ~/.aws/credentials
  echo "aws_access_key_id = $aws_access_key_id" >> ~/.aws/credentials
  echo "aws_secret_access_key = $aws_secret_access_key" >> ~/.aws/credentials

  clear;

fi

INSTALLED="XX";
EXPECTED=$(curl https://raw.githubusercontent.com/brendanmanning/static/master/version.txt);

if [ -f ~/Trailmapper_latest.jar ]; then

  # Get the installed version
  INSTALLED=$(java -jar ~/Trailmapper_latest.jar -v)

fi

echo "INSTALLED VERSION: ${INSTALLED}";
echo "EXPECTED VERSION: ${EXPECTED}";

if [ $INSTALLED != $EXPECTED ]; then

  echo "--------------------------------------------------------"
  echo "                 DOWNLOADING LATEST                     "
  echo "   Getting the most up to date version of the wizard    "
  echo "               Please be patient...                     "
  echo "--------------------------------------------------------"

  # Get the latest deployment
  aws s3 cp s3://wizard-deploys/Trailmapper.jar ~/Trailmapper_latest.jar --profile wizard-cicd-readonly

  # Cleanup the UI
  clear;
 
 fi

# Run the wizard
cd ~
java -jar ~/Trailmapper_latest.jar
