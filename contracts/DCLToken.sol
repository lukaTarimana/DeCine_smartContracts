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
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title The DeCine Loyalty token.
 * @author DeCine
 * @notice The DeCine Loyalty token is an ERC20 token that is used to reward users for their activity on the DeCine platform.
 * @dev The DeCine Loyalty token is based on the OpenZeppelin ERC20Upgradeable contract and is Ownable.
 */
contract DeCineLoyaltyToken is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    OwnableUpgradeable
{
    /// @notice The mapping of authorized minters.
    mapping(address => bool) public minters;

    // Events.
    /**
     * @notice The Mint event is emitted when new tokens are minted.
     * @param to The address to which the tokens are transferred.
     * @param amount The amount of tokens minted.
     */
    event Mint(address indexed to, uint256 amount);

    /**
     * @notice The smart contract constructor.
     * @dev The constructor is used to disable the initializers.
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Returns the version of the smart contract.
     * @return The version of the smart contract.
     */
    function contractVersion() external pure returns (string memory) {
        return "1.0";
    }

    /**
     * @notice The function is used to add a new minter.
     * @dev This function adds a new minter to the mapping of authorized minters.
     * @param minter The address of the minter to be added.
     */
    function addMinter(address minter) public onlyOwner {
        minters[minter] = true;
    }

    /**
     * @notice The function is used to remove a minter.
     * @dev This function removes a minter from the mapping of authorized minters.
     * @param minter The address of the minter to be removed.
     */
    function removeMinter(address minter) public onlyOwner {
        minters[minter] = false;
    }

    /**
     * @notice The initializer of the contract.
     * @dev This initializer is used to initialize the upgreadable DeCine NFT smart contract.
     */
    function initialize() public initializer {
        __ERC20_init("DeCineLoyalty", "DCL");
        __ERC20Burnable_init();
        __Ownable_init();
    }

    /**
     * @notice The mint function is used to mint new tokens.
     * @dev This function mints new tokens and transfers them to the specified address.
     * @param to The address to which the tokens will be transferred.
     * @param amount The amount of tokens to be minted.
     */
    function mint(address to, uint256 amount) public {
        require(minters[msg.sender], "NOT_A_MINTER");
        _mint(to, amount);
        emit Mint(to, amount);
    }
}
