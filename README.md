# servicenow-terraform

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret

 $ az account set --subscription="<>>"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/20000000-0000-0000-0000-000000000000"




curl "https://instance.servicenow.com/api/sn_sc/servicecatalog/items/d82ea08510247200964f77ffeec6c4ee/order_now" \
--request POST \
--header "Accept:application/json" \
--header "Content-Type:application/json" \
--data "{
  sysparm_quantity: 1,
  variables: {
    replacement: 'Yes',
    originalnumber: '1640000',
    data_plan: '500MB'
  }
}" \
--user "username":"password"