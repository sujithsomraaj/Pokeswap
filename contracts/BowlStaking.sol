pragma solidity <=0.7.3;

import './math.sol';
import './char.sol';
import './router.sol';

contract CharStaking is PokeMath{
    
    uint256 public OverallStakes;
    address public pair;
    uint256 public lastClaim;
    CHAR public char_address;

    constructor(address _pair,address _char) public{
        pair = _pair;
        char_address = CHAR(_char);
    }
    
    struct Stake {
        uint256 stakingAmount;
        bool active;
    }
    
    mapping(address => Stake) public stake;
    
    function stakeWorkLP(uint256 _amount) public{
        require(IUniswapV2Pair(pair).balanceOf(msg.sender)>=_amount,'Insufficient Funds');
        Stake storage s = stake[msg.sender];
        require(s.active == false,'Already active stake');
        s.stakingAmount = _amount;
        OverallStakes = OverallStakes + _amount; 
        s.active = true;
        IUniswapV2Pair(pair).transferFrom(msg.sender,address(this),_amount);
    }
    

    function claimStakingLP() public{
        Stake storage s = stake[msg.sender];
        require(s.active == true,'No Active Stake');
        uint256 a = PokeMath.safeMul(s.stakingAmount,10**18);
        uint256 b = PokeMath.safeDiv(a,OverallStakes);
        uint256 c = PokeMath.safeMul(b,char_address.balanceOf(address(this)));
        uint256 d = PokeMath.safeMul(c,3);
        uint256 e = PokeMath.safeDiv(d,10**20);
        s.active = false;
        s.stakingAmount = 0;
        IUniswapV2Pair(pair).transfer(msg.sender,s.stakingAmount);
        char_address.transfer(msg.sender,e);
    }
    
    function claimToken() public{
        Stake storage s = stake[msg.sender];
        require(s.active == true,'No Active Stake');
        uint256 a = PokeMath.safeMul(s.stakingAmount,10**18);
        uint256 b = PokeMath.safeDiv(a,OverallStakes);
        uint256 c = PokeMath.safeMul(b,char_address.balanceOf(address(this)));
        uint256 d = PokeMath.safeMul(c,3);
        uint256 e = PokeMath.safeDiv(d,10**20);
        char_address.transfer(msg.sender,e);
    }
    
    function fetchUnclaimed() public view returns(uint256){
        Stake storage s = stake[msg.sender];
        require(s.active == true,'No Active Stake');
        uint256 a = PokeMath.safeMul(s.stakingAmount,10**18);
        uint256 b = PokeMath.safeDiv(a,OverallStakes);
        uint256 c = PokeMath.safeMul(b,char_address.balanceOf(address(this)));
        uint256 d = PokeMath.safeMul(c,3);
        uint256 e = PokeMath.safeDiv(d,10**20);
        return e;
    }
    
}