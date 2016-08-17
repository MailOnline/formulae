import ReactiveCocoa
@testable import formulae

func createObservables(x: String) -> (Observable?) {

    let tokensX = x.tokenized()

    let properties = ["X" : tokensX]

    let f = createObservableTokens(variableToTokens: properties)
    let propertyX = tokensX.reduce([], f).first

    switch (propertyX) {

    case .some(.observable(let oX)): return oX
    default: return nil
    }
}

func createObservables(x: String, y: String) -> (Observable?, Observable?) {

    let tokensX = x.tokenized()
    let tokensY = y.tokenized()

    let properties = ["X" : tokensX,
                      "Y" : tokensY]

    let f = createObservableTokens(variableToTokens: properties)
    let propertyX = tokensX.reduce([], f).first
    let propertyY = tokensY.reduce([], f).first

    switch (propertyX, propertyY) {

    case (.some(.observable(let oX)), .some(.observable(let oY))): return (oX, oY)
    case (.none, .some(.observable(let oY))): return (nil, oY)
    case (.some(.observable(let oX)), .none): return (oX, nil)
    default: return (nil, nil)
    }
}

func createObservables(x: String, y: String, z: String) -> (Observable?, Observable?, Observable?) {

    let tokensX = x.tokenized()
    let tokensY = y.tokenized()
    let tokensZ = z.tokenized()

    let properties = ["X" : tokensX,
                      "Y" : tokensY,
                      "Z" : tokensZ]

    let f = createObservableTokens(variableToTokens: properties)
    let propertyX = tokensX.reduce([], f).first
    let propertyY = tokensY.reduce([], f).first
    let propertyZ = tokensZ.reduce([], f).first

    switch (propertyX, propertyY, propertyZ) {
    case (.some(.observable(let oX)), .some(.observable(let oY)), .some(.observable(let oZ))): return (oX, oY, oZ)
    case (.some(.observable(let oX)), .some(.observable(let oY)), .none): return (oX, oY, nil)
    case (.none, .some(.observable(let oY)), .some(.observable(let oZ))): return (nil, oY, oZ)
    case (.none, .none, .some(.observable(let oZ))): return (nil, nil, oZ)
    case (.none, .some(.observable(let oY)), nil): return (nil, oY, nil)
    case (.some(.observable(let oX)), .none, .none): return (oX, nil, nil)
    case (.some(.observable(let oX)), .none, .some(.observable(let oZ))): return (oX, nil, oZ)
    default: return (nil, nil, nil)
    }
}
