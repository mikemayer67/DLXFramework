//
//  main.swift
//  TestDriver-OSX
//
//  Created by Mike Mayer on 10/16/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Foundation

print("Hello, World!")

let demo = [[1,4,7],[1,4],[4,5,7],[3,5,6],[2,3,6,7],[2,7]]

let dlx = DLX(demo)

guard dlx != nil else
{
  print("Error: " + (DLX.error ?? "Unknown") )
  exit(1)
}

dlx!.dump()
