import brownie
from brownie import Contract, accounts, MultiSigWallet, reverts
import pytest

@pytest.fixture
def wallet(scope="module"):
    wallet = MultiSigWallet.deploy([accounts[0], accounts[1], accounts[2], accounts[3], accounts[4]], 5, {'from': accounts[0]})
    return wallet

def test_deposit(wallet):
    accounts[0].transfer(wallet, "10 ether")
    assert wallet.balance() == "10 ether"

def test_owners(wallet):
    assert wallet.GetOwners({'from': accounts[0]}) == [accounts[0], accounts[1], accounts[2], accounts[3], accounts[4]]

def test_submit(wallet):
    wallet.submit(accounts[5], 1000000000000000000, "", {'from': accounts[0]})
    assert len(wallet.GetSubmissions({'from': accounts[0]})) != 0

def test_approvalCount(wallet):
    wallet.submit(accounts[5], 1000000000000000000, "", {'from': accounts[0]})
    wallet.approve(0, {'from': accounts[1]})
    wallet.approve(0, {'from': accounts[0]})
    assert wallet.getApprovalCount(0) == 2


def test_revoke(wallet):
    wallet.submit(accounts[5], 1000000000000000000, "", {'from': accounts[0]})
    wallet.approve(0, {'from': accounts[1]})
    wallet.approve(0, {'from': accounts[0]})
    wallet.revoke(0, {'from': accounts[1]})
    assert wallet.getApprovalCount(0) == 1

def test_Execute_Fail(wallet):
    wallet.submit(accounts[5], 1000000000000000000, "", {'from': accounts[0]})
    wallet.approve(0, {'from': accounts[1]})
    wallet.approve(0, {'from': accounts[0]})
    with brownie.reverts():
        wallet.SendFunds(0)
