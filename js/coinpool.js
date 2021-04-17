/*coinpool.js

The aim of this file to to create a set of funcions the interact
with the main GUI

For now we have the following GUI files:

index.html
createpool.html
pool.html
market.html
vault.html
viewpool.html 

*/

/*
This code needs to be inserted as the first script into every HTML page in the <HEADER> tag:

<script language="javascript" type="text/javascript" src="https://unpkg.com/@metamask/legacy-web3@latest/dist/metamask.web3.min.js"></script>

then add:

<script language="javascript" type="text/javascript" src="js/coinpool.js"></script>

*/

/*
This code needs to be inserted into every HTML page after <BODY> tag:

    <script>

      function startApp() {
        // Any startup code goes here  
      } // startApp()

      window.addEventListener('load', function() {
        initCoinPoolContract();  

        // Now we can start our app & access contract "coinpool" freely:
        startApp()

      })
      
    </script>

*/

/*
Initialization of the Dapp functions  
*/
let coinPoolAddress = "COIN POOL CONTRACT ADDRESS"; //TODO
let coinPoolABI = "ABI GOES HERE"; //TODO
let provider;
var web3;
var poolUserAddress;
var coinPoolContract;
var coinPoolObj;


function initCoinPoolContract() {
  if (typeof web3 === 'undefined') {
    provider = new Web3.providers.HttpProvider('http://127.0.0.1:9545')
    web3 = new Web3(window.BinanceChain);
    web3.setProvider(provider);

    poolUserAddress = web3.eth.accounts[0];
    web3.eth.defaultAccount = poolUserAddress;

    coinPoolContract = web3.eth.contract(coinPoolABI);
    coinPoolObj = coinPoolContract.at(coinPoolAddress);
  }  
} // initCoinPoolContract()


/*
Common functions here
*/

function getPoolDetails(_poolID) {
 
 return coinPoolObj.getPoolDetails(_poolID).call(); //TODO
  
} //getPoolDetails()

function addNewPool(_userAddress, _poolName, _assetName, _assetAmount) {
    
 return coinPoolObj.addNewPool(_userAddress, _poolName, _assetName, _assetAmount).call(); //TODO   
  
} //addNewPool()

function getAllActivePools() {
 
 return coinPoolObj.getAllActivePools().call(); //TODO
  
} //getAllActivePools()

function getAllActivePools_Count() {
    
 return coinPoolObj.acivePoolCount().call(); //TODO
 
} //getAllActivePools_Count()

function getActivePools_byOwner(_userAddress) {
    
 return coinPoolObj.getAllActivePools_byOwner().call(); //TODO
  
} //getActivePools_byOwner()

function getActivePools_MemberOf(_userAddress) {
    
 return coinPoolObj.getAllActivePools_MemberOf().call(); //TODO
  
} //getActivePools_MemberOf()

function joinExistingActivePool(_poolID, _userAddress) {
    
 return coinPoolObj.joinExistingActivePool().call(); //TODO
  
} //joinExistingActivePool()

function getAllVaultDetails(_userAddress) {
    
 return coinPoolObj.getAllVaultDetails(_userAddress).call(); //TODO
  
} //getAllVaultDetails()

function getAllMarketDetails() {
    
 return coinPoolObj.getAllMarketDetails().call(); //TODO
  
} //getAllMarketDetails(()

function payoutPoolEarnings(_poolID,_userAddress) {
    
 return coinPoolObj.payoutPoolEarnings(_poolID, _userAddress).call(); //TODO
  
} //payoutPoolEarnings(()

function depositIntoPool(_poolID,_userAddress) {
    
 return coinPoolObj.depositIntoPool(_poolID, _userAddress).call(); //TODO
  
} //depositIntoPool(()

/*
index.html
*/

// ?????

/*
createpool.html
*/

// Button to start a new pool
$("#button").click(function() { //TODO need a button [id='']
  addNewPool(poolUserAddress,$("#poolName").val(), $("#asset").val(), $("#amount").val())  //TODO
  } 
 );
 

/*
pool.html
*/
/* In the "startApp" section we display using the following:
      function startApp() {
        // Any startup code goes here  
        arraylist = getAllActivePools();
        arrayCount = getAllActivePools_Count();
        for{
        .......
        arrayPoolPoolDetails = getPoolDetails(poolID);
        .......
          for{
          .......
          .......
          // fill in the HTML page
          }
        .......
        .......
        }
      } // startApp()
*/

// Button to "Join" an existing active pool
$("#button").click(function() { //TODO need a button [id=''] for "Join"
  joinExistingActivePool($("#poolID").val(),poolUserAddress)  //TODO
  } 
 );


/*
viewpool.html
*/

/* In the "startApp" section we display using the following:
      function startApp() {
        // Any startup code goes here  
        arrayPoolDetails = getPoolDetails(poolID);
        for{
        .......
        .......
        // fill in the HTML page
        }
      } // startApp()
*/

// Button to "payout" an existing active pool member
$("#button").click(function() { //TODO need a button [id=''] for "PAYOUT"
  payoutPoolEarnings($("#poolID").val(),poolUserAddress)  //TODO
  } 
 );

/*
market.html
*/


/* In the "startApp" section we display using the following:
      function startApp() {
        // Any startup code goes here  
        arrayMarketDetails = getAllMarketDetails();
        for{
        .......
        .......
        // fill in the HTML page
        }
      } // startApp()
      
*/


/*
vault.html
*/

/* In the "startApp" section we display using the following:
      function startApp() {
        // Any startup code goes here  
        arrayVaultDetails = getAllVaultDetails(userAddress);
        for{
        .......
        .......
        // fill in the HTML page
        }
      } // startApp()
      
*/



