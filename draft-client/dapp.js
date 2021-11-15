console.log("hello dapp developers!");

// contract address on Rinkeby:
const ssAddress = "0x434d499d748C8d4b78A7cb27ddf34Da080315d6c"

// add contract ABI from Remix:
const ssABI = [
	{
		"inputs": [],
		"name": "retrieve",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "num",
				"type": "uint256"
			}
		],
		"name": "store",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]

// detect metamask is/is not installed
window.addEventListener('load', function() {
  if (typeof window.ethereum !== 'undefined') {
    console.log("MetaMask Detected!");
    let mmDetected = document.getElementById("mm-detected");
    mmDetected.innerHTML = "MetaMask has been detected!";
  }

  else {
    console.log("MetaMask Not Available!");
    this.alert("You need to install MetaMask!");
  }
})

const mmEnable = document.getElementById("mm-connect");

mmEnable.onclick = async() => {
  console.log("beep!");
  await ethereum.request({ method:'eth_requestAccounts'});

  const mmCurrentAccount = document.getElementById("mm-current-account");
mmCurrentAccount.innerHTML = "Your current address is: " + ethereum.selectedAddress;
}

const ssSubmit = document.getElementById("ss-input-button");

ssSubmit.onclick = async() => {
    const ssInputValue = document.getElementById("ss-input-box").value;
    console.log(ssInputValue);

    var web3 = new Web3(window.ethereum);

    const simpleStorage = new web3.eth.Contract(ssABI, ssAddress);
    simpleStorage.setProvider(window.ethereum);

    await simpleStorage.methods.store(ssInputValue).send({from: ethereum.selectedAddress});
}