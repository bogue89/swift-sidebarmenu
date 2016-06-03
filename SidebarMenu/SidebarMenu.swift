//
//  SidebarController.swift
//  SidebarMenu component
//
//  Created by Jorge Benavides on 5/16/16.
//  Copyright © 2016 PEW PEW. All rights reserved.
//

import UIKit

class SidebarController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let presentAnimation = SidebarPresentAnimation()
    let dismissAnimation = SidebarDismissAnimation()
    let presentInteraction = SidebarPresentInteraction()
    let dismissInteraction = SidebarDismissInteraction()
    
    var dismissedControllerView:UIView? = nil
    var peekViewForDismissedController = UIView()
    var constraintForPeekView:NSLayoutConstraint!
    var gapForPeekView:CGFloat = 40
    
    var presentAnimationDuration:NSTimeInterval = 0.5
    var dismissAnimationDuration:NSTimeInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // we link the inherited controller to make changes on the view and other values any time
        self.presentAnimation.MainController = self
        self.dismissAnimation.MainController = self
        self.view.addSubview(self.peekViewForDismissedController)
        self.peekViewForDismissedController.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(
            item: self.peekViewForDismissedController,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0))
        self.view.addConstraint(NSLayoutConstraint(
            item: self.peekViewForDismissedController,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0))
        self.view.addConstraint(NSLayoutConstraint(
            item: self.peekViewForDismissedController,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1,
            constant: 0))
        self.constraintForPeekView = NSLayoutConstraint(
            item: self.peekViewForDismissedController,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(self.constraintForPeekView)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.bringSubviewToFront(self.peekViewForDismissedController)
        self.peekViewForDismissedController.backgroundColor = UIColor.redColor()
    }
    override func presentViewController(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        // delegate the present animation of the new controller to sidebarcontroller
        viewControllerToPresent.transitioningDelegate = self
        
        // attach the view controller to present to the interactions
        self.presentInteraction.attachToViewController(self, snapController: viewControllerToPresent)
        self.dismissInteraction.attachToViewController(viewControllerToPresent)
        
        // call the present method from super
        super.presentViewController(viewControllerToPresent, animated: animated, completion: completion)
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        constraintForPeekView.constant = 0
        self.view.updateConstraints()
    }
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // set the animation for the presented transition
        return self.presentAnimation
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // set the animation for the dismissed transition
        return self.dismissAnimation
    }
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // set the interaction for the presented transition if is not bussy
        return self.presentInteraction.transitionInProgress ? self.presentInteraction : nil
    }
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // set the interaction for the dismissed transition if is not bussy
        return self.dismissInteraction.transitionInProgress ? self.dismissInteraction : nil
    }
}
class SidebarPresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var MainController:SidebarController!
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.MainController.presentAnimationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        let bounds = UIScreen.mainScreen().bounds
        
        toViewController.view.frame = CGRectOffset(bounds, bounds.size.width - (self.MainController.dismissedControllerView != nil ? -self.MainController.constraintForPeekView.constant : 0), 0)
        
        containerView.addSubview(toViewController.view)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            
            toViewController.view.frame = bounds
            
            }, completion: {
                finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}
class SidebarDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var MainController:SidebarController!
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.MainController.dismissAnimationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        let bounds = UIScreen.mainScreen().bounds
        
        self.MainController.dismissedControllerView?.removeFromSuperview()
        self.MainController.dismissedControllerView = fromViewController.view.snapshotViewAfterScreenUpdates(true)
        
        fromViewController.view.frame = bounds
        toViewController.view.frame = bounds
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            
            fromViewController.view.frame = CGRectOffset(bounds, bounds.size.width-self.MainController.gapForPeekView, 0)
            
            }, completion: {
                finished in
                self.MainController.constraintForPeekView.constant = -self.MainController.gapForPeekView
                self.MainController.peekViewForDismissedController.addSubview(self.MainController.dismissedControllerView!)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}
class SidebarPresentInteraction: UIPercentDrivenInteractiveTransition {
    var viewController: SidebarController!
    var snapController: UIViewController!
    var shouldCompleteTransition = false
    var transitionInProgress = false
    var width:CGFloat = 0.0
    
    func attachToViewController(viewController: UIViewController, snapController: UIViewController) {
        self.viewController = viewController as! SidebarController
        self.snapController = snapController
        self.width = self.viewController.view.frame.size.width
        setupGestureRecognizer(self.viewController.view)
    }
    
    private func setupGestureRecognizer(view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        gesture.edges = .Right
        view.addGestureRecognizer(gesture)
        
        let touch = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        viewController.peekViewForDismissedController.addGestureRecognizer(touch)
    }
    
    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let viewTranslation = gestureRecognizer.translationInView(gestureRecognizer.view!.superview!)
        
        switch gestureRecognizer.state {
        case .Began:
            transitionInProgress = true
            self.viewController.presentViewController(self.snapController, animated: true, completion: {})
        case .Changed:
            let const = CGFloat(-viewTranslation.x / self.width)
            shouldCompleteTransition = const > 0.5
            updateInteractiveTransition(const)
        case .Cancelled, .Ended:
            transitionInProgress = false
            if !shouldCompleteTransition || gestureRecognizer.state == .Cancelled {
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition()
            }
        default:
            print("default")
        }
    }
}
class SidebarDismissInteraction: UIPercentDrivenInteractiveTransition {
    var viewController: UIViewController!
    var shouldCompleteTransition = false
    var transitionInProgress = false
    var width:CGFloat = 0.0

    func attachToViewController(viewController: UIViewController) {
        self.viewController = viewController
        self.width = self.viewController.view.frame.size.width
        setupGestureRecognizer(self.viewController.view)
    }
    
    private func setupGestureRecognizer(view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        gesture.edges = .Left
        view.addGestureRecognizer(gesture)
    }
    
    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let viewTranslation = gestureRecognizer.translationInView(gestureRecognizer.view!.superview!)
        switch gestureRecognizer.state {
        case .Began:
            transitionInProgress = true
            self.viewController.dismissViewControllerAnimated(true, completion: {})
        case .Changed:
            let const = CGFloat(viewTranslation.x / self.width)
            shouldCompleteTransition = const > 0.5
            updateInteractiveTransition(const)
        case .Cancelled, .Ended:
            transitionInProgress = false
            if !shouldCompleteTransition || gestureRecognizer.state == .Cancelled {
                cancelInteractiveTransition()
            } else {
                finishInteractiveTransition()
            }
        default:
            print("default")
        }
    }
}