// SPDX-License-Identifier: MIT
/* 

 /$$   /$$           /$$ /$$$$$$$$                              
| $$  | $$          |__/| $$_____/                              
| $$  | $$ /$$$$$$$  /$$| $$    /$$$$$$   /$$$$$$  /$$$$$$/$$$$ 
| $$  | $$| $$__  $$| $$| $$$$$|____  $$ /$$__  $$| $$_  $$_  $$
| $$  | $$| $$  \ $$| $$| $$__/ /$$$$$$$| $$  \__/| $$ \ $$ \ $$
| $$  | $$| $$  | $$| $$| $$   /$$__  $$| $$      | $$ | $$ | $$
|  $$$$$$/| $$  | $$| $$| $$  |  $$$$$$$| $$      | $$ | $$ | $$
 \______/ |__/  |__/|__/|__/   \_______/|__/      |__/ |__/ |__/
                                                                
                                                                
                                                                
    Website: https://UniFarm.Finance
    X: https://x.com/UniLauncher_Farm
    Telegram: https://t.me/UniFarmFinance
    Github: https://github.com/UniLauncher-Farm

    Factory contract for creating new Superchain compatible tokens with built-in token-launcher,
    auto renounce & liquidity burn, and anti-bot features. Requires UniFarm token
    holdings to create new tokens. Max 10 tokens per wallet to prevent spam.
*/

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface ISemver {
    function version() external view returns (string memory);
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC7802 is IERC165 {
    event CrosschainMint(address indexed to, uint256 amount, address indexed sender);
    event CrosschainBurn(address indexed from, uint256 amount, address indexed sender);
    function crosschainMint(address _to, uint256 _amount) external;
    function crosschainBurn(address _from, uint256 _amount) external;
}

library Predeploys {
    uint256 internal constant PREDEPLOY_COUNT = 2048;
    address internal constant LEGACY_MESSAGE_PASSER = 0x4200000000000000000000000000000000000000;
    address internal constant L1_MESSAGE_SENDER = 0x4200000000000000000000000000000000000001;
    address internal constant DEPLOYER_WHITELIST = 0x4200000000000000000000000000000000000002;
    address internal constant WETH = 0x4200000000000000000000000000000000000006;
    address internal constant L2_CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000007;
    address internal constant GAS_PRICE_ORACLE = 0x420000000000000000000000000000000000000F;
    address internal constant L2_STANDARD_BRIDGE = 0x4200000000000000000000000000000000000010;
    address internal constant SEQUENCER_FEE_WALLET = 0x4200000000000000000000000000000000000011;
    address internal constant OPTIMISM_MINTABLE_ERC20_FACTORY = 0x4200000000000000000000000000000000000012;
    address internal constant L1_BLOCK_NUMBER = 0x4200000000000000000000000000000000000013;
    address internal constant L2_ERC721_BRIDGE = 0x4200000000000000000000000000000000000014;
    address internal constant L1_BLOCK_ATTRIBUTES = 0x4200000000000000000000000000000000000015;
    address internal constant L2_TO_L1_MESSAGE_PASSER = 0x4200000000000000000000000000000000000016;
    address internal constant OPTIMISM_MINTABLE_ERC721_FACTORY = 0x4200000000000000000000000000000000000017;
    address internal constant PROXY_ADMIN = 0x4200000000000000000000000000000000000018;
    address internal constant BASE_FEE_VAULT = 0x4200000000000000000000000000000000000019;
    address internal constant L1_FEE_VAULT = 0x420000000000000000000000000000000000001A;
    address internal constant SCHEMA_REGISTRY = 0x4200000000000000000000000000000000000020;
    address internal constant EAS = 0x4200000000000000000000000000000000000021;
    address internal constant GOVERNANCE_TOKEN = 0x4200000000000000000000000000000000000042;
    address internal constant LEGACY_ERC20_ETH = 0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000;
    address internal constant CROSS_L2_INBOX = 0x4200000000000000000000000000000000000022;
    address internal constant L2_TO_L2_CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000023;
    address internal constant SUPERCHAIN_WETH = 0x4200000000000000000000000000000000000024;
    address internal constant ETH_LIQUIDITY = 0x4200000000000000000000000000000000000025;
    address internal constant OPTIMISM_SUPERCHAIN_ERC20_FACTORY = 0x4200000000000000000000000000000000000026;
    address internal constant OPTIMISM_SUPERCHAIN_ERC20_BEACON = 0x4200000000000000000000000000000000000027;
    address internal constant OPTIMISM_SUPERCHAIN_ERC20 = 0xB9415c6cA93bdC545D4c5177512FCC22EFa38F28;
    address internal constant SUPERCHAIN_TOKEN_BRIDGE = 0x4200000000000000000000000000000000000028;

    function getName(address _addr) internal pure returns (string memory out_) {
        require(isPredeployNamespace(_addr), "Predeploys: address must be a predeploy");
        if (_addr == LEGACY_MESSAGE_PASSER) return "LegacyMessagePasser";
        if (_addr == L1_MESSAGE_SENDER) return "L1MessageSender";
        if (_addr == DEPLOYER_WHITELIST) return "DeployerWhitelist";
        if (_addr == WETH) return "WETH";
        if (_addr == L2_CROSS_DOMAIN_MESSENGER) return "L2CrossDomainMessenger";
        if (_addr == GAS_PRICE_ORACLE) return "GasPriceOracle";
        if (_addr == L2_STANDARD_BRIDGE) return "L2StandardBridge";
        if (_addr == SEQUENCER_FEE_WALLET) return "SequencerFeeVault";
        if (_addr == OPTIMISM_MINTABLE_ERC20_FACTORY) return "OptimismMintableERC20Factory";
        if (_addr == L1_BLOCK_NUMBER) return "L1BlockNumber";
        if (_addr == L2_ERC721_BRIDGE) return "L2ERC721Bridge";
        if (_addr == L1_BLOCK_ATTRIBUTES) return "L1Block";
        if (_addr == L2_TO_L1_MESSAGE_PASSER) return "L2ToL1MessagePasser";
        if (_addr == OPTIMISM_MINTABLE_ERC721_FACTORY) return "OptimismMintableERC721Factory";
        if (_addr == PROXY_ADMIN) return "ProxyAdmin";
        if (_addr == BASE_FEE_VAULT) return "BaseFeeVault";
        if (_addr == L1_FEE_VAULT) return "L1FeeVault";
        if (_addr == SCHEMA_REGISTRY) return "SchemaRegistry";
        if (_addr == EAS) return "EAS";
        if (_addr == GOVERNANCE_TOKEN) return "GovernanceToken";
        if (_addr == LEGACY_ERC20_ETH) return "LegacyERC20ETH";
        if (_addr == CROSS_L2_INBOX) return "CrossL2Inbox";
        if (_addr == L2_TO_L2_CROSS_DOMAIN_MESSENGER) return "L2ToL2CrossDomainMessenger";
        if (_addr == SUPERCHAIN_WETH) return "SuperchainWETH";
        if (_addr == ETH_LIQUIDITY) return "ETHLiquidity";
        if (_addr == OPTIMISM_SUPERCHAIN_ERC20_FACTORY) return "OptimismSuperchainERC20Factory";
        if (_addr == OPTIMISM_SUPERCHAIN_ERC20_BEACON) return "OptimismSuperchainERC20Beacon";
        if (_addr == SUPERCHAIN_TOKEN_BRIDGE) return "SuperchainTokenBridge";
        revert("Predeploys: unnamed predeploy");
    }

    function notProxied(address _addr) internal pure returns (bool) {
        return _addr == GOVERNANCE_TOKEN || _addr == WETH;
    }

    function isSupportedPredeploy(address _addr, bool _useInterop) internal pure returns (bool) {
        return _addr == LEGACY_MESSAGE_PASSER || _addr == DEPLOYER_WHITELIST || _addr == WETH
            || _addr == L2_CROSS_DOMAIN_MESSENGER || _addr == GAS_PRICE_ORACLE || _addr == L2_STANDARD_BRIDGE
            || _addr == SEQUENCER_FEE_WALLET || _addr == OPTIMISM_MINTABLE_ERC20_FACTORY || _addr == L1_BLOCK_NUMBER
            || _addr == L2_ERC721_BRIDGE || _addr == L1_BLOCK_ATTRIBUTES || _addr == L2_TO_L1_MESSAGE_PASSER
            || _addr == OPTIMISM_MINTABLE_ERC721_FACTORY || _addr == PROXY_ADMIN || _addr == BASE_FEE_VAULT
            || _addr == L1_FEE_VAULT || _addr == SCHEMA_REGISTRY || _addr == EAS || _addr == GOVERNANCE_TOKEN
            || (_useInterop && _addr == CROSS_L2_INBOX) || (_useInterop && _addr == L2_TO_L2_CROSS_DOMAIN_MESSENGER)
            || (_useInterop && _addr == SUPERCHAIN_WETH) || (_useInterop && _addr == ETH_LIQUIDITY)
            || (_useInterop && _addr == OPTIMISM_SUPERCHAIN_ERC20_FACTORY)
            || (_useInterop && _addr == OPTIMISM_SUPERCHAIN_ERC20_BEACON)
            || (_useInterop && _addr == SUPERCHAIN_TOKEN_BRIDGE);
    }

    function isPredeployNamespace(address _addr) internal pure returns (bool) {
        return uint160(_addr) >> 11 == uint160(0x4200000000000000000000000000000000000000) >> 11;
    }

    function predeployToCodeNamespace(address _addr) internal pure returns (address) {
        require(
            isPredeployNamespace(_addr), "Predeploys: can only derive code-namespace address for predeploy addresses"
        );
        return address(
            uint160(uint256(uint160(_addr)) & 0xffff | uint256(uint160(0xc0D3C0d3C0d3C0D3c0d3C0d3c0D3C0d3c0d30000)))
        );
    }
}

error Unauthorized();
error OnlyCustomGasToken();
error NotCustomGasToken();
error TransferFailed();
error ZeroAddress();

interface IUniFarmswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniFarmswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline 
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract UniFarmTokenFactory {
    address[] public deployedTokens;
    address public constant UniFarmS_TOKEN = 0xbf0cAfCbaaF0be8221Ae8d630500984eDC908861;
    uint256 public requiredTokens = 150_000 * 10**18;
    
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function setRequiredTokens(uint256 _newAmount) external onlyOwner {
        requiredTokens = _newAmount;
    }
    
    event TokenCreated(
        address tokenAddress,
        string name,
        string symbol,
        string description,
        string image,
        string twitter,
        string telegram,
        string website,
        address developer
    );

    // Update struct to include balances
    struct TokenInfo {
        address tokenAddress;
        string name;
        string symbol;
        string description;
        string image;
        string twitter;
        string telegram;
        string website;
        address developer;
        uint256 launchTime;
        bool isActive;
        uint256 ethBalance;    // New field
        uint256 tokenBalance;  // New field
    }

    // Add mapping for quick token info lookup
    mapping(address => TokenInfo) public tokenInfo;
    
    // Add sorting/filtering helpers
    mapping(uint256 => address) public tokenByIndex;
    uint256 public totalTokens;

    mapping(address => uint256) public tokensPerWallet;
    uint256 constant MAX_TOKENS = 10;

    function createToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory image,
        string memory twitter,
        string memory telegram,
        string memory website
    ) public {
        require(tokensPerWallet[msg.sender] < MAX_TOKENS);
        IERC20 UniFarmToken = IERC20(UniFarmS_TOKEN);
        require(UniFarmToken.balanceOf(msg.sender) >= requiredTokens, "Must hold required tokens");
        
        UniFarmTokenLaunch newToken = new UniFarmTokenLaunch(name, symbol, description, image, twitter, telegram, website, msg.sender);
        address tokenAddress = address(newToken);
        
        // Update token info with balances
        tokenInfo[tokenAddress] = TokenInfo({
            tokenAddress: tokenAddress,
            name: name,
            symbol: symbol,
            description: description,
            image: image,
            twitter: twitter,
            telegram: telegram,
            website: website,
            developer: msg.sender,
            launchTime: block.timestamp,
            isActive: true,
            ethBalance: 0,    // Initial balance
            tokenBalance: 0    // Initial balance
        });

        tokenByIndex[totalTokens] = tokenAddress;
        totalTokens++;
        
        deployedTokens.push(tokenAddress);
        emit TokenCreated(tokenAddress, name, symbol, description, image, twitter, telegram, website, msg.sender);
    }

    function getDeployedTokens() public view returns (address[] memory) {
        return deployedTokens;
    }

    // Update getTokensPaginated to refresh balances before returning
    function getTokensPaginated(uint256 start, uint256 size) 
        external 
        view 
        returns (
            TokenInfo[] memory tokens,
            uint256 total
        ) 
    {
        uint256 end = start + size;
        if (end > totalTokens) {
            end = totalTokens;
        }
        
        tokens = new TokenInfo[](end - start);
        for (uint256 i = start; i < end; i++) {
            TokenInfo memory token = tokenInfo[tokenByIndex[i]];
            // Update balances before returning
            token.ethBalance = address(token.tokenAddress).balance;
            token.tokenBalance = IERC20(token.tokenAddress).balanceOf(address(token.tokenAddress));
            tokens[i - start] = token;
        }
        
        return (tokens, totalTokens);
    }

    

    // Update getTokensByDeveloper to include current balances
    function getTokensByDeveloper(address developer) 
        external 
        view 
        returns (TokenInfo[] memory) 
    {
        TokenInfo[] memory result = new TokenInfo[](totalTokens);
        uint256 count = 0;
        
        for (uint256 i = 0; i < totalTokens; i++) {
            TokenInfo memory token = tokenInfo[tokenByIndex[i]];
            if (token.developer == developer) {
                // Update balances before adding to results
                token.ethBalance = address(token.tokenAddress).balance;
                token.tokenBalance = IERC20(token.tokenAddress).balanceOf(address(token.tokenAddress));
                result[count] = token;
                count++;
            }
        }
        
        // Trim array to actual size
        TokenInfo[] memory trimmedResult = new TokenInfo[](count);
        for (uint256 i = 0; i < count; i++) {
            trimmedResult[i] = result[i];
        }
        
        return trimmedResult;
    }

    // Helper function for string comparison
    function contains(string memory source, string memory search) 
        internal 
        pure 
        returns (bool) 
    {
        return keccak256(abi.encodePacked(source)) == keccak256(abi.encodePacked(search));
    }
}

