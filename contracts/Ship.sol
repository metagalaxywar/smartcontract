pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Ship is
    Initializable,
    ERC721EnumerableUpgradeable,
    AccessControlUpgradeable
{
    bool private locked;
    modifier lock() {
        require(locked == false, "IS LOCKING");
        locked = true;
        _;
        locked = false;
    }
    bytes32 public constant GAME_PLATFORM = keccak256("GAME_PLATFORM");
    using SafeMath for uint256;

    string public baseUri;
    mapping(uint256=>uint256) public shipTypes;
    event MintNFT(address _account, uint256 _tokenId);

    function initialize() public initializer {
        __ERC721_init("Space Ship", "SHIP");
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        baseUri = "/ship/";
        locked = false;
    }

    function grantPlatform(address _account)
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

    function mintShip(
        address account,
        uint256 _type
    )
        external
        virtual
        
        onlyRole(GAME_PLATFORM)
        lock
        returns (uint256 tokenId)
    {
        tokenId = totalSupply().add(1);
        shipTypes[tokenId] = _type;
        _mint(account, tokenId);
    }
 function mintShipByOwner(
        address account,
        uint256 _type
    )
        external
        virtual
        
        onlyRole(DEFAULT_ADMIN_ROLE)
        lock
        returns (uint256 tokenId)
    {
        tokenId = totalSupply().add(1);
        shipTypes[tokenId] = _type;
        _mint(account, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        "/",
                        shipTypes[tokenId],
                        "/",
                        numberToString(tokenId)
                    )
                )
                : "";
    }

    function setBaseUri(string memory _uri) external  onlyRole(DEFAULT_ADMIN_ROLE) {
        baseUri = _uri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }

   
    function getInventory(address _account)
        external
        view
        
        returns (uint256[] memory _ids, uint256[] memory _types)
    {
        uint256 tokenCount = balanceOf(_account);

        if (tokenCount == 0) {
            _ids = new uint256[](0);
        } else {
            uint256[] memory ids = new uint256[](tokenCount);
            _types = new uint256[](tokenCount);
            for (uint256 i = 0; i < tokenCount; i++) {
                uint256 tokenId = tokenOfOwnerByIndex(_account, i);
                ids[i] = tokenId;
                _types[i] = shipTypes[tokenId];
            }
            _ids = ids;
        }
    }
    
    function numberToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721EnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
