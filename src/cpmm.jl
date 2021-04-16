mutable struct Reserve
    first::Asset
    second::Asset
    positions::Array{SwapPosition, 1}
end

struct ConstantProduct <: Protocol
    reserves::Array{Reserve, 1}
    positions::Array{SwapPosition, 1}
    fee::Float64
    # swaps::Array{Swap, 1}
end

struct SwapPosition
    reserve::Reserve
    src::Swap
    dst::Swap
end

function ConstantProduct(pairs::Array{Tuple{Asset, Asset},1}, fee::Float64)
    reserves = []
    for p in pairs
        first = unify(p[1])
        second = unify(p[2])
        push!(reserves, Reserve(first, second, []))
    end
    ConstantProduct(reserves, [], fee)

function 


pancakeSwap_trading_pairs = [(CAKE, BUSD), (WBNB, CAKE), (BUSD, WBNB)]


PancakeSwap = ConstantProduct(pancakeSwap_trading_pairs)

function update(cp::ConstantProduct)
    
end

function fillPositions(cp::ConstantProduct)
    for r in cp.reserves
        s1 = Swap(unify(r.first), r)
        s2 = Swap(unity(r.second), r)
        sp = SwapPosition(r, s1, s2)
        push!(r.positions, sp)
        push!(cp.positions, sp)

        s1 = Swap(unify(r.second), r)
        s2 = Swap(unify(r.first), r)
        sp = SwapPosition(r, s1, s2)
        push!(r.positions, sp)
        push!(cp.positions, sp)

function getSwaps(cp::ConstantProduct)
    fillPositions(cp)
    swaps = []
    for p in cp.positions
        push!(swaps, p.src)
        push!(swaps, p.dst)
    end
    return swaps

function getConstraints(cp::ConstantProduct)
    constraints = []
    for r in getReserves(cp)
        steps = r.positions[1].src.variables
        if steps <= 1
            break
        end
        push!(constraints, r.positions[1].src.variables[1] >= 0, r.positions[1].dst.variables[1] >= 0, r.positions[2].src.variables[1] >= 0, r.positions[2].dst.variables[1] >= 0)
        const = [r.positions[1].src.variables[1], r.positions[2].dst.variables[1]]
        for i in 2:length(steps)
            x0 = r.positions[1].src.variables[i-1]
            x1 = r.positions[1].dst.variables[i-1]
            x2 = r.positions[2].src.variables[i-1]
            x3 = r.positions[2].dst.variables[i-1]

            push!(const, x0, x3)

            # r.first[i] = r.first[i-1] - x0 + x3
            # r.second[i] = r.second[i-1] + x1 - x2
        end
        push!(constraints, +(const) <= max(const))
    end
    for p in getPositions(cp):
        for i in 1:length(p.src.variables)
            r1 = getBalance(p.reserves, p.src.assets[1])
            r2 = getBalance(p.reserves, p.dst.assets[1])
            
            x = p.src.variables[i]
            y = p.dst.variables[i]
            k = r1*r2
            push!(constraints, k/(r1+x*(1-cp.fee)) - (r2 - y) <= 0)
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

getReserves(cp::ConstantProduct) = cp.reserves
getPositions(cp::ConstantProduct) = cp.positions
