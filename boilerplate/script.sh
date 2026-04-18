sudo ./engine start t6c1 ../rootfs-alpha "/bin/sh -c 'sleep 30'"
sudo ./engine start t6c2 ../rootfs-beta "/bin/sh -c 'sleep 25'"
sudo ./engine start t6c3 ../rootfs-gamma "/bin/sh -c 'sleep 20'"

sudo ./engine ps

ps aux | grep engine