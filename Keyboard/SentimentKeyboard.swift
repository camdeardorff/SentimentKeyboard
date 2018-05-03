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
    var currentSuggestsionsForWord: [(word: Word, suggestions: [Synonym])] = []
    var currentSynonymsForWord: (word: Word, suggestions: [Synonym])? = nil
    
    var tableView: UITableView!
    var visualEffectsView: UIVisualEffectView!
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
        tableView.backgroundColor = .clear //UIColor.gray.withAlphaComponent(0.75)
        
        visualEffectsView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectsView.frame = tableView.bounds
        tableView.backgroundView = visualEffectsView
        
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
        
        print("showing sentiment")
        
        let textDocumentProxy = self.textDocumentProxy
        
        guard let text = textDocumentProxy.documentContextBeforeInput,
            let banner = bannerView as? SentimentBanner else { return }
        
        let prediction = classificationService.predictSentiment(from: text)
        
        // if negative find replacements for any negative words
        if prediction.sentiment == .negative {

            
            let partsOfSpeechForToken = TextProcessor.shared.partsOfSpeechForToken(inString: text)
            var words = partsOfSpeechForToken.enumerated().map { (arg) -> Word in
                let (idx, posForToken) = arg
                return Word(id: idx,
                            text: posForToken.token,
                            range: posForToken.range,
                            pos: posForToken.tag,
                            isNegative: classificationService.wordHasNegativeSentiment(word: posForToken.token))
            }
            
            words = words.filter { $0.isNegative }
            
            for word in words {
                let tag = Tag.fromNSLingusticTag(word.pos)
                Thesaurus.shared.synonymsWithPOS(forWord: word.text, tag: tag) {  synonyms in
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }

                        if let synonymList = synonyms?.sort(),
                            let top = synonymList.first,
                            let banner = strongSelf.bannerView as? SentimentBanner {
                            
                            
                            let matches = Array(synonymList
                                .filter { !strongSelf.classificationService.wordHasNegativeSentiment(word: $0.word) }
                                .suffix(10))
                            
                            print("word: ", word, " has top syn: ", top.word, " and matches: \n\t", matches.map { $0.word })
                            
                            banner.addNew(replacementSuggestion: (word: word, replacement: top.word))
                            strongSelf.currentSuggestsionsForWord.append((word: word, suggestions: matches))
                        }
                    }
                }
            }
        }
        banner.update(sentiment: prediction.sentiment, replacements: [])

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



extension SentimentKeyboard: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let synForWord = currentSynonymsForWord else { return UITableViewCell(frame: .zero) }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel?.text = synForWord.suggestions[indexPath.row].word
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSynonymsForWord?.suggestions.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension SentimentKeyboard: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let synForWord = currentSynonymsForWord {
            if synForWord.suggestions.count > indexPath.row {
                let replacement = synForWord.suggestions[indexPath.row]
                replace(word: synForWord.word, with: replacement.word)
                if let sentimentBanner = bannerView as? SentimentBanner {
                    sentimentBanner.closeButtonWasPressed(self)
                }
            }
        }
        
        hideSuggestionTable()
    }
}

extension SentimentKeyboard: SentimentBannerDelegate {
    func showAllReplacements(forSuggestion suggestion: (word: Word, replacement: String)) {
        if let replacements = (currentSuggestsionsForWord.filter { $0.word == suggestion.word }).first {
            currentSynonymsForWord = replacements
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

