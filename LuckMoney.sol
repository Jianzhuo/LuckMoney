// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * 1. Finish LuckyMoneyCreator and LuckyMoney contract
 * 2. Design necessary events and use them
 * 3. Add necessary modifier(s) to predefined functions
 * 
 */

/** 
 * @title LuckyMoneyCreator
 * @dev Implements creating new lucky money envelope
 */
contract LuckyMoneyCreator {
    // storages
    //creator address => array of LuckyMoney addresses created by creator
    mapping(address => address[]) luckyMoneys;
    
    constructor(){
      // todo
    }
    
    /**
     * create an instance of lucky money contract and transfer all eth to it
     * max_participants
     * 
     */
    function create(uint max_participants) payable public
    returns(bool success) {
        //create an instance of LuckyMoney contract
        //wrap the new LuckyMoney(max_participants, msg.sender) in a try/catch as a failsafe.
        try new LuckyMoney(max_participants, msg.sender) returns (LuckyMoney newLuckyMoney){
            //transfer all eth to new LuckyMoney instance 
            //msg.value to get received eth 
            payable(address(newLuckyMoney)).transfer(msg.value);
            //push created LuckyMoney's address to array
            luckyMoneys[msg.sender].push(address(newLuckyMoney));
            return true;
        }catch{
            return false;
        }
    }
    
    /**
     * @dev return all LuckyMoney created by the given user
     * 
     */
     //For solidty v0.5 the constant modifier for function was deprecated.
    function query(address user) view public returns(address[] memory){
        return luckyMoneys[user];
    }

    /**
     * Test functions
     * 
     */
    // fallback() external payable { }
    // receive() external payable { }
    // function testRoll(address _luckMoneyAddress) public{
    //      TestLuckyMoney tlm = TestLuckyMoney(_luckMoneyAddress);
    //      tlm.roll();
    // }

    // function testParticipants(address _luckMoneyAddress) public view returns(address[] memory){
    //     TestLuckyMoney tlm = TestLuckyMoney(_luckMoneyAddress);
    //     return tlm.participants();
    // }

    // function testGetBalance(address _luckMoneyAddress) public view returns(uint){
    //     TestLuckyMoney tlm = TestLuckyMoney(_luckMoneyAddress);
    //     return address(tlm).balance;
    // }

}

// interface TestLuckyMoney { 
//     function roll() external;
//     function participants() external view returns(address[] memory);
// }

/**
 * 
 * @dev 
 * 
 */
contract LuckyMoney {
    // storages
    address[] participantAddresses;
    uint max_participants;
    address private creator;
    
    //used to generate random value
    uint randNonce = 0;
    
    constructor(uint _max_participants, address _creator) {
        max_participants = _max_participants;
        creator = _creator;
    }

    //fallback function
    fallback() external payable { }
    receive() external payable { }
    
    /**
     * @dev return all participants
     * 
     */
    function participants() public view returns(address[] memory){
        return participantAddresses;
    }
    
    /**
     * @dev anyone can roll and get rewarded a random amount of remnant eth from the contract
     * as long as doesn't exceed max_participants
     * each account can only roll once
     * 
     */
    function roll() public{
        // check is account rolled or not
        bool isRolled = false;
    
        for (uint i=0; i < participantAddresses.length; i++) {
            if (msg.sender == participantAddresses[i]) {
                isRolled = true;
                break;
            }
        }
        require(isRolled == false, "Account already rolled.");
        // check if exceed max_participants 
        require(participantAddresses.length < max_participants, "Reached max participants.");
        //if this roll reached the max_participants tranfer all the left amount to him.
        if(participantAddresses.length == max_participants-1){
            payable(msg.sender).transfer(address(this).balance);
        }else{
            payable(msg.sender).transfer(random());
        }
        participantAddresses.push(msg.sender);
    }
    
    /**
     * @dev generate a random uint
     * 
     */
    function random() private returns(uint){
        randNonce++;
        //use %address(this).balance to make sure the generated random value is less then contract balance.
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)))%(address(this).balance);
    }
    
    /**
     * @dev only owner can call
     * refund remant eth and destroy itself
     * 
     */
    function refund() public {
        require(msg.sender == creator, "Only owner can call!");
        payable(creator).transfer(address(this).balance);
        selfdestruct(payable(creator)); 
    }
    
}