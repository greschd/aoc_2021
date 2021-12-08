#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

using Combinatorics

DIGIT_TO_SEGMENTS = Dict(
    0 => "abcefg",
    1 => "cf",
    2 => "acdeg",
    3 => "acdfg",
    4 => "bcdf",
    5 => "abdfg",
    6 => "abdefg",
    7 => "acf",
    8 => "abcdefg",
    9 => "abcdfg",
)
VALID_SEGMENT_SEQUENCES = values(DIGIT_TO_SEGMENTS)
SEGMETS_TO_DIGITS = Dict([(value, key) for (key, value) in DIGIT_TO_SEGMENTS])
CHAR_TO_IDX = Dict([(c, i) for (i, c) in enumerate(collect("abcdefg"))])
ALL_CHARS = collect("abcdefg")

function parse_input(filename)
    res = []
    for line in eachline(open(filename))
        in_part, out_part = split(line, " | ")
        input_signals = collect.(split(in_part, " "))
        output_signals = collect.(split(out_part, " "))
        push!(res, (input_signals, output_signals))
    end
    res
end

function count_output_lengths(values)
    res = zeros(Int, 7)
    for (_, output_signals) in values
        for signal in output_signals
            res[length(signal)] += 1
        end
    end
    res
end

function convert_signal(signal, perm)
    signal_indices = [CHAR_TO_IDX[c] for c in collect(signal)]
    reduce(*, sort(perm[signal_indices]))
end

function signal_is_valid(signal, perm)
    return convert_signal(signal, perm) in VALID_SEGMENT_SEQUENCES
end

function map_output(signals, perm)
    digits = [SEGMETS_TO_DIGITS[convert_signal(s, perm)] for s in signals]
    return sum([d * 10^(i - 1) for (i, d) in enumerate(reverse(digits))])
end

function determine_output(signals)
    input_signals, output_signals = signals
    all_signals = cat(input_signals, output_signals, dims = 1)
    for perm in permutations(ALL_CHARS)
        if all(signal_is_valid(signal, perm) for signal in all_signals)
            return map_output(output_signals, perm)
        end
    end
end

function run_puzzle(filename)
    parsed_input = parse_input(filename)
    out_lengths = count_output_lengths(parsed_input)

    println("Part 1: ", sum(out_lengths[[2, 4, 3, 7]]))

    println("Part 2: ", sum(determine_output.(parsed_input)))
end

run_puzzle(ARGS[1])
