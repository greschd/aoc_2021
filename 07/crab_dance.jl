#!/usr/bin/env julia

using DelimitedFiles

function get_min_fuel(positions, cost_func = x -> x)
    fuel_needed = typemax(Int)
    for target in range(minimum(positions), maximum(positions), step = 1)
        fuel_needed = minimum([fuel_needed, sum(cost_func.(abs.(positions .- target)))])
    end
    fuel_needed
end

function run_puzzle(filename)
    positions = readdlm(filename, ',', Int)
    println(get_min_fuel(positions))
    println(get_min_fuel(positions, x -> fld(x^2 + x, 2)))
end

run_puzzle(ARGS[1])
