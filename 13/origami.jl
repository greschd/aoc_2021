#!/usr/bin/env julia

function read_input(filename)
    points = []
    line_iterator = Iterators.Stateful(eachline(open(filename)))
    for line in line_iterator
        if isempty(line)
            break
        end
        push!(points, map(x -> parse(Int, x), split(line, ',')))
    end
    folds = []
    for line in line_iterator
        tail = split(line, "fold along ")[2]
        dir, val = split(tail, "=")
        push!(folds, (dir, parse(Int, val)))
    end
    cat(points..., dims = 2)' .+ 1, folds
end

function show_grid(grid)
    res_chars = fill('.', size(grid)...)
    res_chars[grid] .= '#'
    res_str = []
    for line in eachcol(res_chars)
        push!(res_str, reduce(*, line))
    end
    display(res_str)
    println()
end

function get_starting_grid(points)
    res = falses(maximum(points[:, 1]), maximum(points[:, 2]))
    for p in eachrow(points)
        res[p...] = true
    end
    res
end

function execute_fold(grid, fold)
    dir, val = fold
    if dir == "y"
        return execute_fold(grid', ("x", val))'
    end
    val += 1
    size_x, size_y = size(grid)
    l1 = val - 1
    l2 = size_x - val
    new_size_x = max(l1, l2)
    res = falses((new_size_x, size_y))
    res[1:l1, :] = grid[1:l1, :]
    res[end:-1:(end-l2+1), :] .|= grid[val+1:end, :]
    res
end

function run_puzzle(filename)
    points, folds = read_input(filename)
    grid = get_starting_grid(points)
    grid_new = execute_fold(grid, folds[1])

    println("Part 1: ", sum(grid_new))

    for fold in folds
        grid = execute_fold(grid, fold)
    end
    show_grid(grid)
end

run_puzzle(ARGS[1])
