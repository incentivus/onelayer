abstract type AbstractPosition end
# ps_utils = pyimport("ps")

mutable struct Reserve
    first::Asset
    second::Asset
    address::String
    positions::Array{<:AbstractPosition, 1}
end

struct SwapPosition <: AbstractPosition
    reserve::Reserve
    src::Swap
    dst::Swap
end


struct ConstantProduct <: Protocol
    reserves::Array{Reserve, 1}
    positions::Array{SwapPosition, 1}
    fee::Float64
    # swaps::Array{Swap, 1}
end

function fillPositions(cp::ConstantProduct)
    for r in cp.reserves
        s1 = Swap(-1*unify(r.first), nothing)
        s2 = Swap(unify(r.second), nothing)
        sp = SwapPosition(r, s1, s2)
        push!(r.positions, sp)
        push!(cp.positions, sp)

        s1 = Swap(-1*unify(r.second), nothing)
        s2 = Swap(unify(r.first), nothing)
        sp = SwapPosition(r, s1, s2)
        push!(r.positions, sp)
        push!(cp.positions, sp)
    end
end


function ConstantProduct(pairs::Array{<:Tuple{Asset, Asset, String}, 1}, fee::Float64)
    reserves = []
    for p in pairs
        first = unify(p[1])
        second = unify(p[2])
        push!(reserves, Reserve(first*10000, second*100, p[3], Array{SwapPosition, 1}()))
    end
    
    cp = ConstantProduct(reserves, [], fee)
    fillPositions(cp)
    return cp
end

# pancakeSwap_trading_pairs = [(AAVE, DAI)]#, (WBNB, CAKE), (BUSD, WBNB)]


# PancakeSwap = ConstantProduct(pancakeSwap_trading_pairs, 0.002)

