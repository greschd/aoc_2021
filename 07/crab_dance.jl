#!/usr/bin/env julia

using Statistics
using DelimitedFiles

function get_min_fuel(positions, cost_func)
    fuel_needed = typemax(Int)
    for target in range(minimum(positions), maximum(positions), step = 1)
        fuel_needed_current = sum(cost_func.(abs.(positions .- target)))
        fuel_needed = minimum([fuel_needed, fuel_needed_current])
    end
    fuel_needed
end

function run_puzzle(filename)
    positions = readdlm(filename, ',', Int)
    println(get_min_fuel(positions, x -> x))
    println(get_min_fuel(positions, x -> fld(x^2 + x, 2)))
end

run_puzzle(ARGS[1])
