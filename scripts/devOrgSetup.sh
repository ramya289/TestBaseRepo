#!/bin/bash
  
# This is the bash script to create Scratch Org and Push Code

# bash scripts/devOrgSetup.sh (Use this command to run this file)

echo "This is the bash script to create Scratch Org and Push Code"

# Dev Hub alias name
# If it's not connected with your CLI then run this below command
# sfdx auth:web:login -d -a bwDevHub
# devHub=bwDevHub
devHub=RBWPDevHub

# Dev Credentials Org alias name, this org contains Custom Metadata Records
# If it's not connected with your CLI then run this below command
# sfdx auth:web:login -a cmdDevBWP
cmdOrg=cmdDevBWP

echo "Enter alias Name for Scratch Org: "
read scratch_alias
 
echo "Creating Scratch Org"  
#sfdx force:org:create -v $devHub -a $scratch_alias orgName=$scratch_alias features=PersonAccounts hasSampleData=true -f config/project-scratch-def.json -d 15 -w 5
sfdx force:org:create -v $devHub -a $scratch_alias orgName=$scratch_alias hasSampleData=true -f config/project-scratch-def.json -d 30 -w 5
# -w: The streaming client socket timeout (in minutes).
# -d: Duration of the scratch org (in days) (default:7, min:1, max:30).
echo "=============================================================================" 

echo "Retrieving Developer Custom Metadata"
sfdx force:source:retrieve -u $cmdOrg -m "CustomMetadata"
# -u: Alias name of the Dev Credentials Org.
echo "=============================================================================" 

echo "Pushing Code" 
sfdx force:source:push -u $scratch_alias
echo "=============================================================================" 

echo "Assigning Permission Sets"
sfdx force:user:permset:assign -u $scratch_alias -n "Breadwinner_Payments_Admin_User,Developer_Permissions" 
echo "=============================================================================" 

#echo "Importing sample data"
#sfdx force:data:tree:import -u $scratch_alias -p sample-data/Account-Contact-Opportunity-plan.json
#echo "=============================================================================" 

echo "Opening Org" 
sfdx force:org:open -u $scratch_alias