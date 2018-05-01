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
    var currentSuggestsionsForWord: [(word: Word, suggestions: [(synonym: String, pos: NSLinguisticTag)])] = []
    
    
    var tableView: UITableView!
    var items = ["a", "b", "c", "d", "e", "f", "g", "h"]
    
    // MARK: load
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
    }
    
    // MARK: view
    
    override func createBanner() -> ExtraView? {
        let banner = SentimentBanner(globalColors: type(of: self).globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
        banner.delegate = self
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
    
    func setupTableView() {
        guard let bannerHeight = self.bannerView?.frame.height else { return }

        let frame = CGRect(x: view.frame.origin.x,
                           y: view.frame.height,
                           width: view.frame.width,
                           height: view.frame.height - bannerHeight)
        
        tableView = UITableView(frame: frame)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.85)
        view.addSubview(tableView)       
    }
    
    func replace(word: Word, with replacement: String) {

        // find and remove the old word
        let textDocumentProxy = self.textDocumentProxy
        let characterCount = textDocumentProxy.documentContextBeforeInput?.count ?? 0
        let startPoint = characterCount - word.range.upperBound
        textDocumentProxy.adjustTextPosition(byCharacterOffset: -startPoint)
        for _ in word.range.lowerBound..<word.range.upperBound {
            textDocumentProxy.deleteBackward()
        }
        
        // inser the replacement and show the new sentiment
        textDocumentProxy.insertText(replacement)
        showSentiment()
        
        // put the text position at the end
        let trailingCount = textDocumentProxy.documentContextAfterInput?.count ?? 0
        textDocumentProxy.adjustTextPosition(byCharacterOffset: trailingCount)

    }
    
}

extension SentimentKeyboard {
    func showSentiment() {
        
        let textDocumentProxy = self.textDocumentProxy
        
        guard let text = textDocumentProxy.documentContextBeforeInput,
            let banner = bannerView as? SentimentBanner else { return }
        
        let prediction = classificationService.predictSentiment(from: text)
        
        var replacements: [(word: Word, replacement: String)]? = []
        
        // if negative find replacements for any negative words
        if prediction.sentiment == .negative {
            
//            // find negative words in the text
//            let contributingWords = classificationService.wordsWithNegativeSentiment(inText: text)
//            // get parts of speech for each token in the text
            
            let partsOfSpeechForToken = TextProcessor.shared.partsOfSpeechForToken(inString: text)
            let words = partsOfSpeechForToken.enumerated().map { (arg) -> Word in
                let (idx, posForToken) = arg
                return Word(id: idx,
                            text: posForToken.token,
                            range: posForToken.range,
                            pos: posForToken.tag,
                            isNegative: classificationService.wordHasNegativeSentiment(word: posForToken.token))
            }
            
            
            
            for word in words {
                print("found negative word `\(word.text)` to be a \(String(describing: word.pos))")
                if let synonyms = Thesaurus.shared.resultForQuery(query: word.text)?.synonyms {
                    
                    
                    
                    let matches = synonyms.suffix(10)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !classificationService.wordHasNegativeSentiment(word: $0) }
                        .map { (synonym: $0, pos: TextProcessor.shared.partOfSpeechFor(word: $0)) }
                        .filter {  $0.pos != nil }
                        .map { (synonym: $0.synonym, pos: $0.pos!) }
                    
                    currentSuggestsionsForWord.append((word: word, suggestions: matches))
                    
                    print("relacements for word: ", word.text, " : ", matches)
                    if let replacement = matches.randomItem() {
                        print("replace `\(word.text)` with `\(replacement)`")
                        replacements?.append((word: word, replacement: replacement.synonym))
                    }
                }
            }
        }
        
        banner.update(sentiment: prediction.sentiment, replacements: replacements)

    }
}

extension SentimentKeyboard {
    func hideSuggestionTable() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.frame = CGRect(x: 0,
                                          y: self.view.frame.height,
                                          width: self.tableView.frame.width,
                                          height: self.tableView.frame.height)
        }, completion: { _ in
            self.tableView.isHidden = true
        })
    }
    func showSuggestionTable() {
        guard let bannerHeight = self.bannerView?.frame.height else { return }
        self.tableView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.tableView.frame = CGRect(x: self.view.frame.origin.x,
                                          y: self.view.frame.origin.y + bannerHeight,
                                          width: self.view.frame.width,
                                          height: self.view.frame.height - bannerHeight)
        }
    }
}

extension SentimentKeyboard: UITableViewDelegate {
    
}

extension SentimentKeyboard: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension SentimentKeyboard: SentimentBannerDelegate {
    func showAllReplacements(forSuggestion suggestion: (word: Word, replacement: String)) {
        if let replacements = (currentSuggestsionsForWord.filter { $0.word == suggestion.word }).first {
            items = replacements.suggestions.map { $0.synonym }
            tableView.reloadData()
            showSuggestionTable()
        }
    }
    
    func closeButtonPressed() {
        hideSuggestionTable()
    }
    
    func replacementSelected(forSuggestion suggestion: (word: Word, replacement: String)) {
        print("replace '\(suggestion.word)' with \(suggestion.replacement)")
        replace(word: suggestion.word, with: suggestion.replacement)
    }
    
}

