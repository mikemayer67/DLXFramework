//
//  PickerViewController.swift
//  SudokuTestDriver-iOS
//
//  Created by Mike Mayer on 11/9/18.
//  Copyright © 2018 VMWishes. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
  @IBOutlet weak var pickerView : UIPickerView!
  
  var delegate : ViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let i = delegate?.currentDataSetIndex()
    {
      pickerView.selectRow(i, inComponent: 0, animated: true)
    }
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return delegate?.dataSetNames.count ?? 0
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return delegate?.dataSetNames[row]
  }
  
  @IBAction func handleCancel(_ sender: UIBarButtonItem)
  {
    dismiss(animated: true)
  }
  
  @IBAction func handleSelect(_ sender: UIBarButtonItem)
  {
    let row = pickerView.selectedRow(inComponent: 0)
    delegate?.selectDataSet(row)
    dismiss(animated: true)
  }
}
