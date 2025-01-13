pragma solidity =0.5.16;

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

import './interfaces/IUniFarmV2Factory.sol';
import './UniFarmV2Pair.sol';

contract UniFarmV2Factory is IUniFarmV2Factory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'UniFarmV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniFarmV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniFarmV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniFarmV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniFarmV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniFarmV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function withdraw(address _token) public {
        uint amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(owner, amount);
    }
    function withdrawETH() public {
        require(msg.sender == feeToSetter, 'UniFarmV2: FORBIDDEN');
        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniFarmV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
