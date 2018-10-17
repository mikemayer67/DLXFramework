//
//  RootNote.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class RootNode : Node
{
  func isEmpty() -> Bool
  {
    let r = self.right
    return (r == nil) || (r === self)
  }
  
  func hasEmptyColumn() -> Bool
  {
    if isEmpty() { return false }
    
    var c = self.right!
    while c is HeaderNode
    {
      let h = c as! HeaderNode
      if h.size == 0 { return true }
      assert( c.right != nil, "Incomplete linkage encountered" )
      c = c.right!
    }
    return false
  }
}
