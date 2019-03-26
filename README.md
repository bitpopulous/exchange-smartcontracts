# exchange-smartcontracts
Smart contracts for exchange platform


## Ropsten Test Network Smart Contract Addresses



Platform Admin/Server Address - `0xf8b3d742b245ec366288160488a12e7a2f1d720d`

## Live Network Smart Contract Addresses


PXT token - `0xc14830e53aa344e8c14603a91229a0b925b0b262`, precision - 8

USDC token - `0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48`, precision - 6

TUSD token - `0x8dd5fbce2f6a956c3022ba3663759011dd51e73e`, precision - 18

XAU (ERC1155Mintable.sol) token - `0x73a3b7dffe9af119621f8467d8609771ab4bc33f`, precision - 0


GBPp token- `0xc1e50afcd71a09f81f1b4e4daa1d1a1a4d678d2a`, precision - 6

AccessManager.sol - `0x98ca4bf7e522cd6d2f69cf843dfab327a1e26497`   
PopulousToken.sol - `0xd4fa1460f537bb9085d22c7bccb5dd450ef28e3a`      
SafeMath.sol - ``          
Exchange.sol - ``    
DataManager.sol - `0xcd565ca18f06e2e4d251b55dc49a4fe456c72052`       
Utils.sol - `0xcab23f0118f87d01a6d2fd3d93aeeaca789c8fb7`

Platform Admin/Server Address - `0x63d509f7152769ddf162ed048b83719fe1e31080`




`truffle@v4.0.0-beta.2`

for ppt transfer to `DepositContract.sol` on the livenet, `39-40 thousand GWei` is required for Gas Limit/Costs

`gas:` 8000000
`gasPrice:` 100000000000

command to unlock account in truffle console - e.g., `web3.personal.unlockAccount(web3.eth.coinbase, 'password', '0x5460')` with time in hex `0x5460` = `21,600 seconds`

note: before redeploying `Exchange.sol`, delete `Exchange.json and DepositContract.json` in the `build/contracts/` directory first and verify Access Manager `AM()` is set after deployment.

if livenet deployment fails, check transaction queue and if queue is high, remove account and replace with a new one with an empty transaction queue.
