#!/usr/bin/env julia

function parse_input(filename)
    map(x -> parse(Int, x), hcat(collect.(eachline(open(filename)))...))'
end

function find_low_points_idx(height_map)
    height, width = size(height_map)
    up_lower = cat(height_map[1:height-1, :] .< height_map[2:height, :], trues((1, width)), dims = 1)
    down_lower = cat(trues((1, width)), height_map[2:height, :] .< height_map[1:height-1, :], dims = 1)
    right_lower = cat(height_map[:, 1:width-1] .< height_map[:, 2:width], trues((height, 1)), dims = 2)
    left_lower = cat(trues((height, 1)), height_map[:, 2:width] .< height_map[:, 1:width-1], dims = 2)
    up_lower .& down_lower .& left_lower .& right_lower
end

function find_basin_size(starting_point, height_map)
    processed_points = Set()
    new_points = Set([starting_point])
    while !isempty(new_points)
        point_to_process = pop!(new_points)
        push!(processed_points, point_to_process)
        x, y = point_to_process
        for neighbor in [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
            if neighbor in union(new_points, processed_points)
                continue
            end
            try
                new_value = height_map[neighbor...]
                if new_value == 9
                    continue
                end
                if height_map[neighbor...] >= height_map[point_to_process...]
                    push!(new_points, neighbor)
                end
            catch BoundsError
            end
        end
    end
    length(processed_points)
end

function find_basin_sizes(height_map)
    low_points_idx = find_low_points_idx(height_map)
    starting_indices = map(Tuple, findall(low_points_idx))
    sizes = map(x -> find_basin_size(x, height_map), starting_indices)
    sizes
end

function run_puzzle(filename)
    height_map = parse_input(filename)
    low_points = height_map[find_low_points_idx(height_map)]
    println("Part 1: ", sum(low_points .+ 1))
    basin_sizes = find_basin_sizes(height_map)
    println("Part 2: ", reduce(*, sort(basin_sizes)[length(basin_sizes)-2:length(basin_sizes)]))
end

run_puzzle(ARGS[1])
