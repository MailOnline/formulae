import XCTest
@testable import formulae

final class TokenizerTests: XCTestCase {

    func testBasicFormula() {
        let tokens = "10 + X".tokenized()
        let expectations: [Token] = [.constant(10), .variable("X"), .mathSymbol(.mathOperator(.plus))]

        XCTAssert(tokens == expectations)
    }
}
