ps aux | grep defunct
ps aux | grep engine
lsmod | grep monitor

echo "cleanup procedure"
sudo ps -ef | grep defunct
