---

# 🎯 Roteiro Operacional: Criação do Custom Role "Custom PostgreSQL Creator" no Azure

---

## 1️⃣ Objetivo

Criar um Azure Custom Role com permissões mínimas para:

* Criar Azure Database for PostgreSQL Flexible Server.
* Realizar o join da instância na Virtual Network.
* Ler resource groups (para vinculação durante a criação).

---

## 2️⃣ Pré-requisitos

* Permissão de **Owner** ou **User Access Administrator** na subscription (para criar custom roles).
* Azure CLI instalado e autenticado:

  ```bash
  az login
  az account set --subscription "<ID-ou-Nome-da-Subscription>"
  ```

---

## 3️⃣ Conteúdo do Role Definition

Crie um arquivo local chamado `custom-postgresql-creator.json` com o seguinte conteúdo:

```json
{
  "properties": {
    "roleName": "Custom PostgreSQL Creator",
    "description": "Permite criar instâncias do Azure Database for PostgreSQL Flexible Server e associar à rede.",
    "assignableScopes": [
      "/subscriptions/cd8eb3e2-2cf3-45e7-b805-fbe2052c0d2c"
    ],
    "permissions": [
      {
        "actions": [
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
        "notActions": [],
        "dataActions": [],
        "notDataActions": []
      }
    ]
  }
}

```

⚠ Atenção: Substituir `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` pelo ID da subscription onde o role será válido.

Para consultar o ID da subscription:

```bash
az account show --query id -o tsv
```

---

## 4️⃣ Publicação do Custom Role

Execute o comando abaixo para publicar:

```bash
az role definition create --role-definition custom-postgresql-creator.json
```

---

## 5️⃣ Validação

Verifique se o role foi criado com sucesso:

```bash
az role definition list --name "Custom PostgreSQL Creator" --output json
```

---

## 6️⃣ Atribuição do Role

Agora atribua o custom role ao usuário, grupo ou service principal desejado:

```bash
az role assignment create \
  --assignee <UPN-ou-Object-ID> \
  --role "Custom PostgreSQL Creator" \
  --scope /subscriptions/<ID-da-subscription>/resourceGroups/<nome-do-resource-group>
```

---

## 7️⃣ Teste de Validação

* Acesse o Portal Azure com o usuário atribuído.
* Tente criar um **Azure Database for PostgreSQL Flexible Server**.
* Confirme que:

  * É possível criar a instância.
  * É possível associar à VNET.
  * Não há permissão ampla para criar outros recursos fora do escopo.

---

✅ **Fim do roteiro**

---

Se quiser, eu também posso montar um **modelo pronto de documentação interna**, no estilo padrão de ITSM, para você anexar em base de conhecimento de GMUD, Change, Governança etc.

👉 Quer que eu monte essa versão?
(Nesse caso fica com "objetivo", "responsável", "pré-requisito", "execução", "rollback" etc).
