pragma solidity ^0.4.2;

contract ERC20Interface {

    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract Owner {
    address public owner;
    function Owner() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if(msg.sender != owner) throw;
        _;
    }
    function transferOwnership(address new_owner) onlyOwner {
        owner = new_owner;
    }
}

contract FuturXe is ERC20Interface,Owner {

    string  public name;
    string  public symbol;
    uint8   public decimals;
    uint256 public totalSupply;
    
    mapping(address => uint256) balances;
    mapping (address => bool) public frozenAccount;
    mapping(address => mapping (address => uint256)) allowed;
    
    event FrozenFunds(address target, bool frozen);
    
    function FuturXe(uint256 initial_supply, string _name, string _symbol, uint8 _decimal) {
        balances[msg.sender]  = initial_supply;
        name                  = _name;
        symbol                = _symbol;
        decimals              = _decimal;
        totalSupply           = initial_supply;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address to, uint value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        if(balances[msg.sender] < value) return false;
        if(balances[to] + value < balances[to]) return false;
        balances[msg.sender] -= value;
        balances[to] += value;
        
        Transfer(msg.sender, to, value);

        return true;
    }


    function transferFrom(address from, address to, uint value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        if(balances[from] < value) return false;
        if( allowed[from][msg.sender] >= value ) return false;
				// if (allowed[from][msg.sender] < value)로 수정해야 됨
        if(balances[to] + value < balances[to]) return false;
        
        balances[from] -= value;
        allowed[from][msg.sender] -= value;
        balances[to] += value;
        
        Transfer(from, to, value);

        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner{
        balances[target] += mintedAmount;
        totalSupply += mintedAmount;
        
        Transfer(0,owner,mintedAmount);
        Transfer(owner,target,mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function changeName(string _name) onlyOwner {
        name = _name;
    }

    function changeSymbol(string _symbol) onlyOwner {
        symbol = _symbol;
    }

    function changeDecimals(uint8 _decimals) onlyOwner {
        decimals = _decimals;
    }
}