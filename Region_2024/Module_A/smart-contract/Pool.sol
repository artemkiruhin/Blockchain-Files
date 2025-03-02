// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";

contract Pool is Ownable {
    using SafeERC20 for IERC20;

    Token public token0;
    Token public token1;
    Token public lpToken;
    
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);

    constructor(
        address _token0,
        address _token1,
        address _lpToken,
        address _owner
    ) Ownable(_owner) {
        token0 = Token(_token0);
        token1 = Token(_token1);
        lpToken = Token(_lpToken);
    }

    function initialize(uint256 amount0, uint256 amount1) external onlyOwner {
        require(reserve0 == 0 && reserve1 == 0, "Pool: ALREADY_INITIALIZED");
        
        IERC20(address(token0)).safeTransferFrom(msg.sender, address(this), amount0);
        IERC20(address(token1)).safeTransferFrom(msg.sender, address(this), amount1);
        
        reserve0 = amount0;
        reserve1 = amount1;
    }
    
    function addLiquidity(uint256 amount0Desired, uint256 amount1Desired) external returns (uint256 lpAmount) {
        uint256 amount0;
        uint256 amount1;
        
        if (reserve0 == 0 && reserve1 == 0) {
            amount0 = amount0Desired;
            amount1 = amount1Desired;
        } else {
            uint256 amount1Optimal = quote(amount0Desired, reserve0, reserve1);
            
            if (amount1Optimal <= amount1Desired) {
                amount0 = amount0Desired;
                amount1 = amount1Optimal;
            } else {
                uint256 amount0Optimal = quote(amount1Desired, reserve1, reserve0);
                amount0 = amount0Optimal;
                amount1 = amount1Desired;
            }
        }
        
        IERC20(address(token0)).safeTransferFrom(msg.sender, address(this), amount0);
        IERC20(address(token1)).safeTransferFrom(msg.sender, address(this), amount1);
        
        uint256 totalSupply = lpToken.totalSupply();
        
        if (totalSupply == 0) {
            lpAmount = calculateValueInEth(amount0, amount1) / lpToken.priceInEth();
            lpToken.mint(msg.sender, lpAmount);
        } else {
            uint256 lpAmount0 = (amount0 * totalSupply) / reserve0;
            uint256 lpAmount1 = (amount1 * totalSupply) / reserve1;
            lpAmount = lpAmount0 < lpAmount1 ? lpAmount0 : lpAmount1;
            lpToken.mint(msg.sender, lpAmount);
        }
        
        reserve0 += amount0;
        reserve1 += amount1;
        
        emit Mint(msg.sender, amount0, amount1);
        
        return lpAmount;
    }
    
    function removeLiquidity(uint256 lpAmount) external returns (uint256 amount0, uint256 amount1) {
        lpToken.burn(msg.sender, lpAmount);
        
        uint256 totalSupply = lpToken.totalSupply();
        amount0 = (lpAmount * reserve0) / totalSupply;
        amount1 = (lpAmount * reserve1) / totalSupply;
        
        IERC20(address(token0)).safeTransfer(msg.sender, amount0);
        IERC20(address(token1)).safeTransfer(msg.sender, amount1);
        
        reserve0 -= amount0;
        reserve1 -= amount1;
        
        emit Burn(msg.sender, amount0, amount1, msg.sender);
        
        return (amount0, amount1);
    }
    
    function swap(uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address to) external {
        require(amount0Out > 0 || amount1Out > 0, "Pool: INSUFFICIENT_OUTPUT_AMOUNT");
        require(amount0Out < reserve0 && amount1Out < reserve1, "Pool: INSUFFICIENT_LIQUIDITY");
        
        if (amount0In > 0) {
            IERC20(address(token0)).safeTransferFrom(msg.sender, address(this), amount0In);
        }
        if (amount1In > 0) {
            IERC20(address(token1)).safeTransferFrom(msg.sender, address(this), amount1In);
        }
        
        uint256 balance0 = reserve0 + amount0In - amount0Out;
        uint256 balance1 = reserve1 + amount1In - amount1Out;
        require(balance0 * balance1 >= reserve0 * reserve1, "Pool: K");
        
        if (amount0Out > 0) {
            IERC20(address(token0)).safeTransfer(to, amount0Out);
        }
        if (amount1Out > 0) {
            IERC20(address(token1)).safeTransfer(to, amount1Out);
        }
        
        reserve0 = balance0;
        reserve1 = balance1;
        
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function calculateValueInEth(uint256 amount0, uint256 amount1) public view returns (uint256) {
        return (amount0 * token0.priceInEth() / (10 ** token0.decimals())) + 
               (amount1 * token1.priceInEth() / (10 ** token1.decimals()));
    }
    
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) public pure returns (uint256 amountB) {
        require(amountA > 0, "Pool: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "Pool: INSUFFICIENT_LIQUIDITY");
        amountB = (amountA * reserveB) / reserveA;
    }
    
    function getPoolInfo() public view returns (
        address token0Address,
        address token1Address,
        uint256 reserve0Amount,
        uint256 reserve1Amount
    ) {
        return (address(token0), address(token1), reserve0, reserve1);
    }
}
