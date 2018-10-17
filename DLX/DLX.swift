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
  var headers = Dictionary<Int,HeaderNode>()
  
  public private(set) static var error : String?
  
  public init?( _ A:[[Int]] )
  {
    DLX.error = nil
    
    let columns = Array(Set(A.reduce([],+))).sorted()
    guard columns.count > 0 else { return nil }
    
    if let a = columns.first, let b = columns.last
    {
      guard b == a + columns.count - 1 else
      {
        DLX.error =
          String(format: "Insufficient column coverage (min=%d, max=%d, count=%d)",
                 a, b, columns.count)
        return nil
      }
      
      for c in a...b
      {
        let h = HeaderNode(in:dlx)
        headers[c] = h
      }
    }
    else
    {
      return nil
    }
  }
}
