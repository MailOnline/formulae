import XCTest
@testable import formulae

final class TokenizerTests: XCTestCase {

    func testBasicFormula() {
        let tokens = "10 + X".tokenized()
        let expectations: [Token] = [.constant(10), .variable("X"), .mathSymbol(.mathOperator(.plus))]

        XCTAssert(tokens == expectations)
    }

    func testPerformance() {
        let tokens = "( ( 10 + X * 0 ( 1 - 3 ) / 10 ) ^ 3 ) * 1 + ( ( 10 + X * 0 ( 1 - 3 ) / 10 ) ^ 3 ) * 1 * 0"

        self.measure {
            let _ = tokens.tokenized()
        }
    }
}
