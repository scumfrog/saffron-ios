import XCTest
@testable import Saffron

final class IngredientTests: XCTestCase {

    // MARK: - formattedQuantity

    func testZeroQuantityReturnsEmpty() {
        let ing = Ingredient(quantity: 0, unit: "g", name: "sal")
        XCTAssertEqual(ing.formattedQuantity(), "")
    }

    func testWholeNumberBelow10() {
        let ing = Ingredient(quantity: 2, unit: "", name: "huevos")
        XCTAssertEqual(ing.formattedQuantity(), "2")
    }

    func testWholeNumberAtOrAbove10IsRounded() {
        XCTAssertEqual(Ingredient(quantity: 10, unit: "g", name: "x").formattedQuantity(), "10")
        XCTAssertEqual(Ingredient(quantity: 300, unit: "g", name: "x").formattedQuantity(), "300")
    }

    func testDecimalBelow10ShowsOneDecimalPlace() {
        let ing = Ingredient(quantity: 1.5, unit: "cda", name: "aceite")
        XCTAssertEqual(ing.formattedQuantity(), "1.5")
    }

    func testDecimalBelow10TrailingZeroIsOmitted() {
        // 2.0 should display as "2", not "2.0"
        let ing = Ingredient(quantity: 2.0, unit: "cda", name: "aceite")
        XCTAssertEqual(ing.formattedQuantity(), "2")
    }

    func testScalingDoubles() {
        let ing = Ingredient(quantity: 200, unit: "g", name: "harina")
        XCTAssertEqual(ing.formattedQuantity(ratio: 2), "400")
    }

    func testScalingHalves() {
        let ing = Ingredient(quantity: 200, unit: "g", name: "harina")
        XCTAssertEqual(ing.formattedQuantity(ratio: 0.5), "100")
    }

    func testScalingProducesDecimal() {
        // 200 * 1.5 = 300 (≥ 10, rounded to Int)
        let ing = Ingredient(quantity: 200, unit: "g", name: "harina")
        XCTAssertEqual(ing.formattedQuantity(ratio: 1.5), "300")
    }

    func testSmallQuantityScalingProducesDecimal() {
        // 2 * 1.5 = 3 (< 10, but no decimal needed)
        let ing = Ingredient(quantity: 2, unit: "cda", name: "aceite")
        XCTAssertEqual(ing.formattedQuantity(ratio: 1.5), "3")
    }

    // MARK: - displayLine

    func testDisplayLineWithUnitAndName() {
        let ing = Ingredient(quantity: 300, unit: "g", name: "harina de fuerza")
        XCTAssertEqual(ing.displayLine(), "300 g harina de fuerza")
    }

    func testDisplayLineWithoutUnit() {
        let ing = Ingredient(quantity: 2, unit: "", name: "huevos")
        XCTAssertEqual(ing.displayLine(), "2 huevos")
    }

    func testDisplayLineScaled() {
        let ing = Ingredient(quantity: 100, unit: "g", name: "azúcar")
        XCTAssertEqual(ing.displayLine(ratio: 2), "200 g azúcar")
    }

    func testDisplayLineNameOnlyWhenQuantityAndUnitEmpty() {
        let ing = Ingredient(quantity: 0, unit: "", name: "sal al gusto")
        XCTAssertEqual(ing.displayLine(), "sal al gusto")
    }
}
