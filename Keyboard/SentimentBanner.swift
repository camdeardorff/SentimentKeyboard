//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

protocol SentimentBannerDelegate {
    func closeButtonPressed()
    func showAllReplacements(forSuggestion suggestion: (word: Word, replacement: String))
    func replacementSelected(forSuggestion suggestion: (word: Word, replacement: String))
}

class SentimentBanner: ExtraView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var replacementCollectionView: UICollectionView!
    @IBOutlet var sentimentLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    
    var delegate: SentimentBannerDelegate?
    
    var currentSentiment: Sentiment? {
        didSet {
            if let sentiment = currentSentiment {
                updateAppearance(withSentiment: sentiment)
            }
        }
    }
    
    var replacementSuggestions: [(word: Word, replacement: String)]? {
        didSet {
            if let sentiment = currentSentiment,
                sentiment != .negative {
                self.replacementCollectionView.reloadData()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { // change 2 to desired number of seconds
                    
                    self.replacementCollectionView.reloadData()
                }
            }
        }
    }
        
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        sharedInit()
    }

    required init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SentimentBanner.handleLongPress(_:)))
        replacementCollectionView.addGestureRecognizer(longPressRecognizer)
        
        if let flowLayout = replacementCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        
        closeButton.isHidden = true
        closeButton.tintColor = .lightGray
    }
    
    
    func update(sentiment: Sentiment, replacements: [(word: Word, replacement: String)]? = nil) {
        print("update sentiment to: ", sentiment)
        currentSentiment = sentiment
        replacementSuggestions = replacements
    }
    
    private func updateAppearance(withSentiment sentiment: Sentiment) {
        
        let duration = 0.3
        
        self.sentimentLabel.backgroundColor = .clear
        UIView.animate(withDuration: duration, animations: {
            self.sentimentLabel.text = sentiment.emoji
            self.contentView.backgroundColor = sentiment.color
        }, completion: { _ in
            self.sentimentLabel.backgroundColor = sentiment.color
        })
        
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
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: replacementCollectionView)
            if let indexPath = replacementCollectionView.indexPathForItem(at: touchPoint) {
                if let rs = replacementSuggestions,
                    indexPath.row < rs.count {
                    let replacement = rs[indexPath.row]
                    delegate?.showAllReplacements(forSuggestion: replacement)
                    closeButton.isHidden = false
                    sentimentLabel.isHidden = true
                }
            }
        }
    }
    
    @IBAction func closeButtonWasPressed(_ sender: Any) {
        if !closeButton.isHidden {
            delegate?.closeButtonPressed()
            closeButton.isHidden = true
            sentimentLabel.isHidden = false
        }
    }
    
    
}
extension SentimentBanner: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("BANG BANG!!!")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReplacementSuggestionCell.identifier, for: indexPath)
        
        if let replacementSuggestionCell = cell as? ReplacementSuggestionCell,
            let replacements = replacementSuggestions {

            replacementSuggestionCell.setLabel(withWord: replacements[indexPath.row].word.text,
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let rs = replacementSuggestions else { return }
        if rs.count > indexPath.row {
            delegate?.replacementSelected(forSuggestion: rs[indexPath.row])
        }
    }
}


