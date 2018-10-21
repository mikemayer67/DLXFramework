//
//  Node.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class DLXNode
{
  var left  : DLXNode!
  var right : DLXNode!
  var up    : DLXNode!
  var down  : DLXNode!
  
  init()
  {
    self.left  = self
    self.right = self
    self.up    = self
    self.down  = self
  }
  
  func insert(after x:DLXNode)
  {
    self.left       = x
    self.right      = x.right
    self.left.right = self
    self.right.left = self
  }
  
  func insert(before x:DLXNode)
  {
    self.right      = x
    self.left       = x.left
    self.left.right = self
    self.right.left = self
  }
  
  func insert(below x:DLXNode)
  {
    self.up      = x
    self.down    = x.down
    self.up.down = self
    self.down.up = self
  }
  
  func insert(above x:DLXNode)
  {
    self.down    = x
    self.up      = x.up
    self.up.down = self
    self.down.up = self
  }
  
  func removeFromRow()
  {
    self.left.right = self.right
    self.right.left = self.left
  }
  
  func removeFromColumn()
  {
    self.up.down = self.down
    self.down.up = self.up
  }
  
  func reinsert()
  {
    self.up.down    = self
    self.down.up    = self
    self.left.right = self
    self.right.left = self
  }
}

class DLXRootNode : DLXNode
{
  var empty : Bool { return self.right === self }
  
  func add(_ col:DLXColumnNode)
  {
    col.insert(before:self) // this inserts self at the END of the list of columns
  }
  
  func hasEmptyColumn() -> Bool
  {
    var rval = false
    
    var c = self.right as? DLXColumnNode
    while c != nil, rval == false
    {
      if c!.rows == 0 { rval = true }
      c = c!.right as? DLXColumnNode
    }
    return rval
  }
}

class DLXColumnNode : DLXNode
{
  var id    = 0
  var rows  = 0
  
  var string : String { return String(format:" %d(%d)",id,rows) }
  
  init(_ id:Int)
  {
    self.id = id
    super.init()
  }
  
  func add(row node:DLXGridNode)
  {
    node.insert(above:self) // this inserts node at bottom of the column
    self.rows += 1
  }
}

class DLXGridNode : DLXNode
{
  let row : Int!
  let col : DLXColumnNode!
  
  init(row:Int, col:DLXColumnNode)
  {
    self.row = row
    self.col = col
    
    super.init()
    
    col.add(row:self)
  }
}
