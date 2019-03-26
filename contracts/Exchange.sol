pragma solidity ^0.4.17;
/**
This is the core module of the system. Currently it holds the code of
the Bank and crowdsale modules to avoid external calls and higher gas costs.
It might be a good idea in the future to split the code, separate Bank
and crowdsale modules into external files and have the core interact with them
with addresses and interfaces. 
*/
import "./iERC20Token.sol";
import "./CurrencyToken.sol";
import "./DepositContract.sol";
import "./SafeMath.sol";
import "./DataManager.sol";
import "./ERC1155.sol";
import "./withAccessManager.sol";

/// @title Exchange contract
contract Exchange is withAccessManager {
    // EVENTS
    // Bank events
    event EventWithdrawEther(bytes32 _blockchainActionId, address ether_address, uint256 amount, bytes32 accountId, address depositContract, address to, uint pptFee);
    event EventWithdrawERC721(bytes32 _blockchainActionId, address erc721_tokenAddress, uint256 token_id, bytes32 accountId, address depositContract, address to, uint pptFee);
    event EventWithdrawPPT(bytes32 blockchainActionId, address pptAddress, uint amount, bytes32 accountId, address depositContract, address to);
    event EventNewDepositContract(bytes32 blockchainActionId, bytes32 clientId, address depositContractAddress, uint256 version);
    event EventWithdrawXAUp(bytes32 _blockchainActionId, address erc1155Token, uint token_id, uint amount, bytes32 accountId, address depositContract, address to, uint pptFee);

    // FIELDS
    struct tokens {   
        address _token;
        uint256 _precision;
    }
    mapping(bytes8 => tokens) public tokenDetails;

    // NON-CONSTANT METHODS
    // Constructor method called when contract instance is 
    // deployed with 'withAccessManager' modifier.
    constructor(address _accessManager) public withAccessManager(_accessManager) {
        //pxt
        tokenDetails[0x505854]._token = 0xc14830E53aA344E8c14603A91229A0b925b0B262;
        tokenDetails[0x505854]._precision = 8;
        //usdc
        tokenDetails[0x55534443]._token = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        tokenDetails[0x55534443]._precision = 6;
        //tusd
        tokenDetails[0x54555344]._token = 0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
        tokenDetails[0x54555344]._precision = 18;
        //ppt
        tokenDetails[0x505054]._token = 0xd4fa1460F537bb9085d22C7bcCB5DD450Ef28e3a;        
        tokenDetails[0x505054]._precision = 8;
        //xau
        tokenDetails[0x584155]._token = 0x73a3b7DFFE9af119621f8467D8609771AB4BC33f;
        tokenDetails[0x584155]._precision = 0;
    }

    /**
    BANK MODULE
    */
    // NON-CONSTANT METHODS

    // Creates a new 'depositAddress' gotten from deploying a deposit contract linked to a client ID
    function createAddress(address _dataManager, bytes32 _blockchainActionId, bytes32 clientId) 
        public
        onlyServer
    {   
        require(_dataManager != 0x0);
        DepositContract newDepositContract = new DepositContract(clientId, AM);
        require(DataManager(_dataManager).setDepositAddress(_blockchainActionId, newDepositContract, clientId) == true);
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, 0x0, 0, clientId, DataManager(_dataManager).getDepositAddress(clientId), 0) == true);
        EventNewDepositContract(_blockchainActionId, clientId, DataManager(_dataManager).getDepositAddress(clientId), newDepositContract.getVersion());
    }

    /** @dev Withdraw an amount of PPT Populous tokens to a blockchain address 
      * @param _blockchainActionId the blockchain action id
      * @param pptAddress the address of the PPT smart contract
      * @param accountId the account id of the client
      * @param pptFee the amount of fees to pay in PPT tokens
      * @param adminExternalWallet the platform admin wallet address to pay the fees to 
      * @param to the blockchain address to withdraw and transfer the pokens to
      * @param inCollateral the amount of pokens withheld by the platform
      */    
    function withdrawERC20(
        address _dataManager, bytes32 _blockchainActionId, 
        address pptAddress, bytes32 accountId, 
        address to, uint256 amount, uint256 inCollateral, 
        uint256 pptFee, address adminExternalWallet) 
        public 
        onlyServer 
    {   
        require(_dataManager != 0x0);
        require(DataManager(_dataManager).getActionStatus(_blockchainActionId) == false && DataManager(_dataManager).getDepositAddress(accountId) != 0x0);
        require(adminExternalWallet != 0x0 && pptFee > 0 && amount > 0);
        address depositContract = DataManager(_dataManager).getDepositAddress(accountId);
        if(pptAddress == tokenDetails[0x505054]._token) {
            uint pptBalance = SafeMath.safeSub(DepositContract(depositContract).balanceOf(tokenDetails[0x505054]._token), inCollateral);
            require(pptBalance >= SafeMath.safeAdd(amount, pptFee));
        } else {
            uint erc20Balance = DepositContract(depositContract).balanceOf(pptAddress);
            require(erc20Balance >= amount);
        }
        require(DepositContract(depositContract).transfer(tokenDetails[0x505054]._token, adminExternalWallet, pptFee) == true);
        require(DepositContract(depositContract).transfer(pptAddress, to, amount) == true);
        bytes32 tokenSymbol = iERC20Token(pptAddress).symbol();    
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, tokenSymbol, amount, accountId, to, pptFee) == true);
        emit EventWithdrawPPT(_blockchainActionId, pptAddress, amount, accountId, depositContract, to);
    }

    // ether withdraw function using transferEther in deposit contract
    function withdrawEther(
        address _dataManager, bytes32 _blockchainActionId,
        address _to, uint256 _value,
        bytes32 accountId, uint256 pptFee, 
        address adminExternalWallet) 
        public
        onlyServer 
    {
        require(DataManager(_dataManager).getActionStatus(_blockchainActionId) == false && DataManager(_dataManager).getDepositAddress(accountId) != 0x0);
        require(adminExternalWallet != 0x0 && pptFee > 0);
        DepositContract o = DepositContract(DataManager(_dataManager).getDepositAddress(accountId));
        // send ppt fee
        require(o.transfer(tokenDetails[0x505054]._token, adminExternalWallet, pptFee) == true);
        // transfer erc721 tokens to address from deposit contract
        require(o.transferEther(_to, _value) == true);
        // set action status in dataManager
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, 0x0, 0, accountId, _to, pptFee) == true);
        // emit event 
        emit EventWithdrawEther(_blockchainActionId, 0x0, _value, accountId, o, _to, pptFee);
    }

    // erc721 withdraw function using transferFrom in erc1155 token contract
    function withdrawERC721(
        address _dataManager, bytes32 _blockchainActionId,
        address _to, uint256 _id, address erc721Token, bytes32 erc721TokenSymbol,
        bytes32 accountId, uint256 pptFee, 
        address adminExternalWallet) 
        public
        onlyServer 
    {
        require(DataManager(_dataManager).getActionStatus(_blockchainActionId) == false && DataManager(_dataManager).getDepositAddress(accountId) != 0x0);
        require(adminExternalWallet != 0x0 && pptFee > 0);
        DepositContract o = DepositContract(DataManager(_dataManager).getDepositAddress(accountId));
        // send ppt fee
        require(o.transfer(tokenDetails[0x505054]._token, adminExternalWallet, pptFee) == true);
        // transfer erc721 tokens to address from deposit contract
        require(o.transferERC721(erc721Token, _to, _id) == true);
        // set action status in dataManager
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, erc721TokenSymbol, 0, accountId, _to, pptFee) == true);
        // emit event 
        emit EventWithdrawERC721(_blockchainActionId, tokenDetails[0x584155]._token, _id, accountId, o, _to, pptFee);
    }

    // erc1155 withdraw function using transferFrom in erc1155 token contract
    function withdrawERC1155(
        address _dataManager, bytes32 _blockchainActionId,
        address _to, uint256 _id, uint256 _value,
        bytes32 accountId, uint256 pptFee, 
        address adminExternalWallet) 
        public
        onlyServer 
    {
        require(DataManager(_dataManager).getActionStatus(_blockchainActionId) == false && DataManager(_dataManager).getDepositAddress(accountId) != 0x0);
        require(adminExternalWallet != 0x0 && pptFee > 0 && _value > 0);
        DepositContract o = DepositContract(DataManager(_dataManager).getDepositAddress(accountId));
        require(o.transfer(tokenDetails[0x505054]._token, adminExternalWallet, pptFee) == true);
        // transfer xaup tokens to address from deposit contract
        require(o.transferERC1155(tokenDetails[0x584155]._token, _to, _id, _value) == true);
        // set action status in dataManager
        require(DataManager(_dataManager).setBlockchainActionData(_blockchainActionId, 0x584155, _value, accountId, _to, pptFee) == true);
        // emit event 
        emit EventWithdrawXAUp(_blockchainActionId, tokenDetails[0x584155]._token, _id, _value, accountId, o, _to, pptFee);
    }
}