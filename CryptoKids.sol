// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

    //Owner DAD
    //Define Kids
    //Add kid to contract
    //Deposit funds to contract, specifically to a Kid's account
    //Kid checks is able to withdraw
    //Kid withdraws money

    contract CryptoKids{
    //Owner DAD
    address owner;

    event LogKidFundingReceived(address addr, uint amount, uint contractBalance);

    constructor() {
        owner = msg.sender;
    }
    
    //Define Kids
    struct kid{
        address payable walletAddress;
        string firstName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    kid[] public kids;

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can add kids");
        _;
    }

    //Add kid to contract
    function addKid(address payable walletAddress,string memory firstName,uint releaseTime,uint amount, bool canWithdraw) public onlyOwner{
        kids.push(kid(walletAddress,firstName,releaseTime,amount,canWithdraw));
    }

    function balanceOf() public view returns(uint){
        return address(this).balance;
    }
    //Deposit funds to contract, specifically to a Kid's account
    function deposit(address walletAddress) payable public{
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance(address walletAddress) private {
        for(uint i=0;i<kids.length;i++){
            if(kids[i].walletAddress==walletAddress){
                kids[i].amount += msg.value;
                emit LogKidFundingReceived(walletAddress, msg.value, balanceOf());
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint){
        for(uint i=0;i<kids.length;i++){
            if(kids[i].walletAddress==walletAddress){
                return i;
            }
        }
        return 999;
    }
    //Kid checks is able to withdraw
    function availableToWithdraw(address walletAddress) public returns(bool){
        uint i = getIndex(walletAddress);
        require(block.timestamp > kids[i].releaseTime, "You can not withdraw yet");
        if(block.timestamp > kids[i].releaseTime){
            kids[i].canWithdraw = true;
            return true;
        }
        else{
            return false;
        }
    } 

        //Kid withdraws money
        function withdraw(address payable  walletAddress) payable public{
            uint i = getIndex(walletAddress);
            require(msg.sender==kids[i].walletAddress,"You must be the kid to withdraw");
            require(kids[i].canWithdraw == true, "You are not able to withdraw at this time");
            kids[i].walletAddress.transfer(kids[i].amount);
        }

}
