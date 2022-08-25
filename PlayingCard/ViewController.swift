//
//  ViewController.swift
//  PlayingCard
//
//  Created by Nataliya Lazouskaya on 23.08.22.
//

import UIKit

class ViewController: UIViewController {
    
    private var deck = PlayingCardDeck()
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    private var faceUpCardsViews: [PlayingCardView] {
        cardViews.filter{ $0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 2.0, y: 2.0) && $0.alpha == 1}
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardsViews.count == 2 && faceUpCardsViews[0].rank == faceUpCardsViews[1].rank && faceUpCardsViews[0].suit == faceUpCardsViews[1].suit
    }
    
    lazy var animator = UIDynamicAnimator(referenceView: self.view)//animator, behavior, add items
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    var lastChosenCardView: PlayingCardView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cards = [PlayingCard]()
        
        for _ in 1...((cardViews.count + 1)/2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard)))
            cardBehavior.addItem(cardView)
        }
    }
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardsViews.count < 2 {
                
                lastChosenCardView = chosenCardView
                
                cardBehavior.removeItem(chosenCardView)
                
                UIView.transition(with: chosenCardView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromLeft],
                                  animations:{
                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                },
                                  completion:{ finished in// here we don't have memory cycle because closure does capture self, self doesnt any way point to this closure. Animation system only has pointer to this closure
                    let cardsToAnimate = self.faceUpCardsViews
                    if self.faceUpCardViewsMatch {
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.6,
                            delay: 0,
                            animations: {
                                cardsToAnimate.forEach {
                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 2.0, y: 2.0)
                                }
                            },
                            completion: { position in
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.75,
                                    delay: 0,
                                    animations: {
                                        cardsToAnimate.forEach {
                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                            $0.alpha = 0
                                        }
                                    },
                                    completion: { position in
                                        cardsToAnimate.forEach {
                                            $0.isHidden = true
                                            $0.alpha = 1
                                            $0.transform = .identity
                                        }
                                    }
                                )
                            }
                        )
                    } else if cardsToAnimate.count == 2 {
                        
                        if chosenCardView == self.lastChosenCardView {// last chosen card should control animation
                            cardsToAnimate.forEach { cardView in
                                UIView.transition(with: cardView,
                                                  duration: 0.5,
                                                  options: [.transitionFlipFromLeft],
                                                  animations:{
                                    cardView.isFaceUp = false
                                },
                                                  completion: {finished in
                                    self.cardBehavior.addItem(cardView)
                                }
                                )
                            }
                        }
                    } else {
                        if !chosenCardView.isFaceUp {
                            self.cardBehavior.addItem(chosenCardView)
                        }
                    }
                }
                )
            }
        default: break
        }
    }
}

