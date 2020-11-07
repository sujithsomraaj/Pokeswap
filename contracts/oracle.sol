//SPDX-License-Identifier: UNLICENSED

pragma solidity <=0.7.4;

import './sqrt.sol';
import './bowl.sol';
import './char.sol';

interface IPriceOracle{
    /**
     * @dev this function returns the rebase value of SQRT
     * returns an uint256 with 18 decimal precision
     * */
    function fetchSqrt() external view returns(uint256);
    /**
     * @dev this function returns the rebase value of BOWL
     * returns an uint256 with 18 decimal precision
     * */
    function fetchBowl() external view returns(uint256);
    /**
     * @dev this function returns the rebase value of CHAR
     * returns an uint256 with 18 decimal precision
     * */
    function fetchChar() external view returns(uint256);
}

contract PriceOracle{
    
    uint256 public sqrt;
    uint256 public char;
    uint256 public bowl;
    
    address public governor;
    
    SQRT public sqrt_contract;
    CHAR public char_contract;
    BOWL public bowl_contract;
    
    constructor() public{
        governor = msg.sender;
    }
    
    function setcontracts(address scontract,address ccontract,address bcontract) public returns(bool){
        require(msg.sender == governor,'Cannot Update');
        sqrt_contract = SQRT(scontract);
        char_contract = CHAR(ccontract);
        bowl_contract = BOWL(bcontract);
        return true;
    }
    
    function updateSqrt(uint256 price) public  returns(bool){
        require(msg.sender == governor,'Cannot Update');
        sqrt = price * 10**18;
        sqrt_contract.setrebase();
        return true;
    }
    
    function updateChar(uint256 price) public returns(bool){
        require(msg.sender == governor,'Cannot Update');
        char = price * 10**18;
        char_contract.setrebase();
        return true;
    }
    
    function updateBowl(uint256 price) public returns(bool){
        require(msg.sender == governor,'Cannot Update');
        bowl = price * 10**18;
        bowl_contract.setrebase();
        return true;
    }
    
    function updateGovernor(address new_governor) public returns(bool){
        require(msg.sender == governor,'Cannot Update');
        governor = new_governor;
        return true;
    }
    
    
    function fetchSqrt() public view returns(uint256){
        return sqrt;
    }
    
    function fetchChar() public view returns(uint256){
        return char;
    }
    
    function fetchBowl() public view returns(uint256){
        return bowl;
    }
    
}