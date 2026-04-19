# OS Jackfruit: Supervised Multi-Container Runtime

Lightweight container runtime in C with a long-running supervisor and a kernel memory monitor.

## 1. Team Information

1. PES2UG24CS124 - C K Gagan Gowda
2. PES2UG24CS116 - Bhuvan M S

## 2. Build, Load, and Run Instructions

```bash
# Prerequisites
sudo apt update
sudo apt install -y build-essential linux-headers-$(uname -r) wget

# From repo root
mkdir -p rootfs-base
wget https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-3.20.3-x86_64.tar.gz
tar -xzf alpine-minirootfs-3.20.3-x86_64.tar.gz -C rootfs-base
cp -a ./rootfs-base ./rootfs-alpha
cp -a ./rootfs-base ./rootfs-beta

# Build
cd boilerplate
make

# Load monitor
sudo insmod monitor.ko
ls -l /dev/container_monitor

# Start supervisor (terminal 1)
sudo ./engine supervisor ../rootfs-base

# Start containers (terminal 2)
sudo ./engine start alpha ../rootfs-alpha "/cpu_hog 100"
sudo ./engine start beta  ../rootfs-beta  "/cpu_hog 100"
sudo ./engine ps

# Logs and stop
sudo ./engine logs alpha
sudo ./engine stop alpha
sudo ./engine stop beta

# Cleanup
sudo rmmod monitor
make clean
```

## 3. Demo with Screenshots

### 3.1 Multi-container supervision
Command: `sudo ./engine start alpha ...` and `sudo ./engine start beta ...`

![Multi-container supervision](1.jpeg)

### 3.2 Metadata tracking (`ps`)
Command: `sudo ./engine ps`

![Container metadata](2.jpeg)

### 3.3 Bounded-buffer logging
Command: `sudo ./engine start gamma ...` then `sudo ./engine logs gamma`

![Bounded-buffer logging output](3.jpeg)

### 3.4 CLI and IPC
Command: `sudo ./engine start alpha2 ../rootfs-alpha "..."`

![CLI to supervisor IPC](4.jpeg)

### 3.5 Soft-limit warning
Command: `sudo ./engine start alpha ../rootfs-alpha "/memory_hog 4 500" --soft-mib 8 --hard-mib 100` and `dmesg | tail -20`

![Soft-limit warning](5.jpeg)

### 3.6 Scheduling experiment
Command: `./experiment.sh`

![Scheduling experiment](6.jpeg)

### 3.7 Clean teardown
Command: `sudo rmmod monitor` and `ls -l /dev/container_monitor`

![Clean teardown](7.jpeg)

## 4. Engineering Analysis

- Isolation: Containers use PID/UTS/mount namespaces plus `chroot`, with `/proc` mounted inside each container.
- Lifecycle: A long-running supervisor handles start/stop/ps/logs, reaps children, and tracks state.
- IPC and sync: UNIX domain socket for control path and pipes for log path; mutex + condition variables for bounded-buffer logging.
- Memory enforcement: Kernel module checks RSS periodically; soft limit logs warning, hard limit kills process.
- Scheduling: Nice values influence completion behavior in concurrent CPU-bound runs.

## 5. Design Decisions and Tradeoffs

| Subsystem | Choice | Tradeoff |
|---|---|---|
| Isolation | `clone` namespaces + `chroot` | Simpler than `pivot_root`, but less strict |
| Supervisor | Single daemon for all containers | Central point of failure |
| Control IPC | UNIX domain socket | Requires supervisor availability |
| Logging | Pipe producers + bounded buffer + consumer | Back-pressure possible when full |
| Monitor | Kernel timer + linked list of PIDs | Periodic checks can miss tiny spikes |

## 6. Scheduler Experiment Results

Extracted from screenshot 6 (`./experiment.sh`):

| Run | nice=0 duration | nice=10 duration |
|---|---|---|
| 1 | 10s | 11s |
| 2 | 12s | 12s |
| 3 | 14s | 15s |

Computed summary:

- Average (nice=0): 12.00s
- Average (nice=10): 12.67s
- Relative slowdown of nice=10: 5.6%
- Observation: nice=10 is generally slower in this workload.