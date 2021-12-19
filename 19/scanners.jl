#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

using DataStructures

ROTATION_GENERATORS = [
    [1 0 0; 0 1 0; 0 0 1],
    [1 0 0; 0 0 1; 0 -1 0],
    [0 0 1; 0 1 0; -1 0 0],
    [0 1 0; -1 0 0; 0 0 1],
]

function expand_generators(generators)
    res_set = Set([])
    for gen in generators
        union!(res_set, [gen])
        for rot in res_set
            new_rot = rot
            while true
                new_rot = gen * new_rot
                if new_rot in res_set
                    break
                end
                union!(res_set, [new_rot])
            end
        end
    end
    res_set
end

ROTATIONS = expand_generators(ROTATION_GENERATORS)

NEWAXIS = [CartesianIndex()]

function read_input(filename)
    scanners = []
    beacons = Matrix{Int}(undef, 0, 3)
    for line in eachline(open(filename))
        if occursin("---", line)
            continue
        elseif occursin(",", line)
            beacons = vcat(beacons, map(x -> parse(Int, x), split(line, ","))')
        else
            push!(scanners, beacons)
            beacons = Matrix{Int}(undef, 0, 3)
        end
    end
    push!(scanners, beacons)
    scanners
end

function get_distances(scanner)
    dist_mat = scanner[:, NEWAXIS, :] .- scanner[NEWAXIS, :, :]
    ni, nj, _ = size(dist_mat)
    res = []
    for i = 1:ni
        for j = 1:nj
            if i == j
                continue
            end
            push!(res, (i, j, dist_mat[i, j, :]))
        end
    end
    res
end

function contains_all(sensor, points)
    points_set = Set(filter(x -> all(abs.(x) .<= 1000), [p for p in eachrow(points)]))
    issubset(points_set, Set(eachrow(sensor)))
end

function validate_offset(candidate, reference, offset)
    contains_all(candidate, reference .- offset) & contains_all(reference, candidate .+ offset)
end

function try_match_scanner_norot(candidate, reference)
    candidate_vecs = get_distances(candidate)
    reference_vecs = get_distances(reference)
    matched_count = DefaultDict(0)

    rvec_set = Set([vec for (i, j, vec) in reference_vecs])

    for (ci, cj, cvec) in candidate_vecs
        if !(cvec in rvec_set)
            continue
        end
        for (ri, rj, rvec) in reference_vecs
            if cvec == rvec
                offset = (reference[ri, :] .- candidate[ci, :])'
                matched_count[offset] += 1
                if matched_count[offset] >= 12 * 11
                    return offset, true
                end
            end
        end
    end
    return nothing, false
end

function try_match_scanner(candidate, reference)
    for rotation in ROTATIONS
        candidate_rotated = candidate * rotation
        offset, success = try_match_scanner_norot(candidate_rotated, reference)
        if success
            return offset, candidate_rotated, success
        end
    end
    return nothing, nothing, false
end

function match_all_scanners(scanners)
    matched_scanners = [([0 0 0], scanners[1])]
    unmatched_scanners = scanners[2:end]
    new_matched_scanners = deepcopy(matched_scanners)
    while !isempty(unmatched_scanners)
        new_matched_scanners_this_iter = []
        unmatched_scanners_this_iter = []
        for candidate in unmatched_scanners
            matched = false
            for (r_offset, reference) in new_matched_scanners
                offset, rotated_scanner, success = try_match_scanner(candidate, reference)
                if success
                    full_offset = r_offset .+ offset
                    push!(matched_scanners, (full_offset, rotated_scanner))
                    push!(new_matched_scanners_this_iter, (full_offset, rotated_scanner))
                    matched = true
                    break
                end
            end
            if !matched
                push!(unmatched_scanners_this_iter, candidate)
            end
        end
        if isempty(new_matched_scanners_this_iter)
            throw("No change during an entire iteration.")
        end
        new_matched_scanners = new_matched_scanners_this_iter
        unmatched_scanners = unmatched_scanners_this_iter
    end
    matched_scanners
end

function count_beacons(matched_scanners)
    res = Set()
    for (offset, sc) in matched_scanners
        union!(res, eachrow(sc .+ offset))
    end
    length(res)
end

function get_max_manhattan_dist(matched_scanners)
    offsets = vcat([sc[1] for sc in matched_scanners]...)
    dist_mat = offsets[:, NEWAXIS, :] .- offsets[NEWAXIS, :, :]
    manhattan_dist = sum(abs.(dist_mat), dims = 3)
    maximum(manhattan_dist)
end

function run_puzzle(filename)
    scanners = read_input(filename)
    matched_scanners = match_all_scanners(scanners)
    println("Part 1: ", count_beacons(matched_scanners))
    println("Part 2: ", get_max_manhattan_dist(matched_scanners))
end

run_puzzle(ARGS[1])
