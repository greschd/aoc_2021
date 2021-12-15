#!/usr/bin/env julia

using DelimitedFiles

function read_input(filename)
    res = cat([map(x -> parse(Int, x), collect(line)) for line in eachline(open(filename))]..., dims = 2)
    res
end

function create_extended_input(input)
    res_col = input
    for i = 1:4
        res_col = vcat(res_col, input .+ i)
    end
    res = res_col
    for i = 1:4
        res = hcat(res, res_col .+ i)
    end
    mod.((res .- 1), 9) .+ 1
end

function find_path_cost(input)
    cost_array = fill(typemax(Int), size(input))
    cost_array[1, 1] = 0
    for cost = 0:typemax(Int)
        idx = cost_array .== cost
        if idx[end, end]
            return cost
        end
        for cart_idx in findall(idx)
            for offset in [CartesianIndex(1, 0), CartesianIndex(-1, 0), CartesianIndex(0, 1), CartesianIndex(0, -1)]
                cart_idx_new = cart_idx + offset
                if checkbounds(Bool, cost_array, cart_idx_new)
                    cost_array[cart_idx_new] = min(cost_array[cart_idx_new], cost + input[cart_idx_new])
                end
            end
        end
    end
end

function run_puzzle(filename)
    input = read_input(filename)
    println("Part 1: ", find_path_cost(input))
    println("Part 2: ", find_path_cost(create_extended_input(input)))
    # display(create_extended_input(input))
end

run_puzzle(ARGS[1])
