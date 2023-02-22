//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract CPAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    //mint shares
    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    //burn shares
    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    //swap tokens
    function swap(address _tokenIn, uint256 _amountIn)
        external
        returns (uint256 amountOut)
    {
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "Invalid token"
        );
        require(_amountIn > 0, "Cannot swap zero token");

        //determine which token is coming into the liquidity pool
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        //Pull in token
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        //calculate tokenOut including fee 0.3%
        uint256 amountWithFee = (_amountIn * 997) / 1000;
        // dy = ydx / (x + dx)
        amountOut = (reserve1 * amountWithFee) / (reserve0 + amountWithFee);

        //transfer it to msg.sender
        tokenOut.transfer(msg.sender, amountOut);
    }

    //add liquidity
    function addLiquidity() external {}

    //remove liquidity
    function removeLiquidity() external {}
}

