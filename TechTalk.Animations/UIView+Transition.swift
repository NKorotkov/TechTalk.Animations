//
//  UIView+Transition.swift
//  TechTalk.Animations
//
//  Created by KOROTKOV Nikolay on 25.10.2021.
//

import UIKit

fileprivate let translationValue: CGFloat = 16

extension UIView {
    enum ExtraTransitions {
        case slideFromLeft
        case slideFromRight
        case slideFromTop
        case slideFromBottom
        
        fileprivate var snapshotTransform: CGAffineTransform {
            switch self {
            case .slideFromLeft:
                return .init(translationX: translationValue, y: 0)
            case .slideFromRight:
                return .init(translationX: -translationValue, y: 0)
            case .slideFromTop:
                return .init(translationX: 0, y: translationValue)
            case .slideFromBottom:
                return .init(translationX: 0, y: -translationValue)
            }
        }
        
        fileprivate var originalTransform: CGAffineTransform {
            switch self {
            case .slideFromLeft:
                return .init(translationX: -translationValue, y: 0)
            case .slideFromRight:
                return .init(translationX: translationValue, y: 0)
            case .slideFromTop:
                return .init(translationX: 0, y: -translationValue)
            case .slideFromBottom:
                return .init(translationX: 0, y: translationValue)
            }
        }
    }
}

extension UIView {
    class func transition(with view: UIView, duration: TimeInterval, transition: ExtraTransitions, options: UIView.AnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        
        guard let superview = view.superview,
        let snapshot = view.snapshotView(afterScreenUpdates: false)
        else { return }
        
        snapshot.frame = snapshot.frame.offsetBy(
            dx: view.frame.origin.x,
            dy: view.frame.origin.y
        )
        
        superview.addSubview(snapshot)
        view.transform = transition.originalTransform
        view.alpha = 0
        animations?()
        
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            snapshot.transform = transition.snapshotTransform
            view.transform = .identity
            view.alpha = 1
            snapshot.alpha = 0
        } completion: {
            snapshot.removeFromSuperview()
            completion?($0)
        }
    }
}
