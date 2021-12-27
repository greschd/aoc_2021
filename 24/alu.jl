#!/usr/bin/env julia
#=
exec julia --project=. "${BASH_SOURCE[0]}" "$@"
=#

using DataStructures

struct Variable
    name::Char
end

abstract type Expression end
struct Constant <: Expression
    value::Int
end

abstract type Operation end
abstract type UnaryOperation <: Operation end
abstract type BinaryOperation <: Operation end

struct Inp <: UnaryOperation
    target::Variable
end

struct Add <: BinaryOperation
    lhs::Variable
    rhs::Union{Constant,Variable}
end

struct Mul <: BinaryOperation
    lhs::Variable
    rhs::Union{Constant,Variable}
end

struct Div <: BinaryOperation
    lhs::Variable
    rhs::Union{Constant,Variable}
end

struct Mod <: BinaryOperation
    lhs::Variable
    rhs::Union{Constant,Variable}
end

struct Eql <: BinaryOperation
    lhs::Variable
    rhs::Union{Constant,Variable}
end



struct Input <: Expression
    index::Int
end

struct Literal <: Expression
    value::Int
end

struct VarExpr <: Expression
    name::Char
end

struct Sum <: Expression
    lhs::Expression
    rhs::Expression
end

struct Product <: Expression
    lhs::Expression
    rhs::Expression
end

struct Fraction <: Expression
    lhs::Expression
    rhs::Expression
end

struct Remainder <: Expression
    lhs::Expression
    rhs::Expression
end

struct IsEqual <: Expression
    lhs::Expression
    rhs::Expression
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
        return Inp(parse_element(tail))
    else
        el1, el2 = split(tail, ' ')
        if op == "add"
            operation = Add
        elseif op == "div"
            operation = Div
        elseif op == "mul"
            operation = Mul
        elseif op == "mod"
            operation = Mod
        elseif op == "eql"
            operation = Eql
        else
            throw("Operation " * op * " not defined.")
        end
        return operation(parse_element(el1), parse_element(el2))
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
    # return Variable(VARIABLE_IDX_MAPPING[elem[1]])
    return Variable(elem[1])
end

function split_by_input(program)
    res_instructions = []
    current_instr = []
    for instr in program
        if typeof(instr) == Inp
            current_instr = []
            push!(res_instructions, current_instr)
        end
        push!(current_instr, instr)
    end
    res_instructions
end

struct State
    variables::Dict
    inputs::Vector{Any}
end

function evaluate(program, initial_state::State)
    state = deepcopy(initial_state)
    for instruction in program
        apply!(state, instruction)
    end
    return state
end

function apply!(state::State, instruction::Inp)
    state.variables[instruction.target.name] = popfirst!(state.inputs)
end

function apply!(state::State, instruction::BinaryOperation)
    state.variables[instruction.lhs.name] = evaluate_binop(instruction, get_value(state, instruction.lhs), get_value(state, instruction.rhs))
end

function get_value(state, constant::Constant)
    return constant
end

function get_value(state, variable::Variable)
    return state.variables[variable.name]
end

function evaluate_binop(instruction::Mul, lhs::Constant, rhs::Constant)
    return Constant(lhs.value * rhs.value)
end

function evaluate_binop(instruction::Mul, lhs::Expression, rhs::Expression)
    Product(lhs, rhs)
end

function evaluate_binop(instruction::Add, lhs::Constant, rhs::Expression)
    return evaluate_binop(instruction, rhs, lhs)
end

function evaluate_binop(instruction::Mul, lhs::Constant, rhs::Expression)
    return evaluate_binop(instruction, rhs, lhs)
end

function evaluate_binop(instruction::Eql, lhs::Constant, rhs::Expression)
    return evaluate_binop(instruction, rhs, lhs)
end

function evaluate_binop(instruction::Mul, lhs::Expression, rhs::Constant)
    if rhs.value == 0
        return Constant(0)
    elseif rhs.value == 1
        return lhs
    end
    return Product(lhs, rhs)
end

function evaluate_binop(instruction::Add, lhs::Constant, rhs::Constant)
    return Constant(lhs.value + rhs.value)
end

function evaluate_binop(instruction::Add, lhs::Expression, rhs::Constant)
    if rhs.value == 0
        return lhs
    end
    return Sum(lhs, rhs)
end

function evaluate_binop(instruction::Add, lhs::Expression, rhs::Expression)
    return Sum(lhs, rhs)
end

function evaluate_binop(instruction::Mod, lhs::Constant, rhs::Constant)
    return Constant(mod(lhs.value, rhs.value))
