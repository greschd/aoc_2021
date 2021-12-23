#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

TARGETS = Dict('A' => 3, 'B' => 5, 'C' => 7, 'D' => 9)
TARGETS_REVERSE = Dict(v => k for (k, v) in TARGETS)
COST = Dict('A' => 1, 'B' => 10, 'C' => 100, 'D' => 1000)
HALLWAY_POSSIBLE_INDICES = [1, 2, 4, 6, 8, 10, 11]

function parse_cave_line(line)
    filter(x -> !occursin(x, " #"), collect(line))
end

function read_input(filename)
    line_iterator = Iterators.Stateful(eachline(open(filename)))
    popfirst!(line_iterator)
    num_slots = sum(collect(popfirst!(line_iterator)) .== '.')
    caves = []
    for line in line_iterator
        if all(occursin(char, " #") for char in collect(line))
            break
        end
        # caves = hcat(caves..., parse_cave_line(line))
        push!(caves, parse_cave_line(line))
    end
    caves_mat::Matrix{Union{Nothing,Char}} = cat(caves..., dims = 2)
    cave_mapping = Dict(3 => caves_mat[1, :], 5 => caves_mat[2, :], 7 => caves_mat[3, :], 9 => caves_mat[4, :])
    hallway = Vector{Union{Nothing,Char}}([nothing for _ in 1:num_slots])
    cave_mapping, hallway
end

function movable_to(caves, cave_idx)
    vals = setdiff(Set(caves[cave_idx]), [nothing])
    all(vals .== TARGETS_REVERSE[cave_idx])
end

function hallway_passable(hallway, start_idx, end_idx)
    if start_idx < end_idx
        all(hallway[start_idx+1:end_idx] .== nothing)
    elseif start_idx > end_idx
        all(hallway[end_idx:start_idx-1] .== nothing)
    else
        true
    end
end

function move_to_cave!(caves, hallway, start_pos, cave_idx, amphipod)
    hallway[start_pos] = nothing
    num_moves = 0
    cave = caves[cave_idx]
    for in_cave_idx in reverse(1:length(cave))
        if cave[in_cave_idx] === nothing
            cave[in_cave_idx] = amphipod
            num_moves += in_cave_idx
            break
        end
    end

    start, stop = sort([start_pos, cave_idx])
    num_moves += (stop - start)
    COST[amphipod] * num_moves
end

function first_nonzero(cave)
    for (in_cave_idx, val) in enumerate(cave)
        if val !== nothing
            return (in_cave_idx, val)
        end
    end
end

function move_to_hallway!(caves, hallway, cave_idx, hallway_idx)
    num_moves = 0
    cave = caves[cave_idx]
    amphipod::Char = ' '
    in_cave_idx, amphipod = first_nonzero(cave)
    cave[in_cave_idx] = nothing
    num_moves += in_cave_idx

    hallway[hallway_idx] = amphipod
    start, stop = sort([hallway_idx, cave_idx])
    num_moves += (stop - start)
    COST[amphipod] * num_moves
end

function all_done(caves, hallway)
    return all(hallway .== nothing) & all(
        all(val .== TARGETS_REVERSE[cave_idx] for val in cave_vals)
        for (cave_idx, cave_vals) in caves
    )
end

function creates_blocker(caves, hallway, cave_idx, hallway_idx)
    _, first_amphipod = first_nonzero(caves[cave_idx])
    target_idx = TARGETS[first_amphipod]
    if target_idx > hallway_idx
        for in_hallway_amphipod in filter(x -> x !== nothing, hallway[hallway_idx:target_idx])
            if TARGETS[in_hallway_amphipod] < hallway_idx
                return true
            end
        end
    else
        for in_hallway_amphipod in filter(x -> x !== nothing, hallway[target_idx:hallway_idx])
            if TARGETS[in_hallway_amphipod] > hallway_idx
                return true
            end
        end
    end
    return false
end


function find_minimum_cost(caves, hallway, cutoff = typemax(Int))
    caves = deepcopy(caves)
    hallway = deepcopy(hallway)
    if all_done(caves, hallway)
        return 0
    end
    cost = 0
    while true
        no_progress = true
        for (pos, amphipod) in enumerate(hallway)
            if amphipod === nothing
                continue
            end
            target_idx = TARGETS[amphipod]
            if movable_to(caves, target_idx) & hallway_passable(hallway, pos, target_idx)
                cost += move_to_cave!(caves, hallway, pos, target_idx, amphipod)
                no_progress = false
            end
        end
        if no_progress
            break
        end
    end
    if all_done(caves, hallway)
        return cost
    end
    if cost >= cutoff
        return cutoff
    end
    min_additional_cost = typemax(Int) - cost
    for (cave_idx, cave) in caves
        if all((cave .== TARGETS_REVERSE[cave_idx]) .| (cave .=== nothing)) | all(cave .=== nothing)
            continue
        end
        for hallway_idx in HALLWAY_POSSIBLE_INDICES
            if hallway_passable(hallway, cave_idx, hallway_idx) & !creates_blocker(caves, hallway, cave_idx, hallway_idx)
                new_caves = deepcopy(caves)
                new_hallway = deepcopy(hallway)

                move_cost = move_to_hallway!(new_caves, new_hallway, cave_idx, hallway_idx)

                if (cost + move_cost) >= cutoff
                    return cutoff
                end
                min_additional_cost = min(
                    min_additional_cost,
                    find_minimum_cost(
                        new_caves,
                        new_hallway,
                        min_additional_cost - move_cost
                    ) + move_cost
                )
            end
        end
    end
    cost += min_additional_cost
    if cost >= cutoff
        return cutoff
    end
    if cost < 0
        return typemax(Int)
    end
    return cost
end

function run_puzzle(filename)
    caves, hallway = read_input(filename)
    println("Solution: ", find_minimum_cost(caves, hallway, 100000))
end

run_puzzle(ARGS[1])
