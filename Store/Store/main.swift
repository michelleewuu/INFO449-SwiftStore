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

protocol PricingScheme {
    func applyDiscount(items: [SKU]) -> Int
}

class TwoForOnePricing: PricingScheme {
    private let itemName: String
    private let itemPrice: Int
    
    init(itemName: String, itemPrice: Int) {
        self.itemName = itemName
        self.itemPrice = itemPrice
    }
    
    func applyDiscount(items: [SKU]) -> Int {
        let eligibleItems = items.filter { $0.name == itemName }
        let groupsOfThree = eligibleItems.count / 3
        let remainingItems = eligibleItems.count % 3
        return (groupsOfThree * 2 + remainingItems) * itemPrice
    }
}

class Store {
    let version = "0.1"
    func helloWorld() -> String {
        return "Hello world"
    }
}

