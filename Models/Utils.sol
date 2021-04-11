// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

library Utils{
    
    struct Token{
        string name;
        address deployedAddress;
    }
    
    struct AccountSummary{
        string assetName;
        uint256 available;
        uint256 staked;
        uint256 contributed;
    }
    
    function compareString(string memory first, string memory second) public view returns(bool){
        if(keccak256(bytes(first)) == keccak256(bytes(second))){
            return true;
        }
        return false;
    }
    
    function generateRandomUint() public returns(uint randomUint){
        // Using keccak to generate random data as solidity has low support for this.
        randomUint = uint(keccak256(abi.encodePacked(block.timestamp)));
    }
    
    function generateRandomUint256() public returns(uint256 randomUint){
        // Using keccak to generate random data as solidity has low support for this.
        randomUint = uint256(keccak256(abi.encodePacked(block.timestamp)));
    }
    
    function timestampDays(uint _days) public returns(uint256 timestamp){
        timestamp =  uint256(block.timestamp + (_days *  40 ));
    }
    
    function timestamp(uint _days) public returns(uint256 timestamp){
        timestamp =  uint256((_days *  40));
    }
    
    function chooseRandomBetween(uint _start, uint _stop) public returns(uint _randomIndex){
        _randomIndex = (uint(keccak256(abi.encodePacked(block.timestamp))) % _stop) + _start;
    }
    
//     function toLower(string memory str) public returns (string memory) {
// 		bytes memory bStr = bytes(str);
// 		bytes memory bLower = new bytes(bStr.length);
// 		for (uint i = 0; i < bStr.length; i++) {
// 			// Uppercase character...
// 			if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
// 				// So we add 32 to make it lowercase
// 				bLower[i] = bytes1(int(bStr[i]) + 32);
// 			} else {
// 				bLower[i] = bStr[i];
// 			}
// 		}
// 		return string(bLower);
// 	}
} //Utils


library Pool_Utils {

    //----------------------------------
    // Type definitions
    //----------------------------------
    struct CryptoAsset {
        string Name;
        uint Amount;
    }  // struct CryptoAsset 

    struct CryptoAssetWithAddress {
        CryptoAsset Asset;
        address walletAddress;        
    }  // struct CryptoAssetWithAddress 

    //----------------------------------
    // Functions
    //----------------------------------
    function isSameStringValue(string memory _a, string memory _b)
      internal pure returns (bool) {
      if (bytes(_a).length != bytes(_b).length) {
        return false;
      } else {
        return (keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b)));
      }
    } // isSameStringValue()

   /* TODO TODO TODO
   function integerToString(uint _i) internal pure 
      returns (string memory) {
      
      if (_i == 0) {
         return "0";
      }
      uint j = _i;
      uint len;
      
      while (j != 0) {
         len++;
         j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len - 1;
      
      while (_i != 0) {
         uint8 _bytes8 = uint8(48 + _i % 10);
     //Todo   bstr[k--] = _bytes8;
         _i /= 10;
      }
      return string(bstr);
   }  // integerToString() 
   */ 

} // library Pool_Utils