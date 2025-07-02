Segue abaixo a **tradução completa para inglês (en-us)** da sua documentação técnica, mantendo o tom formal e técnico:

---

## Documentation: Logical Volume (LVM) and XFS Filesystem Expansion

### Summary

1. [Introduction](#introduction)
2. [Initial Configuration Check](#initial-configuration-check)
3. [Creating a New LVM Partition](#creating-a-new-lvm-partition)
4. [Expanding the Volume Group (VG)](#expanding-the-volume-group-vg)
5. [Expanding Logical Volumes (LVs)](#expanding-logical-volumes-lvs)
6. [Creating a New Logical Volume and Mounting](#creating-a-new-logical-volume-and-mounting)
7. [Final Verification](#final-verification)

---

### Introduction

This document provides a detailed step-by-step guide for creating a new LVM partition, expanding the `rootvg` volume group, and increasing the size of existing logical volumes that use the XFS filesystem. The expansion was performed for the `/var`, `/tmp`, and `/home` directories, as well as the creation of a new logical volume mounted at `/dados`.

### Initial Configuration Check

Before starting the expansion process, check the current status of the logical volumes (LVs), volume group (VG), and filesystem type using the following commands:

1. **Check the volume group (`rootvg`):**

   ```bash
   vgdisplay rootvg
   ```

2. **Check the logical volumes (LVs):**

   ```bash
   lvs
   ```

3. **Check the mounted filesystem types:**

   ```bash
   df -T
   ```

### Creating a New LVM Partition

#### Step 1: Add a New Disk

* **Add a new physical or virtual disk** to the machine that will be used for expansion.

#### Step 2: Identify the New Disk

Use the following command to identify the new disk, for example `/dev/sdb`:

```bash
fdisk -l
```

#### Step 3: Create a New LVM Partition

Create a new partition on the identified disk:

```bash
fdisk /dev/sdb
```

Inside `fdisk`:

* Press `n` to create a new partition.
* Choose `primary`.
* Accept the default values to use the entire disk space.
* Press `t` and set the type to `8e` (Linux LVM).
* Press `w` to write the changes.

### Expanding the Volume Group (VG)

#### Step 1: Create a Physical Volume (PV)

```bash
pvcreate /dev/sdb1
```

#### Step 2: Add the PV to the Volume Group (`rootvg`)

```bash
vgextend rootvg /dev/sdb1
```

After running the above command, the `rootvg` volume group will have additional free space.

### Expanding Logical Volumes (LVs)

The existing logical volumes were expanded to meet the new storage requirements.

#### Expand `/var` to 50 GB

1. **Extend the logical volume:**

   ```bash
   lvextend -L +42G /dev/mapper/rootvg-varlv
   ```

2. **Extend the XFS filesystem:**

   ```bash
   xfs_growfs /var
   ```

#### Expand `/tmp` to 50 GB

1. **Extend the logical volume:**

   ```bash
   lvextend -L +48G /dev/mapper/rootvg-tmplv
   ```

2. **Extend the XFS filesystem:**

   ```bash
   xfs_growfs /tmp
   ```

#### Expand `/home` to 50 GB

1. **Extend the logical volume:**

   ```bash
   lvextend -L +49G /dev/mapper/rootvg-homelv
   ```

2. **Extend the XFS filesystem:**

   ```bash
   xfs_growfs /home
   ```

### Creating a New Logical Volume and Mounting

#### Step 1: Create the Logical Volume for `/dados`

Use the remaining free space in the `rootvg`:

```bash
lvcreate -l 100%FREE -n dadoslv rootvg
```

#### Step 2: Format the New Logical Volume with XFS

```bash
mkfs.xfs /dev/mapper/rootvg-dadoslv
```

#### Step 3: Mount the New Logical Volume at `/dados`

1. **Create the `/dados` directory:**

   ```bash
   mkdir /dados
   ```

2. **Add the new volume to `/etc/fstab`:**

   ```bash
   echo '/dev/mapper/rootvg-dadoslv /dados xfs defaults 0 2' >> /etc/fstab
   ```

3. **Mount all filesystems:**

   ```bash
   mount -a
   ```

### Final Verification

Verify that all volumes have been expanded and are using the new space correctly:

```bash
df -h
```

This command should display the new sizes for the `/var`, `/tmp`, `/home`, and `/dados` partitions.

---

### Conclusion

This document details the process of expanding logical volumes using LVM in a Linux environment with XFS filesystem. By following the provided steps, you can efficiently manage disk space to meet storage requirements.

If you need further details or additional assistance, please contact the system administrator.

---

Se quiser, posso gerar o arquivo formatado (Markdown, PDF, etc.)! Quer? 🚀
