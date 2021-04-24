// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 ;
import "./Pool.sol";
import "./Cycle.sol";

library Utils{
    
    struct AccountSummary{
        string assetName;
        uint256 available;
        uint256 staked;
        uint256 contributed;
    }
    
    struct Auction{
        uint poolId;
        address account;
        string poolAssetName;
        uint256 poolAssetAmount;
        string stakeAssetName;
        uint256 stakeAssetAmount;
    }
    
    function compareString(string memory first, string memory second) public pure returns(bool){
        if(keccak256(bytes(first)) == keccak256(bytes(second))){
            return true;
        }
        return false;
    }
    
    function generateRandomUint() public view returns(uint randomUint){
        // Using keccak to generate random data as solidity has low support for this.
        randomUint = uint(keccak256(abi.encodePacked(block.timestamp)));
    }
    
    function generateRandomUint256() public view returns(uint256 randomUint){
        // Using keccak to generate random data as solidity has low support for this.
        randomUint = uint256(keccak256(abi.encodePacked(block.timestamp)));
    }
    
    function timestampDays(uint _days) public view returns(uint256 timestamp){
        timestamp =  uint256(block.timestamp + (_days *  40 ));
    }
    
    function timestamp(uint _days) public pure returns(uint256 timestamp){
        timestamp =  uint256((_days *  40));
    }
    
    function chooseRandomBetween(uint _start, uint _stop) public view returns(uint _randomIndex){
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


library ext1{
    function viewAuctionedStakes(PoolsList listOfPools) public view returns(Utils.Auction[10] memory auctions, uint8 count){
        // Pool[] memory pools = getList_ofPools().getRunningPools();
        Pool[] memory pools = listOfPools.getRunningPools();
        // Auction[] memory auctions = new Auction[](pools.length * 10);
        // Utils.Auction[] memory auctionDatas = new Utils.Auction[]();
        count = 0;
        for(uint8 i=0; i<pools.length; i++){
            Cycle cycle = pools[i].getCyclesList().getCurrentCycle();
            if(cycle.getCycleStatus() == Cycle.CycleStatus.AUCTIONING){
                for(uint8 j=0; j<cycle.getAuctioningMembers().length; j++){
                    Utils.Auction memory auctionData;
                    auctionData.poolId = pools[i].getPoolId();
                    auctionData.account = cycle.getAuctioningMembers()[j].getAccount();
                    (auctionData.poolAssetName, auctionData.poolAssetAmount) = pools[i].getRequirement_forContributionAsset();
                    (auctionData.stakeAssetName, ) = pools[i].getRequirement_forStakingAsset();
                    auctionData.stakeAssetAmount = auctionData.poolAssetAmount;
                    auctions[count] = auctionData;
                    count++;
                }
            }
        }
        // allAuctions = auctions
    }

    function servicePool(uint _id, PoolsList listOfPools) public returns(bool){
        // Pool pool = getList_ofPools().getPool_withId(_id);
        Pool pool = listOfPools.getPool_withId(_id);
        require(!pool.isPoolStatus_concluded(), "This pool has ended");
        
        //begin pending pools
        // emit Check(block.timestamp, pool.getCycleStartDate());
        if(pool.isPoolStatus_addingmembers() && block.timestamp > pool.getCycleStartDate()){
            // pool.cycleStartDate = block.timestamp;
            pool.runThisPool(new CyclesList(pool));
            return true; 
        }
        
        //select winners, conclude cycles, auction assets, pay users, initiate new cycles or conclude pool with no more cycles left
        if(pool.isPoolStatus_running() && block.timestamp > pool.getCycleStartDate() 
            + (pool.getCurrentCycleNo() * Utils.timestamp(pool.getCycleInterval()))){
                
            pool.getCyclesList().selectAWinningMember_forThisCycle();
             return true;
        }
        
        return false;
    }
}

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
    // function isSameStringValue(string memory _a, string memory _b)
    //   internal pure returns (bool) {
    //   if (bytes(_a).length != bytes(_b).length) {
    //     return false;
    //   } else {
    //     return (keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b)));
    //   }
    // } // isSameStringValue()

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