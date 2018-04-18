//
//  PredictionClassification_UnitTests.swift
//  SentimentKeyboard
//
//  Created by Cameron Deardorff on 4/17/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import XCTest
@testable import SentimentKeyboard_App

class SentimentKeyboard_UnitTests: XCTestCase {
    
    let classificationService = ClassificationService()
    
    func test_positive_sentence() {
        let negativeSentence = "I love my new phone"
        let prediction = classificationService.predictSentiment(from: negativeSentence)
        XCTAssert(prediction.sentiment == .positive)
    }
    
    func test_neutral_sentence() {
        let negativeSentence = "tomorrow is wednesday"
        let prediction = classificationService.predictSentiment(from: negativeSentence)
        XCTAssert(prediction.sentiment == .neutral)
    }
    
    func test_negative_sentence() {
        let negativeSentence = "This is the worst book I've ever read"
        let prediction = classificationService.predictSentiment(from: negativeSentence)
        XCTAssert(prediction.sentiment == .negative)
    }

    func test_negative_words() {
        let negativeSentence = "This is the worst book I've ever read evil bitch buttface fuck ass"
        
        let words = classificationService.wordsWithNegativeSentiment(inText: negativeSentence)
        print(words)
        XCTAssert(!words.isEmpty)
    }

}
