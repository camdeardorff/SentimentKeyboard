//
//  ReplacementSuggestionCell.swift
//  SentimentKeyboard_Keyboard
//
//  Created by Cameron Deardorff on 4/18/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ReplacementSuggestionCell: UICollectionViewCell {
    static let identifier = "_ReplacementSuggestionCell"
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clipsToBounds = false
        
        contentView.layer.cornerRadius = 8
        
        contentView.backgroundColor = .lightGray
        backgroundColor = .clear
        
        layer.shadowColor = UIColor.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        layer.shadowOpacity = 1.0;
        layer.shadowRadius = 0.0;
    }

    func setLabel(withWord word: String, andReplacement replacement: String) {
        let fontSize:CGFloat = 17
        let text = "\(word)  \(replacement)"
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: fontSize), range: NSMakeRange(0, word.count))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: fontSize), range: NSMakeRange(word.count, text.count - word.count))
        
        label.attributedText = attributedString
    }
}
