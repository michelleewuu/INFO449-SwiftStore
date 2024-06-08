//
//  StoreTests.swift
//  StoreTests
//
//  Created by Ted Neward on 2/29/24.
//

import XCTest

final class StoreTests: XCTestCase {

    var register = Register()

    override func setUpWithError() throws {
        register = Register()
    }

    override func tearDownWithError() throws { }

    func testBaseline() throws {
        XCTAssertEqual("0.1", Store().version)
        XCTAssertEqual("Hello world", Store().helloWorld())
    }
    
    func testOneItem() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(199, receipt.total())

        let expectedReceipt = """
Receipt:
Beans (8oz Can): $1.99
------------------
TOTAL: $1.99
"""
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    func testThreeSameItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199 * 3, register.subtotal())
    }
    
    func testThreeDifferentItems() {
        register.scan(Item(name: "Beans (8oz Can)", priceEach: 199))
        XCTAssertEqual(199, register.subtotal())
        register.scan(Item(name: "Pencil", priceEach: 99))
        XCTAssertEqual(298, register.subtotal())
        register.scan(Item(name: "Granols Bars (Box, 8ct)", priceEach: 499))
        XCTAssertEqual(797, register.subtotal())
        
        let receipt = register.total()
        XCTAssertEqual(797, receipt.total())

        let expectedReceipt = """
Receipt:
Beans (8oz Can): $1.99
Pencil: $0.99
Granols Bars (Box, 8ct): $4.99
------------------
TOTAL: $7.97
"""
        XCTAssertEqual(expectedReceipt, receipt.output())
    }
    
    // tests 2-for-1 extra credit task
    func testTwoForOnePricing() {
        let price = TwoForOnePricing(itemName: "Beans", itemPrice: 199)
        register = Register(pricingScheme: price)
        register.scan(Item(name: "Beans", priceEach: 199))
        register.scan(Item(name: "Beans", priceEach: 199))
        register.scan(Item(name: "Beans", priceEach: 199))
        XCTAssertEqual(398, register.subtotal(), "Subtotal should reflect 2-for-1 pricing")
    }
    
    func testGroupedPricing() {
        let item1 = Item(name: "Ketchup", priceEach: 100)
        let item2 = Item(name: "Beer", priceEach: 200)
        let pricingScheme = GroupedPricing(eligibleItems: ["Ketchup", "Beer"], discountPercentage: 0.10)
        let items = [item1, item2]
        
        let total = pricingScheme.applyDiscount(items: items)
        XCTAssertEqual(total, 270, "Grouped Pricing failed")
    }
    
    func testWeightedItem() {
        let weightedItem = WeightedItem(name: "Banana", weight: 2.5, pricePerPound: 100)
        let price = weightedItem.price()
        XCTAssertEqual(price, 250, "Weighted item pricing failed")
    }
    
    // Test for Coupon
    func testCoupon() {
        let item = Item(name: "Orange", priceEach: 100)
        let coupon = Coupon(itemName: "Orange", discount: 0.15)
        let items = [item, item]
        
        let total = coupon.applyDiscount(items: items)
        XCTAssertEqual(total, 185, "Coupon discount failed")
    }
    
    func testRainCheck() {
        let item = Item(name: "Grapes", priceEach: 200)
        let rainCheck = RainCheck(itemName: "Grapes", promisedPrice: 150, weight: nil)
        let items = [item, item]
        
        let total = rainCheck.applyDiscount(items: items)
        XCTAssertEqual(total, 350, "RainCheck discount failed")
    }
    
    func testRainCheckWithWeight() {
        let item = WeightedItem(name: "Watermelon", weight: 3.0, pricePerPound: 100)
        let rainCheck = RainCheck(itemName: "Watermelon", promisedPrice: 80, weight: 3.0)
        let items = [item]
        
        let total = rainCheck.applyDiscount(items: items)
        XCTAssertEqual(total, 240, "RainCheck with weight discount failed")
    }
}
