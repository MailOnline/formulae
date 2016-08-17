import ReactiveCocoa

public enum ObservableToken {
    case observable(Observable)
    case constant(Double)
    case mathOperator(Operator)
}

private func + (lhs: ObservableToken, rhs: ObservableToken) -> ObservableToken {
    switch (lhs, rhs) {
    case (.observable(let l), .observable(let r)): return .observable(l + r)
    case (.constant(let l), .constant(let r)): return .constant(l + r)
    case (.constant(let l), .observable(let r)): return .observable(.readOnly(Property(value: l)) + r)
    case (.observable, .constant): return rhs + lhs
    default: fatalError()
    }
}

public enum Observable {
    case readOnly(Property<Double>)
    case readWrite(MutableProperty<Double>)
}

private func + (lhs: Observable, rhs: Observable) -> Observable {
    return apply(f: +, lhs: lhs, rhs: rhs)
}

private func apply(f: (Double, Double) -> Double, lhs: Observable, rhs: Observable) -> Observable {
    switch (lhs, rhs) {
    case (.readOnly(let x), .readOnly(let y)):
        return .readOnly(x.combineLatest(with: y).map(f))
    case (.readOnly, .readWrite(let y)):
        return apply(f: f, lhs: lhs, rhs: .readOnly(Property(y)))
    case (.readWrite, .readOnly):
        return apply(f: f, lhs: rhs, rhs: lhs)
    case (.readWrite(let x), .readWrite(let y)):
        let pX = Property(x)
        let pY = Property(y)
        return apply(f: f, lhs: .readOnly(pX), rhs: .readOnly(pY))
    }
}

private func apply(mathOperator: Operator, toStack stack: [ObservableToken]) -> [ObservableToken] {
    let d = stack.deconstructed()

    switch (mathOperator, d.0, d.1, d.2)  {
    case (.plus, let x, let y, let xs): return [x + y] + xs
//    case (.minus, let x, let y, let xs): fatalError("minus not implemented")
//    case (.multiplication, let x, let y, let xs): : fatalError("multiplication not implemented")
//    case (.division, let x, let y, let xs): : fatalError("division not implemented")
//    case (.power, let x, let y, let xs): : fatalError("power not implemented")
    default: fatalError("\(mathOperator) not implemented")
    }
}

public func createObservableTokens(polishTokensMap: [String: [Token]] = [:]) -> ([ObservableToken], Token) -> [ObservableToken] {

    // https://en.wikipedia.org/wiki/Memoization
    var memo: [String: MutableProperty<Double>] = [:]

    func _createObservableTokens(stack: [ObservableToken], token: Token) -> [ObservableToken] {

        func _createObservableProperty(_ variable: String) -> [ObservableToken] {

            if let property = memo[variable] {
                return [.observable(.readWrite(property))]
            }

            let tokens = polishTokensMap[variable]!
            //1st check if we are dealing with just a var (simpler case)
            guard tokens.count != 1 else {

                let property = MutableProperty(0.0)
                memo[variable] = property
                return [.observable(.readWrite(property))]
            }

            //2nd we are dealing with a formula, so we need to recursively solve this
            return tokens.reduce([], _createObservableTokens)
        }

        switch token {
        case .constant(let constant): return [.constant(constant)] + stack
        case .variable(let variable): return _createObservableProperty(variable) + stack
        case .mathSymbol(.mathOperator(let op)): return apply(mathOperator: op, toStack: stack)
        default: fatalError("token: \(token)\nstack: \(stack)")
        }
    }
    
    return _createObservableTokens
}
