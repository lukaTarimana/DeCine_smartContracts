// SPDX-License-Identifier: UNLICENSED

//
// ██████╗ ███████╗ ██████╗██╗███╗   ██╗███████╗
// ██╔══██╗██╔════╝██╔════╝██║████╗  ██║██╔════╝
// ██║  ██║█████╗  ██║     ██║██╔██╗ ██║█████╗
// ██║  ██║██╔══╝  ██║     ██║██║╚██╗██║██╔══╝
// ██████╔╝███████╗╚██████╗██║██║ ╚████║███████╗
// ╚═════╝ ╚══════╝ ╚═════╝╚═╝╚═╝  ╚═══╝╚══════╝
//

pragma solidity 0.8.19;

// Imports.
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol"; // Interface of the ERC20 standard as defined in the EIP.
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol"; // Safe operations with ERC20 tokens.
import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol"; // The ERC721A standard.
import "erc721a-upgradeable/contracts/extensions/ERC721AQueryableUpgradeable.sol"; // The ERC721A Queryable extension.
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol"; // The Ownable extension.
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol"; // The Initializable extension.
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol"; // The Strings library.
import "./libs/Base64.sol";

/**
 * @title The DeCine NFT contract.
 * @author DeCine
 * @notice This contract is used to operate with DeCine NFTs.
 * @dev This contract is based on the ERC721A standard and is upgreadable.
 */
