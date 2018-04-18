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
}
