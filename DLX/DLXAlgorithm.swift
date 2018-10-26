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
    guard let c = dlx.pickColumn() else {
      dlx.addSolution(Q.sorted())
      return
    }
    
    guard c.rows > 0 else { return }
    
    c.cover()
    
    var r = c.down as? DLXGridNode
    while r != nil, self.isCancelled == false
    {
      Q.append(r!.row)
      
      var j = r!.right as! DLXGridNode
      while j !== r
      {
        j.col.cover()
        j = j.right as! DLXGridNode
      }
      
      dive( 1+level )
      
      j = r!.left as! DLXGridNode
      while j !== r
      {
        j.col.uncover()
        j = j.left as! DLXGridNode
      }
      
      Q.removeLast()
      r = r!.down as? DLXGridNode
    }
    
    c.uncover()
  }
}
