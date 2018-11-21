//
//  ViewController.swift
//  SudokuTestDriver-iOS
//
//  Created by Mike Mayer on 11/3/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
  @IBOutlet weak var sudokuView: SudokuView!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var solveButton: UIBarButtonItem!
  @IBOutlet weak var puzzleNameLabel: UILabel!
  @IBOutlet weak var puzzleEditButton: UIButton!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var currentLabel: UILabel!
  @IBOutlet weak var currentSlider: UISlider!
  
  let dataSets = [
    "diag" : [(0,0,1),(1,1,2),(2,2,3),(3,3,4),(4,4,5),(5,5,6),(6,6,7),(7,7,8),(8,8,9)],
    "bad" : [(0,0,1),(1,1,2),(2,2,3),(3,3,4),(4,4,5),(5,5,6),(6,6,7),(7,7,8),(8,8,9),(0,2,2)],
    "conceptis" : [(0,0,4),(0,2,9),(0,3,6),(0,6,7),(1,1,6),(1,4,2),(1,5,4),(1,7,9),(2,0,7),(2,3,3),(2,8,4),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(6,8,9),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    "conceptis-1" : [(0,0,4),(0,2,9),(0,3,6),(0,6,7),(1,1,6),(1,4,2),(1,5,4),(1,7,9),(2,0,7),(2,3,3),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(6,8,9),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    "conceptis-2" : [(0,0,4),(0,3,6),(0,6,7),(1,1,6),(1,4,2),(1,5,4),(1,7,9),(2,0,7),(2,3,3),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(6,8,9),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    "conceptis-3" : [(0,0,4),(0,3,6),(0,6,7),(1,1,6),(1,4,2),(1,5,4),(1,7,9),(2,0,7),(2,3,3),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    "conceptis-8" : [(0,0,4),(0,3,6),(0,6,7),(2,3,3),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    ]
  
  lazy var dataSetNames = dataSets.keys.sorted()
  
  var isRunning = false
  var dlx : DLXSudoku?
  
  var curDataSet : String?
  {
    didSet
    {
      if curDataSet != oldValue
      {
        puzzleNameLabel.text = curDataSet
        
        dlx = nil
        curSolution = 0
        numSolutions = 0
        
        if let data = dataSets[curDataSet!]
        {
          do {
            dlx = try DLXSudoku(data)
            sudokuView.set(startingGrid:data)
            statusLabel.text = nil
          }
          catch DLXError.InputEmpty {
            logException("Empty Coverage Matrix")
          }
          catch DLXError.InputNoCoverage {
            logException("Incomplete Coverage Matrix")
          }
          catch DLXSudokuError.InvalidStartingGrid {
            logException("Impossible Coverage Matrix")
          }
          catch let err {
            logException(err.localizedDescription)
          }
        }
        
        updateAll()
      }
    }
  }
  
  var curSolution = 0
  {
    didSet
    {
      if curSolution < 0 { curSolution = 0 }
      if curSolution > numSolutions { curSolution = numSolutions }
      
      currentSlider.value = Float(curSolution)

      if curSolution != oldValue
      {
        if curSolution == 0
        {
          sudokuView.clearUnlockedCells()
        }
        else
        {
          let sol = dlx?.sudokuSolution(curSolution-1)
          sudokuView.set(solutionGrid: sol!)
        }
      }
    }
  }
  
  var numSolutions = 0
  {
    didSet
    {
      currentSlider.maximumValue = Float(numSolutions)
    }
  }
  
  func updateAll()
  {
    switch (curSolution,numSolutions)
    {
    case (0,_):
      currentLabel.text = "Givens"
    case (1,1):
      currentLabel.text = "Solution"
    default:
      currentLabel.text = String(format:"Solution %d of %d",curSolution,numSolutions)
    }
    
    currentSlider.isHidden = numSolutions == 0
    
    if isRunning {
      cancelButton.isEnabled = true
      solveButton.isEnabled = false
      puzzleEditButton.isEnabled = false
    }
    else
    {
      cancelButton.isEnabled = false
      solveButton.isEnabled = (dlx != nil && dlx!.isComplete==false )
      puzzleEditButton.isEnabled = true
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
        
    curDataSet = dataSetNames[ Int.random(in: 1...dataSetNames.count) - 1]
    
    updateAll()
    
    NotificationCenter.default.addObserver(forName:.DLXSolutionFound,     object:nil, queue:OperationQueue.main, using:handleNewSolutionNotification)
    NotificationCenter.default.addObserver(forName:.DLXAlgorithmCanceled, object:nil, queue:OperationQueue.main, using:handleCanceledNotification)
    NotificationCenter.default.addObserver(forName:.DLXAlgorithmComplete, object:nil, queue:OperationQueue.main, using:handleCompletedNotification)
  }
  
  func selectDataSet(_ row:Int)
  {
    curDataSet = dataSetNames[row]
  }

  @IBAction func handleSolve(_ sender: UIBarButtonItem)
  {
    isRunning = true
    sudokuView.clearUnlockedCells()
    updateAll()
    dlx!.solve()
  }
  
  @IBAction func handleCancel(_ sender: UIBarButtonItem)
  {
    dlx!.cancel()
  }
  
  @IBAction func handleCurrentSlider()
  {
    curSolution = Int( currentSlider.value + 0.5 )
    updateAll()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let pvc = segue.destination as? PickerViewController
    {
      pvc.delegate = self
    }
  }
  
  func currentDataSetIndex() -> Int?
  {
    for i in 0...dataSetNames.count-1
    {
      if dataSetNames[i] == curDataSet {
        return i
      }
    }
    return nil
  }
  
  
  @objc func handleNewSolutionNotification(_ notification:Notification)
  {
    if let n = dlx?.solutions.count, n > 0
    {
      numSolutions = n
      self.logInfo(String(format: "%d solution%@ found", n, n == 1 ? "" : "s"))
    }
    else
    {
      numSolutions = 0
      logInfo("")
    }
  }
  
  @objc func handleCanceledNotification(_ notification:Notification)
  {
    let n = dlx?.solutions.count ?? 0
    numSolutions = n
    self.logInfo(String(format: "Canceled after %d solution%@", n, n == 1 ? "" : "s"))
    if curSolution == 0 { curSolution = n }
    isRunning = false
    updateAll()
  }
  
  @objc func handleCompletedNotification(_ notification:Notification)
  {
    let n = dlx?.solutions.count ?? 0
    numSolutions = n
    self.logInfo(String(format: "Completed with %d soluton%@", n, n == 1 ? "" : "s" ))
    if curSolution == 0 { curSolution = n }
    isRunning = false
    updateAll()
  }

  
  func log(_ msg:String) { print(msg) }
  
  func logException(_ msg:String)
  {
    statusLabel.text = msg
    statusLabel.textColor = UIColor(red: 0.6, green: 0.3, blue: 0.3, alpha: 1.0)
  }
  
  func logError(_ msg:String)
  {
    statusLabel.text = msg
    statusLabel.textColor = UIColor(red:0.5, green:0.3, blue:0.3, alpha: 1.0)
  }
  
  func logInfo(_ msg:String, color:UIColor = UIColor.blue)
  {
    statusLabel.text = msg
    statusLabel.textColor = color
  }
  
  @IBAction func handleSwipeLeft( _ sender : UIGestureRecognizer )
  {
    curSolution = curSolution + 1
    updateAll()
  }
  
  @IBAction func handleSwipeRight( _ sender : UIGestureRecognizer )
  {
    curSolution = curSolution - 1
    updateAll()
  }
  
  @IBAction func handleSwipeLeft2( _ sender : UIGestureRecognizer )
  {
    curSolution = curSolution + max( numSolutions / 10, 1 )
    updateAll()
  }
  
  @IBAction func handleSwipeRight2( _ sender : UIGestureRecognizer )
  {
    curSolution = curSolution - max( numSolutions / 10, 1 )
    updateAll()
  }
}

