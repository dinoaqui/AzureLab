---

# 📄 **Roteiro: Publicação e Controle de Azure Custom Role no GitHub**

## 🎯 Objetivo

Armazenar e versionar a criação do Azure Custom Role: `Custom PostgreSQL Creator`
Com as permissões mínimas para criação de Azure Database for PostgreSQL Flexible Server.

---

## 📁 Estrutura de diretórios no repositório GitHub (exemplo)

```bash
azure-iam-roles/
└── custom-roles/
    └── postgresql-flexible-server-creator/
        ├── role-definition.json
        └── README.md
```

---

## 📄 Conteúdo do `role-definition.json`

```json
{
  "Name": "Custom PostgreSQL Creator",
  "IsCustom": true,
  "Description": "Permite criar instâncias do Azure Database for PostgreSQL Flexible Server e associar à rede.",
  "Actions": [
    "Microsoft.DBforPostgreSQL/flexibleServers/write",
    "Microsoft.DBforPostgreSQL/flexibleServers/read",
    "Microsoft.Resources/subscriptions/resourceGroups/read",
    "Microsoft.Network/virtualNetworks/subnets/join/action"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  ]
}
```

> ⚠ **Importante:** substituir `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` pelo ID da sua subscription.

---

## 📄 Conteúdo do `README.md`

````markdown
# Azure Custom Role: Custom PostgreSQL Creator

## Descrição

Permite criar instâncias do Azure Database for PostgreSQL Flexible Server e associá-las à rede.

## Permissões

- Microsoft.DBforPostgreSQL/flexibleServers/write
- Microsoft.DBforPostgreSQL/flexibleServers/read
- Microsoft.Resources/subscriptions/resourceGroups/read
- Microsoft.Network/virtualNetworks/subnets/join/action

## Como publicar o role via Azure CLI

### 1️⃣ Login no Azure CLI

```bash
az login
````

### 2️⃣ Substitua o ID da subscription no role-definition.json

### 3️⃣ Publicar o role

```bash
az role definition create --role-definition ./role-definition.json
```

### 4️⃣ Validar

```bash
az role definition list --name "Custom PostgreSQL Creator"
```

---

## 🔒 Boas práticas de versionamento

* Toda alteração no role-definition deve ser realizada via Pull Request.
* Sempre incluir uma versão (`v1.0.0`, `v1.0.1`, etc) no histórico de commits.

```

---

✅ **Pronto para ser publicado.**

Se quiser, eu também posso:

- Montar o **repositório inicial em Markdown**;
- Gerar o **YAML de CI/CD** para automatizar a publicação do role no Azure (muito usado em pipelines corporativos).

Se quiser dar o próximo passo, me avise.  
👉 **Quer que eu monte o modelo de repositório pronto?**
```
