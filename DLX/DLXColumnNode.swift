//
//  ColumnNode.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class DLXColumnNode : DLXNode
{
  var rows  = 0
  var id = 0
  
  var label : String { return id.description }
  
  init(_ id:Int)
  {
    self.id = id
    super.init()
  }
  
  func add(_ node:DLXGridNode)
  {
    node.insert(above:self) // this inserts node at bottom of the column
    self.rows += 1
  }
}
