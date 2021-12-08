//
//  PlayingCardDeck.swift
//  PlayingCards
//
//  Created by Linda adel on 11/30/21.
//

import Foundation

struct PlayingCardDeck {

    private(set) var cards = [PlayingCard]()
    
    init() {
        for suit in PlayingCard.Suit.all {
            for rank in PlayingCard.Rank.all {
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
    }
    
    mutating func draw() -> PlayingCard?{
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        }
        return nil
    }
}
