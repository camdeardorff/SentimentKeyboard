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

/*
 This is the demo keyboard. If you're implementing your own keyboard, simply follow the example here and then
 set the name of your KeyboardViewController subclass in the Info.plist file.
 */

class SentimentKeyboard: KeyboardViewController {
    
    let classificationService = ClassificationService()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPressed(_ key: Key) {
        // with the current text, show the sentiment
        showSentiment()
        // insert the key pressed into the text
        let keyOutput = key.outputForCase(self.shiftState.uppercase())
        textDocumentProxy.insertText(keyOutput)
    }
    
    override func backspaceUp(_ sender: KeyboardKey) {
        super.backspaceUp(sender)
        showSentiment()
    }
    
    func showSentiment() {
        let textDocumentProxy = self.textDocumentProxy
        
        guard let text = textDocumentProxy.documentContextBeforeInput,
            let banner = bannerView as? SentimentBanner else { return }
        
        let sentiment = classificationService.predictSentiment(from: text)
        banner.update(sentiment: sentiment)
        
    }
    
    override func createBanner() -> ExtraView? {
        let banner = SentimentBanner(globalColors: type(of: self).globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
        banner.update(sentiment: .neutral)
        return banner
    }
}
