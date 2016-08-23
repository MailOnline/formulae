import XCTest
import ReactiveCocoa
@testable import formulae

final class PropertyGeneratorTest: XCTestCase {

    func testSingleConstant_0() {

        let observables = createObservables(withFormula: ["X": "10"])

        guard
            case .some(.readOnly(let property)) = observables["X"]
            else {
                fatalError("\(observables)")
        }

        XCTAssert(property.value == 10)
    }

    func testSingleConstant_1() {

        let observables = createObservables(withFormula: ["X": "10", "Y": "10", "Z": "X + Y"])

        guard
            case .some(.readOnly) = observables["X"],
            case .some(.readOnly) = observables["Y"],
            case .some(.readOnly(let property)) = observables["Z"]
            else {
                fatalError("\(observables)")
        }

        XCTAssert(property.value == 20)
    }

    func testSingleConstant_2() {

        let observables = createObservables(withFormula: ["X": "10", "Y": "10", "Z": "X + Y + 10"])

        guard
            case .some(.readOnly) = observables["X"],
            case .some(.readOnly) = observables["Y"],
            case .some(.readOnly(let property)) = observables["Z"]
            else {
                fatalError("\(observables)")
        }
        
        XCTAssert(property.value == 30)
    }

    func testSingleVariable_0() {

        let observables = createObservables(withFormula: ["X": "X"])

        guard
            case .some(.readWrite(let property)) = observables["X"]
            else {
                fatalError("\(observables)")
        }

        XCTAssert(property.value == 0)
    }

    func testVariable_1() {

        let observables = createObservables(withFormula: ["X": "X",
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

        let observables = createObservables(withFormula: ["X": "X",
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

        let observables = createObservables(withFormula: ["X": "X",
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

    func testVariableMultipleVariables_0() {

        let observables = createObservables(withFormula: ["X": "X",
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

    func testVariableMultipleVariables_1() {

        let observables = createObservables(withFormula: ["X": "X",
                                                          "Y": "X + 20",
                                                          "Z": "X + Y + 5"])
        guard
            case .some(.readWrite(let propertyX)) = observables["X"],
            case .some(.readOnly(let propertyY)) = observables["Y"],
            case .some(.readOnly(let propertyZ)) = observables["Z"]
            else {
                fatalError("\(observables)")
        }

        XCTAssertTrue(propertyX.value == 0)
        XCTAssertTrue(propertyY.value == 20)
        XCTAssertTrue(propertyZ.value == 25)

        propertyX.value = 10
        XCTAssertTrue(propertyZ.value == 45)
    }

    func testVariableMultipleVariables_4() {

        let observables = createObservables(withFormula: ["A": "A",
                                                          "X": "10",
                                                          "Y": "X + 20",
                                                          "Z": "X + Y + 5 + A"])
        guard
            case .some(.readWrite(let propertyA)) = observables["A"],
            case .some(.readOnly(let propertyX)) = observables["X"],
            case .some(.readOnly(let propertyY)) = observables["Y"],
            case .some(.readOnly(let propertyZ)) = observables["Z"]
            else {
                fatalError("\(observables)")
        }

        XCTAssertTrue(propertyA.value == 0)
        XCTAssertTrue(propertyX.value == 10)
        XCTAssertTrue(propertyY.value == 30)
        XCTAssertTrue(propertyZ.value == 45)

        propertyA.value = 10
        XCTAssertTrue(propertyZ.value == 55)

        propertyA.value = 5
        XCTAssertTrue(propertyZ.value == 50)
    }

    func testVariableMultipleVariables_5() {

        let observables = createObservables(withFormula: ["A": "A",
                                                          "B": "B",
                                                          "C": "2",
                                                          "X": "1",
                                                          "Y": "X + 2",
                                                          "Z": "( ( X + Y + 5 + A ) ^ B ) ^ C"])
        guard
            case .some(.readWrite(let propertyA)) = observables["A"],
            case .some(.readWrite(let propertyB)) = observables["B"],
            case .some(.readOnly) = observables["C"],
            case .some(.readOnly(let propertyX)) = observables["X"],
            case .some(.readOnly(let propertyY)) = observables["Y"],
            case .some(.readOnly(let propertyZ)) = observables["Z"]
            else {
                fatalError("\(observables)")
        }

        propertyA.value = 1
        propertyB.value = 1

        XCTAssertTrue(propertyA.value == 1)
        XCTAssertTrue(propertyX.value == 1)
        XCTAssertTrue(propertyY.value == 3)
        XCTAssertTrue(propertyZ.value == 100)

        propertyA.value = 2
        propertyB.value = 2
        XCTAssertTrue(propertyZ.value == 14641.0)

        propertyA.value = 3
        propertyB.value = 3
        XCTAssertTrue(propertyZ.value == 2985984.0)
    }

    func testConstant_operations() {

        let operations = ["5 + 3", "5 - 3", "5 * 3", "5 / 3"]
        let results: [Double] = [8, 2, 15, (5 / 3)]

        for (index, val) in operations.enumerated() {

            let observables = createObservables(withFormula: ["X" : val])

            guard
                case .some(.readOnly(let propertyX)) = observables["X"]
                else {
                    fatalError("\(observables)")
            }
            
            XCTAssertTrue(propertyX.value == results[index])
        }
    }
}
