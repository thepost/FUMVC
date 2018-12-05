import XCTest
import FUMVC

class Tests: XCTestCase {
    
	var modelController: ModelController?
	
	override func setUp() {
		super.setUp()
		modelController = ModelController(modelName: "Model")
	}
	
	override func tearDown() {
		//per-test case cleanup:
		//deleteAll()
		super.tearDown()
	}
	
	override class func tearDown() {
		//overall test case instance cleanup:
		super.tearDown()
	}
	
	// MARK: - Tests
	
	func testAddRecipe() {
		let recipeName = "Pizza"
		
		let newRecipe = modelController!.add(Recipe.self)
		XCTAssertNotNil(newRecipe)
		
		newRecipe?.name = recipeName
		XCTAssertEqual(recipeName, newRecipe?.name, "Recipe name is not set")
	}
	
	func testTotalRecipes() {
		
		let newRecipe = modelController!.add(Recipe.self)
		newRecipe?.name = "Total Pizza"
		
		let total = modelController!.total(Recipe.self)
		XCTAssertGreaterThan(total, 0)
	}
	
	func testFetchRecipes() {
		
		let pizzaName = "Fetcheroni Pizza"
		let newRecipe = modelController!.add(Recipe.self)
		newRecipe?.name = pizzaName
		
		let predicate = NSPredicate(format: "name LIKE %@", pizzaName)
		let fetched = modelController!.fetch(Recipe.self, predicate: predicate)
		
		guard let fetchedRecipe = fetched?.last else {
			XCTAssertNotNil(fetched)
			return
		}
		XCTAssertEqual(fetchedRecipe, newRecipe, "The fetched Recipe does not equal the created Recipe!")
	}
	
	func testDeleteRecipe() {
		
		//Test for deletion by objectID...
		let expectation1 = XCTestExpectation(description: "Delete core data object by objectID")
		
		let newRecipe = modelController!.add(Recipe.self)
		var total = modelController!.total(Recipe.self)
		
		modelController!.delete(by: newRecipe!.objectID) {
			
			let deletedTotal = self.modelController!.total(Recipe.self)
			XCTAssertLessThan(deletedTotal, total)
			expectation1.fulfill()
		}
		
		//Test for deletion by predicate...
		let expectation2 = XCTestExpectation(description: "Delete core data object by predicate")
		
		let outdatedRecipe = modelController!.add(Recipe.self)
		let pizzaName = "Cheese Crust Pizza"
		outdatedRecipe?.name = pizzaName
		
		total = modelController!.total(Recipe.self)
		let predicate = NSPredicate(format: "name LIKE %@", pizzaName)
		
		modelController!.delete(Recipe.self, predicate: predicate) {
			
			let deletedTotal = self.modelController!.total(Recipe.self)
			XCTAssertLessThan(deletedTotal, total)
			expectation2.fulfill()
		}
		
		wait(for: [expectation1, expectation2], timeout: 10.0)
	}
    
}
