//
//  DLXAlgorithm.swift
//  
//
//  Created by Mike Mayer on 10/21/18.
//

import Foundation

class DLXAlgorithm : Operation
{
  let dlx : DLX!
  
  init(_ dlx:DLX)
  {
    self.dlx = dlx
  }
  
  override func main()
  {
    for i in 1..<10
    {
      if self.isCancelled
      {
        NotificationCenter.default.post(name: .DLXAlgorithmCanceled, object: self.dlx)
        print("Canceled")
        return
      }
      
      let delay = Double.random(in:1.0...5.0)
      print("Time to next solution: ", delay.description)
      Thread.sleep(forTimeInterval: delay)
      print("Solution found")
      
      dlx.addSolution(Array(1...i))
    }
    print("Complete")
    
    dlx.isComplete = true
    NotificationCenter.default.post(name: .DLXAlgorithmComplete, object: self.dlx)
  }
}
