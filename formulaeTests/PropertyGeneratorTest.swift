import XCTest
import ReactiveCocoa
@testable import formulae

final class PropertyGeneratorTest: XCTestCase {

    func testSingleConstant() {

        let constantToken = "10".tokenized()
        let f = createObservableTokens()
        let readWriteProperty = constantToken.reduce([], f).first

        XCTAssertNotNil(readWriteProperty)
        guard case .constant(let c) = readWriteProperty! else {
            fatalError("Should be a readWrite property")
        }

        XCTAssertTrue(c == 10)
    }

    func testSingleVariable_0() {

        let propertyX = createObservables(x: "X")

        XCTAssertNotNil(propertyX)

        guard
            case .some(.readWrite) = propertyX else {
            fatalError("\(propertyX) should be a readWrite property")
        }
    }

    func testVariable_1() {

        let properties = createObservables(x: "X", y: "X + 10")

        XCTAssertNotNil(properties.0)
        XCTAssertNotNil(properties.1)

        guard
            case .some(.readWrite(let x)) = properties.0,
            case .some(.readOnly(let y)) = properties.1
        else {
            fatalError("\(properties.0) should be readWrite\n\(properties.1) should be readOnly")
        }

        x.value = 10
        XCTAssertTrue(y.value == 20)
    }

    func testVariable_2() {

        let properties = createObservables(x: "X", y: "5 + X + 10")

        XCTAssertNotNil(properties.0)
        XCTAssertNotNil(properties.1)

        guard
            case .some(.readWrite(let x)) = properties.0,
            case .some(.readOnly(let y)) = properties.1
            else {
                fatalError("\(properties.0) should be readWrite\n\(properties.1) should be readOnly")
        }

        x.value = 10
        XCTAssertTrue(y.value == 25)
    }

    func testVariable_3() {

        let properties = createObservables(x: "X", y: "10 + X")

        XCTAssertNotNil(properties.0)
        XCTAssertNotNil(properties.1)

        guard
            case .some(.readWrite(let x)) = properties.0,
            case .some(.readOnly(let y)) = properties.1
            else {
                fatalError("\(properties.0) should be readWrite\n\(properties.1) should be readOnly")
        }

        x.value = 10
        XCTAssertTrue(y.value == 20)
    }

    func testVariableMultipleVariables() {

        let properties = createObservables(x: "X", y: "Y", z: "X + Y + 10")

        XCTAssertNotNil(properties.0)
        XCTAssertNotNil(properties.1)
        XCTAssertNotNil(properties.2)

        guard
            case .some(.readWrite(let x)) = properties.0,
            case .some(.readWrite(let y)) = properties.1,
            case .some(.readOnly(let z)) = properties.2
            else {
                fatalError("\(properties.0) should be readWrite\n\(properties.1) should be readWrite\n\(properties.2) should be readOnly")
        }

        x.value = 10
        y.value = 10
        XCTAssertTrue(z.value == 30)
    }


    func testConstant_operations() {

        let operations = ["5 + 3", "5 - 3", "5 * 3", "5 / 3"]
        let results: [Double] = [8, 2, 15, (5 / 3)]

        for (index, val) in operations.enumerated() {

            let constantToken = val.tokenized()
            let f = createObservableTokens()
            let readWriteProperty = constantToken.reduce([], f).first

            XCTAssertNotNil(readWriteProperty)
            guard case .constant(let c) = readWriteProperty! else {
                fatalError("Should be a readWrite property")
            }
            
            XCTAssertTrue(c == results[index])
        }
    }
}
