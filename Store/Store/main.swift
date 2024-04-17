//
//  main.swift
//  Store
//
//  Created by Ted Neward on 2/29/24.
//

import Foundation

protocol SKU {
    var name: String { get }
    func price() -> Int
}

class Item: SKU {
    var name: String
    private var pricePerItem: Int
    
    init(name: String, priceEach: Int) {
        self.name = name
        self.pricePerItem = priceEach
    }
    
    func price() -> Int {
        return pricePerItem
    }
}

class Receipt {
    private var scannedItems: [SKU] = []
    
    func addItem(_ item: SKU) {
        scannedItems.append(item)
    }
    
    func items() -> [SKU] {
        return scannedItems
    }
    
    func total() -> Int {
        return items().reduce(0) { $0 + $1.price() }
    }
    
    func output() -> String {
        var receiptOutput = "Receipt:\n"
        for item in scannedItems {
            receiptOutput += "\(item.name): $\(String(format: "%.2f", Double(item.price())/100.0))\n"
        }
        receiptOutput += "------------------\n"
        receiptOutput += "TOTAL: $\(String(format: "%.2f", Double(total())/100.0))"
        return receiptOutput
    }
}

class Register {
    private var currReceipt = Receipt()
    private var pricingScheme: PricingScheme?
    init(pricingScheme: PricingScheme? = nil) {
        self.currReceipt = Receipt()
        self.pricingScheme = pricingScheme
    }
    
    func scan(_ item: SKU) {
        currReceipt.addItem(item)
    }
    
    func subtotal() -> Int {
        return pricingScheme?.applyDiscount(items: currReceipt.items()) ?? currReceipt.total()
    }
    
    func total() -> Receipt {
        let finalReceipt = currReceipt
        currReceipt = Receipt()
        return finalReceipt
    }
}

// PricingScheme protocol
protocol PricingScheme {
    func applyDiscount(items: [SKU]) -> Int
}

// 2-for-1 pricing extra credit
class TwoForOnePricing: PricingScheme {
    private let itemName: String
    private let itemPrice: Int
    
    init(itemName: String, itemPrice: Int) {
        self.itemName = itemName
        self.itemPrice = itemPrice
    }
    
    // applies the 2-for-1 discount to eligible items
    func applyDiscount(items: [SKU]) -> Int {
        let eligibleItems = items.filter { $0.name == itemName }
        let groupsOfThree = eligibleItems.count / 3
        let remainingItems = eligibleItems.count % 3
        return (groupsOfThree * 2 + remainingItems) * itemPrice
    }
}

// grouped purchases extra credit
class GroupedPricing: PricingScheme {
    private let eligibleItems: [String]
    private let discountPercentage: Double
    
    init(eligibleItems: [String], discountPercentage: Double) {
        self.eligibleItems = eligibleItems
        self.discountPercentage = discountPercentage
    }
    
    func applyDiscount(items: [SKU]) -> Int {
        let filteredItems = items.filter { eligibleItems.contains($0.name) }
        guard filteredItems.count == eligibleItems.count else { return items.reduce(0) { $0 + $1.price() } }
        let discountedPrice = filteredItems.reduce(0) { $0 + Int(Double($1.price()) * (1 - discountPercentage)) }
        let regularPrice = items.filter { eligibleItems.contains($0.name) }.reduce(0) { $0 + $1.price() }
        return discountedPrice + regularPrice
    }
}

// WeightedSKU protocol
protocol WeightedSKU {
    var weight: Double { get }
}

// priced by weight extra credit
class WeightedItem: WeightedSKU {
    var itemName: String
    var weight: Double
    private var pricePerPound: Int
    
    init(itemName: String, weight: Double, pricePerPound: Int) {
        self.itemName = itemName
        self.weight = weight
        self.pricePerPound = pricePerPound
    }
    
    func price() -> Int {
        return Int(Double(pricePerPound) * weight)
    }
}

// coupon extra credit
class Coupon: PricingScheme {
    var itemName: String
    var discount: Double
    
    init(itemName: String, discount: Double) {
        self.itemName = itemName
        self.discount = discount
    }
    
    func applyDiscount(items: [SKU]) -> Int {
        var total = 0
        var itemsDiscounted = false
        for item in items {
            if !itemsDiscounted && item.name == itemName {
                total += Int(Double(item.price()) * (1 - discount))
                itemsDiscounted = true
            } else {
                total += item.price()
            }
        }
        return total
    }
}

class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}

