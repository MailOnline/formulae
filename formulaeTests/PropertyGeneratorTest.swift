import XCTest
import ReactiveCocoa
@testable import formulae

final class PropertyGeneratorTest: XCTestCase {

    func testSingleConstant() {

        let observables = createObservables(variableToFormula: ["X": "10"])

        guard
             case .some(.readOnly(let property)) = observables["X"]
        else {
            fatalError("\(observables)")
        }

        XCTAssert(property.value == 10)
    }

    func testSingleVariable_0() {

        let observables = createObservables(variableToFormula: ["X": "X"])

        guard
            case .some(.readWrite(let property)) = observables["X"]
            else {
                fatalError("\(observables)")
        }

        XCTAssert(property.value == 0)
    }

    func testVariable_1() {

        let observables = createObservables(variableToFormula: ["X": "X",
                                                                "Y": "X + 10"])
        guard
            case .some(.readWrite(let propertyX)) = observables["X"],
            case .some(.readOnly(let propertyY)) = observables["Y"]
        else {
            fatalError("\(observables)")
        }

        XCTAssertTrue(propertyX.value == 0)
        XCTAssertTrue(propertyY.value == 10)
    }

    func testVariable_2() {

        let observables = createObservables(variableToFormula: ["X": "X",
                                                                "Y": "5 + X + 10"])
        guard
            case .some(.readWrite(let propertyX)) = observables["X"],
            case .some(.readOnly(let propertyY)) = observables["Y"]
            else {
                fatalError("\(observables)")
        }

        XCTAssertTrue(propertyX.value == 0)
        XCTAssertTrue(propertyY.value == 15)
    }

    func testVariableDependency_1() {

        let observables = createObservables(variableToFormula: ["X": "X",
                                                                "Y": "X + 10"])
        guard
            case .some(.readWrite(let propertyX)) = observables["X"],
            case .some(.readOnly(let propertyY)) = observables["Y"]
            else {
                fatalError("\(observables)")
        }

        XCTAssertTrue(propertyX.value == 0)
        XCTAssertTrue(propertyY.value == 10)

        propertyX.value = 10

        XCTAssertTrue(propertyY.value == 20)
    }

    func testVariableMultipleVariables() {

        let observables = createObservables(variableToFormula: ["X": "X",
                                                                "Y": "Y",
                                                                "Z": "X + Y"])
        guard
            case .some(.readWrite(let propertyX)) = observables["X"],
            case .some(.readWrite(let propertyY)) = observables["Y"],
            case .some(.readOnly(let propertyZ)) = observables["Z"]
            else {
                fatalError("\(observables)")
        }

        XCTAssertTrue(propertyX.value == 0)
        XCTAssertTrue(propertyY.value == 0)
        XCTAssertTrue(propertyZ.value == 0)

        propertyX.value = 10
        propertyY.value = 10

        XCTAssertTrue(propertyZ.value == 20)
    }

    func testConstant_operations() {

        let operations = ["5 + 3", "5 - 3", "5 * 3", "5 / 3"]
        let results: [Double] = [8, 2, 15, (5 / 3)]

        for (index, val) in operations.enumerated() {

            let observables = createObservables(variableToFormula: ["X" : val])

            guard
                case .some(.readOnly(let propertyX)) = observables["X"]
                else {
                    fatalError("\(observables)")
            }

            XCTAssertTrue(propertyX.value == results[index])
        }
    }
}