end

function evaluate_binop(instruction::Mod, lhs::Expression, rhs::Expression)
    return Remainder(lhs, rhs)
end

function evaluate_binop(instruction::Div, lhs::Constant, rhs::Constant)
    return Constant(div(lhs.value, rhs.value))
end


function evaluate_binop(instruction::Div, lhs::Expression, rhs::Constant)
    if rhs.value == 1
        return lhs
    end
    return Fraction(lhs, rhs)
end

function evaluate_binop(instruction::Eql, lhs::Constant, rhs::Constant)
    Constant(lhs.value == rhs.value ? 1 : 0)
end

function evaluate_binop(instruction::Eql, lhs::Expression, rhs::Expression)
    if (minval(lhs) > maxval(rhs)) | (minval(rhs) > maxval(lhs))
        return Constant(0)
    end
    IsEqual(lhs, rhs)
end

function minval(expr::Input)
    return 1
end

function maxval(expr::Input)
    return 9
end

function minval(expr::Sum)
    return minval(expr.lhs) + minval(expr.rhs)
end

function maxval(expr::Sum)
    return maxval(expr.lhs) + maxval(expr.rhs)
end

function minval(expr::Remainder)
    0
end

function maxval(expr::Remainder)
    maxval(expr.rhs) - 1
end

function minval(expr::Constant)
    expr.value
end

function maxval(expr::Constant)
    expr.value
end

function minval(expr::IsEqual)
    0
end

function maxval(expr::IsEqual)
    1
end

function evaluate_expr(expr::Sum, z, inp)
    evaluate_expr(expr.lhs, z, inp) + evaluate_expr(expr.rhs, z, inp)
end


function evaluate_expr(expr::Product, z, inp)
    evaluate_expr(expr.lhs, z, inp) * evaluate_expr(expr.rhs, z, inp)
end

function evaluate_expr(expr::Constant, z, inp)
    expr.value
end

function evaluate_expr(expr::VarExpr, z, inp)
    z
end

function evaluate_expr(expr::Input, z, inp)
    inp
end

function evaluate_expr(expr::Fraction, z, inp)
    div(evaluate_expr(expr.lhs, z, inp), evaluate_expr(expr.rhs, z, inp))
end

function evaluate_expr(expr::IsEqual, z, inp)
    evaluate_expr(expr.lhs, z, inp) == evaluate_expr(expr.rhs, z, inp) ? 1 : 0
end

function evaluate_expr(expr::Remainder, z, inp)
    mod(evaluate_expr(expr.lhs, z, inp), evaluate_expr(expr.rhs, z, inp))
end

function find_maximal_part_nr!(partial_program_expressions, initial_state, invalid_states, in_reverse = true)
    iter_idx = length(partial_program_expressions)
    if initial_state in invalid_states[iter_idx]
        return nothing
    end
    iter_range = 1:9
    if in_reverse
        iter_range = reverse(iter_range)
    end
    for next_input in iter_range
        # if iter_idx > 11
        #     println(iter_idx, ": ", next_input)
        # end
        next_state = evaluate_expr(partial_program_expressions[1], initial_state, next_input)
        if length(partial_program_expressions) == 1
            if next_state == 0
                return [next_input]
            end
        else
            res = find_maximal_part_nr!(partial_program_expressions[2:end], next_state, invalid_states, in_reverse)
            if res === nothing
                push!(invalid_states[iter_idx-1], next_state)
            else
                return vcat([next_input], res)
            end
        end
    end
end

function run_puzzle(filename)
    program = parse_program(filename)
    program_split = split_by_input(program)
    initial_vars = Dict{Char,Any}('w' => VarExpr('w'), 'x' => VarExpr('x'), 'y' => VarExpr('y'), 'z' => VarExpr('z'))
    initial_vars_zero = Dict{Char,Any}('w' => Constant(0), 'x' => Constant(0), 'y' => Constant(0), 'z' => Constant(0))
    evaluated_parts = [evaluate(part, State(i == 1 ? initial_vars_zero : initial_vars, [Input(i)])).variables['z'] for (i, part) in enumerate(program_split)]

    invalid_states = Dict([(i, Set()) for i in 1:14])
    res = find_maximal_part_nr!(evaluated_parts, 0, invalid_states)

    println("Part 1: ", reduce(*, string.(res)))

    res2 = find_maximal_part_nr!(evaluated_parts, 0, invalid_states, false)

    println("Part 2: ", reduce(*, string.(res2)))
end

run_puzzle(ARGS[1])
