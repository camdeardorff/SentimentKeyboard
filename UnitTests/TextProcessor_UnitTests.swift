//
//  TextProcessor_UnitTests.swift
//  SentimentKeyboard_Keyboard
//
//  Created by Cameron Deardorff on 4/20/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import XCTest
@testable import SentimentKeyboard_App

class TextProcessor_UnitTests: XCTestCase {
    
    func test_process_sentence() {
        let sentence = "What is the weather in San Francisco?"
        
        let parts = TextProcessor.shared.partsOfSpeechForToken(inString: sentence)
        for part in parts {
            print(part.token, " -> ", part.tag)
        }
        XCTAssert(!parts.isEmpty)
    }
    
    func test_pos_word() {
        let word = "and"
        
        let pos = TextProcessor.shared.partOfSpeechFor(word: word)
        print(pos)
        XCTAssert(true)
    }
}
