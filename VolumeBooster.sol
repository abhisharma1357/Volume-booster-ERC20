// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract VolumeBooster {
    address public owner;
    IUniswapV2Router02 public uniswapRouter;

    event EthDeposited(address indexed sender, uint256 amount);
    event EthWithdrawn(address indexed owner, uint256 amount);
    event BuySellExecuted(address indexed token, uint256 ethSpent, uint256 tokensBought);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _uniswapRouter) {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
    }

    // Function to accept ETH and store in the contract
    receive() external payable {
        emit EthDeposited(msg.sender, msg.value);
    }

    // Function to withdraw ETH to the owner
    function withdrawEth(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(owner).transfer(_amount);
        emit EthWithdrawn(owner, _amount);
    }

    /**
     * @dev Executes a buy-sell transaction on Uniswap in one go
     * @param _tokenAddress The address of the ERC20 token
     * @param _ethAmount The amount of ETH to use for buying the token
     */
    function executeBuySell(address _tokenAddress, uint256 _ethAmount) external onlyOwner {
        require(address(this).balance >= _ethAmount, "Insufficient ETH balance");

        // Define the path for buying and selling: ETH -> Token -> ETH
        address;
        path[0] = uniswapRouter.WETH();
        path[1] = _tokenAddress;

        // Buy tokens
        uint256[] memory amounts = uniswapRouter.swapExactETHForTokens{value: _ethAmount}(
            0, // accept any amount of Tokens
            path,
            address(this), // tokens go to this contract
            block.timestamp + 15 // deadline is 15 seconds from now
        );

        uint256 tokensBought = amounts[1];

        // Approve Uniswap router to spend the tokens
        IERC20(_tokenAddress).approve(address(uniswapRouter), tokensBought);

        // Sell tokens back to ETH
        path[0] = _tokenAddress;
        path[1] = uniswapRouter.WETH();

        uniswapRouter.swapExactTokensForETH(
            tokensBought,
            0, // accept any amount of ETH
            path,
            address(this), // ETH goes back to this contract
            block.timestamp + 15 // deadline is 15 seconds from now
        );

        emit BuySellExecuted(_tokenAddress, _ethAmount, tokensBought);
    }
}
