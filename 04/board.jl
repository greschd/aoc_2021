#!/usr/bin/env julia

using DelimitedFiles

BOARD_SIZE = 5

struct GameState
    boards
    marked
end

function read_input(filename)
    line_iterator = Iterators.Stateful(eachline(open(filename)))
    drawn_numbers = [parse(Int, val) for val in split(popfirst!(line_iterator), ",")]
    drawn_numbers

    boards = []
    while (!isempty(line_iterator))
        popfirst!(line_iterator)
        board_lines = collect(Iterators.take(line_iterator, BOARD_SIZE))
        board = map(item -> parse(Int, item), hcat([
            [item for item in split(line, r"[\s]+") if !(length(item) == 0)]
            for line in board_lines
        ]...))
        push!(boards, board)
    end
    drawn_numbers, permutedims(cat(boards..., dims = 3), (3, 1, 2))
end

function get_new_state(initial_state::GameState, number_to_mark::Int)
    GameState(
        initial_state.boards,
        (initial_state.marked) .| (initial_state.boards .== number_to_mark)
        # (initial_state.marked).or(falses(size(initial_state.boards)))
    )
end

function find_winners(game_state::GameState)
    marked = game_state.marked
    col_wins = dropdims(reduce(|, reduce(&, marked, dims = 2), dims = 3), dims = (2, 3))
    row_wins = dropdims(reduce(|, reduce(&, marked, dims = 3), dims = 2), dims = (2, 3))
    wins = col_wins .| row_wins
    findall(wins)
end

function sum_unmarked(game_state::GameState, winner::Int)
    winning_board = game_state.boards[winner, :, :]
    marks_winning = game_state.marked[winner, :, :]
    sum(winning_board[.!marks_winning])
end

function run_p1(filename)
    drawn_numbers, boards = read_input(filename)
    game_state = GameState(boards, falses(size(boards)))
    for number in drawn_numbers
        game_state = get_new_state(game_state, number)
        winners = find_winners(game_state)
        if (length(winners) > 0)
            winner = winners[1]
            score = sum_unmarked(game_state, winner) * number
            return score
        end
    end
end

function run_p2(filename)
    drawn_numbers, boards = read_input(filename)
    game_state = GameState(boards, falses(size(boards)))

    num_boards = size(boards)[1]
    previous_winners = Set()
    for number in drawn_numbers
        game_state = get_new_state(game_state, number)
        winners = Set(find_winners(game_state))
        if (length(winners) == num_boards)
            last_winner = pop!(setdiff(winners, previous_winners))
            score = sum_unmarked(game_state, last_winner) * number
            return score
        end
        previous_winners = winners
    end
end

println(run_p1(ARGS[1]))
println(run_p2(ARGS[1]))
