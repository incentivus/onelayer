mutable struct Reserve
    first::Asset
    second::Asset
end

struct ConstantProduct <: Protocol
    reserves::Array{Reserve, 1}
    positions::Array{SwapPosition, 1}
    # swaps::Array{Swap, 1}
end

struct SwapPosition
    reserve::Reserve
    src::Swap
    dst::Swap
end

function ConstantProduct(pairs::Array{Tuple{Asset, Asset},1})
    reserves = []
    for p in pairs
        first = unify(p[1])
        second = unify(p[2])
        push!(reserves, Reserve(first, second))
    end
    ConstantProduct(reserves, [])

function 


pancakeSwap_trading_pairs = [(CAKE, BUSD), (WBNB, CAKE), (BUSD, WBNB)]


PancakeSwap = ConstantProduct(pancakeSwap_trading_pairs)

function update(cp::ConstantProduct)
    
end

function getSwaps(cp::ConstantProduct)
    swaps = []
    for r in cp.reserves
        sp = SwapPosition(r, )
        push!(swaps, r.first)
        push!(swaps, r.second)
    end
    return swaps

function getConstraints(cp::ConstantProduct)
    constraints = []
    for r in cp.reserves:
        push!(constraints, r.




    

    





getReserves(cp::ConstantProduct) = cp.reserves
