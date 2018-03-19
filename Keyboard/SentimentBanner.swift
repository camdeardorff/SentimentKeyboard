//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

class SentimentBanner: ExtraView {
    
    var sentimentLabel: UILabel = UILabel()
    var currentSentiment: Sentiment? {
        didSet {
            if let sentiment = currentSentiment {
                updateAppearance(withSentiment: sentiment)
            }
        }
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        
        self.addSubview(self.sentimentLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.sentimentLabel.center = self.center
        self.sentimentLabel.font = UIFont.systemFont(ofSize: 30)
        self.sentimentLabel.frame.origin = CGPoint(x: frame.width / 2 - sentimentLabel.frame.width / 2, y: self.sentimentLabel.frame.origin.y)
        self.sentimentLabel.sizeToFit()
    }
    
    func update(sentiment: Sentiment) {
        currentSentiment = sentiment
    }
    
    private func updateAppearance(withSentiment sentiment: Sentiment) {
        self.sentimentLabel.text = sentiment.emoji
        self.sentimentLabel.sizeToFit()
        self.backgroundColor = sentiment.color
    }
}
