//
//  sudoku4.swift
//  DLXTestDriver-OSX
//
//  Created by Mike Mayer on 10/26/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

class sudoku4
{
  static func grid() -> [[Int]]
  {
    var rval = [[Int]]()
    
    for r in 0..<4 {
      for c in 0..<4 {
        for d in 1...4 {
          let xr = 4*r + d      // row constraint
          let xc = 4*c + d + 16 // col constraint

          let x = ( r < 2 ? ( c < 2 ? 0 : 1 ) : ( c < 2 ? 2 : 3 ) ) // region
          
          let xx = 4*x + d + 32
          
          rval.append( [xr, xc, xx] )
        }
      }
    }
    return rval
  }
}
