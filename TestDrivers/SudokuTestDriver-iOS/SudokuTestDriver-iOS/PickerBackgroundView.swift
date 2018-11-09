//
//  PickerBackgroundView.swift
//  SudokuTestDriver-iOS
//
//  Created by Mike Mayer on 11/9/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class PickerBackgroundView: UIView {

    override func draw(_ rect: CGRect)
    {
      var path = UIBezierPath(rect: rect)
      UIColor.white.setFill()
      path.fill()
      
      path = UIBezierPath()
      path.move(to: rect.origin)
      path.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y))
      path.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
      path.addLine(to: CGPoint(x:rect.origin.x + rect.size.width, y:rect.origin.y + rect.size.height))
      UIColor.black.setStroke()
      path.stroke()
    }

}
