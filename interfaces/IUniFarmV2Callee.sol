pragma solidity >=0.5.0;

interface IUniFarmV2Callee {
    function uniFarmV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
