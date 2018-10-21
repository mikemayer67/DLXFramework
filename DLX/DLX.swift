//
//  DLX.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation


enum DLXError : Error
{
  case InputMatrixEmpty
  case InputMatrixMissingColumns(min:Int, max:Int, count:Int)
}

public class DLX
{
  let dlx = DLXRootNode()
  
  var columns = Dictionary<Int,DLXColumnNode>()
  var rows    = Dictionary<Int,DLXGridNode>()
  
  let numColumns : Int!
  
  public init( _ A:[[Int]] ) throws
  {
    let indices = Set(A.reduce([],+))
    numColumns = indices.count
    
    guard numColumns > 0 else {
      throw DLXError.InputMatrixEmpty
    }
    
    let a = indices.min()!
    let b = indices.max()!
    let n = indices.count
    
    guard b == ( a + n - 1 ) else {
      throw DLXError.InputMatrixMissingColumns(min: a, max: b, count: n)
    }
    
    for j in a...b {
      let col = DLXColumnNode(j)
      columns[j] = col
      dlx.add(col)
    }
    
    for i in 0..<A.count {
      for j in A[i] {
        let node = DLXGridNode(row: i, col: columns[j]! )
        if let h = rows[i] { node.insert(before:h) }
        else               { rows[i] = node }
      }
    }
  }
  
}
