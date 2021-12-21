#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

using DataStructures

function read_input(filename)
    res = Vector{Int}()
    for line in eachline(open(filename))
        _, tail = split(line, ": ")
        push!(res, parse(Int, tail))
    end
    res
end

function mod_1_based(val, maxval)
    mod(val - 1, maxval) + 1
end

function run_dice_game(starting_positions)
    player_positions = deepcopy(starting_positions)
    num_players = length(starting_positions)
    player_scores = zeros(Int, (num_players,))
    player_idx = 1

    for roll_idx in Iterators.Stateful(1:typemax(Int))
        die_res = mod_1_based(roll_idx, 100)
        player_positions[player_idx] += die_res
        if mod_1_based(roll_idx, 3) == 3
            player_positions[player_idx] = mod_1_based(player_positions[player_idx], 10)
            player_scores[player_idx] += player_positions[player_idx]
            if player_scores[player_idx] >= 1000
                return player_scores, roll_idx
            end
            player_idx = mod_1_based(player_idx + 1, num_players)
        end
    end

end

function step_player(wfc)
    wfc_new = DefaultDict(BigInt(0))
    for ((pos, points), value) in wfc
        wfc_new[(mod_1_based(pos + 1, 10), points)] += value
        wfc_new[(mod_1_based(pos + 2, 10), points)] += value
        wfc_new[(mod_1_based(pos + 3, 10), points)] += value
    end
    wfc_new
end

function award_points(wfc)
    wfc_new = DefaultDict(BigInt(0))
    for ((pos, points), value) in wfc
        wfc_new[(pos, points + pos)] += value
    end
    wfc_new
end

function remove_winning(wfc)
    win_count = 0
    wfc_new = DefaultDict(0)
    for ((pos, points), value) in wfc
        if points >= 21
            win_count += value
        else
            wfc_new[(pos, points)] += value
        end
    end
    wfc_new, win_count
end

function run_player_step(wfc)
    wfc_new = wfc
    for _ = 1:3
        wfc_new = step_player(wfc_new)
    end
    wfc_new = award_points(wfc_new)
    return remove_winning(wfc_new)
end

function run_dirac_dice_game(starting_positions)
    p1, p2 = starting_positions
    wfc_p1 = Dict((p1, 0) => BigInt(1))
    wfc_p2 = Dict((p2, 0) => BigInt(1))

    p1_wins = []
    p2_wins = []

    while !(isempty(wfc_p1) & isempty(wfc_p2))
        wfc_p1, new_wins_p1 = run_player_step(wfc_p1)
        push!(p1_wins, new_wins_p1)
        wfc_p2, new_wins_p2 = run_player_step(wfc_p2)
        push!(p2_wins, new_wins_p2)
    end
    p1_wins, p2_wins
end

function evaluate_world_count(p1_wins, p2_wins)
    p1_world_count = BigInt(1)
    p2_world_count = BigInt(1)
    p1_win_count = BigInt(0)
    p2_win_count = BigInt(0)
    for (p1_w, p2_w) in zip(p1_wins, p2_wins)
        p1_world_count *= BigInt(27)
        p1_win_count += p1_w * p2_world_count
        p1_world_count -= p1_w

        p2_world_count *= BigInt(27)
        p2_win_count += p2_w * p1_world_count
        p2_world_count -= p2_w
    end
    p1_win_count, p2_win_count
end

function run_puzzle(filename)
    input = read_input(filename)
    scores, roll_count = run_dice_game(input)
    println("Part 1: ", minimum(scores) * roll_count)

    p1_wins, p2_wins = run_dirac_dice_game(input)
    println("Part 2: ", maximum(evaluate_world_count(p1_wins, p2_wins)))
end

run_puzzle(ARGS[1])
