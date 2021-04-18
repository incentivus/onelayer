abstract type AbstractPosition end

mutable struct Reserve
    first::Asset
    second::Asset
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
        s1 = Swap(unify(r.first), nothing)
        s2 = Swap(unify(r.second), nothing)
        sp = SwapPosition(r, s1, s2)
        push!(r.positions, sp)
        push!(cp.positions, sp)

        s1 = Swap(unify(r.second), nothing)
        s2 = Swap(unify(r.first), nothing)
        sp = SwapPosition(r, s1, s2)
        push!(r.positions, sp)
        push!(cp.positions, sp)
    end
end


function ConstantProduct(pairs::Array{<:Tuple{Asset, Asset}, 1}, fee::Float64)
    reserves = []
    for p in pairs
        first = unify(p[1])
        second = unify(p[2])
        push!(reserves, Reserve(first, second, Array{SwapPosition, 1}()))
    end
    
    cp = ConstantProduct(reserves, [], fee)
    fillPositions(cp)
    return cp
end

# pancakeSwap_trading_pairs = [(AAVE, DAI)]#, (WBNB, CAKE), (BUSD, WBNB)]


# PancakeSwap = ConstantProduct(pancakeSwap_trading_pairs, 0.002)

function update(cp::ConstantProduct)
    
end

function swapNumbers(cp::ConstantProduct)
    length(cp.reserves)*4
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
    for r in getReserves(cp)
        steps = length(r.positions[1].src.variables)
        if steps <= 1
            break
        end
        # push!(constraints, r.positions[1].src.variables[1] >= 0, r.positions[1].dst.variables[1] >= 0, r.positions[2].src.variables[1] >= 0, r.positions[2].dst.variables[1] >= 0)
        # cons = [r.positions[1].src.variables[1], r.positions[2].dst.variables[1]]
        for i in 1:steps
            x0 = r.positions[1].src.variables[i]
            x1 = r.positions[1].dst.variables[i]
            x2 = r.positions[2].src.variables[i]
            x3 = r.positions[2].dst.variables[i]

            push!(cons, x0, x3)

            # r.first[i] = r.first[i-1] - x0 + x3
            # r.second[i] = r.second[i-1] + x1 - x2
        end
        push!(constraints, sum(cons) <= maximum(cons))
    end
    for p in getPositions(cp)
        for i in 1:length(p.src.variables)
            r1 = getBalance(p.reserve, p.src.assets[1])
            r2 = getBalance(p.reserve, p.dst.assets[1])
            
            x = p.src.variables[i]
            y = p.dst.variables[i]
            k = r1*r2
            push!(constraints, k/(r1+x*(1-cp.fee)) - (r2 - y) <= 0, x >= 0, y >= 0)
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
