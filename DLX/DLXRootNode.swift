//
//  RootNote.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class DLXRootNode : DLXNode
{
  func isEmpty() -> Bool
  {
    let r = self.right
    return (r == nil) || (r === self)
  }
  
  func add(_ x:DLXColumnNode)
  {
    x.insert(before:self) // this inserts self at the END of the list of columns
  }
  
  func hasEmptyColumn() -> Bool
  {
    if isEmpty() { return false }
    
    var c = self.right!
    while c !== self
    {
      assert( c is DLXColumnNode, "Root node row linkage can only contain ColumnNodes" )
      assert( c.right != nil,  "Incomplete root row linkage encountered" )

      let h = c as! DLXColumnNode
      if h.rows == 0 { return true }
      c = c.right!
    }
    return false
  }
}
