# MultiSig_Wallet
A multi signature wallet for EVM compatible chains to send ether(or native coin) to other addresses. It requires 80% of the owners of this wallet to approve/vote to execute the transaction. 

# tests
These test test the functionality and securityy of te MultiSig Wallet. Carried out with pytest in the Brownie IDE

# deployment
this is compatible with aEVM compatible blockchains as it is written in solidity. The constructor takes an array or addresses that are to e declarred as owners and the number of total votes, which should be equal to the number or owners ut ownly 80% votes ae required to execute a transaction.
