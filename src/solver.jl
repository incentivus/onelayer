struct Solver
    variables::Array{Variable, 1}
    constraints::Array{Constraint, 1}
    swaps::Array{Swap, 1}
    tokens::Dict{Symbol, Int64}
    protocols::Array{<:Protocol, 1}
end

Solver(vars::Array{Variable,1}, consts::Array{Constraint,1}, swaps::Array{Swap,1}, protocol::Array{<:Protocol,1}) = Solver(vars, consts, swaps, Dict{Symbol, Int64}(), protocol)

function registerTokens(s::Solver, tokens::Array{Symbol, 1})
    for t in tokens 
        if !haskey(s.tokens, t)
            s.tokens[t] = s.tokens.count+1
        end
    end
end

function registerTokens(s::Solver, tokens::Array{<:Asset, 1})
    for t in tokens 
        if !haskey(s.tokens, symbol(t))
            s.tokens[symbol(t)] = s.tokens.count+1
        end
    end
end

function buildAMatrix(s::Solver)
    A = zeros(s.tokens.count, length(s.swaps))
    for i in length(s.swaps)
        swap = s.swaps[i]
        for asset in assets(swap)
            A[s.tokens[symbol(asset)], i] = balance(asset)
        end
    end
end

function buildXMatrix(s::Solver)
    s.variables
end

function solve(s::Solver)
    A = buildAMatrix(s)
    x = buildXMatrix(s)
    # TODO Solve the problem here
end

function newSolver(protocols::Array{<:Protocol, 1}, steps::Int64)
    variableSize = sum(swapNumbers.(protocols))
    X = Array{Variable, 1}()
    for i in 1:steps
        x = Variable(variableSize)
        push!(X, x)
    end
    constraints = Array{Constraint, 1}()
    swaps = Array{Swap, 1}()

    i = 1
    for p in protocols
        for j in 1:steps
            var = X[j][i]
            for s in getSwaps(p)
                addVariable!(s, var)
                i += 1
            end
        end
        append!(constraints, getConstraints(p))
        append!(swaps, getSwaps(p))
    end
    Solver(X, constraints, swaps, protocols)
end

function updateProtocols(s::Solver)
    for p in s.protocols
        update(p)
    end
end

