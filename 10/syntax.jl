#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

using DataStructures

PAIRS = ["()", "[]", "<>", "{}"]

ILLEGAL_CHARS_PTS = Dict(
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137
)

function line_points_p1(line)
    pair_stack = Stack{String}()
    for char in line
        pair_idx = findfirst(map(pair -> char in pair, PAIRS))
        pair = PAIRS[pair_idx]
        if PAIRS[pair_idx][1] == char # opening
            push!(pair_stack, pair)
        else #closing
            if first(pair_stack) == pair
                pop!(pair_stack)
            else
                return ILLEGAL_CHARS_PTS[char]
            end
        end
    end
    return 0
end

COMPLETION_CHARS_PTS = Dict(
    ')' => 1,
    ']' => 2,
    '}' => 3,
    '>' => 4
)


function line_points_p2(line)
    pair_stack = Stack{String}()
    for char in line
        pair_idx = findfirst(map(pair -> char in pair, PAIRS))
        pair = PAIRS[pair_idx]
        if PAIRS[pair_idx][1] == char # opening
            push!(pair_stack, pair)
        else #closing
            if first(pair_stack) == pair
                pop!(pair_stack)
            else
                return 0 # discard corrupted lines
            end
        end
    end
    res = 0
    while !isempty(pair_stack)
        res *= 5
        res += COMPLETION_CHARS_PTS[pop!(pair_stack)[2]]
    end
    return res
end

function run_puzzle(filename)
    lines = readlines(open(filename))
    println(sum(line_points_p1.(lines)))
    scores_incomplete_lines = filter(x -> x !== 0, line_points_p2.(lines))
    res_p2 = sort(scores_incomplete_lines)[fld(length(scores_incomplete_lines) + 1, 2)]
    println(res_p2)
end

run_puzzle(ARGS[1])
