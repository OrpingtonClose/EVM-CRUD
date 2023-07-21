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

geth --datadir data --networkid $NETWORKID --nat extip:$IP
