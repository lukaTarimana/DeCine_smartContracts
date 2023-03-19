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
 * @title The DeCine token.
 * @author DeCine
 * @notice The DeCine token is an ERC20 token that is used as a payment token throughout the different services provided by DeCine.
 * @dev The DeCine token is an ERC20 upgreadable token. The token is mintable by the owner of the contract. The owner of the contract can also upgrade the contract.
 */
contract DeCineToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable {
    /**
     * @notice The constructor of the DeCine token.
     * @dev The following constructor is used to disable the initializers of the implementation smart contracts.
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
     * @notice The initializer of the DeCine token.
     * @dev The initializer is used to initialize the DeCine token.
     */
    function initialize() public initializer {
        __ERC20_init("DeCine", "DCT");
        __ERC20Burnable_init();
        __Ownable_init();
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    /**
     * @notice Mints new tokens.
     * @dev The function is used to mint new tokens.
     * @dev Only the owner of the contract can mint new tokens.
     * @param to The address of the receiver of the tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
