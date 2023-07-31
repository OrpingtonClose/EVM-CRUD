#https://coinsbench.com/create-a-private-ethereum-blockchain-network-829be72658a5

NODENAME=node-`cat /usr/share/dict/words | shuf | grep -v "'" | head -n1`
echo $NODENAME
SSHPORT=2225

vboxmanage import ~/Documents/eth-1.ova --vsys 0 --vmname $NODENAME
VBoxManage modifyvm "$NODENAME" --natpf1 "guestsshh,tcp,,$SSHPORT,,22"
VBoxManage startvm $NODENAME --type headless

ssh -p $SSHPORT orpington@127.0.0.1

sudo su

mkdir data
#wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.24-972007a5.tar.gz
wget https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-1.10.24-972007a5.tar.gz
tar -xvf geth-alltools-linux-amd64-1.10.24-972007a5.tar.gz
mv geth-alltools-linux-amd64-1.10.24-972007a5/geth geth
chmod 777 geth
mv geth /usr/bin/geth

mkdir node1
#mkdir node2
#mkdir node3
# Node1
echo "efg" > node1/password.txt
geth --datadir node1 account new --password node1/password.txt &> node1/key.txt
ADDRESS=$(grep -oP '(?<=0x).*' node1/key.txt)
echo 0x$ADDRESS
# CREATES AN ACCOUNT INSIDE node1
#0x68Eb359f50CdBC5D930eCA48b45FcACa4C4e5f4E

# Node2
# echo "efg" > node2/password.txt
# geth --datadir node2 account new --password node2/password.txt  &> node2/key.txt
# ADDRESS=$(grep -oP '(?<=0x).*' key.txt)
# echo 0x$ADDRESS
# CREATES AN ACCOUNT INSIDE node1
#0x9ef071aA9c3DCa7127aDE83D4BBC2f205A06EE14

# Node3
# echo "xyz" > node3/password.txt
# geth --datadir node3 account new --password node3/password.txt &> node3/key.txt
# ADDRESS=$(grep -oP '(?<=0x).*' key.txt)
# echo 0x$ADDRESS
# CREATES AN ACCOUNT INSIDE node1
#0x503b83a1A56765008934e8F2081cdF1193b5793a
cat <<EOF > genesis.json
{
  "config": {
    "chainId": 50912,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "clique": {
      "period": 15,
      "epoch": 30000
    }
  },
  "nonce": "0x0",
  "timestamp": "0x64c52e3a",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000${ADDRESS,,}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0x47b760",
  "difficulty": "0x1",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {
    "$ADDRESS": {
      "balance": "0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"      
    }
  },
  "number": "0x0",
  "gasUsed": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "baseFeePerGas": null
}
EOF
cp genesis.json node1
# cp genesis.json node2
# cp genesis.json node3

geth --datadir node1/ init node1/genesis.json
# geth --datadir node2/ init node2/genesis.json
# geth --datadir node3/ init node3/genesis.json

#geth --datadir "node1" --port "30311" --http --http.addr "127.0.0.1" --http.port "8501" --http.api "personal,eth,net,web3,txpool,miner" --networkid 50912 --miner.gasprice "0" --allow-insecure-unlock --unlock "0xDD05bcAeB1d99f831fc57C9afe52445C67a2b7E7" --password node1/password.txt --mine
#enode://9a785098dcecc6a25085d7aded9ff4d92220c8bc92abb7e36d0bfbe861abe94199867d1ac490d5d4a6014084fcd35777462c338c744330609a0baf8d8ac8133f@127.0.0.1:30311
SYSFILE=gethprvnode
cat <<EOF > $SYSFILE.service #/etc/systemd/system/myexecuteable.service
[Unit]
Description=Ethereum go client
[Service]
User=root
Type=simple
WorkingDirectory=/home/orpington
ExecStart=/usr/bin/geth --datadir node1 --port "30311" --http --http.addr "127.0.0.1" --http.port "8501" --http.api "personal,eth,net,web3,txpool,miner" --networkid 50912 --miner.gasprice "0" --allow-insecure-unlock --unlock "0x$ADDRESS" --password node1/password.txt --mine
Restart=on-failure
RestartSec=5
[Install]
WantedBy=default.target
EOF

#/etc/systemd/system/gethboot.service
sudo mv $SYSFILE.service /etc/systemd/system/
sudo systemctl enable $SYSFILE
sudo systemctl start $SYSFILE

#geth --datadir node1 --port "30311" --http --http.addr "127.0.0.1" --http.port "8501" --http.api "personal,eth,net,web3,txpool,miner" --networkid 50912 --miner.gasprice "0" --allow-insecure-unlock --unlock "0x$ADDRESS" --password node1/password.txt --mine
#doesnt work
#geth --datadir "node3" --port "30313" --http --http.addr "127.0.0.1" --http.port "8503" --http.api "personal,eth,net,web3,txpool,miner" --networkid 50912 --miner.gasprice "0" --allow-insecure-unlock --unlock "0x503b83a1A56765008934e8F2081cdF1193b5793a" --password node1/password.txt --mine
#
geth attach --exec "eth.sendTransaction({to: '0xdd05bcaeb1d99f831fc57c9afe52445c67a2b7e7',from: '$(echo "0x$ADDRESS")',value: 1})" node1/geth.ipc
geth attach --exec 'eth.getBlock("latest")' node1/geth.ipc
geth attach --exec "eth.getBalance('0x$ADDRESS')" node1/geth.ipc
geth attach --exec "eth.getBalance('0xdd05bcaeb1d99f831fc57c9afe52445c67a2b7e7')" node1/geth.ipc
#err="signed recently, must wait for others"
#eth.sendTransaction({to: '0x9ef071aa9c3dca7127ade83d4bbc2f205a06ee14',from: '0xDD05bcAeB1d99f831fc57C9afe52445C67a2b7E7',value: 10});
