There are important questions to ask before increasing disk space.

* What is consuming all the disk space?
* Is it possible to fix the problem at the source? For example, if an application is spewing too much noise in logs, can we trim the logs down?
* Instead of increasing the disk space, can we horizontally scale?

If answers to the above questions are not enough in solving the problem, we can proceed to increase the disk space as follows:

### Assumptions

We are not attempting to increase the root volume marked as `sda`.

### Limitations

UKCloud has a 2TB limit on its standard block devices.

### Find out if the filesystem is LVM

Run the following command to check the filesystem.

```
$ df -h
Filesystem                   Size  Used Avail Use% Mounted on
/dev/sda1                     50G  9.8G   37G  21% /
udev                         3.9G   12K  3.9G   1% /dev
tmpfs                        799M  244K  799M   1% /run
none                         5.0M     0  5.0M   0% /run/lock
none                         3.9G     0  3.9G   0% /run/shm
/dev/mapper/vg0-es           125G   37G   82G  31% /var/lib/elasticsearch
```

`/dev/mapper/` means it will be but we can double check with the following commands.

```
$ sudo lvs
  LV      VG      Attr   LSize   Origin Snap%  Move Log Copy%  Convert
  es      vg0     -wi-ao 127.00g
```

```
$ sudo pvs
  PV         VG      Fmt  Attr PSize   PFree
  /dev/sdc   vg0     lvm2 a-   128.00g 1020.00m
```

