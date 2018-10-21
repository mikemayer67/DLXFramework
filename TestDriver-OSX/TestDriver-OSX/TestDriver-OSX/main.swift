//
//  main.swift
//  TestDriver-OSX
//
//  Created by Mike Mayer on 10/16/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

let demo = [[1,4,7],[1,4],[4,5,7],[3,5,6],[2,3,6,7],[2,7]]

do
{
  let dlx = try DLX(demo)
  
  dlx.dump()
}
catch DLXError.InputMatrixEmpty
{
  print("Matrix used to initialize DLX cannot be empty")
}
catch let DLXError.InputMatrixMissingColumns(min:a, max:b, count:n)
{
  print("Matrix used to initialize DLX must cover all columns")
  print(String(format:"  Matrix contains indices spanning %d columns (from %d to %d)", 1+b-a, a, b))
  print(String(format:"  ... but contains only %d unique values", n))
}
