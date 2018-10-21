//
//  DLX.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

public class DLX
{
  let dlx = RootNode()
  
  var columns = Dictionary<Int,ColumnNode>()
  var rows    = Dictionary<Int,GridNode>()
  
  let numColumns   : Int!
  
  public private(set) static var error : String?
  
  public init?( _ A:[[Int]] )
  {
    DLX.error = nil

    let indices = Set(A.reduce([],+))
    numColumns = indices.count
    
    guard numColumns > 0 else {
      DLX.error = "empty coverage matrix entered"
      return nil
    }
    
    let a = indices.min()!
    let b = indices.max()!
    
    guard b == ( a + indices.count - 1 ) else {
      DLX.error =
        String(format: "Insufficient column coverage (min=%d, max=%d, count=%d)", a, b, indices.count)
      return nil
    }
    
    for j in a...b {
      let col = ColumnNode(j)
      columns[j] = col
      dlx.add(col)
    }
    
    for i in 0..<A.count {
      for colID in A[i] {
        let node = GridNode(row: i, in: columns[colID]!)
        if let h = rows[i] {
          node.insert(before:h)
        } else {
          rows[i] = node
        }
      }
    }
  }

  func dump()
  {
    print()
    
    var curRows = Set<Int>()

    var columnString = "Columns:"
    
    var c = dlx.right as? ColumnNode
    while c != nil {
      var r = c!.down as? GridNode
      while r != nil {
        curRows.insert(r!.row)
        r = r!.down as? GridNode
      }
      columnString.append( String(format: " %@(%d)", c!.label, c!.rows) )
      c = c!.right as? ColumnNode
    }

    print(columnString)
    
    let sortedRows = Array(curRows).sorted()
    
    if sortedRows.count > 0 {
      print()
      
      sortedRows.forEach { i in
        var rowString = i.description + ":"
        var cur = rows[i]!
        repeat
        {
          rowString.append( " " + cur.col.label )
          cur = cur.right as! GridNode
        } while cur !== rows[i]

        print(rowString)
      }
    }

    print()
  }
  
}
