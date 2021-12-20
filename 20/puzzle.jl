#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

function read_input(filename)
    line_iterator = Iterators.Stateful(eachline(open(filename)))
    key = collect(popfirst!(line_iterator)) .== '#'
    popfirst!(line_iterator)
    img = []
    for line in line_iterator
        push!(img, collect(line) .== '#')
    end
    img_mat = cat(img..., dims = 2)
    key, img_mat'
end

function to_int(bits, T = Int64)
    res = T(0)
    for b in bits
        res <<= 1
        if b
            res += 1
        end
    end
    res
end

function expand(img, key, default = false)
    nx, ny = size(img)
    img_extended = fill(default, (nx + 4, ny + 4))
    img_extended[3:end-2, 3:end-2] = img
    res_mat = falses(nx + 2, ny + 2)
    for i = 1:nx+2
        for j = 1:ny+2
            index_bits = img_extended[i:i+2, j:j+2]'
            index = to_int(index_bits) + 1
            res_mat[i, j] = key[index]
        end
    end
    if default
        new_default = key[end]
    else
        new_default = key[1]
    end
    res_mat, new_default
end

function visualize(img)
    for line in eachrow(img)
        line_str = ""
        for bit in line
            if bit
                line_str *= '#'
            else
                line_str *= '.'
            end
        end
        println(line_str)
    end
end

function run_puzzle(filename)
    key, img = read_input(filename)
    default = false
    for _ = 1:2
        img, default = expand(img, key, default)
    end
    println("Part 1: ", sum(img))
    for _ = 1:48
        img, default = expand(img, key, default)
    end
    println("Part 2: ", sum(img))
end

run_puzzle(ARGS[1])
