//
//  TransitionAnimator.swift
//  canaryForecast
//
//  Created by David Greenwood on 5/30/18.
//  Copyright © 2018 David Greenwood. All rights reserved.
//

import UIKit

//This is not very original

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration : TimeInterval
    var isPresenting : Bool
    var originFrame : CGRect
    
    init(duration : TimeInterval, isPresenting : Bool, originFrame : CGRect) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        if isPresenting {
          container.addSubview(toView)
        }
        else {
           container.insertSubview(toView, belowSubview: fromView)
        }
        
        let detailView = isPresenting ? toView : fromView
  
        toView.frame = isPresenting ?  originFrame : toView.frame
        toView.alpha = isPresenting ? 0 : 1
        toView.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, animations: {
            detailView.frame = self.isPresenting ? fromView.frame : self.originFrame
            detailView.alpha = self.isPresenting ? 1 : 0
        }, completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

}
