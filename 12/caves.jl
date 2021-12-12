#!/usr/bin/env julia

using DelimitedFiles
using DataStructures

function get_adjacency_list(input)
    res = DefaultDict(Set{String})
    for (p1, p2) in eachrow(input)
        push!(res[p1], p2)
        push!(res[p2], p1)
    end
    res
end

function issmallcave(val::String)
    all(islowercase, val)
end

function get_possible_paths(current_position, visited, adjacency_list, allow_small_cave_revisit = false)
    res = []
    for neighbor in adjacency_list[current_position]
        if neighbor == "start"
            continue
        elseif neighbor == "end"
            push!(res, vcat(visited, [neighbor]))
        else
            if issmallcave(neighbor) & (neighbor in visited)
                if allow_small_cave_revisit
                    res = vcat(res, get_possible_paths(neighbor, vcat(visited, [neighbor]), adjacency_list, false))
                else
                    continue
                end
            else
                res = vcat(res, get_possible_paths(neighbor, vcat(visited, [neighbor]), adjacency_list, allow_small_cave_revisit))
            end
        end
    end
    res
end

function run_puzzle(filename)
    input = readdlm(filename, '-', String)
    adjacency_list = get_adjacency_list(input)
    println("Part 1: ", length(get_possible_paths("start", ["start"], adjacency_list)))
    println("Part 2: ", length(get_possible_paths("start", Set(["start"]), adjacency_list, true)))
end

run_puzzle(ARGS[1])
