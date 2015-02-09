//
//  NSImageView.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 2/3/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

import Foundation

extension NSImageView {
    
    func setFilters(filters: NSArray, from: Float, to: Float, animated: Bool = true) {
        
        self.layer!.filters = filters
        
        if animated {
            var filterAnimation = CABasicAnimation()
            filterAnimation.keyPath = "filters.monochromefiter.inputIntensity"
            filterAnimation.fromValue = from
            filterAnimation.toValue = to
            filterAnimation.duration = 1.0
            filterAnimation.fillMode = kCAFillModeForwards
            filterAnimation.removedOnCompletion = false
            
            self.layer!.addAnimation(filterAnimation, forKey: "filterAnimation")
        }
    }
}
