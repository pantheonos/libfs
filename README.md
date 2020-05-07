# Pantheon libfs

Filesystem library for pantheon that features different filesystem formats, device mounting, chrooting, and such.

## Table of contents
- [Pantheon libfs](#pantheon-libfs)
  - [Table of contents](#table-of-contents)
  - [Terminology](#terminology)
  - [Authority](#authority)
    - [Auth elevation](#auth-elevation)
  - [Structure](#structure)
    - [True root](#true-root)
    - [Devices](#devices)
      - [Interface](#interface)
    - [Partitions](#partitions)
      - [Interface](#interface-1)
  - [Translators](#translators)
  - [Library](#library)
    - [libfs.init](#libfsinit)

## Terminology

- **Realspace** → Files and folders outside of the scope of libfs.
- **Virtualspace** → Nodes that are managed by libfs.
- **Translator** → Translates libfs calls to a device or filesystem.

## Authority

Since libfs is made to be detached from the actual user system in Pantheon, there is no builtin authority system for blocking libfs calls. The kernel will automatically lock down use of libfs in the userspace, and instead, only the translator interface for its current filesystem will be provided.

### Auth elevation

Through the OS' user system, some users will have access to either the full libfs interface, or to other permissions such as mounting or containerizing.

## Structure

This is the structure of a system managed by libfs.

### True root

The **true root**, or 0th layer, is usually located at the `/dev` folder of the device. All other devices and filesystems will be mounted under this folder. This folder must exist in the realspace.

### Devices

Devices, the 1st layer, located at `/dev/dx` (where `x` is a lowercase letter A through Z), don't actually need to exist in the virtualspace, but translators may choose to store files in the realspace for persistence.

#### Interface

> Nodes marked as (elevated) needs elevated privileges to be accessed,

- `/dev/dx/info`: reading from this file should always return a serialized Lua table (to be decoded with `serpent` or `libfs.info`). This file cannot be written to.
- `/dev/dx/parts`: reading from this file should return a serialized Lua table containing the partitions of the device. It can be written to, but it will affect the filesystems within.
- `/dev/dx/real/` (elevated): reading and writing to this folder will write into the realspace.

### Partitions

The 2nd layer of the structure. This is only required for devices which are formatted with an in-disk filesystem (An in-memory filesystem does not need it). Each partition must be read with a translator as defined in `/dev/dx/parts`. Each partition is just a numbered folder under the device, in the form `/dev/dx/n/`, where `x` is the device letter and `n` the partition number.

#### Interface

> Nodes marked as (elevated) needs elevated privileges to be accessed,

- `/dev/dx/n/real/` (elevated): reading and writing to this folder will write into the realspace.

## Translators

Translators are special libraries that libfs loads to interact with different devices and filesystem. While the most common example is a translator that just writes files to the realspace, it allows for applications such as storing files in the cloud, FTP, mail protocols, in-memory storage, etc. 

## Library

There is a distinction between the library and the API. The library sets up a libfs system, and the API interacts with it via a privileged daemon (`fsd`) which must be spawned by the kernel.

### libfs.init

`libfs.init (dir : string)`