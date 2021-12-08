//
//  CardBehavior.swift
//  PlayingCards
//
//  Created by Linda adel on 12/6/21.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    // Contains the behaviors that a card must have
    lazy var collisionBehavior : UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
        
    }()
    //in dynamic bahavior items is slow bcse lack of electicity and flip rotated so we are going to fix thid by item behavior
    lazy var itemBehavior : UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    private func push (_ item : UIDynamicItem){
        // to push cards from their potision for dynamic animation
        let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous)
        // Push item towards the center
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                pushBehavior.angle = (CGFloat.pi/2).arc4random
            case let (x, y) where x > center.x && y < center.y:
                pushBehavior.angle = CGFloat.pi-(CGFloat.pi/2).arc4random
            case let (x, y) where x < center.x && y > center.y:
                pushBehavior.angle = (-CGFloat.pi/2).arc4random
            case let (x, y) where x > center.x && y > center.y:
                pushBehavior.angle = CGFloat.pi+(CGFloat.pi/2).arc4random
            default:
                pushBehavior.angle = (CGFloat.pi*2).arc4random
            }
        pushBehavior.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4random
        // After item is pushed, we no longer need it
        pushBehavior.action = {[unowned pushBehavior , weak self] in
            self?.removeChildBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)
    }
    }
    func addItem(_ item : UIDynamicItem){
        // add item to itembehavior and collision to happen
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    func removeItem(_ item : UIDynamicItem){
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
        // we dont have to remove the push bcse we remove it as soon as it happens
        
    }
    // these vars must be added as children and this is done in init
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    // to speacify init that item will be in
    convenience init(in animator : UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
        
    }
}
