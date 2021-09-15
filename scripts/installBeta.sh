#!/bin/bash
  
# This is the bash script to create Scratch Org and install Beta

#Package Version (Beta) Id
PackageId=04t....
#Dev Hub alias name
devHub=bwDevHub
#Scratch Org alias name to create it
scratch_alias=1.6beta1

echo "This script will create Scratch Org and Install Beta"
 
#echo "Creating Scratch Org with Persona Accounts feature"
#sfdx force:org:create -v $devHub -a $scratch_alias orgName=$scratch_alias features=PersonAccounts hasSampleData=true -f config/project-scratch-def.json -d 3 -w 5 -n

echo "Creating Scratch Org"
sfdx force:org:create -v $devHub -a $scratch_alias orgName=$scratch_alias hasSampleData=true -f config/project-scratch-def.json -d 3 -w 5 -n
# -w: The streaming client socket timeout (in minutes).
# -d: Duration of the scratch org (in days) (default:7, min:1, max:30).
# -n: --nonamespace
echo "=============================================================================" 

echo "Installing Beta" 
sfdx force:package:install -u $scratch_alias -p $PackageId -w 5 -s AllUsers -r
# -w: Maximum number of minutes to wait for installation status. The default is 0.
# -s: SECURITYTYPE (Permissible values are: AllUsers, AdminsOnly) Default value: AdminsOnly
# -r: noprompt (Allows the following without an explicit confirmation response: 1) Remote Site Settings and Content Security Policy websites to send or receive data, and 2) --upgradetype Delete to proceed.)
echo "=============================================================================" 

#echo "Importing test data"
#sfdx force:data:tree:import -u $scratch_alias -p sample-data/Account-Contact-Opportunity-plan.json
#echo "=============================================================================" 

echo "Opening Org" 
sfdx force:org:open -u $scratch_alias