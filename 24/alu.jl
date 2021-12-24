#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

using DataStructures

struct Variable
    name::Char
end

struct Constant
    value::Int
end

struct ReadInput
    target::Variable
end

struct Operation
    target::Variable
    operand::Union{Variable,Constant}
    operator
end

function get_value(state, constant::Constant)
    return constant.value
end

function get_value(state, variable::Variable)
    return state[variable.name]
end

function execute!(op::ReadInput, state, input)
    state[op.target.name] = popfirst!(input)
end

function execute!(op::Operation, state, input)
    state[op.target.name] = op.operator(
        get_value(state, op.target), get_value(state, op.operand)
    )
end

function parse_program(filename)
    operations = []
    for line in eachline(open(filename))
        push!(operations, parse_line(line))
    end
    operations
end

function parse_line(line)
    op, tail = split(line, ' ', limit = 2)
    if op == "inp"
        return ReadInput(parse_element(tail))
    else
        el1, el2 = split(tail, ' ')
        if op == "add"
            operation = +
        elseif op == "div"
            operation = fld
        elseif op == "mul"
            operation = *
        elseif op == "mod"
            operation = mod
        elseif op == "eql"
            operation = (a, b) -> a == b ? 1 : 0
        else
            throw("Operation " * op * " not defined.")
        end
        return Operation(parse_element(el1), parse_element(el2), operation)
    end
end

function parse_element(elem)
    value_or_nothing = tryparse(Int, elem)
    if value_or_nothing !== nothing
        return Constant(value_or_nothing)
    end
    if length(elem) > 1
        throw("Invalid element " * e)
    end
    return Variable(elem[1])
end

function run_program(program, input)
    state = DefaultDict(0)
    input = deepcopy(input)
    for operation in program
        execute!(operation, state, input)
    end
    return state
end

function run_puzzle(filename)
    monad = parse_program(filename)
    for model_number in reverse(parse(Int, "1"^14):parse(Int, "9"^14))
        model_nr_string = string(model_number)
        if occursin('0', model_nr_string)
            continue
        end
        input = [parse(Int, x) for x in collect(model_nr_string)]
        res_state = run_program(monad, input)
        if res_state['z'] == 0
            println("Part 1: ", model_number)
            break
        else
            println(model_nr_string)
        end
    end
end

run_puzzle(ARGS[1])
