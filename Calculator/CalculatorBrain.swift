//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Patrick Dawson on 02.03.15.
//  Copyright (c) 2015 Patrick Dawson. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // MARK: - private enum Op
    private enum Op: Printable {
        case Operand(Double)
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double, (Double -> String?)?)
        case BinaryOperation(String, Int, (Double, Double) -> Double, ((Double, Double) -> String?)?)
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
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _, _):
                    return symbol
                default: return ""
                }
            }
        }
        
        var precedence: Int {
            get {
                switch self {
                case .BinaryOperation(_, let precedence, _, _):
                    return precedence
                default:
                    return Int.max
                }
            }
        }
    }
    
    // MARK: - Members
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    private var error: String?
    
    var variableValues: [String:Double] = [:]
    
    // MARK:- Computed properties
    var description: String {
        get {
            if opStack.count > 0 {
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
            
            return " "
        }
    }
    
    // MAKR: - Methods
    init() {
        func learnOperation(operation: Op) {
            knownOps[operation.description] = operation
        }
        
        learnOperation(Op.BinaryOperation("×", 2, *, nil))
        learnOperation(Op.BinaryOperation("÷", 2, { $1 / $0 }, { div, _ in div == 0 ? "div by 0" : nil }))
        learnOperation(Op.BinaryOperation("+", 1, +, nil))
        learnOperation(Op.BinaryOperation("−", 1, { $1 - $0 }, nil))
        learnOperation(Op.UnaryOperation("√", sqrt, { $0 < 0 ? "sqrt on negative op" : nil }))
        learnOperation(Op.UnaryOperation("sin", { sin($0) }, nil))
        learnOperation(Op.UnaryOperation("cos", { cos($0) }, nil))
        learnOperation(Op.UnaryOperation("±", { -1 * $0 }, nil))
        learnOperation(Op.Constant("π", M_PI))
    }
    
    func evaluate() -> Double? {
        if opStack.count > 0 {
            let (result, remainder) = evaluate(opStack)
            println("Result: \(result) with remainder: \(remainder)")
            return result
        }
        return 0
    }
    
    func evaluateAndReportErrors() -> String? {
        error = " "
        let (result, _) = evaluate(opStack)
        return result == nil ? error : nil
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
    
    func popOperandFromStack() {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
    }
    
    func clearStack() {
        opStack = []
    }
    
    func clearVariables() {
        variableValues = [:]
    }
    
    // MARK: - private methods
    
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
                if let value = variableValues[symbol] {
                    return(value, remainingOps)
                }
                error = "Var not set"
                return (nil, remainingOps)
                
            case .UnaryOperation(_, let operation, let errorEval):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    if let errorMsg = errorEval?(operand) {
                        error = errorMsg
                        return (nil, operandEvaluation.remainingOps)
                    }
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, _, let operation, let errorEval):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        if let errorMsg = errorEval?(operand1, operand2) {
                            error = errorMsg
                            return (nil, op2Evaluation.remainingOps)
                        }
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
                
            default: return(nil, remainingOps)
            }
            
            error = "Not enough operands"
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
            case .UnaryOperation(let symbol, _, _):
                let operand = description(remainingOps)
                
                var result = symbol
                result += encapsulateInParenthesis(operand.result)
                
                return (result, operand.remainingOps, op.precedence)
                
            case .BinaryOperation(_, let precedence, _, _):
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
}