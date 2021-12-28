#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

function read_input(filename)
    permutedims(cat(collect.(eachline(open(filename)))..., dims = 2), (2, 1))
end

function move_south(cucumbers)
    ny, nx = size(cucumbers)
    new_cucumber_positions = fill('.', (ny, nx))
    east_facing_cucumbers = cucumbers .== '>'
    new_cucumber_positions[east_facing_cucumbers] .= '>'
    south_facing_cucumbers = cucumbers .== 'v'
    next_spot_exmpty = circshift(cucumbers .== '.', (-1, 0))
    can_move = south_facing_cucumbers .& next_spot_exmpty
    cannot_move = south_facing_cucumbers .& .!next_spot_exmpty
    new_cucumber_positions[circshift(can_move, (1, 0))] .= 'v'
    new_cucumber_positions[cannot_move] .= 'v'
    new_cucumber_positions
end

function swap_east_south(cucumbers)
    new_cucumber_positions = fill('.', size(cucumbers))
    new_cucumber_positions[cucumbers.=='v'] .= '>'
    new_cucumber_positions[cucumbers.=='>'] .= 'v'
    new_cucumber_positions
end

function move_east(cucumbers)
    swap_east_south(permutedims(move_south(permutedims(swap_east_south(cucumbers), (2, 1))), (2, 1)))
end

function show_cucumbers(cucumbers)
    for row in eachrow(cucumbers)
        println(reduce(*, row))
    end
end

function step(cucumbers)
    move_south(move_east(cucumbers))
end

function run_puzzle(filename)
    cucumbers = read_input(filename)

    # show_cucumbers(cucumbers)
    # println()
    # show_cucumbers(step(cucumbers))
    for i in 1:typemax(Int)
        # println(i)
        new_cucumbers = step(cucumbers)
        if new_cucumbers == cucumbers
            println("Part 1: ", i)
            break
        end
        cucumbers = new_cucumbers
    end
end

run_puzzle(ARGS[1])
