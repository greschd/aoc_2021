#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

function parse_part(part)
    _, tail = split(part, "=")
    map(x -> parse(Int, x), split(tail, ".."))
end

function parse_line(line)
    head, tail = split(line, " ")
    parts = split(tail, ",")
    limits = parse_part.(parts)
    state = (head == "on")
    state, limits
end

function read_input(filename)
    steps = []
    for line in eachline(open(filename))
        push!(steps, parse_line(line))
    end
    steps
end

function filter_shift_steps(steps, cutoff = 50)
    steps_new = []
    for (state, limits) in steps
        if any([(l[1] > cutoff) | (l[2] < -cutoff) for l in limits])
            continue
        end
        limits_new = [[max(l[1], -cutoff), min(l[2], cutoff)] .+ (cutoff + 1) for l in limits]
        push!(steps_new, (state, limits_new))
    end
    steps_new
end

function run_p1(steps)
    steps = deepcopy(steps)
    steps_filtered = filter_shift_steps(steps)
    size = 101
    reactor = falses((size, size, size))
    for (state, limits) in steps_filtered
        lx, ly, lz = limits
        reactor[lx[1]:lx[2], ly[1]:ly[2], lz[1]:lz[2]] .= state
    end
    println("Part 1: ", sum(reactor))
end

function intersect(cube1, cube2)
    if any((c1[1] > c2[2]) | (c2[1] > c1[2]) for (c1, c2) in zip(cube1, cube2))
        return []
    end
    return [[max(c1[1], c2[1]), min(c1[2], c2[2])] for (c1, c2) in zip(cube1, cube2)]
end

function split_cube(cube, intersection)
    all_splits = []

    limits = [sort([Set([c[1] - 1, c[2], i[1] - 1, i[2]])...]) for (c, i) in zip(cube, intersection)]
    pairs = []
    for lim in limits
        current_pairs = []
        for (lower, upper) in zip(lim[1:end-1], lim[2:end])
            push!(current_pairs, [lower + 1, upper])
        end
        push!(pairs, current_pairs)
    end
    for p1 in pairs[1]
        for p2 in pairs[2]
            for p3 in pairs[3]
                push!(all_splits, [p1, p2, p3])
            end
        end
    end
    filter!(x -> x != intersection, all_splits)
    all_splits
end

function get_size(cube)
    reduce(*, map(c -> BigInt(c[2] - (c[1] - 1)), cube))
end

function run_p2(steps)
    steps = deepcopy(steps)
    on_cubes = []
    for (state, limits) in steps
        on_cubes_new = []
        for cube_limits in on_cubes
            intersection = intersect(cube_limits, limits)
            if isempty(intersection)
                push!(on_cubes_new, cube_limits)
            else
                for part in split_cube(cube_limits, intersection)
                    push!(on_cubes_new, part)
                end
            end
        end
        if state
            push!(on_cubes_new, limits)
        end
        on_cubes = on_cubes_new
    end
    res = sum(get_size.(on_cubes))
    println("Part 2: ", res)
end

function run_puzzle(filename)
    steps = read_input(filename)
    run_p1(steps)
    run_p2(steps)
end

run_puzzle(ARGS[1])
