//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

/*
This is the demo banner. The banner is needed so that the top row popups have somewhere to go. Might as well fill it
with something (or leave it blank if you like.)
*/

class SentimentBanner: ExtraView {
    
    var sentimentLabel: UILabel = UILabel()
    var currentSentiment: Sentiment? {
        didSet {
            updateAppearance()
        }
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        
        self.addSubview(self.sentimentLabel)
        
        self.updateAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.sentimentLabel.center = self.center
        self.sentimentLabel.frame.origin = CGPoint(x: frame.width / 2 - sentimentLabel.frame.width / 2, y: self.sentimentLabel.frame.origin.y)
    }
    
    func update(sentiment: Sentiment) {
        currentSentiment = sentiment
    }
    
    func updateAppearance() {
        guard let sentiment = currentSentiment else { return }
        self.sentimentLabel.text = sentiment.emoji
        self.sentimentLabel.sizeToFit()
    }
}
