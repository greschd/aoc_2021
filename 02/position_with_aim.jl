#!/usr/bin/env julia

struct Position
    aim
    horizontal_distance
    depth
end

function read_input(filename)
    lines = readlines(open(filename))
    split_lines = [split(l, " ") for l in lines]
    [(command, parse(Int32, step_size)) for (command, step_size) in split_lines]
end

function get_new_position(starting_position, movements)
    current_position = starting_position
    for (command, step_size) in movements
        if command == "forward"
            current_position = Position(
                current_position.aim,
                current_position.horizontal_distance + step_size,
                current_position.depth + (step_size * current_position.aim)
            )
        elseif command == "up"
            current_position = Position(
                current_position.aim - step_size,
                current_position.horizontal_distance,
                current_position.depth
            )
        elseif command == "down"
            current_position = Position(
                current_position.aim + step_size,
                current_position.horizontal_distance,
                current_position.depth
            )
        else
            throw(ArgumentError("Did not understand command " + command))
        end
    end
    current_position
end

function run(filename)
    movements = read_input(filename)
    final_position = get_new_position(Position(0, 0, 0), movements)
    println("Final position: ", final_position)
    println("Multiplied: ", final_position.horizontal_distance * final_position.depth)
end
run("test_input.txt")
run("input.txt")
