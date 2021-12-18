#!/usr/bin/env julia

function read_input(filename)
    res = []
    for line in eachline(open(filename))
        line = replace(line, "[" => "Any[")
        push!(res, eval(Meta.parse(line)))
    end
    res
end

function plain_tuple_indices(val)
    if (typeof(val[1]) == Int) & (typeof(val[2]) == Int)
        return [[]]
    end
    res = []
    if (typeof(val[1]) != Int)
        for r in plain_tuple_indices(val[1])
            push!(res, vcat([1], r))
        end
    end
    if (typeof(val[2]) != Int)
        for r in plain_tuple_indices(val[2])
            push!(res, vcat([2], r))
        end
    end
    res
end

function value_indices(val)
    res = []
    if typeof(val[1]) == Int
        push!(res, [1])
    else
        for r in value_indices(val[1])
            push!(res, vcat([1], r))
        end
    end
    if typeof(val[2]) == Int
        push!(res, [2])
    else
        for r in value_indices(val[2])
            push!(res, vcat([2], r))
        end
    end
    res
end

function get_at(val, idx)
    res = val
    for i in idx
        res = res[i]
    end
    res
end

function set_at(val, idx, new_val)
    res = val
    for i in idx[1:end-1]
        res = res[i]
    end
    res[idx[end]] = new_val
end

function add_at(val, idx, new_val)
    res = val
    for i in idx[1:end-1]
        res = res[i]
    end
    res[idx[end]] += new_val
end

function explode_first!(val)
    val_indices = value_indices(val)
    for idx in plain_tuple_indices(val)
        if length(idx) >= 4
            tup = get_at(val, idx)
            for (i, vidx) in enumerate(val_indices)
                if vidx[1:end-1] == idx
                    if checkbounds(Bool, val_indices, i - 1)
                        add_at(val, val_indices[i-1], tup[1])
                    end
                    if checkbounds(Bool, val_indices, i + 2)
                        add_at(val, val_indices[i+2], tup[2])
                    end
                    break
                end
            end
            set_at(val, idx, 0)
            return true
        end
    end
    return false
end

function split_first!(val)
    for idx in value_indices(val)
        v = get_at(val, idx)
        if v >= 10
            set_at(val, idx, Any[fld(v, 2), cld(v, 2)])
            return true
        end
    end
    return false
end

function snf_reduce!(val)
    val
    while true
        if explode_first!(val)
            continue
        end
        if split_first!(val)
            continue
        end
        break
    end
    # val
end

function snf_add(lhs, rhs)
    res = Any[lhs, rhs]
    snf_reduce!(res)
    res
end

function get_magnitude(val)
    3 * get_magnitude(val[1]) + 2 * get_magnitude(val[2])
end

function get_magnitude(val::Int)
    val
end

function run_puzzle(filename)
    input = read_input(filename)
    res = reduce(snf_add, deepcopy(input))
    println("Part 1: ", get_magnitude(res))

    max_pair_magnitude = 0
    for i = 1:length(input)
        for j = 1:length(input)
            if i == j
                continue
            end
            max_pair_magnitude = max(max_pair_magnitude, get_magnitude(snf_add(deepcopy(input[i]), deepcopy(input[j]))))
        end
    end
    println("Part 2: ", max_pair_magnitude)
end

run_puzzle(ARGS[1])
