pragma solidity ^0.4.20;

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    function approve(address spender, uint256 value) returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifing the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}

contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function finishMinting() onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

}

contract BurnableToken is StandardToken {

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint _value) public {
        require(_value > 0);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

    event Burn(address indexed burner, uint indexed value);

}

contract ERC20GeoManna is MintableToken, BurnableToken{

    string public constant name = "GeoManna";

    string public constant symbol = "GM";

    uint32 public constant decimals = 2;

    uint public INITIAL_SUPPLY = 100000000 * 100;

    function ERC20GeoManna() {
        mint(msg.sender, INITIAL_SUPPLY);

        //запретить дальнейший минтинг
        finishMinting();
    }


}

contract Crowdsale is Ownable {
    using SafeMath for uint;


    ERC20GeoManna public token;
    uint public start;
    uint public end;
    uint public rate;
    uint public softcap;
    address public wallet; //кошелек сбора средств
    uint public minPrice;
    address public referer;
    uint public coin;
    uint public bonusCount;

    mapping(address => uint) public balances;
    mapping(address => uint) public bonusReferers;

    function Crowdsale(address _wallet) {
        token = new ERC20GeoManna();
        start = 1523491200;
        end = 1527897599;
        rate = 0.0002 * 1 ether;
        softcap = 500 * 1 ether;
        wallet = _wallet;
        minPrice = 0.1 * 1 ether;
        coin = 100;
        bonusCount = 0;
    }

    modifier saleIsOn() {
        require(now > start && now < end && tokenBalance() > 0);
        _;
    }

    // Возврат средств, в случае недостижения softcap
    function refund() {
        require(this.balance < softcap && now > end);
        uint value = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(value);
    }

    // Переводит собранные средства (если достигнут softcap) и остаток токенов на кошелек wallet
    function finishCrowdSale() public onlyOwner returns(bool){
        if( (now > end)||(tokenBalance()==0) ) {

            if(this.balance >= softcap) {
                wallet.transfer(this.balance);
            }
            token.burn(tokenBalance());

            return true;
        } else{
            return false;
        }
    }

    function setReferer(address _referer) public {
        referer = _referer;
    }

    //Продажа
    function createTokens() saleIsOn  payable {
        require(msg.value>=minPrice);
        uint tokens = msg.value.mul(coin).div(rate);
        uint rest = 0;
        // в случае если начислили эфиров больше,
        // чем есть на контракте, то продадим оставшиеся токены и вернем сдачу
        if(tokenBalance() < tokens){
            tokens = tokenBalance();
            rest = msg.value.sub(tokens.mul(rate).div(coin));
            msg.sender.transfer(rest);
        }
        token.transfer(msg.sender, tokens);
        balances[msg.sender] = balances[msg.sender].add(msg.value.sub(rest));

        if(msg.data.length == 20) {
            referer = bytesToAddress(bytes(msg.data));
            // проверка, чтобы инвестор не начислил бонусы сам себе
            require(referer != msg.sender);
            uint refererTokens = tokens.mul(10).div(100);
            // начисляем рефереру
            token.transfer(referer, refererTokens);
            bonusCount += refererTokens;
            bonusReferers[referer] = refererTokens;
        }
    }


    function bytesToAddress(bytes source) internal pure returns(address) {
        uint result;
        uint mul = 1;
        for(uint i = 20; i > 0; i--) {
            result += uint8(source[i-1])*mul;
            mul = mul*256;
        }
        return address(result);
    }
    function() external payable {
        createTokens();

    }

    function tokenBalance() returns (uint) {
        return token.balanceOf(address(this));
    }

    // Для админа

    function etherBalance() returns (uint){
        return this.balance;
    }

    function bonusBalance() returns (uint){
        return bonusCount;
    }

    function soldTokens() returns(uint){
        return token.INITIAL_SUPPLY().sub(tokenBalance());
    }

    // Для инвестора

    function boughtTokens(address _investor) returns(uint){
        return token.balanceOf(_investor);
    }

    function getBonusReferer(address _referer) returns(uint){
        return bonusReferers[_referer];
    }
}

