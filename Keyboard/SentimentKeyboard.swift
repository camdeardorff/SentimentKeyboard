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
        let textDocumentProxy = self.textDocumentProxy
        let keyOutput = key.outputForCase(self.shiftState.uppercase())
        
        if let text = textDocumentProxy.documentContextBeforeInput {
            let sentiment = classificationService.predictSentiment(from: text)
            
            if let banner = bannerView as? SentimentBanner {
                banner.update(sentiment: sentiment)
            }
        }
        
        textDocumentProxy.insertText(keyOutput)
    }
    
    override func createBanner() -> ExtraView? {
        let banner = SentimentBanner(globalColors: type(of: self).globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
        banner.update(sentiment: .neutral)
        return banner
    }
}
