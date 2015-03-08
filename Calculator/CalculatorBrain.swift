//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Patrick Dawson on 02.03.15.
//  Copyright (c) 2015 Patrick Dawson. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: Printable {
        case Operand(Double)
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let value):
                    return "\(value)"
                case .Constant(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                default: return ""
                }
            }
        }
        
        var precedence: Int {
            get {
                switch self {
                case .BinaryOperation(_, let precedence, _):
                    return precedence
                default:
                    return Int.max
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues: [String:Double] = [:]
    
    init() {
        func learnOperation(operation: Op) {
            knownOps[operation.description] = operation
        }
        
        learnOperation(Op.BinaryOperation("×", 2, *))
        learnOperation(Op.BinaryOperation("÷", 2) { $1 / $0 })
        learnOperation(Op.BinaryOperation("+", 1, +))
        learnOperation(Op.BinaryOperation("−", 1) { $1 - $0 })
        learnOperation(Op.UnaryOperation("√", sqrt))
        learnOperation(Op.UnaryOperation("sin") { sin($0) })
        learnOperation(Op.UnaryOperation("cos") { cos($0) })
        learnOperation(Op.UnaryOperation("±") { -1 * $0 })
        learnOperation(Op.Constant("π", M_PI))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Constant(_, let operand):
                return (operand, remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            default: return(nil, remainingOps)
            }
        }
        
        return (nil, ops)
    }
    
    private func encapsulateInParenthesis(str: String) -> String {
        return "(\(str))"
    }
    
    private func description(ops: [Op]) -> (result: String, remainingOps: [Op], precedence: Int) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
                
            case .Operand(let value):
                return (String(format: "%g", value) , remainingOps, op.precedence)
            case .UnaryOperation(let symbol, _):
                let operand = description(remainingOps)
                
                var result = symbol
                result += encapsulateInParenthesis(operand.result)
                
                return (result, operand.remainingOps, op.precedence)
                
            case .BinaryOperation(_, let precedence, _):
                let op1 = description(remainingOps)
                var op1Str = op1.result
                if op1.precedence < precedence {
                    op1Str = encapsulateInParenthesis(op1Str)
                }
                
                let op2 = description(op1.remainingOps)
                var op2Str = op2.result
                if op2.precedence < precedence {
                    op2Str = encapsulateInParenthesis(op2Str)
                }
                
                var result = "\(op2Str) \(op.description) \(op1Str)"
                return (result, op2.remainingOps, precedence)
                
            default:
                return (op.description, remainingOps, op.precedence)
            }
        }
        
        return ("?", ops, Int.max)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("Result: \(result) with remainder: \(remainder)")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
    func clearStack() {
        opStack = []
    }
    
    func clearVariables() {
        variableValues = [:]
    }
    
    // MARK:- Computed properties
    var description: String {
        get {
            var desc = ""
            var remainder: [Op]
            var expr: String
            
            (desc, remainder, _) = description(opStack)
            
            while !remainder.isEmpty {
                (expr, remainder, _) = description(remainder)
                desc = "\(expr), " + desc
            }
            
            return "\(desc) ="
        }
    }
}