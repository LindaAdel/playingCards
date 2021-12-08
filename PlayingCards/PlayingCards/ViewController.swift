//
//  ViewController.swift
//  PlayingCards
//
//  Created by Linda adel on 11/30/21.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    
    // for dynamic animation : The animator controling the dynamic behaviors
    lazy var animator = UIDynamicAnimator(referenceView: view)
   
    lazy var cardBehavior = CardBehavior(in: animator)
    // var to control the lead of flipped cards so the animation dont over lap
    var lastCardTapped : PlayingCardView?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displayCards()
       
    }
    func displayCards(){
        var cards = [PlayingCard]()
        // create card pairs
        for _ in 1...((cardViews.count+1)/2) {
            let card  = deck.draw()!
            cards += [card, card]
        }
        //Setup each cardView
        for cardView in cardViews {
            // cards start facing down
            cardView.isFacedUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            // adding a gesture recognizer a tap gesture to card
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            
            cardBehavior.addItem(cardView)
           
            
        }
    }
    @IBAction func flipCard(_ sender: UITapGestureRecognizer)
        {
        switch sender.state {
        case .ended:
            // to get the card that was tapped and as a playingcardview
            if let chosenCardView = sender.view as? PlayingCardView , faceUpCardViews.count < 2{
                lastCardTapped = chosenCardView
                // remove behavior when card is tapped to fix it 
                cardBehavior.removeItem(chosenCardView)
                flipAnimation(chosenCardView)
            }
        default:
            break
        }
            
        }
    private func flipAnimation(_ tappedCard : PlayingCardView ){
        UIView.transition(with: tappedCard,
                          duration: 0.6,
                          options: .transitionFlipFromLeft,
                          // animation take a closure with what will happen using animation
                          animations: {tappedCard.isFacedUp = !tappedCard.isFacedUp} ,
                          // to flip down cards in mismatch if they are 2 cards animation inside animation
                          completion: { [self]
                            finishedFlip in
                            let cardToAnimate = self.faceUpCardViews
                            // animation for matched card
                            if self.faceUpCardViewsMatch {
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.7,
                                    delay: 0,
                                    // no option necessary
                                    options: [],
                                    animations: {
                                        cardToAnimate.forEach {
                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 2.0, y: 2.0)
                                        }
                                    },
                                    completion: {
                                        position in
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.7,
                                            delay: 0,
                                            // no option necessary
                                            options: [],
                                            animations: {
                                                cardToAnimate.forEach {
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x:0.1, y: 0.1)
                                                    $0.alpha = 0
                                                }
                                            },
                                            // complition once animation is done wil trigger for steps after animation like removing matching cards from cards
                                            completion: {
                                                position in
                                                cardToAnimate.forEach {
                                                    $0.isHidden = true
                                                    $0.alpha = 1
                                                    $0.transform = .identity
                                                }
                                            }
                                            )
                                    })
                            }
                            // mismatched cards
                            else
                            if  cardToAnimate.count == 2 {
                                if tappedCard == self.lastCardTapped
                                {
                                //  for each card in 2 faced up cards , face then down
                                cardToAnimate.forEach({cardView in
                                    UIView.transition(with: tappedCard,
                                                      duration: 0.6,
                                                      options: .transitionFlipFromLeft,
                                                      // animation take a closure with what will happen using animation
                                                      animations: {cardView.isFacedUp = false},
                                                      completion: {finished in
                                                        // add behavior to card after flipping down
                                                        self.cardBehavior.addItem(cardView)})
                                })
                                }
                                
                            } else if !tappedCard.isFacedUp{
                                // when one card is flipped down
                                self.cardBehavior.addItem(tappedCard)
                            }
                          }
        )
        
    }
    // varible to detect list of card facing up so we can turn them down in case of mismatch
    // hidden is for cards that already matched
    private var faceUpCardViews : [PlayingCardView]{
        return cardViews.filter({
            $0.isFacedUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 2.0, y: 2.0) && $0.alpha == 1
        })
    }
    private var faceUpCardViewsMatch :Bool{
        return faceUpCardViews.count == 2 &&
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    
        
    }

      
}
//        func addSwipeGestureRecongnizer(){
//        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
//        swipe.direction = [.left,.right]
//        playingCardView.addGestureRecognizer(swipe)
//        let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecognizer:)))
//        playingCardView.addGestureRecognizer(pinch)
//    }
//    @objc func nextCard(){
//    if let card = deck.draw() {
//        playingCardView.rank = card.rank.order
//        playingCardView.suit = card.suit.rawValue
//    }
        


