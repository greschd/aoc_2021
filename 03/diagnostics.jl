#!/usr/bin/env julia

function read_input(filename)
    lines = readlines(open(filename))
    reduce(vcat, permutedims.(collect.(lines)))
end

function to_decimal(bits)
    # inefficient, but it works...
    to_decimal(string.(Int.(bits)))
end

function to_decimal(characters::Union{Vector{Char},Vector{String}})
    parse(Int, reduce(string, characters), base = 2)
end

function is_1_most_common(column)
    num_entries = size(column, 1)
    sum(column .== '1') >= num_entries / 2.0
end

function get_rates(data)
    gamma_rate_bits = map(is_1_most_common, eachcol(data))
    epsilon_rate_bits = .!(gamma_rate_bits)
    gamma_rate = to_decimal(gamma_rate_bits)
    epsilon_rate = to_decimal(epsilon_rate_bits)
    gamma_rate, epsilon_rate
end

function run_p1(filename)
    gamma_rate, epsilon_rate = get_rates(read_input(filename))
    println("gamma: ", gamma_rate)
    println("epsilon: ", epsilon_rate)
    println("product: ", gamma_rate * epsilon_rate)
end

function get_filter_index(data, col_idx, value_to_keep_func)
    col = data[:, col_idx]
    col .== value_to_keep_func(col)
end

function filter_data(data, value_to_keep_func)
    counter = 0
    while true
        counter += 1
        filter_idx = get_filter_index(data, counter, value_to_keep_func)
        data = data[filter_idx, :]
        if size(data, 1) == 1
            break
        end
    end
    data[1, :]
end

function run_p2(filename)
    data = read_input(filename)
    o2gen_rating = to_decimal(filter_data(data, column -> is_1_most_common(column) ? '1' : '0'))
    co2scrub_rating = to_decimal(filter_data(data, column -> is_1_most_common(column) ? '0' : '1'))
    println("Oxygen generator rating: ", o2gen_rating)
    println("CO2 scrubber rating: ", co2scrub_rating)
    println("product: ", o2gen_rating * co2scrub_rating)
end

# println(to_decimal([true, false, true]))
println("## Part 1 ##")
run_p1("input.txt")
println()
println("## Part 2 ##")
run_p2("input.txt")