function update(cp::ConstantProduct)
    py"""
    from web3 import Web3
    import collections
    import json
    from web3.middleware import geth_poa_middleware
    
    import _thread as thread
    import numpy as np
    import cvxpy as cp
    
    w3 = Web3(Web3.HTTPProvider("https://bsc-dataseed.binance.org/"))
    
    
    w3.middleware_onion.inject(geth_poa_middleware, layer=0)
    
    abi = [{'inputs': [], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'constructor'}, {'anonymous': False, 'inputs': [{'indexed': True, 'internalType': 'address', 'name': 'owner', 'type': 'address'}, {'indexed': True, 'internalType': 'address', 'name': 'spender', 'type': 'address'}, {'indexed': False, 'internalType': 'uint256', 'name': 'value', 'type': 'uint256'}], 'name': 'Approval', 'type': 'event'}, {'anonymous': False, 'inputs': [{'indexed': True, 'internalType': 'address', 'name': 'sender', 'type': 'address'}, {'indexed': False, 'internalType': 'uint256', 'name': 'amount0', 'type': 'uint256'}, {'indexed': False, 'internalType': 'uint256', 'name': 'amount1', 'type': 'uint256'}, {'indexed': True, 'internalType': 'address', 'name': 'to', 'type': 'address'}], 'name': 'Burn', 'type': 'event'}, {'anonymous': False, 'inputs': [{'indexed': True, 'internalType': 'address', 'name': 'sender', 'type': 'address'}, {'indexed': False, 'internalType': 'uint256', 'name': 'amount0', 'type': 'uint256'}, {'indexed': False, 'internalType': 'uint256', 'name': 'amount1', 'type': 'uint256'}], 'name': 'Mint', 'type': 'event'}, {'anonymous': False, 'inputs': [{'indexed': True, 'internalType': 'address', 'name': 'sender', 'type': 'address'}, {'indexed': False, 'internalType': 'uint256', 'name': 'amount0In', 'type': 'uint256'}, {'indexed': False, 'internalType': 'uint256', 'name': 'amount1In', 'type': 'uint256'}, {'indexed': False, 'internalType': 'uint256', 'name': 'amount0Out', 'type': 'uint256'}, {'indexed': False, 'internalType': 'uint256', 'name': 'amount1Out', 'type': 'uint256'}, {'indexed': True, 'internalType': 'address', 'name': 'to', 'type': 'address'}], 'name': 'Swap', 'type': 'event'}, {'anonymous': False, 'inputs': [{'indexed': False, 'internalType': 'uint112', 'name': 'reserve0', 'type': 'uint112'}, {'indexed': False, 'internalType': 'uint112', 'name': 'reserve1', 'type': 'uint112'}], 'name': 'Sync', 'type': 'event'}, {'anonymous': False, 'inputs': [{'indexed': True, 'internalType': 'address', 'name': 'from', 'type': 'address'}, {'indexed': True, 'internalType': 'address', 'name': 'to', 'type': 'address'}, {'indexed': False, 'internalType': 'uint256', 'name': 'value', 'type': 'uint256'}], 'name': 'Transfer', 'type': 'event'}, {'constant': True, 'inputs': [], 'name': 'DOMAIN_SEPARATOR', 'outputs': [{'internalType': 'bytes32', 'name': '', 'type': 'bytes32'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'MINIMUM_LIQUIDITY', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'PERMIT_TYPEHASH', 'outputs': [{'internalType': 'bytes32', 'name': '', 'type': 'bytes32'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [{'internalType': 'address', 'name': '', 'type': 'address'}, {'internalType': 'address', 'name': '', 'type': 'address'}], 'name': 'allowance', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'address', 'name': 'spender', 'type': 'address'}, {'internalType': 'uint256', 'name': 'value', 'type': 'uint256'}], 'name': 'approve', 'outputs': [{'internalType': 'bool', 'name': '', 'type': 'bool'}], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': True, 'inputs': [{'internalType': 'address', 'name': '', 'type': 'address'}], 'name': 'balanceOf', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'address', 'name': 'to', 'type': 'address'}], 'name': 'burn', 'outputs': [{'internalType': 'uint256', 'name': 'amount0', 'type': 'uint256'}, {'internalType': 'uint256', 'name': 'amount1', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'decimals', 'outputs': [{'internalType': 'uint8', 'name': '', 'type': 'uint8'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'factory', 'outputs': [{'internalType': 'address', 'name': '', 'type': 'address'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'getReserves', 'outputs': [{'internalType': 'uint112', 'name': '_reserve0', 'type': 'uint112'}, {'internalType': 'uint112', 'name': '_reserve1', 'type': 'uint112'}, {'internalType': 'uint32', 'name': '_blockTimestampLast', 'type': 'uint32'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'address', 'name': '_token0', 'type': 'address'}, {'internalType': 'address', 'name': '_token1', 'type': 'address'}], 'name': 'initialize', 'outputs': [], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'kLast', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'address', 'name': 'to', 'type': 'address'}], 'name': 'mint', 'outputs': [{'internalType': 'uint256', 'name': 'liquidity', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'name', 'outputs': [{'internalType': 'string', 'name': '', 'type': 'string'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [{'internalType': 'address', 'name': '', 'type': 'address'}], 'name': 'nonces', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'address', 'name': 'owner', 'type': 'address'}, {'internalType': 'address', 'name': 'spender', 'type': 'address'}, {'internalType': 'uint256', 'name': 'value', 'type': 'uint256'}, {'internalType': 'uint256', 'name': 'deadline', 'type': 'uint256'}, {'internalType': 'uint8', 'name': 'v', 'type': 'uint8'}, {'internalType': 'bytes32', 'name': 'r', 'type': 'bytes32'}, {'internalType': 'bytes32', 'name': 's', 'type': 'bytes32'}], 'name': 'permit', 'outputs': [], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'price0CumulativeLast', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'price1CumulativeLast', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'address', 'name': 'to', 'type': 'address'}], 'name': 'skim', 'outputs': [], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'uint256', 'name': 'amount0Out', 'type': 'uint256'}, {'internalType': 'uint256', 'name': 'amount1Out', 'type': 'uint256'}, {'internalType': 'address', 'name': 'to', 'type': 'address'}, {'internalType': 'bytes', 'name': 'data', 'type': 'bytes'}], 'name': 'swap', 'outputs': [], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'symbol', 'outputs': [{'internalType': 'string', 'name': '', 'type': 'string'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': False, 'inputs': [], 'name': 'sync', 'outputs': [], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'token0', 'outputs': [{'internalType': 'address', 'name': '', 'type': 'address'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'token1', 'outputs': [{'internalType': 'address', 'name': '', 'type': 'address'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': True, 'inputs': [], 'name': 'totalSupply', 'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}], 'payable': False, 'stateMutability': 'view', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'address', 'name': 'to', 'type': 'address'}, {'internalType': 'uint256', 'name': 'value', 'type': 'uint256'}], 'name': 'transfer', 'outputs': [{'internalType': 'bool', 'name': '', 'type': 'bool'}], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}, {'constant': False, 'inputs': [{'internalType': 'address', 'name': 'from', 'type': 'address'}, {'internalType': 'address', 'name': 'to', 'type': 'address'}, {'internalType': 'uint256', 'name': 'value', 'type': 'uint256'}], 'name': 'transferFrom', 'outputs': [{'internalType': 'bool', 'name': '', 'type': 'bool'}], 'payable': False, 'stateMutability': 'nonpayable', 'type': 'function'}]
    def getReserves(address):
        contract = w3.eth.contract(address=address, abi=abi)
        return contract.functions.getReserves().call()
    
    """

    for r in cp.reserves
        res = py"getReserves"(r.address)
        r.first = unify(r.first)*res[1]/(10^decimal(r.first))
        r.second = unify(r.second)*res[2]/(10^decimal(r.second))
    end    
