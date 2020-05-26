//
//  MemoryGame.swift
//  Memorize
//
//  Created by Tieda Wei on 2020-05-22.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import Foundation

struct MemoryGame<CardContent> {
    var cards: [Card]
    
    init(numberOfPairsOfCard: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()
        for pairIndex in 0..<numberOfPairsOfCard {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
    }
    
    func index(of card: Card) -> Int {
        for index in 0..<cards.count {
            if cards[index].id == card.id {
                return index
            }
        }
        return 0 // TODO:
    }
    
    mutating func choose(card: Card) {
        let chosenIndex = index(of: card)
        cards[chosenIndex].isFaceUp.toggle()
    }
    
    struct Card: Identifiable {
        var isFaceUp = false
        var isMatched = false
        var content: CardContent
        var id: Int
    }
}
