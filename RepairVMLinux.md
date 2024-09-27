## **Como Montar Partições LVM Usando uma VM de Reparo**

### **Objetivo**
Este roteiro descreve o processo de montar uma partição raiz LVM de um disco de outra VM, usando uma VM de reparo para acessar e corrigir o sistema de arquivos, como o arquivo `/etc/fstab`.

### **Pré-requisitos**
- Acesso à VM de reparo.
- Disco problemático anexado à VM de reparo como um disco de dados.
- Conhecimento básico de LVM e comandos de terminal.

---

### **Passo a Passo**

#### **1. Anexar o Disco à VM de Reparos**
1. **Desligue** a VM original.
2. No portal de gerenciamento (Azure, GCP, AWS, etc.), **anexe o disco problemático** como um disco de dados à VM de reparo.
3. **Inicie** a VM de reparo.

#### **2. Verificar os Discos e Partições**
1. Liste os discos conectados para identificar o novo disco e suas partições:
   
   ```bash
   lsblk
   ```

   Exemplo de saída:

   ```bash
   NAME              MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
   sda                 8:0    0   30G  0 disk 
   └─sda1              8:1    0   30G  0 part /
   sdb                 8:16   0  512G  0 disk
   └─sdb4              8:36   0 63.3G  0 part
     ├─rootvg-tmplv  252:0    0    2G  0 lvm  
     ├─rootvg-usrlv  252:1    0   10G  0 lvm  
     ├─rootvg-homelv 252:2    0    1G  0 lvm  
     ├─rootvg-varlv  252:3    0    8G  0 lvm  
     └─rootvg-rootlv 252:4    0    2G  0 lvm  
   ```

2. Verifique se o disco anexado é reconhecido (por exemplo, `/dev/sdb4`).

#### **3. Ativar o Volume Group**
1. Ative o Volume Group do disco LVM com o seguinte comando:

   ```bash
   vgchange -ay <nome_do_volume_group>
   ```

   Exemplo:

   ```bash
   vgchange -ay rootvg
   ```

   Isso ativa os volumes lógicos associados ao Volume Group.

#### **4. Montar o Volume Lógico da Partição Raiz**
1. Crie um ponto de montagem temporário:

   ```bash
   mkdir /mnt/reparo
   ```

2. Monte o volume lógico da partição raiz:

   ```bash
   mount /dev/<volume_group_name>/<logical_volume_name> /mnt/reparo
   ```

   Exemplo:

   ```bash
   mount /dev/rootvg/rootlv /mnt/reparo
   ```

#### **5. Acessar e Corrigir o Sistema de Arquivos**
1. Navegue até o ponto de montagem e faça as correções necessárias, como editar o arquivo `/etc/fstab`:

   ```bash
   nano /mnt/reparo/etc/fstab
   ```

   **Verifique o conteúdo do arquivo e corrija entradas erradas de UUID, pontos de montagem ou tipos de sistema de arquivos.**

#### **6. Desmontar o Volume**
1. Após realizar as correções, desmonte o volume:

   ```bash
   umount /mnt/reparo
   ```

2. Se você precisar reanexar o disco à VM original, faça isso através do portal de gerenciamento (Azure, GCP, AWS, etc.).

#### **7. Reiniciar a VM Original**
1. **Desligue** a VM de reparo e **reative** o disco na VM original.
2. **Reinicie** a VM original e verifique se o sistema operacional inicializa corretamente.

---

### **Comandos Essenciais**
- Listar discos e partições: `lsblk`
- Ativar Volume Group: `vgchange -ay <volume_group_name>`
- Montar Volume Lógico: `mount /dev/<volume_group_name>/<logical_volume_name> /mnt/<mount_point>`
- Desmontar Volume: `umount /mnt/<mount_point>`

---

### **Considerações Finais**
- Certifique-se de sempre fazer um backup do arquivo `/etc/fstab` antes de fazer modificações.
- Se estiver lidando com volumes LVM, verifique se o Volume Group foi ativado corretamente para evitar problemas de montagem.

--- 
