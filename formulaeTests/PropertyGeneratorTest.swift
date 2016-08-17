import XCTest
import ReactiveCocoa
@testable import formulae

final class PropertyGeneratorTest: XCTestCase {

    func testSingleVariable() {

        let tokensX = "X".tokenized()
        let properties = ["X" : tokensX]

        let f = createObservableTokens(polishTokensMap: properties)
        let readWriteProperty = tokensX.reduce([], f).first

        XCTAssertNotNil(readWriteProperty)
        guard case .observable(.readWrite) = readWriteProperty! else {
            fatalError("Should be a readWrite property")
        }
    }

    func testConstant() {

        let constantToken = "10".tokenized()
        let f = createObservableTokens(polishTokensMap: [:])
        let readWriteProperty = constantToken.reduce([], f).first

        XCTAssertNotNil(readWriteProperty)
        guard case .constant(let c) = readWriteProperty! else {
            fatalError("Should be a readWrite property")
        }

        XCTAssertTrue(c == 10)
    }

    func testConstant_plus_Constant() {

        let constantToken = "10 + 10".tokenized()
        let f = createObservableTokens(polishTokensMap: [:])
        let readWriteProperty = constantToken.reduce([], f).first

        XCTAssertNotNil(readWriteProperty)
        guard case .constant(let c) = readWriteProperty! else {
            fatalError("Should be a readWrite property")
        }

        XCTAssertTrue(c == 20)
    }
}
