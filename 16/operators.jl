#!/usr/bin/env julia

function parse_input(filename)
    integers = map(x -> parse(Int8, x, base = 16), collect(readline(open(filename))))
    bits = BitVector()
    for i in integers
        b4 = collect(bitstring(i))[end-3:end] .== '1'
        push!(bits, b4...)
    end
    bits
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

function parse_literal(bits)
    res_bin = BitVector()
    remainder_start_idx = 1
    while remainder_start_idx <= length(bits)
        group = bits[remainder_start_idx:min(length(bits), remainder_start_idx + 5)]
        remainder_start_idx += 5
        continue_bit = group[1]
        push!(res_bin, group[2:5]...)
        if !continue_bit
            break
        end
    end
    to_int(res_bin, BigInt), bits[remainder_start_idx:end]
end

function parse_operator(bits)
    length_type_id = bits[1]
    if length_type_id
        num_subpackets = to_int(bits[2:12])
        remainder = bits[13:end]
        sub_packets = []
        for i = 1:num_subpackets
            version, type, content, remainder = parse_packet(remainder)
            push!(sub_packets, (version, type, content))
        end
        return sub_packets, remainder
    else
        sub_packets_length = to_int(bits[2:16])
        sub_bits = bits[17:16+sub_packets_length]
        sub_packets = []
        while any(sub_bits)
            version, type, content, sub_bits = parse_packet(sub_bits)
            push!(sub_packets, (version, type, content))
        end
        return sub_packets, bits[17+sub_packets_length:end]
    end
end

function parse_packet(bits)
    version = to_int(bits[1:3])
    type = to_int(bits[4:6])
    if type == 4
        content, remainder = parse_literal(bits[7:end])
    else
        content, remainder = parse_operator(bits[7:end])
    end
    version, type, content, remainder
end

function accumulate_version(version, type, content::Integer)
    return version
end

function accumulate_version(version, type, content::Vector)
    return version + sum(accumulate_version(part...) for part in content)
end

function accumulate_version(version, type, content)
    return version + accumulate_version(content...)
end

function evaluate_packet(version, type, content)
    if type == 4
        return content
    else
        parts = [evaluate_packet(part...) for part in content]
        if type == 0
            return sum(parts)
        elseif type == 1
            return reduce(*, parts)
        elseif type == 2
            return minimum(parts)
        elseif type == 3
            return maximum(parts)
        elseif type == 5
            return parts[1] > parts[2] ? 1 : 0
        elseif type == 6
            return parts[1] < parts[2] ? 1 : 0
        elseif type == 7
            return parts[1] == parts[2] ? 1 : 0
        end
    end
end

function run_puzzle(filename)
    input = parse_input(filename)
    version, type, content, _ = parse_packet(input)
    packet_final = (version, type, content)
    println("Part 1: ", accumulate_version(packet_final...))
    println("Part 2: ", evaluate_packet(packet_final...))
end

run_puzzle(ARGS[1])
