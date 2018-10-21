//
//  GridNode.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class DLXGridNode : DLXNode
{
  let row : Int!
  let col : DLXColumnNode!
  
  init(row:Int, in col:DLXColumnNode)
  {
    self.row = row
    self.col = col
    
    super.init()
    
    col.add(self)
  }
}
