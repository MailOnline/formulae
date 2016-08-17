public enum Symbol {
    case mathOperator(Operator)
    case mathParenthesis(Parenthesis)

    init?(symbol: String) {

        if let newOperator = Operator(rawValue: symbol) {
            self = .mathOperator(newOperator)
            return
        }

        if let newParenthesis = Parenthesis(rawValue: symbol) {
            self = .mathParenthesis(newParenthesis)
            return
        }

        return nil
    }
}

extension Symbol: Equatable {}

public func == (lhs: Symbol, rhs: Symbol) -> Bool {

    switch(lhs, rhs) {
    case (.mathOperator(let x), .mathOperator(let y)): return x == y
    case (.mathParenthesis(let x), .mathParenthesis(let y)): return x == y
    default: return false
    }
}

public enum Parenthesis: String {
    case open = "("
    case close = ")"
}

extension Parenthesis: Equatable {}

private enum Associativity {
    case left
    case right
}

public enum Operator: String {
    case plus = "+"
    case minus = "-"
    case multiplication = "*"
    case division = "/"
    case power = "^"

    private var precendence: Int {
        switch self {
        case .plus, .minus: return 2
        case .multiplication, .division: return 3
        case .power: return 4
        }
    }

    private var associativity: Associativity {
        switch self {
        case .plus, .minus, .multiplication, .division: return .left
        case .power: return .right
        }
    }
}

extension Operator: Equatable {}

public enum Token {
    case variable(String)
    case constant(Double)
    case mathSymbol(Symbol)
}

extension Token: Equatable {}

public func == (lhs: Token, rhs: Token) -> Bool {
    switch(lhs, rhs) {
    case (.variable(let x), .variable(let y)): return x == y
    case (.constant(let x), .constant(let y)): return x == y
    case (.mathSymbol(let x), .mathSymbol(let y)): return x == y
    default: return false
    }
}

// https://en.wikipedia.org/wiki/Shunting-yard_algorithm
public func tokenize(_ expression: [String], output: [Token] = [], symbolStack: [Symbol] = []) -> [Token] {
    guard let first = expression.first else {
        return output + symbolStack.map { .mathSymbol($0) }
    }

    let subExpression = Array(expression.dropFirst())

    guard let newSymbol = Symbol(symbol: first) else {

        if let n = Double.init(first) {
            return tokenize(subExpression, output: output + [.constant(n)], symbolStack: symbolStack)
        }
        else {
            return tokenize(subExpression, output: output + [.variable(first)], symbolStack: symbolStack)
        }
    }

    guard let firstSymbol = symbolStack.first else {
        return tokenize(subExpression, output: output, symbolStack: [newSymbol])
    }

    switch (newSymbol, firstSymbol) {

    case (.mathOperator(let newOp), .mathOperator(let oldOp)) where (newOp.precendence >= oldOp.precendence && newOp.associativity == .right):
        return tokenize(subExpression, output: output, symbolStack: [newSymbol] + symbolStack)

    case (.mathOperator(let newOp), .mathOperator(let oldOp)) where newOp.precendence > oldOp.precendence:
        return tokenize(subExpression, output: output, symbolStack: [newSymbol] + symbolStack)

    case (.mathOperator, .mathOperator):
        return tokenize(expression, output: output + [.mathSymbol(firstSymbol)], symbolStack: Array(symbolStack.dropFirst()))

    case (.mathParenthesis(.open), _):
        return tokenize(subExpression, output: output, symbolStack: [newSymbol] + symbolStack)

    case (.mathParenthesis(.close), .mathParenthesis(.open)):
        return tokenize(subExpression, output: output, symbolStack: Array(symbolStack.dropFirst()))

    case (_, .mathParenthesis(.open)):
        return tokenize(subExpression, output: output, symbolStack: [newSymbol] + symbolStack)

    case (.mathParenthesis(.close), .mathOperator):
        return tokenize(expression, output: output + [.mathSymbol(firstSymbol)], symbolStack: Array(symbolStack.dropFirst()))
        
    default:
        fatalError("newSymbol:\(newSymbol)\noldSymbol:\(firstSymbol)")
    }
}
