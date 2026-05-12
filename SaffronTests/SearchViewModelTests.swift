import XCTest
import SwiftData
@testable import Saffron

@MainActor
final class SearchViewModelTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Recipe.self, RecipeList.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        context = nil
        container = nil
    }

    // MARK: - Helpers

    @discardableResult
    private func makeRecipe(
        title: String,
        tags: [String] = [],
        ingredients: [Ingredient] = []
    ) -> Recipe {
        let r = Recipe()
        r.title = title
        r.tags = tags
        r.ingredients = ingredients
        context.insert(r)
        return r
    }

    // MARK: - Query matching

    func testEmptyQueryMatchesAll() {
        let r = makeRecipe(title: "Paella")
        let vm = SearchViewModel()
        XCTAssertTrue(vm.matches(r))
    }

    func testQueryMatchesTitle() {
        let r = makeRecipe(title: "Paella valenciana")
        let vm = SearchViewModel()
        vm.query = "paella"
        XCTAssertTrue(vm.matches(r))
    }

    func testQueryIsCaseInsensitive() {
        let r = makeRecipe(title: "Gazpacho")
        let vm = SearchViewModel()
        vm.query = "GAZPACHO"
        XCTAssertTrue(vm.matches(r))
    }

    func testQueryPartialMatch() {
        let r = makeRecipe(title: "Tortilla española")
        let vm = SearchViewModel()
        vm.query = "tort"
        XCTAssertTrue(vm.matches(r))
    }

    func testQueryNoMatch() {
        let r = makeRecipe(title: "Tortilla española")
        let vm = SearchViewModel()
        vm.query = "pizza"
        XCTAssertFalse(vm.matches(r))
    }

    func testQueryMatchesTag() {
        let r = makeRecipe(title: "Arroz negro", tags: ["seafood", "rice"])
        let vm = SearchViewModel()
        vm.query = "seafood"
        XCTAssertTrue(vm.matches(r))
    }

    func testQueryMatchesIngredientName() {
        let arroz = Ingredient(quantity: 300, unit: "g", name: "arroz")
        let r = makeRecipe(title: "Plato de arroz", ingredients: [arroz])
        let vm = SearchViewModel()
        vm.query = "arroz"
        XCTAssertTrue(vm.matches(r))
    }

    func testQueryLeadingAndTrailingSpacesIgnored() {
        let r = makeRecipe(title: "Gazpacho")
        let vm = SearchViewModel()
        vm.query = "  gazpacho  "
        XCTAssertTrue(vm.matches(r))
    }

    // MARK: - Tag filtering

    func testEmptyActiveTagsMatchesAll() {
        let r = makeRecipe(title: "Paella", tags: ["seafood"])
        let vm = SearchViewModel()
        XCTAssertTrue(vm.matches(r))
    }

    func testActiveTagMatchingRecipeTag() {
        let r = makeRecipe(title: "Paella", tags: ["seafood", "rice"])
        let vm = SearchViewModel()
        vm.activeTags = ["seafood"]
        XCTAssertTrue(vm.matches(r))
    }

    func testActiveTagNotInRecipeTagsExcludes() {
        let r = makeRecipe(title: "Pizza", tags: ["italian"])
        let vm = SearchViewModel()
        vm.activeTags = ["seafood"]
        XCTAssertFalse(vm.matches(r))
    }

    func testMultipleActiveTagsRequireAll() {
        let r = makeRecipe(title: "Paella", tags: ["seafood", "rice", "spanish"])
        let vm = SearchViewModel()
        vm.activeTags = ["seafood", "rice"]
        XCTAssertTrue(vm.matches(r))

        vm.activeTags = ["seafood", "italian"]
        XCTAssertFalse(vm.matches(r))
    }

    func testQueryAndTagsCombinedBothRequired() {
        let r = makeRecipe(title: "Paella", tags: ["seafood"])
        let vm = SearchViewModel()
        vm.query = "paella"
        vm.activeTags = ["seafood"]
        XCTAssertTrue(vm.matches(r))

        vm.activeTags = ["meat"]
        XCTAssertFalse(vm.matches(r))
    }

    // MARK: - toggleTag

    func testToggleTagAddsTag() {
        let vm = SearchViewModel()
        vm.toggleTag("seafood")
        XCTAssertTrue(vm.activeTags.contains("seafood"))
    }

    func testToggleTagRemovesExistingTag() {
        let vm = SearchViewModel()
        vm.activeTags = ["seafood"]
        vm.toggleTag("seafood")
        XCTAssertFalse(vm.activeTags.contains("seafood"))
    }

    func testToggleTagIdempotentAdd() {
        let vm = SearchViewModel()
        vm.toggleTag("seafood")
        vm.toggleTag("rice")
        XCTAssertEqual(vm.activeTags.count, 2)
    }
}