contract DeCineNFT is Initializable, ERC721AUpgradeable, ERC721AQueryableUpgradeable, OwnableUpgradeable {
    // Use OpenZeppelin's StringsUpgradeable library to convert uint256 to string.
    using StringsUpgradeable for uint256;
    // Safe operations with tokens.
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @notice The attributes of the NFT.
     */
    struct Attributes {
        /// @notice The rating of the NFT.
        uint8 rating;
        /// @notice The protocol of the NFT.
        address protocol;
    }

    /// @notice The attributes of the NFTs.
    mapping(uint256 => Attributes) public nftAttributes;
    /// @notice The authorized operators that can manage NFT attributes.
    mapping(address => bool) public authorizedOperators;
    /// @notice The authorizes protocols that can have their own NFTs.
    mapping(address => bool) public authorizedProtocols;
    /// @notice The NFTs that are minted by the protocol.
    mapping(address => uint256[]) public protocolNFTs;
    /// @notice The user NFTs.
    mapping(address => uint256[]) public userNFTs;
    /// @notice The protocol NFTs by user addresses.
    mapping(address => mapping(address => Attributes)) public nfts;

    // Events.
    /**
     * @notice The event is emitted when a new operator is added.
     * @param operator The address of the operator.
     */
    event OperatorAdded(address indexed operator);
    /**
     * @notice The event is emitted when an operator is removed.
     * @param operator The address of the operator.
     */
    event OperatorRemoved(address indexed operator);
    /**
     * @notice The event is emitted when a new protocol is added.
     * @param protocol The address of the protocol.
     */
    event ProtocolAdded(address indexed protocol);
    /**
     * @notice The event is emitted when a protocol is removed.
     * @param protocol The address of the protocol.
     */
    event ProtocolRemoved(address indexed protocol);
    /**
     * @notice The event is emitted when there is an emergency withdrawal of funds.
     * @param funcName The name of the function that is used to withdraw funds.
     */
    event EmergencyWithdrawal(string funcName);

    /**
     * @notice The constructor of the contract.
     * @dev This constructor is used to disable the initializers of the inherited contracts.
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice The callback is executed on calls to the current smart contract that have no data (calldata), such as calls made via send() or transfer().
     * @dev The main function of this callback is to react to receiving BNB.
     */
    receive() external payable {}

    /**
     * @notice Sets the authorized operators.
     * @dev This function is used to set the authorized operators.
     * @dev Only the owner can set the authorized operators.
     * @param operator The address of the authorized operator.
     */
    function setAuthorizedOperator(address operator) external onlyOwner {
        authorizedOperators[operator] = true;
        emit OperatorAdded(operator);
    }

    /**
     * @notice Removes the authorized operators.
     * @dev This function is used to remove the authorized operators.
     * @dev Only the owner can remove the authorized operators.
     * @param operator The address of the authorized operator.
     */
    function removeAuthorizedOperator(address operator) external onlyOwner {
        authorizedOperators[operator] = false;
        emit OperatorRemoved(operator);
    }

    /**
     * @notice Sets the authorized protocols.
     * @dev This function is used to set the authorized protocols.
     * @dev Only the owner can set the authorized protocols.
     * @param protocol The address of the authorized protocol.
     */
    function setAuthorizedProtocol(address protocol) external {
        require(authorizedOperators[msg.sender], "NOT_AUTHORIZED_OPERATOR");
        authorizedProtocols[protocol] = true;
        emit ProtocolAdded(protocol);
    }

    /**
     * @notice Removes the authorized protocols.
     * @dev This function is used to remove the authorized protocols.
     * @dev Only the owner can remove the authorized protocols.
     * @param protocol The address of the authorized protocol.
     */
    function removeAuthorizedProtocol(address protocol) external {
        require(authorizedOperators[msg.sender], "NOT_AUTHORIZED_OPERATOR");
        authorizedProtocols[protocol] = false;
        emit ProtocolRemoved(protocol);
    }

    /**
     * @notice Used to remove funds from the contract.
     * @dev Should only use in case of emergency.
     * @param amount The amount of BNB to withdraw.
     * @return True if the transfer was successful.
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner returns (bool) {
        (bool sent, ) = payable(owner()).call{ value: amount }("");
        require(sent, "FUND_TRANSFER_FAILED");
        emit EmergencyWithdrawal("emergencyWithdraw");
        return true;
    }

    /**
     * @notice Withdraws ERC20 tokens to the owner wallet.
     * @param token The address of ERC20 token to withdraw.
     */
    function emergencyWithdrawERC20(IERC20Upgradeable token) external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(owner(), balance);
        emit EmergencyWithdrawal("emergencyWithdrawERC20");
    }

    /**
     * @notice Returns the version of the smart contract.
     * @return The version of the smart contract.
     */
    function contractVersion() external pure returns (string memory) {
        return "1.0";
    }

    /**
     * @notice The initializer of the contract.
     * @dev This initializer is used to initialize the upgreadable DeCine NFT smart contract.
     */
    function initialize() public initializerERC721A initializer {
        // Initialize the ERC721AUpgradeable contract.
        __ERC721A_init("DeCineNFT", "DCNFT");
        // Initialize the Ownable extension.
        __Ownable_init();
    }

    /**
     * @notice Mints a new NFT.
     * @dev This function is used to mint a new NFT.
     * @dev One wallet can only mint one NFT per protocol.
     * @param to The address of the NFT receiver.
     */
    function safeMint(address to) public {
        require(authorizedProtocols[msg.sender], "NOT_AUTHORIZED");
        uint256 tokenId = _nextTokenId();
        nftAttributes[tokenId].rating = 1;
        nftAttributes[tokenId].protocol = msg.sender;
        protocolNFTs[msg.sender].push(tokenId);
        userNFTs[to].push(tokenId);
        nfts[msg.sender][to] = nftAttributes[tokenId];
        _safeMint(to, 1);
    }

    /**
     * @notice Sets the attributes of the NFT.
     * @dev This function is used to set the attributes of the NFT.
     * @dev Only the authorized operators can set the attributes.
     * @param tokenId The token id.
     * @param rating The rating of the NFT.
     */
    function updateNftAttributes(uint256 tokenId, uint8 rating) public {
        require(_exists(tokenId), "TOKEN_NOT_EXIST");
        require(authorizedProtocols[msg.sender], "NOT_AUTHORIZED");
        require(nftAttributes[tokenId].protocol == msg.sender, "NOT_AUTHORIZED");
        nftAttributes[tokenId].rating = rating;
        nfts[msg.sender][ownerOf(tokenId)] = nftAttributes[tokenId];
    }

    /**
     * @notice Returns the attributes of the NFT.
     * @dev This function is used to return the attributes of the NFT.
     * @param tokenId The token id.
     * @return The attributes of the NFT.
     */
    function getNftAttributes(uint256 tokenId) public view returns (Attributes memory) {
        return nftAttributes[tokenId];
    }

    /**
     * @notice Returns the attributes of the NFT.
     * @dev This function is used to return the attributes of the NFT.
     * @param protocol The address of the protocol.
     * @param user The address of the user.
     * @return The attributes of the NFT.
     */
    function getProtocolNftAttributes(address protocol, address user) public view returns (Attributes memory) {
        return nfts[protocol][user];
    }

    /**
     * @notice Returns the user rating per protocol.
     * @param protocol The address of the protocol.
     * @param user The address of the user.
     * @return The user rating per protocol.
     */
    function getUserRating(address protocol, address user) public view returns (uint8) {
        return nfts[protocol][user].rating;
    }

    /**
     * @notice Builds a Base64 image of the NFT.
     * @param tokenId The token id.
     * @return The Base64 image.
     */
    function buildImage(uint256 tokenId) public view returns (string memory) {
        bytes memory starsString = "";
        address owner = ownerOf(tokenId);
        bytes memory ownerString = bytes(
            abi.encodePacked(
                "<text x='25' y='160' fill='rgb(0 0 0)' font-family='Arial sans-serif' font-size='20' style='white-space:pre'>",
                "P: ",
                StringsUpgradeable.toHexString(uint160(nftAttributes[tokenId].protocol), 20),
                "</text>",
                "<text x='25' y='200' fill='rgb(0 0 0)' font-family='Arial sans-serif' font-size='20' style='white-space:pre'>",
                "U: ",
                StringsUpgradeable.toHexString(uint160(owner), 20),
                "</text>"
            )
        );
        Attributes memory nftAttrs = nftAttributes[tokenId];
        string memory colorGold = "rgb(255 215 0)";
        string memory colorBlack = "rgb(0 0 0)";
        string[5] memory starCoords = ["m122", "m192", "m262", "m332", "m402"];

        for (uint8 i = 1; i <= 5; i++) {
            string memory starColor = i > nftAttrs.rating ? colorBlack : colorGold;
            starsString = abi.encodePacked(
                starsString,
                "<path fill='",
                starColor,
                "' d='",
                starCoords[i - 1],
                " 230 6 22h22l-17 13 6 20-17-13-18 13 7-20-18-13h22l7-22Z'/>"
            );
        }

        return
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 500 400'>",
                        "<defs>",
                        "<filter id='ffflux-filter' width='100%' height='100%' x='0%' y='0%' color-interpolation-filters='sRGB' filterUnits='objectBoundingBox' primitiveUnits='userSpaceOnUse'>",
                        "<feTurbulence width='100%' height='100%' x='0%' y='0%' baseFrequency='0.007 0.007' seed='100' type='fractalNoise'/>",
                        "</filter>",
                        "</defs>",
                        "<path fill='url(#ffflux-gradient)' d='M0 0h500v400H0z' filter='url(#ffflux-filter)'/>",
                        "<text fill='rgb(0 0 0)' font-family='Arial sans-serif' font-size='50' font-weight='700' style='white-space:pre' transform='translate(0 23)'><tspan x='116' y='80' text-decoration='overline solid rgba(255 255 255 .8)'>DeCine NFT</tspan></text>",
                        ownerString,
                        starsString,
                        "</svg>"
                    )
                )
            );
    }

    /**
     * @notice Returns the metadata in Base64 JSON format.
     * @param tokenId The token id.
     * @return The Base64 JSON.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721AUpgradeable, IERC721AUpgradeable) returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        return _buildMetadata(tokenId);
    }

    /**
     * @notice Returns the starting token Id number for the first mint.
     * @dev Must be pure to save gas. Change the startTokenId if required. (e.g set to 0).
     * @return The start ID of tokens.
     */
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    /**
     * @notice Builds the NFT metadata.
     * @param tokenId The token id.
     * @return The metadata.
     */
    function _buildMetadata(uint256 tokenId) private view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"DeCine NFT", ',
                                '"description": "DeCine User NFT",',
                                '"image": "',
                                "data:image/svg+xml;base64,",
                                buildImage(tokenId),
                                '", "attributes": ',
                                "[",
                                '{"trait_type": "Wallet Address",',
                                '"value":"',
                                StringsUpgradeable.toHexString(uint160(ownerOf(tokenId)), 20),
                                '"},',
                                '{"trait_type": "Protocol Address",',
                                '"value":"',
                                StringsUpgradeable.toHexString(uint160(nftAttributes[tokenId].protocol), 20),
                                '"}',
                                "]",
                                "}"
                            )
                        )
                    )
                )
            );
    }

    /**
     * @notice Callback function called before a token transfer.
     * @dev This function is called before a token transfer. Token transfers are disabled.
     * @param from The address of the sender.
     * @param to The address of the receiver.
     * @param startTokenId The ID of the first token to transfer.
     * @param quantity The number of tokens to transfer.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        if (from != address(0)) revert("TOKEN_TRANSFERS_DISABLED");
    }
}
