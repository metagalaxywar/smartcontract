pragma solidity ^0.8.0;
import "./Ship.sol";
import "./TokenSale.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract NFTSale is Initializable, AccessControlUpgradeable {
    using SafeMath for uint256;
    Ship public shipNFT;
    uint256[] public nftPrices;
    IERC20 public paymentToken;
    address public receiver;

    uint256[] public maxAmounts;
    mapping(uint256 => uint256) public soldAmounts;
    bool public started;

    function initialize(
        address _ship,
        uint256[] memory _prices,
        address _paymentToken,
        address _receiver,
        uint256[] memory _amounts
    ) public initializer {
        shipNFT = Ship(_ship);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        nftPrices = _prices;
        paymentToken = IERC20(_paymentToken);
        receiver = _receiver;
        maxAmounts = _amounts;
    }

    function setPrices(uint256[] memory _prices)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        nftPrices = _prices;
    }

    function setPaymentToken(address _paymentToken)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        paymentToken = IERC20(_paymentToken);
    }

    function setStarted(bool _started) external onlyRole(DEFAULT_ADMIN_ROLE) {
        started = _started;
    }

    function setReceiver(address _receiver)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        receiver = _receiver;
    }

    function setMaxAmounts(uint256[] memory _amounts)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        maxAmounts = _amounts;
    }

    function mintNFT(uint256 _type, uint256 _amount) external payable {
        require(started);
        require(_amount > 0 && _amount <= 5, "Invalid amount");
        require(nftPrices[_type] > 0, "Invalid type");
        require(maxAmounts[_type] > soldAmounts[_type], "Sold out");
        require(
            maxAmounts[_type] > soldAmounts[_type].add(_amount),
            "Invalid amount"
        );
        uint256 totalPrice = nftPrices[_type].mul(_amount);
        require(msg.value >= totalPrice, "Insufficient BNB value");
        uint256 returnValue = msg.value.sub(totalPrice);
        if (returnValue > 0) {
            safeTransferBNB(msg.sender, returnValue);
        }
        // paymentToken.transferFrom(msg.sender, receiver, totalPrice);
        safeTransferBNB(receiver, totalPrice);
        for (uint256 i = 0; i < _amount; i++) {
            shipNFT.mintShip(msg.sender, _type);
        }
        soldAmounts[_type] = soldAmounts[_type].add(_amount);
        emit BuyShip(msg.sender, _type, _amount);
    }

    function getStatus()
        external
        view
        returns (
            uint256[] memory _amounts,
            uint256[] memory _solds,
            uint256[] memory _prices
        )
    {
        _amounts = maxAmounts;
        _solds = new uint256[](maxAmounts.length);
        _prices = nftPrices;
        for (uint256 i = 0; i < _amounts.length; i++) {
            _solds[i] = soldAmounts[i];
        }
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "BNB_TRANSFER_FAILED");
    }

    event BuyShip(address _account, uint256 _type, uint256 _amount);
}
