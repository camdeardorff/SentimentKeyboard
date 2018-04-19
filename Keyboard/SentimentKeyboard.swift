//
//  Catboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 9/24/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//
//  Adapted by Cameron Deardorff on 3/15/18
//

import UIKit

class SentimentKeyboard: KeyboardViewController {
    
    let classificationService = ClassificationService()
    
    // MARK: load
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: view
    
    override func createBanner() -> ExtraView? {
        let banner = SentimentBanner(globalColors: type(of: self).globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
        banner.update(sentiment: .neutral)
        return banner
    }
    
    // MARK: character input
    
    override func keyPressed(_ key: Key) {
        
        // insert the key pressed into the text
        let keyOutput = key.outputForCase(self.shiftState.uppercase())
        textDocumentProxy.insertText(keyOutput)
        
        // with the current text, show the sentiment
        showSentiment()
    }
    
    override func backspaceUp(_ sender: KeyboardKey) {
        super.backspaceUp(sender)
        showSentiment()
    }
    
}

extension SentimentKeyboard {
    func showSentiment() {
        
        let textDocumentProxy = self.textDocumentProxy
        
        guard let text = textDocumentProxy.documentContextBeforeInput,
            let banner = bannerView as? SentimentBanner else { return }
        
        let prediction = classificationService.predictSentiment(from: text)
        
        var replacements: [(word: String, replacement: String)]? = []
        
        // if negative find replacements for any negative words
        if prediction.sentiment == .negative {
            let contributingWords = classificationService.wordsWithNegativeSentiment(inText: text)
            for word in contributingWords {
                if let synonyms = Thesaurus.shared.resultForQuery(query: word)?.synonyms {
                    if let replacement = synonyms.suffix(5).filter({ classificationService.wordsWithNegativeSentiment(inText: $0).isEmpty }).last {
                        print("replace `\(word)` with `\(replacement)`")
                        replacements?.append((word: word, replacement: replacement))
                    }
                }
                
            }
        }
        
        banner.update(sentiment: prediction.sentiment, replacements: replacements)

    }
}
