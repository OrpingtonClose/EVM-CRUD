#https://github.com/ethereum/go-ethereum/issues/21631

NODENAME=node-two
SSHPORT=2223

vboxmanage import ~/Documents/eth-1.ova --vsys 0 --vmname $NODENAME
VBoxManage modifyvm "$NODENAME" --natpf1 "guestssh,tcp,,$SSHPORT,,22"
VBoxManage startvm $NODENAME

ssh -p $SSHPORT orpington@127.0.0.1

sudo su

mkdir data
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.24-972007a5.tar.gz
tar -xvf geth-linux-amd64-1.10.24-972007a5.tar.gz
mv geth-linux-amd64-1.10.24-972007a5/geth geth
chmod 777 geth
mv geth /usr/bin/geth

#sudo add-apt-repository -y ppa:ethereum/ethereum
#sudo apt-get install ethereum -y

#https://geth.ethereum.org/docs/fundamentals/private-network
PASS=abc
NETWORKID=12345
yes $PASS | geth account new --datadir data &> key.txt
ADDRESS=$(grep -oP '(?<=0x).*' key.txt)
echo 0x$ADDRESS
#EXTRADATA=$(echo "$(printf '0%.0s' {1..32})$ADDRESS$(printf '0%.0s' {1..65})")
EXTRADATA=0000000000000000000000000000000000000000000000000000000000000000${ADDRESS}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cat <<EOF > genesis.json
{
  "config": {
    "chainId": $NETWORKID,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "clique": {
      "period": 5,
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "extradata": "0x$EXTRADATA",
  "alloc": {
    "$ADDRESS": { "balance": "100000000000000000000" }
  }
}
EOF

geth init --datadir data genesis.json

#Setting Up Networking 
INTERFACE=$(ip route list | grep default | awk '{print $5}')
IP=$(ifconfig | grep -A 1 $INTERFACE | grep inet | awk '{print $2}')
echo $INTERFACE $IP
SYSFILE=eth-node

cat <<EOF > $SYSFILE.service #/etc/systemd/system/myexecuteable.service
[Unit]
Description=Ethereum go client
[Service]
User=root
Type=simple
WorkingDirectory=/home/orpington
ExecStart=/usr/bin/geth --datadir data --networkid $NETWORKID --ipcpath /home/orpington/data/geth.ipc
Restart=on-failure
RestartSec=5
[Install]
WantedBy=default.target
EOF

#/etc/systemd/system/gethboot.service
sudo mv $SYSFILE.service /etc/systemd/system/
sudo systemctl enable $SYSFILE
sudo systemctl start $SYSFILE
#journalctl -f -u $SYSFILE
#nmap 127.0.0.1

geth attach /home/orpington/data/geth.ipc #--exec admin.nodeInfo.enode /home/orpington/data/geth.ipc > ~/enr.txt
#geth attach --exec admin.nodeInfo.enode /home/orpington/data/geth.ipc
#admin.addPeer("enode://7d5a89459b3c7f3d5a9db53925f245f063d3240b5ce838b0fc2f461822260361d0636d132e81644076ab016cf812cb455b0172606851083b7358d7cd12ab9c71@5.161.220.126:30308")
exit





# cat <<EOF > gethnode1.service #/etc/systemd/system/myexecuteable.service
# [Unit]
# Description=Ethereum go client
# [Service]
# User=orpington
# Type=simple
# WorkingDirectory=/home/orpington
# ExecStart=/usr/bin/geth --datadir data --networkid $NETWORKID --ipcpath /home/orpington/data/geth.ipc
# Restart=on-failure
# RestartSec=5
# [Install]
# WantedBy=default.target
# EOF

# sudo mv gethnode1.service /etc/systemd/system/
# sudo systemctl enable gethnode1
# sudo systemctl start gethnode1
# journalctl -u gethnode1 -f

# exit

# scp -P 2222 orpington@127.0.0.1:/home/orpington/{genesis.json,enr.txt} .

# vboxmanage import ~/Documents/eth-1.ova --vsys 0 --vmname node1
# VBoxManage modifyvm "node1" --natpf1 "guestssh,tcp,,2223,,22"
# VBoxManage startvm node1

# scp -P 2223 {genesis.json,enr.txt} orpington@127.0.0.1:/home/orpington/

# ssh -p 2223 orpington@127.0.0.1

# mkdir data
# sudo add-apt-repository -y ppa:ethereum/ethereum
# sudo apt-get install ethereum -y