We can see the volume group (VG) `vg0` and logical volume (LV) `es` are visible on `/dev/mapper/vg0-es`. Therefore, we can conclude that the device is using [Logical Volume Management (LVM)](https://wiki.ubuntu.com/Lvm) and comprised of only the `/dev/sdc` block device.

### If the disk is not LVM

We will extend the existing block device via the Carrenza or UKCloud portal and make use of it.

1. Log into the relevant organisation and select the Virtual Data Center (VDC).
2. Click on storage policies.
3. Verify that there is enough storage to expand on the relevant storage area. You can find out what the relevant storage area for the box is by looking in [`verify-boxes`](https://github.com/alphagov/verify-boxes) GitHub repository. For example, `verify-boxes/machines/il2/IDAP_Development/staging-dmz/apps.yaml`, looking up the relevant box should have either `STORAGE-1`, `STORAGE-2`, `STORAGE-ANY` or other something similar.
4. Once verified, click on the `Vapps` tab.
5. Select the relevant `Vapp`.
6. Click on virtual machines.
7. Select the relevant virtual machine.
8. Click on the cog.
9. Click on properties.
10. In the new tab, click on hardware.
11. Find the disk that is not the root mount. The first mount will be the root volume and will have size 50GB.
12. Change the size of this disk to the required amount.
13. Force a `rescan` of the SCSI bus.

    ```
    for dev in /sys/class/scsi_device/*/device/rescan; do echo '- - -' | sudo tee $dev; done
    ```

14. Check that the block device has grown by the expected amount. If not, restart the virtual machine.

    ```
    $ sudo fdisk -l /dev/sdd
    
    Disk /dev/sdd: 2147.5 GB, 2147483648000 bytes
    255 heads, 63 sectors/track, 261083 cylinders, total 4194304000 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0x00000000
    
    Disk /dev/sdd doesn't contain a valid partition table
    ```

15. Run the following command to resize the partition.

    ```
    $ resize2fs /dev/sdd1
    ```

### If the disk is LVM

There are two ways to extend LVM.

1. Extend an existing volume in the volume group.
2. Add a new volume to the volume group.

#### Extending an existing volume in the volume group

1. Log into the relevant organisation and select the VDC.
2. Click on storage policies.
3. Verify that there is enough storage to expand on the relevant storage area. You can find out what the relevant storage area for the box is by looking in [`verify-boxes`](https://github.com/alphagov/verify-boxes) GitHub repository. For example, `verify-boxes/machines/il2/IDAP_Development/staging-dmz/apps.yaml`, looking up the relevant box should have `STORAGE-1`, `STORAGE-2`, `STORAGE-ANY` or other something similar.
4. Once verified, click the `Vapps` tab.
5. Select the relevant `Vapp`.
6. Click on virtual machines.
7. Select the relevant virtual machine.
8. Click on the cog.
9. Click on properties.
10. In the new tab, click on hardware.
11. Find the disk that is not the root mount. The first mount will be the root volume and will have size 50GB.
12. Change the size of this disk to the required amount.
13. Force a `rescan` of the SCSI bus.

    ```
    for dev in /sys/class/scsi_device/*/device/rescan; do echo '- - -' | sudo tee $dev; done
    ```

14. Check that the block device has grown by the expected amount. If not, restart the virtual machine.

    ```
    $ sudo dmesg | tail -n 20
    ...
    [28523.960000] sd 2:0:0:0: [sda] Cache data unavailable
    [28523.960013] sd 2:0:0:0: [sda] Assuming drive cache: write through
    [28523.965375] sd 2:0:1:0: [sdb] Cache data unavailable
    [28523.965378] sd 2:0:1:0: [sdb] Assuming drive cache: write through
    [28523.970244] sd 2:0:2:0: [sdc] Cache data unavailable
    [28523.970247] sd 2:0:2:0: [sdc] Assuming drive cache: write through
    [28523.975696] sd 2:0:3:0: [sdd] 377487360 512-byte logical blocks: (193 GB/180 GiB)
    [28523.975728] sd 2:0:3:0: [sdd] Cache data unavailable
    [28523.975729] sd 2:0:3:0: [sdd] Assuming drive cache: write through
    [28523.975813] sdd: detected capacity change from 75161927680 to 193273528320
    ...
    
    $ sudo fdisk -l /dev/sdd
    
    Disk /dev/sdd: 193.3 GB, 193273528320 bytes
    255 heads, 63 sectors/track, 23497 cylinders, total 377487360 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0x00000000
    
    Disk /dev/sdd doesn't contain a valid partition table
    
    ```

15. Check the current physical volumes' report and let LVM know about the new space on the existing physical volume.

    ```
    $ sudo pvs
     PV         VG   Fmt  Attr PSize   PFree
     /dev/sdd   vg0  lvm2 a--  70.00g  110.00g   
    
    $ sudo pvresize /dev/sdd
     Physical volume "/dev/sdd" changed
     1 physical volume(s) resized / 0 physical volume(s) not resized
    ```

16. Resize the logical volume.

    ```
    $ sudo lvextend -l +100%FREE /dev/mapper/vg0-elasticsearch
    ```

17. Resize the filesystem.

    ```
    $ sudo resize2fs /dev/mapper/vg0-elasticsearch
    ```

18. Verify that the filesystem has the correct size.

    ```
    $ df -h
    Filesystem                     Size  Used Avail Use% Mounted on
    /dev/mapper/vg0-elasticsearch  180G  871K  180G   0% /var/lib/elasticsearch
    ```

#### Adding a new volume to the Volume Group

1. Log into the relevant organisation and select the VDC.
2. Click on storage polices.
3. Verify that there is enough space to expand on the relevant storage area. You can find out what the relevant storage area for the box is by looking in [`verify-boxes`](https://github.com/alphagov/verify-boxes) GitHub repository. For example, `verify-boxes/machines/il2/IDAP_Development/staging-dmz/apps.yaml`, looking up the relevant box should have `STORAGE-1`, `STORAGE-2`, `STORAGE-ANY` or other something similar.
4. Once verified, click on the `Vapps` tab.
5. Select the relevant `Vapp`.
6. Click on virtual machines.
7. Select the relevant virtual machine.
8. Click on the cog.
9. Click on properties.
10. In the new tab, click on hardware.
11. Add an extra disk.

    | IMPORTANT: Make sure you add a paravirtual SCSI. Other disks can prevent the virtual machine from booting up. |
    | --- |

12. Select a relevant size for the volume.
13. Check the current size of volume before expanding it.

    ```
    $ df -h
    Filesystem          Size  Used  Avail Use% Mounted on
    /dev/mapper/vg0-es   50G  970K    50G   1% /var/lib/elasticsearch
    ```

14. Find the new disk. It will be `sd[latest character in alphabet]`. For example,

    ```
    $ sudo dmesg | tail -n 30
    ...
    [ 9001.698682] vmw_pvscsi: msg type: 0x0 - MSG RING: 1/0 (5)
    [ 9001.698686] vmw_pvscsi: msg: device added at scsi0:3:0
    [ 9001.702715] scsi 2:0:3:0: Direct-Access     VMware   Virtual disk     1.0  PQ: 0 ANSI: 2
    [ 9001.702926] sd 2:0:3:0: [sdd] 4194304000 512-byte logical blocks: (2.14 TB/1.95 TiB)
    [ 9001.702955] sd 2:0:3:0: [sdd] Write Protect is off
    [ 9001.702957] sd 2:0:3:0: [sdd] Mode Sense: 61 00 00 00
    [ 9001.702983] sd 2:0:3:0: [sdd] Cache data unavailable
    [ 9001.702984] sd 2:0:3:0: [sdd] Assuming drive cache: write through
    [ 9001.705575] sd 2:0:3:0: [sdd] Cache data unavailable
    [ 9001.705578] sd 2:0:3:0: [sdd] Assuming drive cache: write through
    [ 9001.705668] sd 2:0:3:0: Attached scsi generic sg4 type 0
    [ 9001.706151]  sdd: unknown partition table
    [ 9001.706272] sd 2:0:3:0: [sdd] Cache data unavailable
    [ 9001.706274] sd 2:0:3:0: [sdd] Assuming drive cache: write through
    [ 9001.706314] sd 2:0:3:0: [sdd] Attached SCSI disk
    ...
    
    $ sudo fdisk -l /dev/sdd
    Disk /dev/sdd: 2147.5 GB, 2147483648000 bytes
    255 heads, 63 sectors/track, 261083 cylinders, total 4194304000 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0x00000000
    
    Disk /dev/sdd doesn't contain a valid partition table
    ```

15. Create the physical volume.

    ```
    $ sudo pvcreate /dev/sdd
    ```

16. Add the new physical volume to the volume group.

    ```
    $ sudo vgextend vg0 /dev/sdd
    Volume group "vg0" successfully extended
    ```

17. Resize the logical volume.

    ```
    $ sudo lvextend -l +100%FREE /dev/mapper/vg0-es
    ```

18. Resize the filesystem.

    ```
    $ sudo resize2fs /dev/mapper/vg0-es
    ```

19. Verify that the filesystem has the correct size.

    ```
    $ df -h
    Filesystem              Size  Used  Avail Use% Mounted on
    /dev/mapper/vg0-es     2050G  970K  2050G   0% /var/lib/elasticsearch
    ```
