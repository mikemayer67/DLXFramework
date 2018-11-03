//
//  ViewController.swift
//  SudokuTestDriver-OSX
//
//  Created by Mike Mayer on 10/29/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
  @IBOutlet weak var dataSetPopup: NSPopUpButton!
  
  @IBOutlet weak var startButton: NSButton!
  @IBOutlet weak var cancelButton: NSButton!
  
  @IBOutlet weak var solutionSlider: NSSlider!
  @IBOutlet weak var solutionLabel: NSTextField!
  @IBOutlet weak var decrButton: NSButton!
  @IBOutlet weak var incrButton: NSButton!
  
  @IBOutlet weak var statusLabel: NSTextField!
  @IBOutlet weak var sudokuView: SudokuView!
  
  var isRunning = false
  var dlx : DLXSudoku?
  
  let dataSets = [
    "diag" : [(0,0,1),(1,1,2),(2,2,3),(3,3,4),(4,4,5),(5,5,6),(6,6,7),(7,7,8),(8,8,9)],
    "bad" : [(0,0,1),(1,1,2),(2,2,3),(3,3,4),(4,4,5),(5,5,6),(6,6,7),(7,7,8),(8,8,9),(0,2,2)],
    "conceptis" : [(0,0,4),(0,2,9),(0,3,6),(0,6,7),(1,1,6),(1,4,2),(1,5,4),(1,7,9),(2,0,7),(2,3,3),(2,8,4),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(6,8,9),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    "conceptis-1" : [(0,0,4),(0,2,9),(0,3,6),(0,6,7),(1,1,6),(1,4,2),(1,5,4),(1,7,9),(2,0,7),(2,3,3),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(6,8,9),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    "conceptis-2" : [(0,0,4),(0,3,6),(0,6,7),(1,1,6),(1,4,2),(1,5,4),(1,7,9),(2,0,7),(2,3,3),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(6,8,9),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    "conceptis-3" : [(0,0,4),(0,3,6),(0,6,7),(1,1,6),(1,4,2),(1,5,4),(1,7,9),(2,0,7),(2,3,3),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    "conceptis-8" : [(0,0,4),(0,3,6),(0,6,7),(2,3,3),(3,0,1),(3,2,8),(3,4,9),(3,7,6),(4,1,5),(4,7,7),(5,1,2),(5,4,8),(5,6,1),(5,8,3),(6,0,2),(6,5,3),(7,1,4),(7,3,9),(7,4,7),(7,7,8),(8,2,3),(8,5,5),(8,6,4),(8,8,7)],
    ]
  
  var curSolution = 0
  {
    didSet
    {
      if curSolution < 0 { curSolution = 0 }
      if curSolution > numSolutions { curSolution = numSolutions }
      
      solutionSlider.intValue = Int32(curSolution)
      
      if curSolution == 0 {
        solutionLabel.stringValue = "Entry"
        sudokuView.clearUnlockedCells()
      } else {
        solutionLabel.stringValue = curSolution.description
        if let solution = dlx?.sudokuSolution(curSolution-1) {
          sudokuView.set(solutionGrid: solution)
        } else {
          sudokuView.clearUnlockedCells()
        }
      }
    }
  }
  
  var numSolutions = 0
  {
    didSet
    {
      solutionSlider.maxValue = Double(numSolutions)
    }
  }
  
  var curDataSetTitle : String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSetPopup.removeAllItems()
    dataSetPopup.addItems(withTitles: Array(dataSets.keys.sorted()))
    
    resetFields()
    handleDataSet(dataSetPopup)
    updateAll()
    
    NotificationCenter.default.addObserver(forName:.DLXSolutionFound,     object:nil, queue:OperationQueue.main, using:handleNewSolutionNotification)
    NotificationCenter.default.addObserver(forName:.DLXAlgorithmCanceled, object:nil, queue:OperationQueue.main, using:handleCanceledNotification)
    NotificationCenter.default.addObserver(forName:.DLXAlgorithmComplete, object:nil, queue:OperationQueue.main, using:handleCompletedNotification)
  }
  
  func resetFields()
  {
    solutionLabel.stringValue = ""
    statusLabel.stringValue = ""
    
    curSolution = 0
    solutionSlider.minValue = 0
    solutionSlider.maxValue = 0
    solutionSlider.intValue = 0
  }
  
  func updateAll()
  {
    if isRunning {
      cancelButton.isEnabled = true
      startButton.isEnabled = false
      dataSetPopup.isEnabled = false
    }
    else
    {
      cancelButton.isEnabled = false
      startButton.isEnabled = (dlx != nil && dlx!.isComplete==false )
      dataSetPopup.isEnabled = true
    }
  }

  @IBAction func handleStart(_ sender: NSButton)
  {
    guard dlx != nil else {
      logError("start button active when dlx is nil")
      return
    }
    guard dlx!.isComplete == false else {
      logError("start button active when dlx solution is complete")
      return
    }
    
    isRunning = true
    resetFields()
    sudokuView.clearUnlockedCells()
    updateAll()
    
    dlx!.solve()
  }
  
  @IBAction func handleCancel(_ sender: NSButton)
  {
    guard dlx != nil else {
      logError("cancel button active when dlx is nil")
      return
    }
    guard isRunning else {
      logError("cancel button active when algorithm isn't running")
      return
    }
    dlx!.cancel()
  }
  
  @IBAction func handleDataSet(_ sender: NSPopUpButton)
  {
    if let key = sender.selectedItem?.title {
      if key == curDataSetTitle { return }
      
      resetFields()
      curDataSetTitle = nil
      dlx = nil
      
      if let data = dataSets[key] {
        curDataSetTitle = key
        do {
          dlx = try DLXSudoku(data)
          sudokuView.set(startingGrid: data)
        }
        catch DLXError.InputEmpty {
          logException("Coverage Matrix cannot be Empty")
        }
        catch DLXError.InputNoCoverage {
          logException("Coverage Matrix is not covering any columns")
        }
        catch DLXSudokuError.InvalidStartingGrid {
          logException("Invalid Starting Grid -- no solution possible")
        }
        catch let err {
          logException(err.localizedDescription)
        }
      }
    }
    updateAll()
  }
  
  @IBAction func handleSolutionSlider(_ sender: NSSlider)
  {
    curSolution = Int(sender.intValue)
  }
  
  @IBAction func handleIncrDecr(_ sender: NSButton)
  {
    if sender.tag == 0 { curSolution = curSolution - 1 }
    else               { curSolution = curSolution + 1 }
  }
  
  @objc func handleNewSolutionNotification(_ notification:Notification)
  {
    if let n = dlx?.solutions.count, n > 0
    {
      numSolutions = n
      logInfo(n.description)
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
    statusLabel.stringValue = "Exception Caught: " + msg
    statusLabel.textColor = NSColor(red: 0.6, green: 0.3, blue: 0.3, alpha: 1.0)
  }
  
  func logError(_ msg:String)
  {
    statusLabel.stringValue = "Oops: " + msg
    statusLabel.textColor = NSColor(red:0.5, green:0.3, blue:0.3, alpha: 1.0)
  }
  
  func logInfo(_ msg:String, color:NSColor = NSColor.yellow)
  {
    statusLabel.stringValue = msg
    statusLabel.textColor = color
  }
}

