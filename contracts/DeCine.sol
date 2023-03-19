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
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol"; // Access control mechanism for smart contract functions.
import "./libs/EIP712DataValidator.sol"; // Signed data validator.

// The interface for the DeCine token contract.
interface IDCToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

// The interface for the DeCine Loyalty token contract.
interface IDCLToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address to, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

// The interface for the DeCine NFT contract.
interface IDCNFT {
    function getUserRating(address protocol, address user) external view returns (uint8);
    function safeMint(address to) external;
}

/**
 * @title DeCine Smart Contract.
 * @author DeCine
 * @notice The main smart contract of the DeCine platform.
 * @notice The DeCine smart contract is used to reward users for their activity on the DeCine platform, manage access to the videos, and manage subscriptions.
 * @dev The smart contract is upgradeable and ownable.
 */
contract DeCine is Initializable, OwnableUpgradeable, EIP712DataValidator {
    // Structs.
    /**
     * @notice The struct is used to store the shares of the DeCine platform.
     * @param creator The share of the creators.
     * @param users The share of the users.
     * @param platform The share of the platform.
     * @param denominator The denominator of the shares.
     */
    struct Shares {
        uint256 creator;
        uint256 users;
        uint256 platform;
        uint256 liquidity;
        uint256 denominator;
    }

    /**
     * @notice The struct is used to store the subscription of a user.
     * @param plan The subscription plan.
     * @param expiration The expiration date of the subscription.
     */
    struct Subscription {
        uint8 plan;
        uint256 expiration;
    }

    /**
     * @notice The struct is used to store the subscription plan.
     * @param plan The subscription plan.
     * @param duration The duration of the subscription.
     * @param price The price of the subscription.
     */
    struct SubscriptionPlan {
        uint8 plan;
        uint8 duration; // in days
        uint256 price;
    }

    // Authorized operators.
    mapping(address => bool) public operators;
    // Subscription prices.
    mapping(uint8 => uint256) public subscriptionPrices;
    // User subscriptions.
    mapping(address => Subscription) public subscriptions;
    // Subscription plans.
    mapping(uint8 => SubscriptionPlan) public subscriptionPlans;
    // Loyalty reward multipliers.
    mapping(uint8 => uint256) public loyaltyRewardMultipliers;
    // DeCine Token.
    IDCToken public dcToken;
    // DeCine Loyalty Token.
    IDCLToken public dclToken;
    // Decine NFT.
    IDCNFT public dcNft;
    // Shares.
    Shares public shares;
    // The loyalty reward multiplier denominator.
    uint256 public loyaltyRewardDenominator;

    // Modifiers.
    /**
     * @notice The modifier is used to check if the caller is an operator.
     */
    modifier onlyOperator() {
        require(operators[msg.sender], "NOT_AN_OPERATOR");
        _;
    }

    // Events.
    /**
     * @notice The event is emitted when a user buys a subscription.
     * @param user The address of the user.
     * @param subscriptionPlan The subscription plan.
     */
    event SubscriptionBought(address indexed user, uint8 subscriptionPlan);
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
     * @notice The event is emitted when the DeCine token address is changed.
     * @param dcToken The address of the DeCine token contract.
     */
    event SetDCToken(address indexed dcToken);
    /**
     * @notice The event is emitted when the DeCine Loyalty token address is changed.
     * @param dclToken The address of the DeCine Loyalty token contract.
     */
    event SetDCLToken(address indexed dclToken);
    /**
     * @notice The event is emitted when the DeCine NFT address is changed.
     * @param dcNft The address of the DeCine NFT contract.
     */
    event SetDCNFT(address indexed dcNft);

    /**
     * @notice The smart contract constructor
     * @dev The following constructor is used to disable the initializers of the implementation smart contracts.
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice The smart contract initializer.
     * @dev The following function is used to initialize the smart contract.
     * @param dcToken_ The address of the DeCine token contract.
     * @param dclToken_ The address of the DeCine Loyalty token contract.
     * @param dcNft_ The address of the DeCine NFT contract.
     * @param signingAddress The address of the signing authority.
     */
    function initialize(
        IDCToken dcToken_,
        IDCLToken dclToken_,
        IDCNFT dcNft_,
        address signingAddress
    ) external initializer {
        // Initialize the ownable extension.
        __Ownable_init();
        // Initialize the data validator.
        EIP712DataValidator.initializeValidator(signingAddress);
        // Set the state variables.
        require(address(dcToken_) != address(0), "INVALID_DCT_ADDRESS");
        require(address(dclToken_) != address(0), "INVALID_DCL_ADDRESS");
        require(address(dcNft_) != address(0), "INVALID_DCNFT_ADDRESS");
        require(signingAddress != address(0), "INVALID_SK_ADDRESS");
        dcToken = dcToken_;
        dclToken = dclToken_;
        dcNft = dcNft_;
        shares = Shares(59, 1, 20, 20, 100);
        loyaltyRewardMultipliers[1] = 10;
        loyaltyRewardMultipliers[2] = 11;
        loyaltyRewardMultipliers[3] = 12;
        loyaltyRewardMultipliers[4] = 13;
        loyaltyRewardMultipliers[5] = 20;
        loyaltyRewardDenominator = 100;
    }

    /**
     * @notice The function is used to buy a subscription.
     * @dev This function transfers the DCT tokens from the user to the current smart contract.
     * @dev The collected DCT tokens are used to reward users and creators for their activity on the DeCine platform.
     * @param subscriptionPlan The subscription plan.
     */
    function buySubscription(uint8 subscriptionPlan) external {
        // Transfer DCT tokens from the user to the movie owner.
        dcToken.transferFrom(msg.sender, address(this), subscriptionPrices[subscriptionPlan]);
        // Set the user subscription.
        subscriptions[msg.sender] = Subscription(
            subscriptionPlan,
            block.timestamp + subscriptionPlans[subscriptionPlan].duration * 1 days
        );
        emit SubscriptionBought(msg.sender, subscriptionPlan);
    }

    /**
     * @notice The function is used to add a new operator.
     * @dev The operator is an address that is authorized to perform certain actions on the smart contract.
     * @param operator The address of the operator.
     */
    function addOperator(address operator) external onlyOwner {
        operators[operator] = true;
        emit OperatorAdded(operator);
    }

    /**
     * @notice The function is used to remove an operator.
     * @dev The operator is an address that is authorized to perform certain actions on the smart contract.
     * @param operator The address of the operator.
     */
    function removeOperator(address operator) external onlyOwner {
        operators[operator] = false;
        emit OperatorRemoved(operator);
    }

    /**
     * @notice The function is used to set the new DCT token contract address.
     * @dev The DCT token contract is used to reward users and creators for their activity on the DeCine platform.
     * @param dct The address of the DeCine token contract.
     */
    function setDCToken(IDCToken dct) external onlyOwner {
        dcToken = dct;
        emit SetDCToken(address(dct));
    }

    /**
     * @notice The function is used to set the new DCL token contract address.
     * @dev The DCL token contract is used to reward users for their activity on the DeCine platform.
     * @param dcl The address of the DeCine Loyalty token contract.
     */
    function setDCLToken(IDCLToken dcl) external onlyOwner {
        dclToken = dcl;
        emit SetDCLToken(address(dcl));
    }

    /**
     * @notice The function is used to set the new DeCine NFT contract address.
     * @dev The DeCine NFT contract is used to manage ratings of users and creators.
     * @param dcNft_ The address of the DeCine NFT contract.
     */
    function setDCNft(IDCNFT dcNft_) external onlyOwner {
        dcNft = dcNft_;
        emit SetDCNFT(address(dcNft_));
    }

    /**
     * @notice The function is used to set the subscription price.
     * @dev The subscription price is used to reward users and creators for their activity on the DeCine platform.
     * @param subscriptionPlan The subscription plan.
     * @param price The subscription price.
     */
    function setSubscriptionPrice(uint8 subscriptionPlan, uint256 price) external onlyOwner {
        subscriptionPrices[subscriptionPlan] = price;
    }

    /**
     * @notice The function is used to reward the creators.
     * @dev The function is used to reward the creators based on the number of views of their movies.
     * @dev The users are rewarded in DC and DCL tokens.
     * @param creators The addresses of the creators.
     * @param viewCounts The number of views of a creator during the day.
     * @param totalViews The total number of views during the day.
     */
    function rewardCreators(address[] memory creators, uint256[] memory viewCounts, uint256 totalViews) external onlyOperator {
        // Reward a creator based on the number of views out of the total number of views.
        uint256 rewardAmount = (dcToken.balanceOf(address(this)) * shares.creator) / shares.denominator;

        for (uint256 i = 0; i < creators.length; i++) {
            uint256 reward = (viewCounts[i] * rewardAmount) / totalViews;
            dcToken.transfer(creators[i], reward);
        }
    }

    /**
     * @notice The function is used to reward the users for their activity on the platform.
     * @dev The reward is based on the number of ads watched, time spend on the platform watching videos, and the activity rate.
     * @dev The users are rewarded in DCL tokens.
     * @param user The addresses of the users.
     * @param secondsViewed The number of seconds a user viewed movies during the day.
     * @param adsViewed The number of ads a user viewed during the day.
     * @param activityRate The activity rate of a user during the day.
     */
    function rewardUser(address user, uint256 secondsViewed, uint256 adsViewed, uint256 activityRate) external onlyOperator {
        uint256 rewardAmount = ((secondsViewed / 60 + adsViewed * 100 + activityRate * 1000) *
            loyaltyRewardMultipliers[dcNft.getUserRating(address(this), user)]) / loyaltyRewardDenominator;
        dclToken.mint(user, rewardAmount);
    }

    /**
     * @notice Mints a new NFT token for the user.
     * @dev The NFT token is used to manage the user rating.
     * @param user The address of the user.
     */
    function mintNFT(address user) external onlyOperator {
        dcNft.safeMint(user);
    }

    /**
     * @notice Sets and updates subscription plans.
     * @param subscriptionPlan The subscription plan ID.
     * @param duration The duration of the subscription plan in days.
     * @param price The price of the subscription plan.
     */
    function setSubscriptionPlan(uint8 subscriptionPlan, uint8 duration, uint256 price) external onlyOwner {
        subscriptionPlans[subscriptionPlan] = SubscriptionPlan(subscriptionPlan, duration, price);
    }

    /**
     * @notice Sets the loyalty reward multipliers.
     * @param rating The rating of the user.
     * @param multiplier The multiplier of the loyalty reward.
     */
    function setLoyaltyRewardMultiplier(uint8 rating, uint256 multiplier) external onlyOwner {
        loyaltyRewardMultipliers[rating] = multiplier;
    }

    /**
     * @notice Sets the loyalty reward multipliers.
     * @param denominator The denominator of the loyalty reward multipliers.
     */
    function setLoyaltyRewardDenominator(uint256 denominator) external onlyOwner {
        loyaltyRewardDenominator = denominator;
    }

    /**
     * @notice Returns the version of the smart contract.
     * @return The version of the smart contract.
     */
    function contractVersion() external pure returns (string memory) {
        return "1.0";
    }
}
