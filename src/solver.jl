struct Solver
    variables::Array{Variable, 1}
    constraints::Array{Convex.Constraint, 1}
    swaps::Array{Swap, 1}
    tokens::Dict{Symbol, Int64}
    protocols::Array{Protocol, 1}
end


abstract type Swap end


function registerTokens(s::Solver, tokens::Array{Symbol, 1})
    for t in tokens: 
        if !haskey(s.tokens, t)
            s.tokens[t] = s.tokens.count+1
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

function buildXMatrix(s::Solver)
    s.variables


function solve(s::Solver)
    A = buildAMatrix(s)
    x = buildXMatrix(s)
    # TODO Solve the problem here


function newSolver(protocols::Array{Protocol, 1}, steps::Int64)
    variableSize = sum(length.(getSwaps.(protocols)))
    X = []
    for i in 1:steps
        x = Variable(variableSize)
        push!(X, x)
    end
    constraints = []::Array{Convex.Constraint, 1}
    swaps = []::Array{Swap, 1}

    i = 1
    for p in protocols
        for j in 1:steps
        var = X[j][i]
        for s in getSwaps(p):
            addVariable!(s, var)
            i += 1
        append!(constraints, getConstraints(p))
        append!(swaps, getSwaps(p))
    end
    Solver(x, constraints, swaps, protocols)

function updateProtocols(s::Solver)
    for p in s.protocols
        update(p)
    end
