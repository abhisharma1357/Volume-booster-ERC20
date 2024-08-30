# Volume-booster-ERC20
a smart contract that can buy and sell ERC20 tokens in one transaction on decentralized exchanges like Uniswap
Deposit ETH:

The contract can receive ETH using the receive() function, which allows it to accept ETH and emit an event for logging deposits.
Withdraw ETH:

The withdrawEth function allows the contract owner to withdraw ETH from the contract, ensuring that only the owner can perform this action.
Buy-Sell Execution:

The executeBuySell function performs a buy-sell transaction on Uniswap in a single call. It takes:
_tokenAddress: The address of the ERC20 token to be traded.
_ethAmount: The amount of ETH to be used for the buy transaction.
It buys the token with ETH, approves the Uniswap router to spend the tokens, and then immediately sells them back to ETH.
Emits an event BuySellExecuted with details of the transaction.
