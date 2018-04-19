//
//  CollectionViewCell.swift
//  SentimentKeyboard_Keyboard
//
//  Created by Cameron Deardorff on 4/18/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ReplacementSuggestionCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    
    static let identifier = "_ReplacementSuggestionCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

}
