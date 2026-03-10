//
//  Int+EXT.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

extension Int {
    
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
