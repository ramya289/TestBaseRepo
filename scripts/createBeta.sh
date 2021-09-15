#!/bin/bash
  
# This is the bash script to create Package Version

# Production Package Id
PackageId=0Ho.....

# Dev Hub alias name
# If it's not connected with your CLI then run this below command
# sfdx auth:web:login -a bwDevHub
devHub=bwDevHub

# Production Credentials Org alias name, this org contains Custom Metaadata Records
# If it's not connected with your CLI then run this below command
# sfdx auth:web:login -a cmdProductionBWP
cmdOrg=cmdProductionBWP

echo "Retrieving Production Custom Metadata"
sfdx force:source:retrieve -u $cmdOrg -m "CustomMetadata" 
echo "=============================================================================" 

echo "Creating Package Version (beta)" 
sfdx force:package:version:create -v $devHub -p $PackageId -w 10 -x -c
echo "============================================================================="
