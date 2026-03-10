//
//  Double+EXT.swift
//  Off
//
//  Created by Rodrigo Lemos on 19/02/26.
//

extension Double {
    
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
