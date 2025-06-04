## 📄 Azure Custom Role Deployment Guide - "Custom PostgreSQL Creator" ##
--
## Objective

Create a custom Azure RBAC role that allows the user to deploy Azure Database for PostgreSQL Flexible Server instances and assign them to an existing virtual network.

---

## Required Permissions to Execute

The operator performing this deployment must have:

* **Owner** or **User Access Administrator** role at subscription or resource group scope.

---

## Custom Role Definition

### JSON Role Definition

```json
{
  "Name": "Custom PostgreSQL Creator",
  "IsCustom": true,
  "Description": "Allows creation of Azure Database for PostgreSQL Flexible Server instances and assign them to a Virtual Network subnet.",
  "Actions": [
    "Microsoft.DBforPostgreSQL/flexibleServers/write",
    "Microsoft.DBforPostgreSQL/flexibleServers/read",
    "Microsoft.DBforPostgreSQL/flexibleServers/backups/read",
    "Microsoft.DBforPostgreSQL/flexibleServers/backups/write",
    "Microsoft.DBforPostgreSQL/flexibleServers/backups/delete",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Resources/deployments/validate/action",
    "Microsoft.Resources/deployments/write",
    "Microsoft.Resources/deployments/read"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  ]
}
```

> 🔧 Replace `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` with your actual Azure Subscription ID.

---

## Deployment Steps

### 1️⃣ Login to Azure CLI

```bash
az login
```

> Optional: specify subscription if you have multiple:

```bash
az account set --subscription "<subscription-name-or-id>"
```

---

### 2️⃣ Save Role Definition JSON

* Create a local file named `custom_postgresql_creator.json`
* Paste the JSON role definition into the file.

---

### 3️⃣ Create the Custom Role

```bash
az role definition create --role-definition ./custom_postgresql_creator.json
```

✅ If successful, you will receive no error message.

---

### 4️⃣ Validate Role Creation

```bash
az role definition list --name "Custom PostgreSQL Creator"
```

Or

```bash
az role definition show --name "Custom PostgreSQL Creator"
```

---

### 5️⃣ Assign Role to User/Group

To assign the role to a user, group or service principal:

```bash
az role assignment create \
  --assignee "<object-id-or-username>" \
  --role "Custom PostgreSQL Creator" \
  --scope "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<resource-group-name>"
```

> 🔧 Replace placeholders accordingly.

---

## Important Notes

* This role **does not allow deletion** of PostgreSQL instances.
* Network operations are limited to subnet assignment during deployment.
* Further permission may be required depending on Key Vault, Private DNS Zone, or VNET delegation usage.

---

✅ **Deployment complete and ready for production use.**

---
