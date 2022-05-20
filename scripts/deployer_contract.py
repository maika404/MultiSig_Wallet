from brownie import MultiSigWallet, accounts, Contract


# AAVE_LENDING_POOL_ADDRESS_PROVIDER = "0xd05e3E715d945B59290df0ae8eF85c1BdB684744"


def main():
    Deployed_Wallet = MultiSigWallet.deploy([accounts[0], accounts[1], accounts[2], accounts[3], accounts[4]], 5, {'from': accounts[0]})
    return Deployed_Wallet
