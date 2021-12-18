#!/usr/bin/env julia

function parse_part(val)
    _, tail = split(val, '=')
    l, r = split(tail, "..")
    parse(Int, l), parse(Int, r)
end

function parse_input(filename)
    line = readline(open(filename))
    _, tail = split(line, "target area: ")
    x_part, y_part = split(tail, ", ")
    parse_part(x_part), parse_part(y_part)
end

function get_x(vstart, n)
    if n >= vstart
        return get_y(vstart, vstart)
    else
        return get_y(vstart, n)
    end
end

function get_y(vstart, n)
    return n * vstart - fld(n * (n - 1), 2)
end

function in_area_1d(p, a)
    (p >= a[1]) & (p <= a[2])
end

function in_area(pos, area)
    x, y = pos
    x_area, y_area = area
    in_area_1d(x, x_area) & in_area_1d(y, y_area)
end

function get_num_starting_velocities(x_area, y_area)
    counter = 0
    for vstart_x = 1:x_area[2]
        for vstart_y = y_area[1]:(-y_area[1]-1)
            for n = 1:typemax(Int)
                x = get_x(vstart_x, n)
                y = get_y(vstart_y, n)
                if y < min(y_area...)
                    break
                elseif in_area((x, y), (x_area, y_area))
                    counter += 1
                    break
                end
            end
        end
    end
    counter
end

function run_puzzle(filename)
    x_area, y_area = parse_input(filename)

    println("Part 1: ", fld(y_area[1] * (y_area[1] + 1), 2)) # here we haven't validated n_steps against x...
    println("Part 2: ", get_num_starting_velocities(x_area, y_area))
end

run_puzzle(ARGS[1])
