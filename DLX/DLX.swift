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
  
  public init?( _ A:[[Int]] )
  {
    let columns = A.reduce([],+)
    
    if let a = columns.min(), let b = columns.max()
    {
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
