#!/bin/bash

HIVE_DIR_NAME="hive"
SUDO_CMD="sudo -u hdfs"

echo -n "Please enter the name of the company and press [ENTER] (default: hortonworks): "
read company
if [ "$company" == "" ]; then
        company="hortonworks"
fi
echo -n "Please enter a name to classify assets in the cluster and press [ENTER] (default: projects): "
read projectname
if [ "$projectname" == "" ]; then
	projectname="projects"
fi
echo -n "Please enter a list of data assets seperating by space and press [ENTER] (default: marketing etl edi): "
read assets
if [ "$assets" == "" ]; then
        assets=(marketing etl edi)
else
	assets=($assets)
fi
echo -n "Please enter data processing stages and press [ENTER] (default: raw, standardized, processed): "
read stages
if [ "$stages" == "" ]; then
        stages=(raw standardized processed)
else
	stages=($stages)
fi

#Create Top Level Directory Structure
$SUDO_CMD hdfs dfs -mkdir -p /$company/$projectname
for i in "${assets[@]}"
do
	$SUDO_CMD hdfs dfs -mkdir -p /$company/$projectname/$i
	echo "Created $company/$projectname/$i"
	for j in "${stages[@]}"
	do
             $SUDO_CMD hdfs dfs -mkdir -p /$company/$projectname/$i/$j
	     echo "Created $company/$projectname/$i/$j"
	done
done

#Chmod to make the files owned by hdfs and next we fill create Ranger Policy's to provide access
$SUDO_CMD hdfs dfs -chmod -R 700 /$company

echo 
echo -n "### Ranger Policy Creation"
echo
echo -n "What is the name of user that you want to apply policy to this company: "
read user

#Create a Ranger policy that only gives a user access to the company
#sed 's/{company}/$company/g' defaultCompanyPolicy.json | sed 's/{user}/"$user"/g' > policyfiles/$companyDefaultPolicy.json

#Create the policy in Ranger
#curl -u admin:admin -i -k -X POST http://localhost:6080/service/public/api/policy -d@policyfiles/$companyDefaultPolicy.json -H Content-Type:application/json

curl -u admin:admin -i -k -X POST http://localhost:6080/service/public/api/policy -d@fordCompanyPolicy.json -H Content-Type:application/json
