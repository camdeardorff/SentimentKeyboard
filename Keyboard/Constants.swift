//
//  Constants.swift
//  SentimentKeyboard
//
//  Created by Cameron Deardorff on 3/19/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIColor {
    static let SA_Red = UIColor(red: 0.933, green: 0.435, blue: 0.478, alpha: 1.00)
    static let SA_Blue = UIColor(red: 0.478, green: 0.620, blue: 0.973, alpha: 1.00)
    static let SA_Green = UIColor(red: 0.459, green: 0.804, blue: 0.620, alpha: 1.00)
}

extension UIColor {
    static let lightGray = UIColor(rgb: 0xF1F1F1)
    static let shadow = UIColor(rgb: 0x000000).withAlphaComponent(0.5)
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
