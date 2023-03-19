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

// Import libraries.
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol"; // Provides initialization routines for upgradeable smart contracts.
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol"; // Provides information about the current execution context.
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol"; // Access control mechanism for smart contract functions.
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol"; // Elliptic Curve Digital Signature Algorithm operations.;

/**
 * @title The Data Validator smart contract.
 * @dev The following contract is used to check whether data transmitted to smart contracts
        was signed using the valid private key.
 */
contract EIP712DataValidator is Initializable, ContextUpgradeable, OwnableUpgradeable {
    using ECDSAUpgradeable for bytes32;
    /// @notice The signing name that is used in the domain separator.
    string public constant SIGNING_NAME = "DECINE_DATA_VALIDATOR";
    /// @notice The version that is used in the domain separator.
    string public constant VERSION = "1.0.0";
    /// @notice The type hash of the data that was signed.
    bytes32 public constant TYPE_HASH = keccak256("Data(bytes32 data)");
    /// @notice The wallet address that is used to sign data.
    address public signingAddress;
    /// @notice Domain Separator is the EIP-712 defined structure that defines what contract
    //          and chain these signatures can be used for.  This ensures people can't take
    //          a signature used to mint on one contract and use it for another, or a signature
    //          from testnet to replay on mainnet.
    /// @dev It has to be created in the constructor so we can dynamically grab the chainId.
    ///      https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#definition-of-domainseparator
    bytes32 public domainSeparator;

    /**
     * @notice Sets signing key used for whitelisting.
     * @param signingAddress_ The signing key.
     */
    function setSigningAddress(address signingAddress_) external onlyOwner {
        signingAddress = signingAddress_;
    }

    /**
     * @notice The constructor that initializes the current smart contract.
     * @param signingAddress_ The signing key.
     */
    function initializeValidator(address signingAddress_) public initializer {
        domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(SIGNING_NAME)),
                keccak256(bytes(VERSION)),
                block.chainid,
                address(this)
            )
        );
        signingAddress = signingAddress_;
    }

    /**
     * @notice Checks if a signature provided is valid.
     * @param data The data that was signed.
     * @param encodedData The encoded version of the data.
     * @param signature The data signing signature.
     * @return True if the signature is valid, else - false.
     */
    function isValidDataSignature(bytes calldata data, bytes32 encodedData, bytes calldata signature) public view returns (bool) {
        require(signingAddress != address(0), "SIGNING_ADDRESS_NOT_SET");
        // Check if the encoded data and data are the same.
        require(keccak256(data) == encodedData, "INVALID_DATA");
        // Verify EIP-712 signature by recreating the data structure
        // that we signed on the client side, and then using that to recover
        // the address that signed the signature for this data.
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, keccak256(abi.encode(TYPE_HASH, encodedData))));
        // Use the recover method to see what address was used to create
        // the signature on this data.
        // Note that if the digest doesn't exactly match what was signed we'll
        // get a random recovered address.
        address recoveredAddress = digest.recover(signature);
        return recoveredAddress == signingAddress;
    }
}