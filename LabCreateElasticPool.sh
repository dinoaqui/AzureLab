ADMIN_LOGIN="ServerAdmin"
RESOURCE_GROUP=RG_DELETE
SERVERNAME=FitnessSQLServer-KLN
LOCATION=eastus2
PASSWORD=12qwaszx..

az group create -l $LOCATION -n $RESOURCE_GROUP

az sql server create \
--name $SERVERNAME \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--admin-user $ADMIN_LOGIN \
--admin-password $PASSWORD


az sql db create \
--resource-group $RESOURCE_GROUP \
--server $SERVERNAME \
--name FitnessVancouverDB

az sql db create \
--resource-group $RESOURCE_GROUP \
--server $SERVERNAME \
--name FitnessParisDB
