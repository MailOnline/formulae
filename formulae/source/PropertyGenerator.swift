import ReactiveCocoa

private enum ObservableToken {
    case observable(Observable)
    case constant(Double)
    case mathOperator(Operator)
}

private func apply(f: (Double, Double) -> Double, lhs: ObservableToken, rhs: ObservableToken) -> ObservableToken {
    switch (lhs, rhs) {
    case (.observable(let x), .observable(let y)):
        return .observable(apply(f: f, lhs: x, rhs: y))
    case (.constant(let x), .constant(let y)):
        return .constant(f(x, y))
    case (.constant(let x), .observable(let y)):
        return .observable(apply(f: f, lhs: .readOnly(Property(value: x)), rhs: y))
    case (.observable(let x), .constant(let y)):
        return .observable(apply(f: f, lhs: x, rhs: .readOnly(Property(value: y))))
    default: fatalError("lhs:\(lhs), rhs\(rhs)")
    }
}

private func + (lhs: ObservableToken, rhs: ObservableToken) -> ObservableToken {
    return apply(f: +, lhs: lhs, rhs: rhs)
}

private func - (lhs: ObservableToken, rhs: ObservableToken) -> ObservableToken {
    return apply(f: -, lhs: lhs, rhs: rhs)
}

private func * (lhs: ObservableToken, rhs: ObservableToken) -> ObservableToken {
    return apply(f: *, lhs: lhs, rhs: rhs)
}

private func / (lhs: ObservableToken, rhs: ObservableToken) -> ObservableToken {
    return apply(f: /, lhs: lhs, rhs: rhs)
}

private func ^ (lhs: ObservableToken, rhs: ObservableToken) -> ObservableToken {
    return apply(f: ^, lhs: lhs, rhs: rhs)
}

public enum Observable {
    case readOnly(Property<Double>)
    case readWrite(MutableProperty<Double>)
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

private func + (lhs: Observable, rhs: Observable) -> Observable {
    return apply(f: +, lhs: lhs, rhs: rhs)
}

private func - (lhs: Observable, rhs: Observable) -> Observable {
    return apply(f: -, lhs: lhs, rhs: rhs)
}

private func * (lhs: Observable, rhs: Observable) -> Observable {
    return apply(f: *, lhs: lhs, rhs: rhs)
}

private func / (lhs: Observable, rhs: Observable) -> Observable {
    return apply(f: /, lhs: lhs, rhs: rhs)
}

private func ^ (lhs: Observable, rhs: Observable) -> Observable {
    return apply(f: ^, lhs: lhs, rhs: rhs)
}

private func apply(mathOperator: Operator, toStack stack: [ObservableToken]) -> [ObservableToken] {
    let d = stack.deconstructed()

    switch (mathOperator, d.0, d.1, d.2)  {
    case (.plus, let x, let y, let xs): return [x + y] + xs
    case (.minus, let x, let y, let xs): return [y - x] + xs
    case (.multiplication, let x, let y, let xs): return [x * y] + xs
    case (.division, let x, let y, let xs): return [y / x] + xs
    case (.power, let x, let y, let xs): return [y ^ x] + xs
    }
}

private func createObservableTokens(variableToTokens: [String: [Token]] = [:]) -> ([ObservableToken], Token) -> [ObservableToken] {

    // https://en.wikipedia.org/wiki/Memoization
    var memo: [String: MutableProperty<Double>] = [:]

    func _createObservableTokens(stack: [ObservableToken], token: Token) -> [ObservableToken] {

        func _createObservableProperty(_ variable: String) -> [ObservableToken] {

            if let property = memo[variable] {
                return [.observable(.readWrite(property))]
            }

            let tokens = variableToTokens[variable]!
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

public func createObservables(variableToFormula: [String: String]) -> [String: Observable] {

    let variableToTokens: [String: [Token]] = variableToFormula.map { key, value in
        return value.tokenized()
    }

    let f = createObservableTokens(variableToTokens: variableToTokens)

    return variableToTokens.map { key, tokens in

        guard let observableToken = tokens.reduce([], f).first else { fatalError("There should be at least one value") }

        switch observableToken {
        case .constant(let constant): return.readOnly(Property(value: constant))
        case .observable(let observable):return observable
        case .mathOperator: fatalError("There should never an operator")
        }
    }
}
