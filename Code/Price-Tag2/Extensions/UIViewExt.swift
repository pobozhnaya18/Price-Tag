//
//  UIViewExt.swift
//  barCodes
//
//  Created by NG on 4/9/18.
//  Copyright © 2018 NG. All rights reserved.
//

import Foundation
import UIKit

let expandedDelta = CGFloat(60.0)

extension UIView {
    ///extension method for expandin UIView
    func expandView() {
        let duration = 0.5
        let curve = 1
        if(self.frame.size.height == 70){
            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                self.frame.size.height += expandedDelta
            }, completion: nil)
        }else{

            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                self.frame.size.height -= expandedDelta
            }, completion: nil)
        }
    }
    ///extension method for expandin UITableView
    func expandTableView(isViewExpanded: Bool) {
        let duration = 0.5
        let curve = 1
        if(isViewExpanded){
            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                self.frame.origin.y -= 60
                
            }, completion: nil)
        }else{
            UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                self.frame.origin.y += 60
                
            }, completion: nil)
        }
    }
}
