//
//  GridNode.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class GridNode : Node
{
  let row : Int!
  let col : ColumnNode!
  
  init(row:Int, in col:ColumnNode)
  {
    self.row = row
    self.col = col
    
    super.init()
    
    col.add(self)
  }
}
