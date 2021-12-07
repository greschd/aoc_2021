#!/usr/bin/env julia

using DelimitedFiles

function get_new_counts(fish_counter)
    new_fish_counter = Dict()
    for days_until_birth = 1:8
        new_fish_counter[days_until_birth-1] = fish_counter[days_until_birth]
    end
    new_fish_counter[6] += fish_counter[0]
    new_fish_counter[8] = fish_counter[0]
    new_fish_counter
end

function run_puzzle(filename, num_days)
    input = readdlm(filename, ',', BigInt)
    fish_counter = Dict()
    for days_until_birth = 0:8
        fish_counter[days_until_birth] = sum(BigInt, input .== days_until_birth)
    end

    for _ = 1:num_days
        fish_counter = get_new_counts(fish_counter)
    end
    println(sum(values(fish_counter)))
end

run_puzzle(ARGS[1], 80)
run_puzzle(ARGS[1], 256)
