//
//  SentimentPrediction.swift
//  SentimentKeyboard
//
//  Created by Cameron Deardorff on 4/13/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct SentimentPrediction: CustomStringConvertible {
    
    var sentiment: Sentiment
    var confidence: [Sentiment : Double]
    
    public var description: String {
        let conString = confidence.map { key, value in
            "\n\t - \(key.emoji) + \(String(value))"
            }.reduce("",+)
        
        return "sentiment: \(sentiment)\(conString)"
    }
}
