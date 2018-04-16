//
//  SentimentKeyboard_UnitTests.swift
//  SentimentKeyboard_UnitTests
//
//  Created by Cameron Deardorff on 4/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import XCTest
@testable import SentimentKeyboard_App

class SentimentKeyboard_UnitTests: XCTestCase {
    
    let classificationService = ClassificationService()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_negative_sentence() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let negativeSentence = "This is the worst book I've ever read"
        let prediction = classificationService.predictSentiment(from: negativeSentence)
        XCTAssert(prediction.sentiment == .negative)
    }
    
    func test_negative_words() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let negativeSentence = "This is the worst book I've ever read evil bitch buttface fuck ass"
        
        let words = classificationService.wordsWithNegativeSentiment(inText: negativeSentence)
        print(words)
        XCTAssert(!words.isEmpty)
    }
    
}
