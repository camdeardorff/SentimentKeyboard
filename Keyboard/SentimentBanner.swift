//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

class SentimentBanner: ExtraView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var replacementCollectionView: UICollectionView!
    
    @IBOutlet var sentimentLabel: UILabel!
    var currentSentiment: Sentiment? {
        didSet {
            if let sentiment = currentSentiment {
                updateAppearance(withSentiment: sentiment)
            }
        }
    }
    
    var replacementSuggestions: [(word: String, replacement: String)]? {
        didSet {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // change 2 to desired number of seconds
                
                self.replacementCollectionView.reloadData()
            }
        }
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        sharedInit()
    }
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    func sharedInit() {
        
        Bundle.main.loadNibNamed("SentimentBanner", owner: self, options: nil)
        addSubview(contentView)
        contentView.bounds = self.bounds
        contentView.frame = self.frame
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = .clear
        
        replacementCollectionView.dataSource = self
        replacementCollectionView.delegate = self
        
        replacementCollectionView.register(UINib.init(nibName: "ReplacementSuggestionCell", bundle: nil), forCellWithReuseIdentifier: ReplacementSuggestionCell.identifier)
        replacementCollectionView.backgroundColor = .clear
        replacementCollectionView.contentInset = UIEdgeInsets(top: 0, left: sentimentLabel.frame.width, bottom: 0, right: 0)
        
        if let flowLayout = replacementCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    
    
    func update(sentiment: Sentiment, replacements: [(word: String, replacement: String)]? = nil) {
        print("update sentiment to: ", sentiment)
        currentSentiment = sentiment
        replacementSuggestions = replacements
    }
    
    private func updateAppearance(withSentiment sentiment: Sentiment) {
        
        let duration = 0.3
        
        UIView.animate(withDuration: duration) {
            self.sentimentLabel.text = sentiment.emoji
            self.sentimentLabel.backgroundColor = sentiment.color
            self.contentView.backgroundColor = sentiment.color
        }
        
        if sentiment == .negative {
            UIView.animate(withDuration: duration, delay: duration, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.sentimentLabel.frame.origin.x = 0

            }, completion: nil)
        } else {
            UIView.animate(withDuration: duration, delay: duration, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.sentimentLabel.frame.origin = CGPoint(x: self.frame.width / 2 - self.sentimentLabel.frame.width / 2, y: self.sentimentLabel.frame.origin.y)
            }, completion: nil)
        }
    }
}
extension SentimentBanner: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("BANG BANG!!!")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReplacementSuggestionCell.identifier, for: indexPath)
        
        if let replacementSuggestionCell = cell as? ReplacementSuggestionCell,
            let replacements = replacementSuggestions {

            replacementSuggestionCell.setLabel(withWord: replacements[indexPath.row].word,
                                               andReplacement: replacements[indexPath.row].replacement)
            
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replacementSuggestions?.count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}
extension SentimentBanner: UICollectionViewDelegate {

}


