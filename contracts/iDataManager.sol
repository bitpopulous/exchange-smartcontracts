pragma solidity ^0.4.17;


/// @title DataManager contract
contract iDataManager {
    // FIELDS
    uint256 public version;
    // currency symbol => currency erc20 contract address
    mapping(bytes32 => address) public currencyAddresses;
    // currency address => currency symbol
    mapping(address => bytes32) public currencySymbols;
    // clientId => depositAddress
    mapping(bytes32 => address) public depositAddresses;
    // depositAddress => clientId
    mapping(address => bytes32) public depositClientIds;
    // blockchainActionId => boolean 
    mapping(bytes32 => bool) public actionStatus;
    // blockchainActionData
    struct actionData {
        bytes32 currency;
        uint amount;
        bytes32 accountId;
        address to;
        uint pptFee;
    }
    // blockchainActionId => actionData
    mapping(bytes32 => actionData) public blockchainActionIdData;
    
    
    // NON-CONSTANT METHODS

    /** @dev Adds a new currency sumbol and smart contract address  
      * @param _currencyAddress the currency smart contract address
      * @param _currencySymbol the currency symbol
      * @return success true/false denoting successful function call
      */
    function setCurrency(bytes32 _blockchainActionId, address _currencyAddress, bytes32 _currencySymbol) public returns (bool success);

    /** @dev Updates a currency sumbol and smart contract address  
      * @param _currencyAddress the currency smart contract address
      * @param _currencySymbol the currency symbol
      * @return success true/false denoting successful function call
      */
    function _setCurrency(bytes32 _blockchainActionId, address _currencyAddress, bytes32 _currencySymbol) public returns (bool success);


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
        returns (bool success);
    
    /** @dev Updates a deposit address for client id
      * @param _blockchainActionId the blockchain action id
      * @param _clientId the client id
      * @param _depositContract the deposit contract address for the client
      * @return success true/false denoting successful function call
      */
    function _setDepositAddress(bytes32 _blockchainActionId, bytes32 _clientId, address _depositContract) public returns (bool success);

    /** @dev Adds a new deposit smart contract address linked to a client id
      * @param _depositAddress the deposit smart contract address
      * @param _clientId the client id
      * @return success true/false denoting successful function call
      */
    function setDepositAddress(bytes32 _blockchainActionId, address _depositAddress, bytes32 _clientId) public returns (bool success);

    // CONSTANT METHODS

    /** @dev Gets a deposit address with the client id 
      * @return clientDepositAddress The client's deposit address
      */
    function getDepositAddress(bytes32 _clientId) public view returns (address clientDepositAddress);


    /** @dev Gets a client id linked to a deposit address 
      * @return depositClientId The client id
      */
    function getClientIdWithDepositAddress(address _depositContract) public view returns (bytes32 depositClientId);


    /** @dev Gets a currency smart contract address 
      * @return currencyAddress The currency address
      */
    function getCurrency(bytes32 _currencySymbol) public view returns (address currencyAddress);

   
    /** @dev Gets a currency symbol given it's smart contract address 
      * @return currencySymbol The currency symbol
      */
    function getCurrencySymbol(address _currencyAddress) public view returns (bytes32 currencySymbol);

    /** @dev Gets details of a currency given it's smart contract address 
      * @return _symbol The currency symbol
      * @return _name The currency name
      * @return _decimals The currency decimal places/precision
      */
    function getCurrencyDetails(address _currencyAddress) public view returns (bytes32 _symbol, bytes32 _name, uint8 _decimals);

    /** @dev Get the blockchain action Id Data for a blockchain Action id
      * @param _blockchainActionId the blockchain action id
      * @return bytes32 currency
      * @return uint amount
      * @return bytes32 accountId
      * @return address to
      */
    function getBlockchainActionIdData(bytes32 _blockchainActionId) public view returns (bytes32 _currency, uint _amount, bytes32 _accountId, address _to);


    /** @dev Get the bool status of a blockchain Action id
      * @param _blockchainActionId the blockchain action id
      * @return bool actionStatus
      */
    function getActionStatus(bytes32 _blockchainActionId) public view returns (bool _blockchainActionStatus);

    /** @dev Gets the version number for the current contract instance
      * @return _version The version number
      */
    function getVersion() public view returns (uint256 _version);

}