contract token { mapping (address => uint) public balance; function token() {}  function sendToken(address receiver, uint amount) returns(bool sufficient) {  } }

contract CrowdSale {
    
    address public admin;
    address public beneficiary;
    uint public fundingGoal;
    uint public numFunders;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;   
    mapping (uint => Funder) public funders;
    
    /* data structure to hold information about campaign contributors */
    struct Funder {
        address addr;
        uint amount;
    }
    
    /*  at initialization, setup the owner */
    function CrowdSale() {
    admin = msg.sender;
    }   
    
    function setup(address _beneficiary, uint _fundingGoal, uint _duration, uint _price, address _reward) returns (bytes32 response){
        if (msg.sender == admin && !(beneficiary > 0 && fundingGoal > 0 && deadline > 0)) {
            beneficiary = _beneficiary;
            fundingGoal = _fundingGoal;
            deadline = now + _duration * 1 days;
            price = _price;
            tokenReward = token(_reward);
            
            return "campaign is set";
        } else if (msg.sender != admin) {
            return "not authorized";
        } else  {
            return "campaign cannot be changed";
        }
    }
    
    /* The function without name is the default function that is called whenever anyone sends funds to a contract */
    function () returns (bytes32 response) {
        Funder f = funders[numFunders++];
        f.addr = msg.sender;
        f.amount = msg.value;
        amountRaised += f.amount;
        tokenReward.sendToken(msg.sender, f.amount/price);
        
        return "thanks for your contribution";
    }
        
    /* checks if the goal or time limit has been reached and ends the campaign */
    function checkGoalReached() returns (bytes32 response) {
        if (amountRaised >= fundingGoal){
            uint i = 0; 
            beneficiary.send(amountRaised);
         suicide(beneficiary);
         return "Goal Reached!"; 
        }
        else if (deadline <= block.number){
            uint j = 0;
            uint n = numFunders;
            while (j <= n){
                funders[j].addr.send(funders[j].amount);
                funders[j].addr = 0;
                funders[j].amount = 0;
                j++;
            }
            suicide(beneficiary);
            return "Deadline passed";
        }
        return "Not reached yet";
    }
}