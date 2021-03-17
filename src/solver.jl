struct Solver
    variables::Array{Variable, 1}
    constraints::Array{Convex.Constraint, 1}
    swaps::Array{Swap, 1}
    tokens::Dict{Symbol, Int64}
end


abstract type Swap end


function registerTokens(s::Solver, tokens::Array{Symbol, 1})
    for t in tokens: 
        if !haskey(s.tokens, t)
            s.tokens[t] = s.tokens.count+1
        end
    end

function buildAMatrix(s::Solver)
    A = zeros(tokens.count, length(s.swaps))
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


function newSolver(protocols::Array{Protocol, 1})
    variableSize = sum(length.(getSwaps.(protocols)))
    x = Variable(variableSize)
    constraints = []::Array{Convex.Constraint, 1}
    swaps = []::Array{Swap, 1}

    i = 1
    for p in protocols
        for s in getSwaps(p):
            setVariable!(s, x[i])
            i += 1
        append!(constraints, getConstraints(p))
        append!(swaps, getSwaps(p))
    end
    Solver(x, constraints, swaps)
