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
        cardViews.filter{ $0.isFaceUp && !$0.isHidden }
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardsViews.count == 2 && faceUpCardsViews[0].rank == faceUpCardsViews[1].rank && faceUpCardsViews[0].suit == faceUpCardsViews[1].suit
    }
    
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
        }
    }
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView {
                UIView.transition(with: chosenCardView,
                                  duration: 0.6,
                                  options: [.transitionFlipFromLeft],
                                  animations:{
                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                },
                                  completion:{ finished in// here we don't have memory cycle because closure does capture self, self doesnt any way point to this closure. Animation system only has pointer to this closure
                    if self.faceUpCardViewsMatch {
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.6,
                            delay: 0,
                            animations: {
                                self.faceUpCardsViews.forEach {
                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 2.0, y: 2.0)
                                }
                            },
                            completion: { position in
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.75,
                                    delay: 0,
                                    animations: {
                                        self.faceUpCardsViews.forEach {
                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                            $0.alpha = 0
                                        }
                                    },
                                    completion: { position in
                                        self.faceUpCardsViews.forEach {
                                            $0.isHidden = true
                                            $0.alpha = 1
                                            $0.transform = .identity
                                        }
                                    }
                                )
                            }
                        )
                    } else if self.faceUpCardsViews.count == 2 {
                        self.faceUpCardsViews.forEach { cardView in
                            UIView.transition(with: cardView,
                                              duration: 0.6,
                                              options: [.transitionFlipFromLeft],
                                              animations:{
                                cardView.isFaceUp = false
                            })
                        }
                    }
                }
                )
            }
        default: break
        }
    }
}

