//
//  ViewController.swift
//  DLXTestDriver-iOS
//
//  Created by Mike Mayer on 10/27/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class DLXTestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
  
  @IBOutlet weak var dataSetPicker: UIPickerView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var solutionsText: UITextView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  
  var isRunning = false
  var dlx : DLX?
  
  let dataSets : Dictionary<String,[[Int]]> = [
    "demo 1" : [[1,4,7],[1,4],[4,5,7],[3,5,6],[2,3,6,7],[7,2]],
    "demo 2" : [[1,4,7],[1,4],[4,5,7],[3,5,6],[2,3,6,7],[7,2],[1,3,4],[5,6]],
    "empty" : [[Int]](),
    "uncovered" : [[Int](), [Int](), [Int]()],
    "unique column" : [[1,4,7],[1,2,9],[1,4],[4,5,7],[8],[3,5,6],[2,3,6,7],[7,2]],
    "sudoku 4" : sudoku4.grid()
  ]
  
  var dataSetKeys : [String]!
  
  var solutionsDisplayed = 0
  let maxSolutionsToDisplay = 500
  
  var curDataSetIndex : Int?
  
  var solutionsString = NSMutableAttributedString(string:"")
  
  override func viewDidLoad() {
    super.viewDidLoad()

    dataSetKeys = dataSets.keys.sorted()
    
    resetFields()
    selectDataSet(dataSetPicker.selectedRow(inComponent: 0))
    updateAll()
    
    NotificationCenter.default.addObserver(forName:.DLXSolutionFound,     object:nil, queue:OperationQueue.main, using:handleNewSolutionNotification)
    NotificationCenter.default.addObserver(forName:.DLXAlgorithmCanceled, object:nil, queue:OperationQueue.main, using:handleCanceledNotification)
    NotificationCenter.default.addObserver(forName:.DLXAlgorithmComplete, object:nil, queue:OperationQueue.main, using:handleCompletedNotification)
  }
  
  func resetFields()
  {
    statusLabel.text = ""
    countLabel.text = ""
    solutionsString = NSMutableAttributedString(string:"")
    solutionsText.text = ""
    solutionsDisplayed = 0
  }
  
  func updateAll()
  {
    if isRunning {
      cancelButton.isHidden = false
      startButton.isHidden = true
      dataSetPicker.isUserInteractionEnabled = false
    }
    else
    {
      cancelButton.isHidden = true

      startButton.isHidden = (dlx == nil || dlx!.isComplete == true )
      dataSetPicker.isUserInteractionEnabled = true
    }
  }
  
  @IBAction func handleStart(_ sender: UIButton)
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
    statusLabel.text = "Running"
    countLabel.text = "(no solutions)"
    updateAll()
    
    dlx!.solve()
  }
  
  @IBAction func handleCancel(_ sender: UIButton)
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
  
  @objc func handleNewSolutionNotification(_ notification:Notification)
  {
    if let curCount = dlx?.solutions.count {
      if( curCount == 1 ) {
        countLabel.text = "solution found"
      } else {
        countLabel.text = String(format:"%d solutions found", curCount)
      }
    } else {
      countLabel.text = ""
    }
  }
  
  @objc func handleCanceledNotification(_ notification:Notification)
  {
    statusLabel.text = "Canceled"
    if let S = dlx?.solutions {
      switch S.count {
      case 0: countLabel.text = "(no solution found)"
      case 1: countLabel.text = "solution found"
      default: countLabel.text = String(format:"%d solutions found", S.count)
      }
      while solutionsDisplayed < S.count, solutionsDisplayed < maxSolutionsToDisplay
      {
        log(S[solutionsDisplayed].description)
        solutionsDisplayed += 1
      }
      if solutionsDisplayed == maxSolutionsToDisplay {
        log("... only first " + maxSolutionsToDisplay.description + " solutions displayed")
      }
      logInfo("DLX Algorithm was canceled after " + S.count.description + " solution" + (S.count>1 ? "s" : ""),
              color:UIColor(red:0.5, green:0.0, blue:0.0, alpha: 1.0))
    }
    else
    {
      logInfo("DLX Algorithm was canceled with no solutions",
              color:UIColor(red:0.5, green:0.0, blue:0.0, alpha: 1.0))
    }
    isRunning = false
    updateAll()
  }
  
  @objc func handleCompletedNotification(_ notification:Notification)
  {
    statusLabel.text = "Completed"
    if let S = dlx?.solutions {
      switch S.count {
      case 0: countLabel.text = "(no solution found)"
      case 1: countLabel.text = "solution found"
      default: countLabel.text = String(format:"%d solutions found", S.count)
      }
      while solutionsDisplayed < S.count, solutionsDisplayed < maxSolutionsToDisplay
      {
        log(S[solutionsDisplayed].description)
        solutionsDisplayed += 1
      }
      if solutionsDisplayed == maxSolutionsToDisplay {
        log("... only first " + maxSolutionsToDisplay.description + " solutions displayed")
      }
      logInfo("DLX Algorithm completed after " + S.count.description + " solution" + (S.count>1 ? "s" : ""))
    }
    else
    {
      logInfo("DLX Algorithm completed with no solutions")
    }
    isRunning = false
    updateAll()
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return dataSetKeys.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return dataSetKeys[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectDataSet(row)
  }
  
  func selectDataSet(_ row:Int)
  {
    if row == curDataSetIndex { return }
    
    resetFields()
    dlx = nil
    
    if let data = dataSets[dataSetKeys[row]] {
      do {
        dlx = try DLX(data)
      }
      catch DLXError.InputEmpty {
        logException("Coverage Matrix cannot be Empty")
      }
      catch DLXError.InputNoCoverage
      {
        logException("Coverage Matrix is not covering any columns")
      }
      catch let err
      {
        logException(err.localizedDescription)
      }
    }
    updateAll()
  }

  func logException(_ msg:String)
  {
    let attrMsg = NSAttributedString(string: "Exception Caught: " + msg + "\n", attributes:
      [
        NSAttributedString.Key.foregroundColor: UIColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0),
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)
      ] )
    solutionsText.attributedText = attrMsg
  }
  
  func logError(_ msg:String)
  {
    let attrMsg = NSAttributedString(string: "Oops: " + msg + "\n", attributes:
      [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.backgroundColor: UIColor(red:0.5, green:0.0, blue:0.0, alpha: 1.0),
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)
      ] )
    solutionsText.attributedText = attrMsg
  }
  
  func logInfo(_ msg:String, color:UIColor = UIColor.blue)
  {
    let attrMsg = NSAttributedString(string: msg + "\n", attributes:
      [
        NSAttributedString.Key.foregroundColor: color,
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)
      ] )
    solutionsString.append(attrMsg)
    solutionsText.attributedText = solutionsString
  }
  
  func log(_ msg:String)
  {
    let attrMsg = NSAttributedString(string: msg + "\n", attributes:
      [
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)
      ] )
    solutionsString.append(attrMsg)
    solutionsText.attributedText = solutionsString
  }
}

