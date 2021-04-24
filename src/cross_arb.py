from binance.client import Client
import _thread as thread
from web3 import Web3
import collections
import json
from web3.middleware import geth_poa_middleware

from utils import *
import _thread as thread
import numpy as np
import cvxpy as cp


w3 = Web3(Web3.HTTPProvider("https://bsc-dataseed.binance.org/"))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)

pancakeContract = w3.eth.contract(address="0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F", abi=pancake_abi)
bakeryContract = w3.eth.contract(address="0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F", abi=pancake_abi)

wrapperContract = wrapperContract = w3.eth.contract(address=Web3.toChecksumAddress("0xa01C5801C73126Db86d4A8caEC0776020003c009"), abi=wrapper_abi)



api_key = "3EB87DUw0vaxX8DAREF6o7F2nmhADBaMHGfwzxKYWfCPFPYzfb6MbmMFr8PRgUZK"
api_secret = "G7z0gqLIyAD4nBrDeK6TYKIPDhzm4QfZhtca6Vmagq6gaOlklr4JslDYlcqnLCIS"
client = Client(api_key, api_secret)

trading_volume = 10
cake = w3.toChecksumAddress("0x0e09fabb73bd3ade0a17ecc321fd13a19e81ce82")
btcst = w3.toChecksumAddress("0x78650b139471520656b9e7aa7a5e9276814a38e9")
busd = w3.toChecksumAddress('0xe9e7cea3dedca5984780bafc599bd69add087d56')
wbnb = w3.toChecksumAddress("0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c")
btcb = w3.toChecksumAddress("0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c")
sxp = w3.toChecksumAddress("0x47bead2563dcbf3bf2c9407fea4dc236faba485a")
eth = w3.toChecksumAddress("0x2170ed0880ac9a755fd29b2688956bd959f933f8")
sushi = w3.toChecksumAddress("0x947950bcc74888a40ffa2593c5798f11fc9124c4") 
uni = w3.toChecksumAddress("0xbf5140a22578168fd562dccf235e5d43a02ce9b1")
alice = w3.toChecksumAddress("0xAC51066d7bEC65Dc4589368da368b212745d63E8")
usdt = w3.toChecksumAddress("0x55d398326f99059ff775485246999027b3197955")

def get_buy_entry(quantity, path, protocol="PancakeSwap"):
    return get_swapEntry(True, quantity, path=path, protocol=protocol)

def get_sell_entry(quantity, path, protocol="PancakeSwap"):
    return get_swapEntry(False, quantity, path=path, protocol=protocol)


def get_swapEntry(typ, quantity, addrs1=None, addrs2=None, path=None, protocol="PacakeSwap"):
    protocol_ind = 0
    if protocol != "PancakeSwap":
        protocol_ind = 1
    if path:
        tmp = [w3.toChecksumAddress(p) for p in path]
        return ContractSwapEntry(protocol_ind, typ, quantity, path=tmp)
    else:
        return ContractSwapEntry(protocol_ind, typ, quantity, w3.toChecksumAddress(addrs1), w3.toChecksumAddress(addrs2))


class ContractSwapEntry:
    def __init__(self, protocol, typ, quantity, address0=None, address1=None, path=None):
        self.protocol = protocol
        self.typ = typ
        self.quantity = quantity
        if path:
            self.path = path
            self.address0 = path[0]
            self.address1 = path[-1]
        else:
            self.path = [address0, address1]
            self.address0 = address0
            self.address1 = address1
    def set_value(self, val):
        self.value = val

def get_ratio(swapsEntries):
    tmp = []
    for e in swapsEntries:
        if int(e.quantity*100000) == 0:
            e.set_value(0)
        else:
            tmp.append(e)
    swapsEntries = tmp
    protos = [e.protocol for e in swapsEntries]
    types = [e.typ for e in swapsEntries]

    amounts = [int(e.quantity*100000) for e in swapsEntries]
    paths = [e.path for e in swapsEntries]
    print(paths)
    print(amounts)
    print(types)
    print(protos)
    try:
        res = wrapperContract.functions.getRatio(protos, types, amounts, paths).call()
    except Exception as e:
        print("In:", amounts, "path", paths)
        raise e
    for i in range(len(swapsEntries)):
        swapsEntries[i].set_value(res[i]/100000)




def get_on_chain_data(sym):
    if sym == "CAKEUSDT":
        sell_path = [cake, wbnb, usdt]
        buy_path = [usdt, wbnb, cake]
    if sym == "CAKEBUSD":
        sell_path = [cake, busd]
        buy_path = [busd, cake]

    buy_entry = get_buy_entry(trading_volume, path=buy_path)# , protocol="Bakery")
    sell_entry = get_sell_entry(trading_volume, path=sell_path)#  , protocol="Bakery")
    get_ratio([buy_entry, sell_entry])
   
    return sell_entry.value, buy_entry.value







def get_off_chain_data(symbol):
    data = client.get_order_book(symbol=symbol)
    sell_price = 0
    buy_price = 0
    quantity = 0
    for bid in data["bids"]:
        amount = float(bid[1])
        value = float(bid[0])
        if amount >= trading_volume-quantity:
            sell_price += (trading_volume-quantity)*value
            quantity = trading_volume
        else:
            sell_price += amount*value
            quantity += amount
    quantity = 0
    for ask in data["asks"]:
        amount = float(ask[1])
        value = float(ask[0])
        if amount >= trading_volume-quantity:
            buy_price += (trading_volume-quantity)*value
            quantity = trading_volume
        else:
            buy_price += amount*value
            quantity += amount
    return sell_price, buy_price

def wrapper(message, func, inp):
    if inp:
        print(message, func(inp), inp)
    else:
        print(message, func())

thread.start_new_thread(wrapper, ("On-chain:", get_on_chain_data, "CAKEUSDT"))
thread.start_new_thread(wrapper, ("On-chain:", get_on_chain_data, "CAKEBUSD"))
thread.start_new_thread(wrapper, ("Off-chain:", get_off_chain_data, "CAKEBUSD"))
thread.start_new_thread(wrapper, ("Off-chain:", get_off_chain_data, "CAKEUSDT"))
import time
time.sleep(5)
# print(get_off_chain_data())
# print(get_on_chain_data())
