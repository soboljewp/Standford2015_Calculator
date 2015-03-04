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
        case NamedOperand(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let value):
                    return "\(value)"
                case .NamedOperand(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
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
        learnOperation(Op.NamedOperand("π", M_PI))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .NamedOperand(_, let operand):
                return (operand, remainingOps)
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
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
}