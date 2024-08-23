### Documentação: Expansão de Volumes Lógicos (LVM) e Partições no Sistema de Arquivos XFS

#### Sumário
1. [Introdução](#introdução)
2. [Verificação de Configuração Inicial](#verificação-de-configuração-inicial)
3. [Criação de Nova Partição LVM](#criação-de-nova-partição-lvm)
4. [Expansão do Volume Group (VG)](#expansão-do-volume-group-vg)
5. [Expansão dos Volumes Lógicos (LVs)](#expansão-dos-volumes-lógicos-lvs)
6. [Criação de Novo Volume Lógico e Montagem](#criação-de-novo-volume-lógico-e-montagem)
7. [Verificação Final](#verificação-final)

---

### Introdução

Este documento fornece um passo a passo detalhado para a criação de uma nova partição LVM, expansão do volume group (`rootvg`) e aumento dos volumes lógicos existentes, que utilizam o sistema de arquivos XFS. A expansão foi realizada para os diretórios `/var`, `/tmp`, `/home`, além da criação de um novo volume lógico montado em `/dados`.

### Verificação de Configuração Inicial

Antes de iniciar a expansão, verifique o estado atual dos volumes lógicos (LVs), volume group (VG), e o tipo de sistema de arquivos utilizando os seguintes comandos:

1. **Verificar o volume group (`rootvg`)**:

   ```bash
   vgdisplay rootvg
   ```

2. **Verificar os volumes lógicos (`LVs`)**:

   ```bash
   lvs
   ```

3. **Verificar o tipo de sistema de arquivos montado**:

   ```bash
   df -T
   ```

### Criação de Nova Partição LVM

#### Passo 1: Adicionar um Novo Disco

- **Adicionar um novo disco físico ou virtual** à máquina, que será utilizado para expansão.

#### Passo 2: Identificar o Novo Disco

Use o comando `fdisk -l` para identificar o novo disco adicionado, por exemplo, `/dev/sdb`.

#### Passo 3: Criar uma Nova Partição LVM

Crie uma nova partição no disco identificado:

```bash
fdisk /dev/sdb
```
Dentro do `fdisk`:
- Pressione `n` para criar uma nova partição.
- Escolha `primary`.
- Aceite os valores padrão para utilizar todo o espaço do disco.
- Pressione `t` e selecione o tipo `8e` (Linux LVM).
- Pressione `w` para salvar as mudanças.

### Expansão do Volume Group (VG)

#### Passo 1: Criar um Physical Volume (PV)

```bash
pvcreate /dev/sdb1
```

#### Passo 2: Adicionar o PV ao Volume Group (`rootvg`)

```bash
vgextend rootvg /dev/sdb1
```

Após a execução, o volume group `rootvg` deve ter espaço adicional disponível.

### Expansão dos Volumes Lógicos (LVs)

Os volumes lógicos existentes foram expandidos para atender às novas necessidades de espaço.

#### Expansão do `/var` para 50 GB

1. **Expandir o volume lógico**:

   ```bash
   lvextend -L +42G /dev/mapper/rootvg-varlv
   ```

2. **Expandir o sistema de arquivos XFS**:

   ```bash
   xfs_growfs /var
   ```

#### Expansão do `/tmp` para 50 GB

1. **Expandir o volume lógico**:

   ```bash
   lvextend -L +48G /dev/mapper/rootvg-tmplv
   ```

2. **Expandir o sistema de arquivos XFS**:

   ```bash
   xfs_growfs /tmp
   ```

#### Expansão do `/home` para 50 GB

1. **Expandir o volume lógico**:

   ```bash
   lvextend -L +49G /dev/mapper/rootvg-homelv
   ```

2. **Expandir o sistema de arquivos XFS**:

   ```bash
   xfs_growfs /home
   ```

### Criação de Novo Volume Lógico e Montagem

#### Passo 1: Criar o Volume Lógico (`/dados`)

Use o espaço restante no volume group (`rootvg`):

```bash
lvcreate -l 100%FREE -n dadoslv rootvg
```

#### Passo 2: Formatar o Novo Volume Lógico com XFS

```bash
mkfs.xfs /dev/mapper/rootvg-dadoslv
```

#### Passo 3: Montar o Novo Volume Lógico em `/dados`

1. **Criar o diretório `/dados`**:

   ```bash
   mkdir /dados
   ```

2. **Adicionar o novo volume ao fstab**:

   ```bash
   echo '/dev/mapper/rootvg-dadoslv /dados xfs defaults 0 2' >> /etc/fstab
   ```

3. **Montar o volume**:

   ```bash
   mount -a
   ```

### Verificação Final

Verifique se todos os volumes foram expandidos e estão utilizando o novo espaço corretamente:

```bash
df -h
```

Este comando deve mostrar os novos tamanhos das partições `/var`, `/tmp`, `/home` e `/dados`.

---

### Conclusão

Este documento detalha o processo de expansão de volumes lógicos utilizando LVM em um ambiente Linux com sistema de arquivos XFS. Através dos passos fornecidos, é possível gerenciar de forma eficiente o espaço em disco, garantindo que as necessidades de armazenamento sejam atendidas.

Se precisar de mais detalhes ou assistência adicional, entre em contato com o administrador do sistema.