end

function swapNumbers(cp::ConstantProduct)
    length(cp.positions)*2
end

function getSwaps(cp::ConstantProduct)
    swaps = []
    for p in cp.positions
        push!(swaps, p.src)
        push!(swaps, p.dst)
    end
    return swaps
end

function getConstraints(cp::ConstantProduct)
    constraints = []
    # for r in getReserves(cp)
    #     steps = length(r.positions[1].src.variables)
    #     if steps <= 1
    #         break
    #     end
    #     # push!(constraints, r.positions[1].src.variables[1] >= 0, r.positions[1].dst.variables[1] >= 0, r.positions[2].src.variables[1] >= 0, r.positions[2].dst.variables[1] >= 0)
    #     # cons = [r.positions[1].src.variables[1], r.positions[2].dst.variables[1]]
    #     for i in 1:steps
    #         x0 = r.positions[1].src.variables[i]
    #         x1 = r.positions[1].dst.variables[i]
    #         x2 = r.positions[2].src.variables[i]
    #         x3 = r.positions[2].dst.variables[i]

    #         push!(cons, x0, x3)

    #         # r.first[i] = r.first[i-1] - x0 + x3
    #         # r.second[i] = r.second[i-1] + x1 - x2
    #     end
    #     push!(constraints, sum(cons) <= maximum(cons))
    #     x3 + x4 <= maximum(x3, x4) and x3 >= 0 and x4 >= 0
    # end
    for p in getPositions(cp)
        for i in 1:length(p.src.variables)
            r1 = getBalance(p.reserve, p.src.assets[1])
            r2 = getBalance(p.reserve, p.dst.assets[1])
            
            x = p.src.variables[i]
            y = p.dst.variables[i]
            k = r1*r2
            push!(constraints, r2/(1+x*(1-cp.fee)/r1) - (r2 - y) <= 0, x >= 0, y >= 0, y <= r2)
                                
        end
    end
    return constraints
end



    


function getBalance(r::Reserve, asset::Asset)
    if symbol(r.first) == symbol(asset)
        balance(r.first)
    elseif symbol(r.second) == symbol(asset)
        balance(r.second)
    else
        error("Wrong Reserve.")
    end
end

getReserves(cp::ConstantProduct) = cp.reserves
getPositions(cp::ConstantProduct) = cp.positions





