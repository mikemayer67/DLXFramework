//
//  DLXDump.swift
//  TestDriver-OSX
//
//  Created by Mike Mayer on 10/21/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

extension DLX
{
  func dump()
  {
    print()
    
    var curRows = Set<Int>()
    
    var columnString = "Columns:"
    
    var c = dlx.right as? DLXColumnNode
    while c != nil
    {
      var r = c!.down as? DLXGridNode
      while r != nil
      {
        curRows.insert(r!.row)
        r = r!.down as? DLXGridNode
      }
      columnString.append( c!.string )
      c = c!.right as? DLXColumnNode
    }
    
    print(columnString)
    print()
    
    if( curRows.count > 0 )
    {
      let sortedRows = Array(curRows).sorted()
      sortedRows.forEach { i in
        var rowString = i.description + ":"
        var x = rows[i]!
        repeat
        {
          rowString.append( " " + x.col.id.description )
          x = x.right as! DLXGridNode
        } while x !== rows[i]
        print(rowString)
      }
      print()
    }
  }
}
