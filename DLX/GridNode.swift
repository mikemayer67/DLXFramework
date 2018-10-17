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
  let col : HeaderNode!
  
  init(row:Int, in col:HeaderNode)
  {
    self.row = row
    self.col = col
    
    super.init()
    
    insert(above:col)
    col.size += 1
  }
  
  convenience init(row:Int, in column:HeaderNode, after priorNode:GridNode)
  {
    self.init(row:row, in:column)
    self.insert(after:priorNode)
  }
}
