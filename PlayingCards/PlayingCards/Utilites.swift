//
//  Utilites.swift
//  PlayingCards
//
//  Created by Linda adel on 11/30/21.
//

import Foundation
import UIKit


extension Int {
    var arc4random :Int{
        
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
            
        }
        else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
            
        }
        return 0
    }
}
extension CGFloat {
    var arc4random : CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
