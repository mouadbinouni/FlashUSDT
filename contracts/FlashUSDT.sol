// SPDX-License-Identifier: MIT
pragma solidity ^0.5.10;

contract FlashUSDT {
    string public name = "Tether USD";       // Matches real USDT
    string public symbol = "USDT";           // Same symbol
    uint8 public decimals = 6;               // Matches USDT
    uint256 public totalSupply;
    uint256 public deployTime;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier notExpired() {
        require(now < deployTime + 180 days, "Flash USDT expired");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() public {
        deployTime = now;
        owner = msg.sender;

        // Mint 10 billion USDT (10,000,000,000 * 10^6)
        totalSupply = 10_000_000_000 * (10 ** uint256(decimals));
        balanceOf[owner] = totalSupply;

        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address _to, uint256 _value) public notExpired returns (bool success) {
        require(_to != address(0));
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public notExpired returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public notExpired returns (bool success) {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}
