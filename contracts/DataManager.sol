pragma solidity ^0.4.17;


import "./iERC20Token.sol";
import "./CurrencyToken.sol";
import "./withAccessManager.sol";
import "./iDataManager.sol";

/// @title DataManager contract
contract DataManager is iDataManager, withAccessManager {
    

    // NON-CONSTANT METHODS

    /** @dev Constructor that sets the server when contract is deployed.
      * @param _accessManager The address to set as the access manager.
      */
    constructor(address _accessManager, uint256 _version) public withAccessManager(_accessManager) {
        version = _version;
    }

    /** @dev Adds a new currency sumbol and smart contract address  
      * @param _currencyAddress the currency smart contract address
      * @param _currencySymbol the currency symbol
      * @return success true/false denoting successful function call
      */
    function setCurrency(bytes32 _blockchainActionId, address _currencyAddress, bytes32 _currencySymbol) public onlyServerOrOnlyPopulous returns (bool success) {
        require(actionStatus[_blockchainActionId] == false);
        require(currencySymbols[_currencyAddress] == 0x0 && currencyAddresses[_currencySymbol] == 0x0);
        currencySymbols[_currencyAddress] = _currencySymbol;
        currencyAddresses[_currencySymbol] = _currencyAddress;
        assert(currencyAddresses[_currencySymbol] != 0x0 && currencySymbols[_currencyAddress] != 0x0);
        return true;
    }

    /** @dev Updates a currency sumbol and smart contract address  
      * @param _currencyAddress the currency smart contract address
      * @param _currencySymbol the currency symbol
      * @return success true/false denoting successful function call
      */
    function _setCurrency(bytes32 _blockchainActionId, address _currencyAddress, bytes32 _currencySymbol) public onlyServerOrOnlyPopulous returns (bool success) {
        require(actionStatus[_blockchainActionId] == false);
        currencySymbols[_currencyAddress] = _currencySymbol;
        currencyAddresses[_currencySymbol] = _currencyAddress;
        assert(currencyAddresses[_currencySymbol] != 0x0 && currencySymbols[_currencyAddress] != 0x0);
        setBlockchainActionData(_blockchainActionId, _currencySymbol, 0, 0x0, _currencyAddress, 0);
        return true;
    }

    /** @dev set blockchain action data in struct 
      * @param _blockchainActionId the blockchain action id
      * @param currency the token currency symbol
      * @param accountId the clientId
      * @param to the blockchain address or smart contract address used in the transaction
      * @param amount the amount of tokens in the transaction
      * @return success true/false denoting successful function call
      */
    function setBlockchainActionData(
        bytes32 _blockchainActionId, bytes32 currency, 
        uint amount, bytes32 accountId, address to, uint pptFee) 
        public
        onlyServerOrOnlyPopulous 
        returns (bool success)
    {
        require(actionStatus[_blockchainActionId] == false);
        blockchainActionIdData[_blockchainActionId].currency = currency;
        blockchainActionIdData[_blockchainActionId].amount = amount;
        blockchainActionIdData[_blockchainActionId].accountId = accountId;
        blockchainActionIdData[_blockchainActionId].to = to;
        blockchainActionIdData[_blockchainActionId].pptFee = pptFee;
        actionStatus[_blockchainActionId] = true;
        return true;
    }
    
    /** @dev Updates a deposit address for client id
      * @param _blockchainActionId the blockchain action id
      * @param _clientId the client id
      * @param _depositContract the deposit contract address for the client
      * @return success true/false denoting successful function call
      */
    function _setDepositAddress(bytes32 _blockchainActionId, bytes32 _clientId, address _depositContract) public
      onlyServerOrOnlyPopulous
      returns (bool success)
    {
        require(actionStatus[_blockchainActionId] == false);
        depositAddresses[_clientId] = _depositContract;
        depositClientIds[_depositContract] = _clientId;
        // check that deposit address has been stored for client Id
        assert(depositAddresses[_clientId] == _depositContract && depositClientIds[_depositContract] == _clientId);
        // set blockchain action data
        setBlockchainActionData(_blockchainActionId, 0x0, 0, _clientId, depositAddresses[_clientId], 0);
        return true;
    }

    /** @dev Adds a new deposit smart contract address linked to a client id
      * @param _depositAddress the deposit smart contract address
      * @param _clientId the client id
      * @return success true/false denoting successful function call
      */
    function setDepositAddress(bytes32 _blockchainActionId, address _depositAddress, bytes32 _clientId) public onlyServerOrOnlyPopulous returns (bool success) {
        require(actionStatus[_blockchainActionId] == false);
        require(depositAddresses[_clientId] == 0x0 && depositClientIds[_depositAddress] == 0x0);
        depositAddresses[_clientId] = _depositAddress;
        depositClientIds[_depositAddress] = _clientId;
        assert(depositAddresses[_clientId] != 0x0 && depositClientIds[_depositAddress] != 0x0);
        return true;
    }

    
    // CONSTANT METHODS

    /** @dev Gets a deposit address with the client id 
      * @return clientDepositAddress The client's deposit address
      */
    function getDepositAddress(bytes32 _clientId) public view returns (address clientDepositAddress){
        return depositAddresses[_clientId];
    }

    /** @dev Gets a client id linked to a deposit address 
      * @return depositClientId The client id
      */
    function getClientIdWithDepositAddress(address _depositContract) public view returns (bytes32 depositClientId){
        return depositClientIds[_depositContract];
    }

    /** @dev Gets a currency smart contract address 
      * @return currencyAddress The currency address
      */
    function getCurrency(bytes32 _currencySymbol) public view returns (address currencyAddress) {
        return currencyAddresses[_currencySymbol];
    }
   
    /** @dev Gets a currency symbol given it's smart contract address 
      * @return currencySymbol The currency symbol
      */
    function getCurrencySymbol(address _currencyAddress) public view returns (bytes32 currencySymbol) {
        return currencySymbols[_currencyAddress];
    }

    /** @dev Gets details of a currency given it's smart contract address 
      * @return _symbol The currency symbol
      * @return _name The currency name
      * @return _decimals The currency decimal places/precision
      */
    function getCurrencyDetails(address _currencyAddress) public view returns (bytes32 _symbol, bytes32 _name, uint8 _decimals) {
        return (CurrencyToken(_currencyAddress).symbol(), CurrencyToken(_currencyAddress).name(), CurrencyToken(_currencyAddress).decimals());
    } 

    /** @dev Get the blockchain action Id Data for a blockchain Action id
      * @param _blockchainActionId the blockchain action id
      * @return bytes32 currency
      * @return uint amount
      * @return bytes32 accountId
      * @return address to
      */
    function getBlockchainActionIdData(bytes32 _blockchainActionId) public view 
    returns (bytes32 _currency, uint _amount, bytes32 _accountId, address _to) 
    {
        require(actionStatus[_blockchainActionId] == true);
        return (blockchainActionIdData[_blockchainActionId].currency, 
        blockchainActionIdData[_blockchainActionId].amount,
        blockchainActionIdData[_blockchainActionId].accountId,
        blockchainActionIdData[_blockchainActionId].to);
    }

    /** @dev Get the bool status of a blockchain Action id
      * @param _blockchainActionId the blockchain action id
      * @return bool actionStatus
      */
    function getActionStatus(bytes32 _blockchainActionId) public view returns (bool _blockchainActionStatus) {
        return actionStatus[_blockchainActionId];
    }

    /** @dev Gets the version number for the current contract instance
      * @return _version The version number
      */
    function getVersion() public view returns (uint256 _version) {
        return version;
    }

}