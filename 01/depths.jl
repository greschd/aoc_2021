#!/usr/bin/env julia

function count_increasing(values)
    sum(Int32(second > first) for (first, second) in zip(values, values[2:length(values)]))
end

function get_window_sums(values, window_size = 3)
    index_offset = window_size - 1
    [sum(values[i:i+index_offset]) for i in (1:length(values)-index_offset)]
end

lines = readlines(open("input.txt"))
values = [parse(Int32, i) for i in lines]
println("increasing:", count_increasing(values))
println("increasing windows:", count_increasing(get_window_sums(values)))
