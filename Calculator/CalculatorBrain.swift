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
        case BinaryOperation(String, (Double, Double) -> Double)
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
                case .BinaryOperation(let symbol, _):
                    return symbol
                default: return ""
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
        
        learnOperation(Op.BinaryOperation("×", *))
        learnOperation(Op.BinaryOperation("÷") { $1 / $0 })
        learnOperation(Op.BinaryOperation("+", +))
        learnOperation(Op.BinaryOperation("−") { $1 - $0 })
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
            case .BinaryOperation(_, let operation):
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
    
    private func description(ops: [Op]) -> (result: String, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
                
            case .UnaryOperation(let symbol, _):
                let operandDescription = description(remainingOps)
                let opStr = operandDescription.result ?? "?"
                
                return ("\(op.description)(\(opStr))", operandDescription.remainingOps)
                
            case .BinaryOperation(_, _):
                let op1Description = description(remainingOps)
                let op2Description = description(op1Description.remainingOps)
                let op1Str = op1Description.result ?? "?"
                let op2Str = op2Description.result ?? "?"
                
                return ("\(op2Str) \(op.description) \(op1Str)", op2Description.remainingOps)
                
            default:
                return (op.description, remainingOps)
            }
        }
        
        return ("", ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
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
    
    // MARK:- Computed properties
    var description: String {
        get {
            let (result, remainder) = description(opStack)
            return "\(result) ="
        }
    }
}