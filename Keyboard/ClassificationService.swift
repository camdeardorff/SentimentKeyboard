import CoreML
import Foundation

final class ClassificationService {

    let model = SentimentPolarity()
    let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    lazy var tagger: NSLinguisticTagger = .init(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
        options: Int(self.options.rawValue)
    )
    
    // MARK: - Prediction
    
    func predictSentiment(from text: String) -> SentimentPrediction {
        do {
            let inputFeatures = features(from: text)
            let output = try model.prediction(input: inputFeatures)
            
            return SentimentPrediction(sentiment: Sentiment.from(classLabel: output.classLabel),
                                confidence: sentimentProbabilities(fromDict: output.classProbability))
        } catch {
            return SentimentPrediction(sentiment: .neutral, confidence: [:])
        }
    }
    
    private func sentimentProbabilities(fromDict dict: [String : Double]) -> [Sentiment : Double] {
        return Dictionary(uniqueKeysWithValues: dict.map { key, value in
            (Sentiment.from(classLabel: key), value)
        })
    }
    
    
    func wordsWithNegativeSentiment(inText text: String) -> [String] {
        let words = text.split(separator: " ")
        let negativeWords = words.filter {
            let sample = String($0) + " " + String($0) + " " + String($0)
            let prediction = predictSentiment(from: sample)
            print("prediction of word: ", $0, "-> ", prediction)
            return prediction.sentiment == .negative }
        return negativeWords.map { String($0) }
    }
}

// MARK: - Features

extension ClassificationService {
    func features(from text: String) -> [String: Double] {
        var wordCounts = [String: Double]()
        
        // some of the tag schemes are not available on all devices
        // to see what tag schemes are available uncomment this block
        /*
        for lang in NSLinguisticTagger.availableTagSchemes(forLanguage: "en") {
            print("lang: ", lang)
        }
        */
        
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let tagScheme = NSLinguisticTagSchemeTokenType
        // let tagScheme = NSLinguisticTagSchemeNameType

        // Tokenize and count the sentence
        tagger.enumerateTags(in: range, scheme: tagScheme, options: options) { _, tokenRange, _, _ in
            let token = (text as NSString).substring(with: tokenRange).lowercased()
            
            if let value = wordCounts[token] {
                wordCounts[token] = value + 1.0
            } else {
                wordCounts[token] = 1.0
            }
        }
        
        return wordCounts
    }
}
