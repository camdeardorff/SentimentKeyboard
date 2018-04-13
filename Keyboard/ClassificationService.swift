import CoreML
import Foundation

final class ClassificationService {
    enum Error: Swift.Error {
        case featuresMissing
    }
    
    let model = SentimentPolarity()
    let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    lazy var tagger: NSLinguisticTagger = .init(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
        options: Int(self.options.rawValue)
    )
    
    // MARK: - Prediction
    
    func predictSentiment(from text: String) -> Sentiment {
        do {
            let inputFeatures = features(from: text)
            // Make prediction only with 2 or more words
            guard inputFeatures.count > 1 else {
                throw Error.featuresMissing
            }
            
            let output = try model.prediction(input: inputFeatures)
            
            print("class Probabilities: ", output.classProbability)
            print("prediction: ", output.classLabel)
            
            
            switch output.classLabel {
            case "positive":
                return .positive
            case "negative":
                return .negative
            default:
                return .neutral
            }
        } catch Error.featuresMissing {
            return .neutral
        } catch {
            fatalError("BIG PROBLEM")
        }
    }
    
    func wordsWithNegativeSentiment(inText text: String) -> [String] {
        let words = text.split(separator: " ")
        let negativeWords = words.filter { predictSentiment(from: String($0)) == .negative }
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
