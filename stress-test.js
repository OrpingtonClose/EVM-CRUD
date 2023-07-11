//eth.sendTransaction({
//    to: '0xB83B6241f966B1685C8B2fFce3956E21F35B4DcB',
//    from: eth.accounts[0],
//    value: web3.toWei(10**10)
//  });

//geth --http --http.corsdomain="https://remix.ethereum.org" --http.api web3,eth,debug,personal,net --vmdebug --datadir d --dev console

var { Web3 } = require("web3");

var web3 = new Web3('http://localhost:8545')
var account = web3.eth.accounts.privateKeyToAccount("0x000000000000000000000000000000000000000000000000000000000000002e")
web3.eth.accounts.wallet.add(account.privateKey)

var abi = [{"inputs": [],"name": "get_output","outputs": [{"internalType": "string","name": "","type": "string"}],"stateMutability": "pure","type": "function"}]
var bytecode = "608060405234801561001057600080fd5b50610126806100206000396000f3fe6080604052348015600f57600080fd5b506004361060285760003560e01c806354f8a2f214602d575b600080fd5b603360ab565b6040518080602001828103825283818151815260200191508051906020019080838360005b8381101560715780820151818401526020810190506058565b50505050905090810190601f168015609d5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b60606040518060600160405280602581526020016100cc6025913990509056fe48696969692c20796f757220636f6e74726163742072616e207375636365737366756c6c79a2646970667358221220cfd5c53b342ee7c89881a12e69e4930b23975052ac1bf3b3c988d3f8f3451a5864736f6c63430006010033"

var helloWorldContract = new web3.eth.Contract(abi);
var helloWorldDeployTx = helloWorldContract.deploy({data: bytecode});
helloWorldDeployTx.estimateGas().then(function(gas){console.log("Estimated gas for deployment: " + gas);});

var i = 0;
setInterval(() => {
    helloWorldDeployTx.send({from: account.address, gas: 116971}).on('error', function(error){
        console.log("Error: " + error);
    }).on('transactionHash', function(transactionHash){
        console.log("Deployment txn: " + transactionHash)
    }).on('receipt', function(receipt){
       console.log("New contract address: " + receipt.contractAddress)
    }).finally(function(){
        console.log(i++);
    });
    
}, 100)


