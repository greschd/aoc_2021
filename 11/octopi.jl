#!/usr/bin/env julia

function read_input(filename)
    chars = collect.(eachline(open(filename)))
    map(x -> parse(Int, x), hcat(chars...))'
end

function run_step(input_values)
    mat_size = size(input_values)
    has_flashed = falses(mat_size)
    current_values = input_values .+ 1
    while any(current_values[.!has_flashed] .> 9)
        to_flash = (current_values .> 9) .& (.!has_flashed)

        current_values[1:end-1, :] += to_flash[2:end, :]
        current_values[2:end, :] += to_flash[1:end-1, :]
        current_values[:, 1:end-1] += to_flash[:, 2:end]
        current_values[:, 2:end] += to_flash[:, 1:end-1]
        current_values[1:end-1, 1:end-1] += to_flash[2:end, 2:end]
        current_values[1:end-1, 2:end] += to_flash[2:end, 1:end-1]
        current_values[2:end, 1:end-1] += to_flash[1:end-1, 2:end]
        current_values[2:end, 2:end] += to_flash[1:end-1, 1:end-1]

        has_flashed .|= to_flash
    end
    current_values[has_flashed] .= 0
    current_values, sum(has_flashed)
end

function run_puzzle_1(filename)
    values = read_input(filename)
    flash_count = 0
    for _ in range(1, 100, step = 1)
        values, count = run_step(values)
        flash_count += count
    end
    println("Part 1: ", flash_count)
end

function run_puzzle_2(filename)
    values = read_input(filename)
    for step_idx = 1:typemax(Int)
        values, count = run_step(values)
        if count == length(values)
            println("Part 2: ", step_idx)
            break
        end
    end

end

run_puzzle_1(ARGS[1])
run_puzzle_2(ARGS[1])
