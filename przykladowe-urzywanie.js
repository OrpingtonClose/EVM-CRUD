const ethers = require('ethers');
const web3 = require("web3")
const provider = ethers.getDefaultProvider("http://127.0.0.1:7545")

const privateKey = '0xa49063bad559a3aeac897d1148c583f5c929440e27d47ce6cf9f15dc413b8012'; // Replace with your actual private key
const wallet = new ethers.Wallet(privateKey, provider);

const contractABI = [ // Replace with your actual contract ABI
    'function newWidget(bytes32 key, string memory name, bool delux, uint price) public',
    // Add other function definitions here
];
const contractAddress = '0x61B22EE3Ea2249Cfb6eaEa7318bCD7B1C517d84f'; // Replace with your actual contract address

const contract = new ethers.Contract(contractAddress, contractABI, provider);

// This is an example of how to call newWidget function
const callNewWidget = async (n, d, p) => {
    const contractWithSigner = contract.connect(wallet);
    const key = web3.utils.padLeft(web3.utils.asciiToHex(n), 64) // Replace 'widgetKey' with your actual key
    const name = n; // Replace with your actual widget name
    const delux = d; // Replace with your actual delux value
    const price = ethers.parseEther(p); // Replace '1.0' with your actual price

    try {
        const tx = await contractWithSigner.newWidget(key, name, delux, price);
        console.log('Transaction hash:', tx.hash);
        const receipt = await tx.wait();
        console.log('Transaction was mined in block:', receipt.blockNumber);
    } catch (err) {
        console.log('An error occurred:', err);
    }
};
const main = async () => {
    await callNewWidget("one", true, "123");
    await callNewWidget("two", false, "345");
    await callNewWidget("three", true, "0.23");
    await callNewWidget("four", true, "0.000034");
    await callNewWidget("five", false, "12345");
}

const main1 = async () => {
    for (var n=0; n!== 100; n++ ) {
        await callNewWidget("one" + n, n % 2 === 1, "1" + n);
    }
}

main1();


