#!/usr/bin/env julia

using DataStructures

function read_input(filename)
    line_iterator = Iterators.Stateful(eachline(open(filename)))
    starting_polymer = popfirst!(line_iterator)
    popfirst!(line_iterator)
    pair_substitutions = []
    for line in line_iterator
        push!(pair_substitutions, split(line, " -> "))
    end
    pair_substitutions_extended = Dict([(p, (p[1] * s, s * p[2])) for (p, s) in pair_substitutions])
    starting_polymer, pair_substitutions_extended
end

function step_pair_count(pair_count, substitutions)
    new_pair_count = DefaultDict(0)
    for (key, value) in pair_count
        if haskey(substitutions, key)
            p1, p2 = substitutions[key]
            new_pair_count[p1] += value
            new_pair_count[p2] += value
        else
            new_pair_count[key] += value
        end
    end
    new_pair_count
end

function get_result(pair_count, starting_polymer)
    char_count = DefaultDict(0)
    for (key, value) in pair_count
        char_count[key[1]] += value
        char_count[key[2]] += value
    end
    char_count[starting_polymer[1]] += 1
    char_count[starting_polymer[end]] += 1
    fld(maximum(values(char_count)) - minimum(values(char_count)), 2)
end

function run_puzzle(filename)
    pair_count = DefaultDict(0)
    starting_polymer, pair_substitutions_extended = read_input(filename)

    for pair in map(x -> reduce(*, x), zip(starting_polymer[1:end-1], starting_polymer[2:end]))
        pair_count[pair] += 1
    end

    for _ = 1:10
        pair_count = step_pair_count(pair_count, pair_substitutions_extended)
    end
    println("Part 1: ", get_result(pair_count, starting_polymer))
    for _ = 1:30
        pair_count = step_pair_count(pair_count, pair_substitutions_extended)
    end
    println("Part 2: ", get_result(pair_count, starting_polymer))

end

run_puzzle(ARGS[1])
