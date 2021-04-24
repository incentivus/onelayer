struct Solver
    variables::Array{Variable, 1}
    constraints::Array{Constraint, 1}
    swaps::Array{Swap, 1}
    tokens::Dict{Symbol, Int64}
    protocols::Array{<:Protocol, 1}
    steps::Int64
end

Solver(vars::Array{Variable,1}, consts::Array{Constraint,1}, swaps::Array{Swap,1}, protocol::Array{<:Protocol,1}, steps) = Solver(vars, consts, swaps, Dict{Symbol, Int64}(), protocol, steps)

function registerTokens(s::Solver, tokens::Array{Symbol, 1})
    for t in tokens 
        if !haskey(s.tokens, t)
            s.tokens[t] = s.tokens.count+1
        end
    end
end

function registerTokens(s::Solver)
    for sw in s.swaps
        for t in sw.assets
            if !haskey(s.tokens, symbol(t))
                s.tokens[symbol(t)] = s.tokens.count+1
            end
        end
    end
end

function buildAMatrix(s::Solver)
    A = zeros(s.tokens.count, length(s.swaps))
    for i in 1:length(s.swaps)
        swap = s.swaps[i]
        for asset in assets(swap)
            A[s.tokens[symbol(asset)], i] = balance(asset)
        end
    end
    return A
end

function buildXMatrix(s::Solver)
    s.variables
end

function buildCMatrix(s::Solver, target::Symbol)

    C = zeros(s.tokens.count)
    C[s.tokens[target]] = 1
    return C
end

function solve(s::Solver, first::Symbol, init_amount::Float64, target::Symbol)
    A = buildAMatrix(s)
    X = buildXMatrix(s)
    C = buildCMatrix(s, target)

    balance = zeros(s.tokens.count, s.steps)
    balance[s.tokens[first], 1] = init_amount

    # for i in 1:s.steps-1
    #     balance[:, i] = balance[:, i-1] + A*X[i]
    #     push!(s.constraints, balance[:, i] >= 0)
    # end
    push!(s.constraints, balance[:, s.steps] + A*X[s.steps] >= 0)
    problem = maximize(transpose(C)*(balance[:, s.steps] + A*X[s.steps]), s.constraints)
    return problem
    # solve!(problem, ECOS.Optimizer
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
            for s in getSwaps(p)
                var = X[j][i]
                addVariable!(s, var)
                i += 1
            end
        end
        append!(constraints, getConstraints(p))
        append!(swaps, getSwaps(p))
    end
    s = Solver(X, constraints, swaps, protocols, steps)
    registerTokens(s)
    return s
end

function updateProtocols(s::Solver)
    for p in s.protocols
        update(p)
    end
end

