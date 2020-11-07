// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.25 <0.7.2;


import './oracle.sol';
import './math.sol';

interface ISQRT {
    
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    

}

contract SQRT is PokeMath,ISQRT {
    
    string public constant name = "Squirtzu";
    string public constant symbol = "SQRT";
    uint256 public constant decimals = 18;
    uint256 public override totalSupply = 0;
    uint256 public rebase;
    bool public pos;
    address payable public owner;
    
    PriceOracle public oracle;
    
    constructor(address oracle_address) public{
        uint256 initalSupply = PokeMath.safeMul(302000,10**18);
        owner = msg.sender;
        balance[msg.sender]=initalSupply;
        totalSupply+=initalSupply;
        oracle = PriceOracle(oracle_address);
        emit Transfer(address(0), owner, initalSupply);
     }
     

    mapping (address => uint256) public balance;
    mapping(address => mapping(address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint value);

    
    function transfer(address _reciever, uint256 _value) public override returns (bool){
         require(balanceOf(msg.sender) >= _value);
         uint256 bal = getOriginalBal(_value);
         balance[msg.sender] = PokeMath.safeSub(balance[msg.sender],bal);
         balance[_reciever] = PokeMath.safeAdd(balance[_reciever],bal);
         emit Transfer(msg.sender,_reciever,_value);
         return true;
    }
    
     function transferFrom(address _from, address _to, uint256 _amount )public override returns (bool) {
     require( _to != address(0));
     uint256 bal = getOriginalBal(_amount);
     require(balance[_from] >= bal && allowed[_from][msg.sender] >= bal && bal >= 0);
     balance[_from] = PokeMath.safeSub(balance[_from],bal);
     allowed[_from][msg.sender] = PokeMath.safeSub(allowed[_from][msg.sender],bal);
     balance[_to] = PokeMath.safeAdd(balance[_to],_amount);
     emit Transfer(_from, _to, _amount);
     return true;
     }
     
    
    function approve(address _spender, uint256 _amount) public override returns (bool) {
         require( _spender != address(0));
         allowed[msg.sender][_spender] = _amount;
         emit  Approval(msg.sender, _spender, _amount);
         return true;
     }
     
     function reverseApprove(address _spender, uint256 _amount) public returns (bool){
        require( _spender != address(0));
        if(PokeMath.safeSub(allowed[msg.sender][_spender],_amount) >= 0){
        allowed[msg.sender][_spender] = PokeMath.safeSub(allowed[msg.sender][_spender],_amount);
        emit  Approval(msg.sender, _spender, PokeMath.safeSub(allowed[msg.sender][_spender],_amount));
        return true;
        }
        return false;
     }
     
     
     function allowance(address _owner, address _spender)public view override returns (uint256 remaining) {
         require( _owner != address(0) && _spender != address(0));
         return allowed[_owner][_spender];
     }
     
     function balanceOf(address account) public view override returns(uint256){
        uint256 orginalBal = balance[account];
        uint256 b = PokeMath.safeMul(orginalBal,rebase);
        uint256 c = PokeMath.safeDiv(b,10**20);
        if(pos == true){
           return PokeMath.safeAdd(orginalBal,c); 
        }
        else{
            return PokeMath.safeSub(orginalBal,c); 
        }
     }
     
     function getOriginalBal(uint256 bal)public view returns(uint256){
        uint256 a = PokeMath.safeMul(bal,100);
        uint256 b = PokeMath.safeAdd(10**20,rebase);
        uint256 c = PokeMath.safeDiv(a,b);
        return c * 10 ** 18;
     }
     
     function setrebase() public returns(bool){
         uint256 bowl = oracle.fetchBowl();
         uint256 sqrt = oracle.fetchSqrt();
         if(sqrt>bowl){
             uint256 a = PokeMath.safeSub(sqrt,bowl);
             uint256 b = PokeMath.safeMul(a,10 ** 19);
             uint256 c = PokeMath.safeDiv(b,sqrt);
             rebase = c;
             pos = true;
             return true;
         }
         else{
             uint256 a = PokeMath.safeSub(bowl,sqrt);
             uint256 b = PokeMath.safeMul(a,10 ** 19);
             uint256 c = PokeMath.safeDiv(b,sqrt);
             rebase = c;
             pos = false;
             return false;
         }
     }
     

}