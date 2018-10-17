//
//  HeaderNode.swift
//  
//
//  Created by Mike Mayer on 10/16/18.
//

import Foundation

class HeaderNode : Node
{
  var size = 0
  
  init(in root:RootNode)
  {
    super.init()
    insert(before:root)
  }
}