contract UniFarmTokenLaunch is Context, IERC7802, IERC20, Ownable(address(this)) {
    using SafeMath for uint256;
    
    address public immutable factory;
    string public description;
    string public image;
    string public twitter;
    string public telegram;
    string public website;
    address public developer;
    
    uint256 private constant TAX_DURATION = 2 hours;
    uint256 private constant INITIAL_SELL_TAX = 30;
    uint256 private constant FINAL_SELL_TAX = 2;
    uint256 public addLiquidityStart;
    uint256 private _buyCount = 0;
    uint256 private _preventSwapBefore = 10;

    address private UniFarmswapV2Pair;
    IUniFarmswapV2Router02 private UniFarmswapV2Router;
    bool public tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    
    mapping(address => bool) private _isExcludedFromFee;
    
    uint256 private constant AUTO_LP_THRESHOLD = 0.99 ether;
    uint256 public constant _taxSwapThreshold = 6000000 * 10**18;
    uint256 public constant _maxTaxSwap = 6000000 * 10**18;
    
    address payable private constant _UniFarmSwap = payable(0xC6dA9DBfFCD77E26d55543C9d956E85FD6D48359);
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;

    uint256 immutable maxSupply = 1_000_000_000e18;

    uint256 public constant LAUNCH_DEADLINE = 24 hours;  // or your preferred duration
    uint256 public launchStart;
    bool public launchFailed;

    mapping(address => uint256) public presaleContributions;
    mapping(address => uint256) public userBuyTime;  // Track when each user bought
    uint256 public totalContributions;
    bool public presaleFinalized;

    // Add dead address constant
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // Add state variables
    mapping(address => uint256) public totalUserBuys;  // Track total buys per user
    uint256 public constant MAX_WALLET_PRESALE = 0.1 ether;  // Max 0.1 ETH total per wallet
    uint256 public constant BLOCKS_BETWEEN_BUYS = 10;  // Must wait 10 blocks between buys
    mapping(address => uint256) public lastBuyBlock;  // Track last buy block per user

    // Add new events near other event declarations
    event LaunchStarted(uint256 timestamp, uint256 deadline);
    event LaunchFinalized(uint256 timestamp, uint256 totalContributions);
    event LaunchFailed(uint256 timestamp);

    // Add at top of contract with other state variables
    mapping(address => address) public referrers;          // user -> their referrer
    mapping(address => uint256) public referralEarnings;   // referrer -> total earnings
    mapping(address => uint256) public totalReferrals;     // referrer -> number of referrals
    uint256 public constant REFERRAL_PERCENT = 5;         // 5% of buy goes to referrer
    address public topReferrer;                            // referrer with most referrals
    uint256 public mostReferrals;                         // highest referral count

    // Add new events
    event ReferralPaid(address indexed referrer, address indexed buyer, uint256 amount);
    event TopReferrerChanged(address indexed newTopReferrer, uint256 totalReferrals);
    event PriceUpdate(uint256 timestamp, uint256 price);

    // Mapping to track price per block
    mapping(uint256 => uint256) public pricePerBlock;

    // Track claimed refunds
    mapping(address => bool) public hasClaimedRefund;
    
    // Event for refund claims
    event RefundClaimed(address indexed user, uint256 tokenAmount, uint256 ethAmount);

    modifier onlyDeveloper() {
        require(msg.sender == developer, "Only dev");
        _;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transferCustom(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
        _updateBalance(account, _balances[account].add(amount));
        emit Transfer(address(0), account, amount);
    }

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        string memory _description,
        string memory _image,
        string memory _twitter,
        string memory _telegram,
        string memory _website,
        address _developer
    ) {
        factory = msg.sender;
        _name = tokenName;
        _symbol = tokenSymbol;
        description = _description;
        image = _image;
        twitter = _twitter;
        telegram = _telegram;
        website = _website;
        developer = _developer;
        
        _isExcludedFromFee[_developer] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _mint(address(this), 1_000_000_000e18);
        
        UniFarmswapV2Router = IUniFarmswapV2Router02(0xdD579594aF656E03e6767AE4EE116Ee9e1FA0Dd2);
        
        launchStart = block.timestamp;
        emit LaunchStarted(launchStart, launchStart + LAUNCH_DEADLINE);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transferCustom(_msgSender(), recipient, amount);
        return true;
    }

    function _transferCustom(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0) && to != address(0) && amount > 0, "!params");
        
        // Early protection for presale participants
        if (presaleContributions[from] > 0) {
            require(block.timestamp >= launchStart + 10 minutes, "locked");
        }
        
        uint256 taxAmount = 0;
        
        if (from != developer && to != developer) {
            if (from == UniFarmswapV2Pair && to != address(UniFarmswapV2Router) && !_isExcludedFromFee[to]) {
                _buyCount++;
            }
            
            if (to == UniFarmswapV2Pair && from != address(this)) {
                require(tradingOpen, "!trade");
                if (block.timestamp > addLiquidityStart) {
                    uint256 timeSinceAddLiquidity = block.timestamp - addLiquidityStart;
                    if (timeSinceAddLiquidity < TAX_DURATION) {
                        uint256 taxReduction = (INITIAL_SELL_TAX - FINAL_SELL_TAX) * timeSinceAddLiquidity / TAX_DURATION;
                        taxAmount = amount.mul(INITIAL_SELL_TAX - taxReduction).div(100);
                    } else {
                        taxAmount = amount.mul(FINAL_SELL_TAX).div(100);
                    }
                }
            }

            if (!inSwap && 
                to == UniFarmswapV2Pair && 
                swapEnabled && 
                _buyCount > _preventSwapBefore) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if (contractTokenBalance > _taxSwapThreshold) {
                    swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                    uint256 contractETHBalance = address(this).balance;
                    if (contractETHBalance > 0) {
                        sendETHToFee(contractETHBalance);
                    }
                }
            }
        }

        if (taxAmount > 0) {
            _updateBalance(address(this), _balances[address(this)].add(taxAmount));
            emit Transfer(from, address(this), taxAmount);
        }
        
        _updateBalance(from, _balances[from].sub(amount));
        _updateBalance(to, _balances[to].add(amount.sub(taxAmount)));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function sendETHToFee(uint256 amount) private {
        uint256 split = amount / 2;
        _UniFarmSwap.transfer(split);
        payable(developer).transfer(amount - split);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0 || !tradingOpen) return;
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniFarmswapV2Router.WETH();
        
        _approve(address(this), address(UniFarmswapV2Router), tokenAmount);
        
        UniFarmswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 ethAmount, uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) return;

        _approve(address(this), address(UniFarmswapV2Router), tokenAmount);
        
        UniFarmswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );

        if (!tradingOpen) {
            swapEnabled = true;
            tradingOpen = true;
            
            // Transfer LP tokens after they're received
            uint256 lpBalance = IERC20(UniFarmswapV2Pair).balanceOf(address(this));
            if (lpBalance > 0) {
                // Approve transfer of LP tokens
                IERC20(UniFarmswapV2Pair).approve(address(this), lpBalance);
                // Burn LP tokens by sending to dead address
                IERC20(UniFarmswapV2Pair).transfer(DEAD, lpBalance);
            }
            
            renounceOwnership();
            
            addLiquidityStart = block.timestamp;
        }
    }

    function manualSwap() external {
        require(msg.sender == developer, "Only dev");
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    receive() external payable {}

    function getCurrentPrice() public view returns (uint256 tokensPerETH) {
        uint256 remainingSupply = balanceOf(address(this));
        uint256 soldSupply = _totalSupply - remainingSupply;
        
        // Base price: Start at 510M tokens per ETH
        uint256 basePrice = 510_000_000 * 1e18;
        uint256 presaleAllocation = basePrice; // 510M tokens for presale
        
        // Calculate percentage sold (0-10000) based on presale allocation
        uint256 soldPercentage = (soldSupply * 10000) / presaleAllocation;
        
        // Linear price increase: tokens per ETH decreases as more is sold
        // Start at 100% of base tokens per ETH, decrease to 60% (price increases by 66%)
        uint256 priceMultiplier = 1000 - (soldPercentage * 400 / 10000); // 1000 to 600
        tokensPerETH = basePrice.mul(priceMultiplier).div(1000);
        
        return tokensPerETH;
    }
    
    // Helper function to calculate square root
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        
        return y;
    }

    function quoteBuy(uint256 _ethAmount) public view returns (uint256 tokensOut) {
        uint256 remainingSupply = balanceOf(address(this));
        require(remainingSupply > 0, "No tokens left");
        require(totalContributions + _ethAmount <= 1 ether, "Exceeds cap");
        
        uint256 currentPrice = getCurrentPrice();
        tokensOut = _ethAmount * currentPrice / 1e18;
        
        if (tokensOut > remainingSupply) {
            tokensOut = remainingSupply;
        }
    }

    function quoteSell(uint256 _tokenAmount) public view returns (uint256 ethOut) {
        // Get current price in tokens per ETH
        uint256 currentPrice = getCurrentPrice();
        
        // Calculate ETH output (tokens * (1 ETH / tokens_per_ETH)) with 5% slippage
        ethOut = (_tokenAmount.mul(1e18).mul(95)) / (currentPrice.mul(100));
        
        // Cap at 90% of contract balance to maintain reserves
        uint256 maxOutput = address(this).balance.mul(90) / 100;
        if (ethOut > maxOutput) {
            ethOut = maxOutput;
        }
    }

    function buyTokens(address _urlReferrer) public payable {
        require(!launchFailed, "Launch failed");
        require(block.timestamp <= launchStart + LAUNCH_DEADLINE, "Launch ended");
        require(msg.value >= 0.005 ether, "Min 0.005 ETH");
        require(msg.value <= 0.1 ether, "Max 0.1 ETH per tx");
        require(presaleContributions[msg.sender] + msg.value <= 0.1 ether, "Max 0.1 ETH total per wallet");
        require(!presaleFinalized, "Presale ended");

        // Send 1% to _UniFarmSwap and 1% to referrer if exists
        uint256 UniFarmSwapFee = msg.value * 1 / 100;
        (bool success,) = _UniFarmSwap.call{value: UniFarmSwapFee}("");
        require(success, "UniFarmSwap fee transfer failed");

        // Set the buy time for the 10-minute sell lockup
        userBuyTime[msg.sender] = block.timestamp;
        
        // Automatically set referrer from URL if not already set
        address referrer = referrers[msg.sender];
        if (referrer == address(0) && _urlReferrer != address(0) && _urlReferrer != msg.sender) {
            referrers[msg.sender] = _urlReferrer;
            referrer = _urlReferrer;
            totalReferrals[referrer]++;
            
            // Update top referrer if needed
            if(totalReferrals[referrer] > mostReferrals) {
                mostReferrals = totalReferrals[referrer];
                topReferrer = referrer;
                emit TopReferrerChanged(referrer, mostReferrals);
            }
        }
        
        // Send referral fee if referrer exists
        uint256 referralFee = 0;
        if (referrer != address(0)) {
            referralFee = msg.value * REFERRAL_PERCENT / 100;  // Use REFERRAL_PERCENT constant
            (bool referralSuccess,) = referrer.call{value: referralFee}("");
            require(referralSuccess, "Referral fee transfer failed");
            emit ReferralPaid(referrer, msg.sender, referralFee);
        }
        
        // Handle referral payment
        uint256 buyAmount = msg.value - UniFarmSwapFee - referralFee;
        
        // Get current price and emit price update event
        uint256 currentPrice = getCurrentPrice();
        emit PriceUpdate(block.timestamp, currentPrice);
        
        // Update total contributions
        totalContributions += buyAmount;
        presaleContributions[msg.sender] += buyAmount;
        
        uint256 tokensPerETH = getCurrentPrice();
        uint256 tokenAmount = buyAmount * tokensPerETH / 1e18;
        require(balanceOf(address(this)) > tokenAmount, "sold out");
        
        _updateBalance(address(this), _balances[address(this)].sub(tokenAmount));
        _updateBalance(msg.sender, _balances[msg.sender].add(tokenAmount));
        emit Transfer(address(this), msg.sender, tokenAmount);
    }

    function finalizeLaunch() public onlyDeveloper {
        require(!presaleFinalized, "Already finalized");
        require(address(this).balance >= AUTO_LP_THRESHOLD, "Insufficient ETH");
        require(block.timestamp <= launchStart + LAUNCH_DEADLINE, "Launch period ended");
        require(!launchFailed, "Launch has failed");
        
        // Create the trading pair
        UniFarmswapV2Pair = IUniFarmswapV2Factory(UniFarmswapV2Router.factory())
            .createPair(address(this), UniFarmswapV2Router.WETH());
        
        // Approve router to spend tokens
        _approve(address(this), address(UniFarmswapV2Router), type(uint256).max);
        
        presaleFinalized = true;
        uint256 totalTokensInContract = balanceOf(address(this));
        uint256 ethForLP = address(this).balance;
        
        // Calculate the final presale price
        uint256 finalPresalePrice = getCurrentPrice();
        
        // Add 20% premium to final presale price for LP
        uint256 lpPrice = finalPresalePrice.mul(80).div(100); // 20% less tokens per ETH = higher price
        
        // Calculate tokens for LP based on final price plus premium
        uint256 tokensForLP = ethForLP.mul(lpPrice).div(1e18);
        
        require(tokensForLP <= totalTokensInContract, "Not enough tokens");
        
        // Add to LP with calculated ratio
        addLiquidity(ethForLP, tokensForLP);
        
        // Burn all remaining tokens
        uint256 remainingTokens = balanceOf(address(this));
        if (remainingTokens > 0) {
            _burn(address(this), remainingTokens);
        }
        
        emit LaunchFinalized(block.timestamp, totalContributions);
    }

    function sellTokens(uint256 _tokenAmount) public {
        require(!presaleFinalized, "Presale ended - use DEX");
        require(block.timestamp >= userBuyTime[msg.sender] + 10 minutes, "Cannot sell within 10 minutes of buying");
        require(balanceOf(msg.sender) >= _tokenAmount, "Insufficient balance");
        
        // Get sell quote with slippage
        uint256 ethAmount = quoteSell(_tokenAmount);
        require(ethAmount > 0, "Zero ETH output");
        require(address(this).balance >= ethAmount, "Insufficient contract balance");
        
        // Calculate and send 1% to _UniFarmSwap    
        uint256 UniFarmSwapFee = ethAmount * 1 / 100;
        uint256 userAmount = ethAmount - UniFarmSwapFee;
        (bool UniFarmSwapSuccess,) = _UniFarmSwap.call{value: UniFarmSwapFee}("");
        require(UniFarmSwapSuccess, "UniFarmSwap fee transfer failed");
        
        // Transfer tokens first
        _updateBalance(msg.sender, _balances[msg.sender].sub(_tokenAmount));
        _updateBalance(address(this), _balances[address(this)].add(_tokenAmount));
        
        // Update total contributions
        totalContributions = totalContributions.sub(ethAmount);
        
        // Then transfer ETH to user (minus the fee)
        (bool success,) = payable(msg.sender).call{value: userAmount}("");
        require(success, "ETH transfer failed");
        
        // Get current price and emit price update event
        uint256 currentPrice = getCurrentPrice();
        emit PriceUpdate(block.timestamp, currentPrice);
        
        emit Transfer(msg.sender, address(this), _tokenAmount);
    }

    function claimRefund() external {
        require(block.timestamp > launchStart + LAUNCH_DEADLINE, "Launch still active");
        require(address(this).balance < 2 ether, "Launch successful");
        require(!tradingOpen, "Trading already open");
        require(!hasClaimedRefund[msg.sender], "Already claimed refund");
        
        uint256 userBalance = _balances[msg.sender];
        require(userBalance > 0, "No tokens to refund");
        
        // Get user's contribution amount for fair refund calculation
        uint256 userContribution = presaleContributions[msg.sender];
        require(userContribution > 0, "No contribution found");
        
        // Calculate pro-rata share of remaining ETH
        uint256 ethRefund = (userContribution * address(this).balance) / totalContributions;
        
        // Mark as claimed before transfer to prevent reentrancy
        hasClaimedRefund[msg.sender] = true;
        
        // Update balances
        _updateBalance(msg.sender, 0);
        _updateBalance(address(this), _balances[address(this)].add(userBalance));
        
        // Transfer ETH refund
        payable(msg.sender).transfer(ethRefund);
        
        emit RefundClaimed(msg.sender, userBalance, ethRefund);
        
        // Set launchFailed only after first successful refund
        if (!launchFailed) {
            launchFailed = true;
        }
    }

    // Add new getters
    function getLaunchInfo() public view returns (
        uint256 startTime,
        uint256 endTime,
        uint256 totalRaised,
        bool isFinalized,
        bool isFailed,
        uint256 minContribution,
        uint256 maxContribution,
        uint256 targetAmount,
        uint256 currentPrice
    ) {
        return (
            launchStart,
            launchStart + LAUNCH_DEADLINE,
            totalContributions,
            presaleFinalized,
            launchFailed,
            0.01 ether, // min contribution
            0.1 ether,   // max contribution
            1 ether,     // target amount
            getCurrentPrice()
        );
    }

    // Add function to set referrer
    function setReferrer(address _referrer) external {
        require(_referrer != msg.sender, "Cannot refer yourself");
        require(_referrer != address(0), "Invalid referrer");
        require(referrers[msg.sender] == address(0), "Referrer already set");
        
        referrers[msg.sender] = _referrer;
        totalReferrals[_referrer]++;
        
        // Update top referrer if needed
        if(totalReferrals[_referrer] > mostReferrals) {
            mostReferrals = totalReferrals[_referrer];
            topReferrer = _referrer;
            emit TopReferrerChanged(_referrer, mostReferrals);
        }
    }

    // Add view functions for UI
    function getReferralStats(address _user) external view returns (
        uint256 earnings,
        uint256 referralCount,
        bool isTopReferrer
    ) {
        return (
            referralEarnings[_user],
            totalReferrals[_user],
            _user == topReferrer
        );
    }

    function getUserInfo(address user) public view returns (
        uint256 balance,
        uint256 buyTime,
        uint256 ethContributed,
        bool canSell,
        uint256 timeUntilSell
    ) {
        balance = balanceOf(user);
        buyTime = userBuyTime[user];
        ethContributed = presaleContributions[user];
        
        if (buyTime == 0) {
            canSell = false;
            timeUntilSell = 0;
        } else {
            uint256 sellUnlockTime = buyTime + 10 minutes;
            canSell = block.timestamp >= sellUnlockTime;
            timeUntilSell = block.timestamp >= sellUnlockTime ? 
                0 : 
                sellUnlockTime - block.timestamp;
        }
        
        return (balance, buyTime, ethContributed, canSell, timeUntilSell);
    }

    function updateDescription(string memory _description) external onlyDeveloper {
        description = _description;
    }

    function updateImage(string memory _image) external onlyDeveloper {
        image = _image;
    }

    function updateTwitter(string memory _twitter) external onlyDeveloper {
        twitter = _twitter;
    }

    function updateTelegram(string memory _telegram) external onlyDeveloper {
        telegram = _telegram;
    }

    function updateWebsite(string memory _website) external onlyDeveloper {
        website = _website;
    }

    // Internal function to update balances without factory check
    function _updateBalance(address account, uint256 newBalance) internal {
        _balances[account] = newBalance;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount is greater than balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

     function crosschainMint(address _to, uint256 _amount) external {
        // Only the `SuperchainTokenBridge` has permissions to mint tokens during crosschain transfers.
        if (msg.sender != Predeploys.SUPERCHAIN_TOKEN_BRIDGE) revert Unauthorized();
        
        // Mint tokens to the `_to` account's balance.
        _mint(_to, _amount);

        // Emit the CrosschainMint event included on IERC7802 for tracking token mints associated with cross chain transfers.
        emit CrosschainMint(_to, _amount, msg.sender);
    }

    function crosschainBurn(address _from, uint256 _amount) external {
        // Only the `SuperchainTokenBridge` has permissions to burn tokens during crosschain transfers.
        if (msg.sender != Predeploys.SUPERCHAIN_TOKEN_BRIDGE) revert Unauthorized();

        // Burn the tokens from the `_from` account's balance.
        _burn(_from, _amount);

        // Emit the CrosschainBurn event included on IERC7802 for tracking token burns associated with cross chain transfers.
        emit CrosschainBurn(_from, _amount, msg.sender);
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual returns (bool) {
        return _interfaceId == type(IERC7802).interfaceId || _interfaceId == type(IERC20).interfaceId
            || _interfaceId == type(IERC165).interfaceId;
    }

    function renounceOwnership() public virtual override {
        _transferOwnership(address(0));
    }
}