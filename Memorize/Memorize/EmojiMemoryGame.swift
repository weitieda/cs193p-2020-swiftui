//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Tieda Wei on 2020-05-22.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import SwiftUI

// ViewModel: portal for view to get model
class EmojiMemoryGame {
    
    // You should never name a variable "model", here's teaching purpose, name it "game" instead
    private var model = createMemoryGame()
    
    static func createMemoryGame() -> MemoryGame<String> {
        let emojis = ["😎", "👻", "🎃", "👽"]
        return MemoryGame<String>(numberOfPairsOfCard: emojis.count) { pairIndex in emojis[pairIndex]}
    }
    
    var cards: [MemoryGame<String>.Card] {
        model.cards
    }
    
    // (User) Intent
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
}
