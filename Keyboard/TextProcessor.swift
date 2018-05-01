//
//  TextProcessor.swift
//  SentimentKeyboard_Keyboard
//
//  Created by Cameron Deardorff on 4/20/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

class TextProcessor {
    
    static let shared = TextProcessor()
    
    private init() { }
    
    
    /**
        parses the string provided in search of substrings (tokens) with associated parts of speech
     
         - Parameter inString: string to parse, determining the parts of speech within
         - Returns: a list of tokens (substrings of string provided) and the part of speech they are associated with
     */
    func partsOfSpeechForToken(inString string: String) -> [(token: String, tag: NSLinguisticTag)] {
        let text = NSString(string: string)
        let tags_Ranges = tagsAndRanges(forString: text)
        return tokenMapping(forTags: tags_Ranges.tags, inString: text, withRanges: tags_Ranges.tokenRanges)
    }
    
    /**
        finds the part of speech for a single word
     
        - Parameter word: single word to find pos
        - Returns: optional tag
     */
    func partOfSpeechFor(word: String) -> NSLinguisticTag? {
        let text = NSString(string: word)
        let tags_Ranges = tagsAndRanges(forString: text)
        
        guard let tag = tags_Ranges.tags.first,
            let range = tags_Ranges.tokenRanges.first else { return nil }
        
        return tokenMapping(forTags: [tag], inString: text, withRanges: [range]).first?.tag
    }
    
    
    /**
        extracts any tags found within the string and what substring they are associated with
     
        - Parameter forString: string to parse, determining the parts of speech within
        - Returns: tuple constaining list of tags and also ranges they correspond to
     */
    private func tagsAndRanges(forString string: NSString) -> (tags: [NSLinguisticTag], tokenRanges: [NSRange]) {
        var tokenRanges: NSArray?
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let tags = string.linguisticTags(
            in: NSMakeRange(0, string.length),
            scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass,
            options: options, orthography: nil, tokenRanges: &tokenRanges
        )
        return (tags: tags as [NSLinguisticTag], tokenRanges: tokenRanges as? [NSRange] ?? [NSRange]())
    }
    
    /**
         maps a list of tags to the string substring specified by the matching range within the text
     
         - Parameter forTags: list of tags
         - Parameter inString: string to pull substrings from
         - Parameter withRanges: ranges of substrings within string provided that map to tag
     
         - Returns: list of tuples containing a token (string) and it's part of speech in the text.
     */
    private func tokenMapping(forTags tags: [NSLinguisticTag], inString string: NSString, withRanges ranges: [NSRange]) -> [(token: String, tag: NSLinguisticTag)] {
        
        return tags.enumerated().map { (arg) in
            let (idx, tag) = arg
            
            let range = ranges[idx] as NSRange
            let word = string.substring(with: range)
            return (token: word, tag: tag)
        }
    }
}
