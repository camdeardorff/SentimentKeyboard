//
//  Thesarus_UnitTests.swift
//  SentimentKeyboard
//
//  Created by Cameron Deardorff on 4/17/18.
//  Copyright © 2018 Apple. All rights reserved.
//

//
//  PredictionClassification_UnitTests.swift
//  SentimentKeyboard
//
//  Created by Cameron Deardorff on 4/17/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import XCTest
@testable import SentimentKeyboard_App

class Thesarus_UnitTests: XCTestCase {
    
    func test_get_synonyms() {
        let word = "worst"
        if let result = Thesaurus.shared.resultForQuery(query: word) {
            XCTAssert(!result.synonyms.isEmpty)
        } else {
            XCTFail()
        }
    }
    
}
