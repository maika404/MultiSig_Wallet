//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract MultiSigWallet {
    event Deposited(address indexed sender, uint amount);
    event Submitted(uint indexed txId);
    event Approved(address indexed owner, uint indexed txId );
    event Revoked(address indexed owner, uint indexed txId );
    event FundsSent(uint indexed txId);

    address[] public owners;
    mapping(address => bool) isOwner;
    uint public required;

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) approved;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    modifier onlyOwner(){
        require(isOwner[msg.sender] == true, "Not an owner.");
        _;
    }

    modifier TxExists(uint _txId){
        require(_txId < transactions.length, "Transaction not found.");
        _;
    }

    modifier notApproved(uint _txId){
        require(!approved[_txId][msg.sender], "tx alrready approved");
        _;
    }

    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed , "tx already executed");
        _;
    }

    constructor(address[] memory _owners, uint _votes) {
        require( _owners.length > 0, "owners required");
        require( _votes == _owners.length, "number exceeds limit");

        for (uint i; i < _owners.length; i++){
            address owner = _owners[i];
            require(owner != address(0), "invalid address");
            require(!isOwner[owner], "owner is not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }

        required = (_owners.length / 5) * 4;
        
    }

    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    function submit(address _to, uint _value, bytes calldata _data)
    external 
    onlyOwner
    {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        }));
        emit Submitted(transactions.length - 1);

    }

    function approve(uint _txId)
    external
    onlyOwner 
    TxExists(_txId) 
    notApproved(_txId) 
    notExecuted(_txId) {
        
        approved[_txId][msg.sender] = true;
        emit Approved(msg.sender, _txId);
    }

    function getApprovalCount(uint _txId)
    public
    view
    returns(uint count)
    {
        for (uint i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    function SendFunds(uint _txId)
    external
    TxExists(_txId)
    notExecuted(_txId)
    {
        require(getApprovalCount(_txId) >= required, "approvals less than required");
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");
        emit FundsSent(_txId);
    }

    function revoke(uint _txId) 
    onlyOwner
    external 
    TxExists(_txId)
    notExecuted(_txId)
    {
        require(approved[_txId][msg.sender] = true, "Tx not approved by owner!");
        approved[_txId][msg.sender] = false;
        emit Revoked(msg.sender, _txId);
    }

    function GetOwners() external view returns(address[] memory) {
        return owners;
    }

    function GetSubmissions() external view returns(Transaction[] memory) {
	return transactions;
    }
}