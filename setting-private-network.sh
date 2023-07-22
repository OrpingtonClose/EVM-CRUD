vboxmanage import ~/Documents/eth-1.ova --vsys 0 --vmname bootnode
VBoxManage startvm bootnode
VBoxManage modifyvm "bootnode" --natpf1 "guestssh,tcp,,2222,,22"
yes | ssh -p 2222 orpington@127.0.0.1

mkdir data
sudo add-apt-repository -y ppa:ethereum/ethereumY
sudo apt-get install ethereum -y

#https://geth.ethereum.org/docs/fundamentals/private-network
PASS=abc
NETWORKID=12345
yes $PASS | geth account new --datadir data &> key.txt
ADDRESS=$(grep -oP '(?<=0x).*' key.txt)
echo 0x$ADDRESS
EXTRADATA=$(echo "$(printf '0%.0s' {1..32})$ADDRESS$(printf '0%.0s' {1..65})")
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

cat <<EOF > gethboot.service #/etc/systemd/system/myexecuteable.service
[Unit]
Description=Ethereum go client - boot node
[Service]
User=orpington
Type=simple
WorkingDirectory=/home/orpington
ExecStart=/usr/bin/geth --datadir data --networkid $NETWORKID --nat extip:$IP --ipcpath /home/orpington/data/geth.ipc
Restart=on-failure
RestartSec=5
[Install]
WantedBy=default.target
EOF

#/etc/systemd/system/gethboot.service
sudo mv gethboot.service /etc/systemd/system/
sudo systemctl enable gethboot
sudo systemctl start gethboot
#journalctl -f -u gethboot
#nmap 127.0.0.1

geth attach --exec admin.nodeInfo.enr /home/orpington/data/geth.ipc > ~/enr.txt

cat <<EOF > gethnode1.service #/etc/systemd/system/myexecuteable.service
[Unit]
Description=Ethereum go client
[Service]
User=orpington
Type=simple
WorkingDirectory=/home/orpington
ExecStart=/usr/bin/geth --datadir data2 --networkid $NETWORKID --port 30305 --bootnodes $(geth attach --exec admin.nodeInfo.enr /home/orpington/data/geth.ipc) --ipcpath /home/orpington/data2/geth.ipc
Restart=on-failure
RestartSec=5
[Install]
WantedBy=default.target
EOF

sudo mv gethnode1.service /etc/systemd/system/
sudo systemctl enable gethnode1
sudo systemctl start gethnode1
journalctl -u gethnode1

exit

scp -P 2222 orpington@127.0.0.1:/home/orpington/{genesis.json,enr.txt} .

vboxmanage import ~/Documents/eth-1.ova --vsys 0 --vmname node1
VBoxManage modifyvm "node1" --natpf1 "guestssh,tcp,,2223,,22"
VBoxManage startvm node1

scp -P 2223 {genesis.json,enr.txt} orpington@127.0.0.1:/home/orpington/

ssh -p 2223 orpington@127.0.0.1

mkdir data
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get install ethereum -y


