tenantName=garaio.com
subscriptionName=ce167e67-9065-4703-ae02-b0ee721302a9
resourceGroupName=rg-azb2c-swa-lab
location=westeurope

az login -t garaio.com

az account set --subscription $subscriptionName

az group create --name $resourceGroupName --location $location
az deployment group create --resource-group $resourceGroupName --template-file iac/main.bicep --parameters iac/main.parameters.dev.json