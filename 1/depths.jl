#!/usr/bin/env julia

function count_increasing(values)
    sum(Int32(second > first) for (first, second) in zip(values, values[2:length(values)]))
end

lines = readlines(open("input.txt"))
println(count_increasing([parse(Int32, i) for i in lines]))
