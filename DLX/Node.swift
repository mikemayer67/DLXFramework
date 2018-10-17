//
//  Node.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class Node
{
  var left  : Node?
  var right : Node?
  var up    : Node?
  var down  : Node?
  
  func insert(after x:Node)
  {
    assert( self.left == nil, "Attempted to reinsert linked node")
    assert( self.right == nil, "Attempted to reinsert linked node")
    
    self.left = x
    self.right = x.right ?? x
    self.left!.right = self
    self.right!.left = self
  }
  
  func insert(before x:Node)
  {
    assert( self.left == nil, "Attempted to reinsert linked node")
    assert( self.right == nil, "Attempted to reinsert linked node")
    
    self.right = x
    self.left = x.left ?? x
    self.left!.right = self
    self.right!.left = self
  }
  
  func insert(below x:Node)
  {
    assert( self.up == nil, "Attempted to reinsert linked node")
    assert( self.down == nil, "Attempted to reinsert linked node")
    
    self.up = x
    self.down = x.down ?? x
    self.up!.down = self
    self.down!.up = self
  }
  
  func insert(above x:Node)
  {
    assert( self.up == nil, "Attempted to reinsert linked node")
    assert( self.down == nil, "Attempted to reinsert linked node")
    
    self.down = x
    self.up = x.up ?? x
    self.up!.down = self
    self.down!.up = self
  }
  
  func removeFromRow()
  {
    self.left?.right = self.right
    self.right?.left = self.left
  }
  
  func removeFromColumn()
  {
    self.up?.down = self.down
    self.down?.up = self.up
  }
  
  func reinsert()
  {
    self.up?.down = self
    self.down?.up = self
    self.left?.right = self
    self.right?.left = self
  }
}
