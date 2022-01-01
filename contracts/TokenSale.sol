pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract TokenSale is Initializable, AccessControlUpgradeable {
    using SafeMath for uint256;

    IERC20 public paymentToken;
    IERC20 public saleToken;
    
    bytes32 public constant GAME_PLATFORM = keccak256("GAME_PLATFORM");
    mapping(address => uint256) public maxAllocation;
    address[] public whitelist;
    mapping(address => uint256) public paidAllocation;
    mapping(address=>mapping(uint=>bool)) claimStatus;// status by claim time
    mapping(address=>mapping(uint=>uint256)) claimedAmount;// claimed amount by time
    uint256[] claimRates;
    uint256[] claimTimes;
    uint256 public saleTokenPrice;
    bool public claimable;

    function initialize(address _saleToken, address _paymentToken)
        public
        initializer
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        saleToken = IERC20(_saleToken);
        paymentToken = IERC20(_paymentToken);
        claimable = false;
    }

    function grantPlatfom(address _account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        grantRole(GAME_PLATFORM, _account);
    }

    function revokePlatform(address _account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        revokeRole(GAME_PLATFORM, _account);
    }

    function setPaymentToken(address _paymentToken)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        paymentToken = IERC20(_paymentToken);
    }

    function setSaleToken(address _saleToken)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        saleToken = IERC20(_saleToken);
    }

    function setSaleTokenPrice(uint256 _price)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        saleTokenPrice = _price;
    }

    function setClaimable(bool _claimable)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        claimable = _claimable;
    }

    function addLocationNFT(address _account, uint256 _amount)
        external
        onlyRole(GAME_PLATFORM)
    {
        addAllocation(_account, _amount);
    }

    function addAllocations(
        address[] memory _accounts,
        uint256[] memory _amounts
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < _accounts.length; i++) {
            addAllocation(_accounts[i], _amounts[i]);
        }
    }

    function addAllocation(address _account, uint256 _amount) internal {
        if (maxAllocation[_account] == 0) {
            whitelist.push(_account);
        }
        maxAllocation[_account] = _amount;
    }

    function setClaimSetting(uint256[] memory _claimRates, uint256[] memory _claimTimes) 
        external
        onlyRole(GAME_PLATFORM){
        require(_claimRates.length > 0, "Claim rates are invalid");
        require(_claimTimes.length > 0, "Claim times are invalid");
        require(_claimRates.length == _claimTimes.length, "Claim rates and claim times are invalid" );
        claimRates = _claimRates;
        claimTimes = _claimTimes;
    }

    function buyToken(uint256 _amount) external {
        require(maxAllocation[msg.sender] > 0, "Not In Whitelist");
        require(_amount > 0  && _amount <= maxAllocation[msg.sender], "Invalid Amount");
        require(paidAllocation[msg.sender] == 0, "Already bought");
        
        require(
            saleToken.balanceOf(address(this)) > _amount,
            "Insufficient balance"
        );

        uint256 totalPrice = saleTokenPrice.mul(_amount);
        require(
            paymentToken.balanceOf(msg.sender) > totalPrice,
            "Insufficient usdt balance"
        );

        paymentToken.transferFrom(msg.sender, address(this), totalPrice);

        paidAllocation[msg.sender] = _amount;
        emit BuyToken(msg.sender, _amount);
    }

    function claim(uint _claimTime) external {
        require(claimable, "Claim not open");
        require(paidAllocation[msg.sender] >= 0, "Not bought yet");
        require(_claimTime < claimTimes.length , "Invalid claim time");
        require(block.timestamp > claimTimes[_claimTime], "Claim has not opened yet");
        require(!claimStatus[msg.sender][_claimTime], 'All ready claimed');
        
        uint256 claimAmount = claimRates[_claimTime].mul(paidAllocation[msg.sender]);

        saleToken.transfer(msg.sender, claimAmount);

        claimedAmount[msg.sender][_claimTime] = claimAmount;
        claimStatus[msg.sender][_claimTime] = true;
        
        emit Claim(msg.sender, _claimTime, claimAmount);
    }

    function withdrawSaleToken(address  _account, uint256 _amount) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE){
        require(
            saleToken.balanceOf(address(this)) > _amount,
            "Insufficient balance"
        );
        saleToken.transfer(_account, _amount);
        emit Withdraw(_account, address(saleToken), _amount);
    }

    function withdrawPaymentToken(address  _account, uint256 _amount) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE){

        require(
            paymentToken.balanceOf(address(this)) > _amount,
            "Insufficient balance"
        );
        paymentToken.transfer(_account, _amount);
        emit Withdraw(_account, address(paymentToken), _amount);
    }

    event BuyToken(address _account, uint256 _amount);
    event Claim(address _account, uint _claimTime, uint256 _amount);
    event Withdraw(address _account, address _token, uint256 _amount);
}
