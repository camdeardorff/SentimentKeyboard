//
//  Word.swift
//  SentimentKeyboard_Keyboard
//
//  Created by Cameron Deardorff on 5/1/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct Word {
    let id: Int
    let text: String
    let range: Range<Int>
    let pos: NSLinguisticTag?
    let isNegative: Bool
}

extension Word {
    static func ==(lhs: Word, rhs: Word) -> Bool {
        return lhs.id == rhs.id
        && lhs.text == rhs.text
        && lhs.range == rhs.range
        && lhs.pos == rhs.pos
        && lhs.isNegative == rhs.isNegative
    }
}
