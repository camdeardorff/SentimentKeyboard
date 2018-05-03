//
//  Synonym.swift
//  SentimentKeyboard_App
//
//  Created by Cameron Deardorff on 5/2/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

enum Tag: String, Codable {
    case noun = "n"
    case verb = "v"
    case adjective = "adj"
    case adverb = "adv"
    case prep = "prop"
    case unknown = "u"
    
    
    static func fromNSLingusticTag(_ tag: NSLinguisticTag?) -> Tag {
        guard let tag = tag else { return .unknown }
        switch tag as String {
        case NSLinguisticTagVerb:
            return .verb
        case NSLinguisticTagNoun:
            return .noun
        case NSLinguisticTagAdjective:
            return .adjective
        case NSLinguisticTagAdverb:
            return .adverb
        case NSLinguisticTagPreposition:
            return .prep
        default:
            return .unknown
        }
    }
}

struct Synonym: Codable {
    let word: String
    let score: Int?
    let tags: [Tag]
    
    public init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.word = map.decodeSafelyIfPresent(.word) ?? ""
        self.score = map.decodeSafelyIfPresent(.score)
        self.tags = map.decodeSafelyIfPresent(.tags) ?? []
    }
    
    private enum CodingKeys: CodingKey {
        case word
        case score
        case tags
    }
}

extension Array where Iterator.Element == Synonym {
    func sort() -> [Synonym] {
        
        return sorted(by: {
            guard let score1 = $0.0.score,
                let score2 = $0.1.score else { return false }
            return score1 < score2
        })
        
    }
}


//        return sorted(by: {
//            guard let score1 = $0.0.score,
//                let score2 = $0.1.score else { return false }
//            return score1 < score2 }) as! [Synonym]
