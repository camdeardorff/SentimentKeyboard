//
//  Thesaurus.swift
//  Words
//
//  Created by Sam Soffes on 6/13/14.
//  Copyright (c) 2014 Nothing Magical Inc. All rights reserved.
//
import FMDB

class Thesaurus {
    
    static let shared = Thesaurus()
    
    var database: FMDatabase = {
        let path = Bundle.main.path(forResource: "words", ofType: "sqlite3")
        return FMDatabase(path: path)
    }()
    
    private init() { database.open() }
    deinit { database.close() }
    
    func resultForQuery(query: String) -> Result? {
        guard let set = database.executeQuery("SELECT word, synonyms FROM words WHERE word like ?", withArgumentsIn: [query]) else { return nil }
        if set.next() {
            
            let synonyms = set.string(forColumn: "synonyms")?.split(separator: ",").map { String($0) }
            return Result(word: set.string(forColumn: "word")!, synonyms: synonyms!)
        }
        
        return nil
    }
    
    func synonymsWithPOS(forWord word: String, tag: Tag, callback: @escaping ([Synonym]?) -> ()) {
        
        let urlString = "https://api.datamuse.com/words?rel_syn=\(word)&md=p"
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil,
                let data = data {
                
                let decoder = JSONDecoder()
                var synonyms = try! decoder.decode([Synonym].self, from: data)
                synonyms = synonyms
                    .filter { $0.tags.contains(tag) }
                    .filter { !$0.word.isEmpty }
                callback(synonyms)
                return
                
            }
            callback(nil)
            
        }
        task.resume()
    }
    
}
