// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pool.sol";
import "./Token.sol";

contract Factory {
    address public owner;
    address[] public allPools;
    mapping(address => mapping(address => address)) public getPool;
    address public lpTokenAddress;
    
    event PoolCreated(address indexed token0, address indexed token1, address pool, uint256);

    constructor(address _lpTokenAddress) {
        owner = msg.sender;
        lpTokenAddress = _lpTokenAddress;
    }
    
    function allPoolsLength() external view returns (uint256) {
        return allPools.length;
    }
    
    function createPool(address tokenA, address tokenB) external returns (address pool) {
        require(tokenA != tokenB, "Factory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Factory: ZERO_ADDRESS");
        require(getPool[token0][token1] == address(0), "Factory: POOL_EXISTS");
        
        Pool newPool = new Pool(token0, token1, lpTokenAddress, msg.sender);
        
        pool = address(newPool);
        getPool[token0][token1] = pool;
        getPool[token1][token0] = pool; 
        allPools.push(pool);
        
        emit PoolCreated(token0, token1, pool, allPools.length);
        return pool;
    }
}