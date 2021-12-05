#!/usr/bin/env julia

function parse_line(line)
    split_line = split(line, "->")
    items = hcat([split(part, ",") for part in split_line]...)
    items_parsed = map(x -> parse(Int, x), items)
    items_parsed
end

function read_input(filename)
    input_parsed = cat([parse_line(line) for line in eachline(open(filename))]..., dims = 3)
    # shift positions by 1 to allow 1-based indexing
    input_parsed .+ 1
end

function add_vent!(counter_matrix, vent_matrix, consider_diagonals = false)
    x0, y0 = vent_matrix[:, 1]
    x1, y1 = vent_matrix[:, 2]
    if x0 == x1
        ystart, yend = sort([y0, y1])
        counter_matrix[x0, ystart:yend] .+= 1
    elseif y0 == y1
        xstart, xend = sort([x0, x1])
        counter_matrix[xstart:xend, y0] .+= 1
    elseif consider_diagonals

        x_range = range(x0, x1, step = x1 > x0 ? 1 : -1)
        y_range = range(y0, y1, step = y1 > y0 ? 1 : -1)
        for (x, y) in zip(x_range, y_range)
            counter_matrix[x, y] += 1
        end
    end
end

function run_analysis(filename, consider_diagonals = false)
    input_parsed = read_input(filename)

    max_x = maximum(input_parsed[1, :, :])
    max_y = maximum(input_parsed[2, :, :])

    vent_counter = zeros(Int, (max_x, max_y))

    for vent in eachslice(input_parsed, dims = 3)
        add_vent!(vent_counter, vent, consider_diagonals)
    end

    println("Number of danger points: ", sum(vent_counter .>= 2))
end


run_analysis(ARGS[1])
run_analysis(ARGS[1], true)
