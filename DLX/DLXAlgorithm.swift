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
  
  var Q = Array<Int>()

  override func main()
  {
    dlx.log("Starting DLX")
    dlx.resetSolutions()

    dive(0);
    
    if self.isCancelled
    {
      NotificationCenter.default.post(name: .DLXAlgorithmCanceled, object: self.dlx)
    }
    else
    {
      dlx.isComplete = true
      NotificationCenter.default.post(name: .DLXAlgorithmComplete, object: self.dlx)
    }
  }
  
  func dive(_ level:Int)
  {
    guard let c = dlx.root.pickColumn() else {
      dlx.addSolution(Q.sorted())
      return
    }
    
    guard c.rows > 0 else { return }
    
    c.cover()
    
    dlx.log("Covered column "+c.col.description)
    
    var r = c.down as? DLXGridNode
    while r != nil, self.isCancelled == false
    {
      Q.append(r!.row)
      
      var j = r!.right as! DLXGridNode
      while j !== r
      {
        j.col.cover()
        dlx.log("Covered column " + j.col.col.description + " (from row " + j.row.description + ")")
        j = j.right as! DLXGridNode
      }
      
      dive( 1+level )
      
      j = r!.left as! DLXGridNode
      while j !== r
      {
        j.col.uncover()
        dlx.log("Uncovered column " + j.col.col.description + " (from row " + j.row.description + ")")
        j = j.left as! DLXGridNode
      }
      
      Q.removeLast()
      r = r!.down as? DLXGridNode
    }
    
    c.uncover()
    dlx.log("Uncovered column "+c.col.description)
  }
}
  
  
    /*
    for i in 1..<10
    {
      if self.isCancelled
      {
        NotificationCenter.default.post(name: .DLXAlgorithmCanceled, object: self.dlx)
        return
      }
      
      let delay = Double.random(in:0.5...3.0)
      print("Time to next solution: ", delay.description)
      Thread.sleep(forTimeInterval: delay)
      
      dlx.addSolution(Array(1...i))
    }
 */

