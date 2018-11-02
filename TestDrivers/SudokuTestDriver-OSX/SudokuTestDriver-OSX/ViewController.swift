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
  @IBOutlet weak var statusLabel: NSTextField!
  @IBOutlet weak var sudokuView: SudokuView!
  
  var isRunning = false
  var dlx : DLXSudoku?
  
  let dataSets = [
    "diag" : [(0,0,1),(1,1,2),(2,2,3),(3,3,4),(4,4,5),(5,5,6),(6,6,7),(7,7,8),(8,8,9)]
  ]
  
  var curSolution : Int?
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
    
    curSolution = nil
    solutionSlider.minValue = 0
    solutionSlider.maxValue = 0
    solutionSlider.intValue = 0
    
    sudokuView.clearAllCells()
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
    updateAll()
    
    logError("Don't forget to enable the solver")
 //   dlx!.solve()
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
        catch DLXError.InputNoCoverage
        {
          logException("Coverage Matrix is not covering any columns")
        }
        catch DLXSudokuError.InvalidStartingGrid
        {
          logException("Invalid Starting Grid -- no solution possible")
        }
        catch let err
        {
          logException(err.localizedDescription)
        }
      }
    }
    updateAll()
  }
  
  @IBAction func handleSolutionSlider(_ sender: NSSlider)
  {
    let showSolution = sender.intValue
    let numSolutions = dlx?.solutions.count
    
    log("Slider moved to " + showSolution.description)
    
    switch (showSolution,numSolutions)
    {
    case (_,0):
      solutionLabel.stringValue = ""
    case (0,_):
      solutionLabel.stringValue = "given"
    default:
      solutionLabel.stringValue = String(format:"%d of %d",showSolution,numSolutions)
    }
    
    sudokuView.clearUnlockedCells()
    logError("WORK HERE... Add getSudokuSolution method here and in DLXSudoku class")
    
  }
  
  @objc func handleNewSolutionNotification(_ notification:Notification)
  {
    logError("complete new solution handler")
  }
  
  @objc func handleCanceledNotification(_ notification:Notification)
  {
    statusLabel.stringValue = "Canceled"
    if let S = dlx?.solutions {
      logError("complete cancelation handler")
      logInfo("DLX Algorithm was canceled after " + S.count.description + " solution" + (S.count>1 ? "s" : ""))
    }
    else
    {
      logInfo("DLX Algorithm was canceled with no solutions")
    }
    isRunning = false
    updateAll()
  }
  
  @objc func handleCompletedNotification(_ notification:Notification)
  {
    statusLabel.stringValue = "Completed"
    if let S = dlx?.solutions {
      logError("Complete completion handler")
      logInfo("DLX Algorithm completed after " + S.count.description + " solution" + (S.count>1 ? "s" : ""))
    }
    else
    {
      logInfo("DLX Algorithm completed with no solutions")
    }
    isRunning = false
    updateAll()
  }

  func logException(_ msg:String) { log("Exception Caught: " + msg) }
  func logError(_ msg:String)     { log("Oops: " + msg) }
  func logInfo(_ msg:String)      { log(msg) }
  func log(_ msg:String)          { print(msg) }
}

