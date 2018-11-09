//
//  SudokuView-iOS.swift
//  
//
//  Created by Mike Mayer on 11/3/18.
//

import UIKit

fileprivate let boxBorder : CGFloat = 4.0
fileprivate let cellBorder : CGFloat = 2.0

class SudokuView : UIView
{
  
  fileprivate let backgroundView = BackgroundView()
  fileprivate var cellViews = [[CellView]]()
  
  override init(frame frameRect: CGRect)
  {
    super.init(frame:frameRect)
    populateSubviews()
  }
  
  required init?(coder decoder: NSCoder) {
    super.init(coder:decoder)
    populateSubviews()
  }
  
  override func awakeFromNib()
  {
    for _ in 1...15 {
      let r = Int.random(in: 0...8)
      let c = Int.random(in: 0...8)
      let d = Int.random(in: 1...9)
      let f = Double.random(in: 0.0...1.0)
      setCell(row: r, col: c, digit: d, locked: f<0.3)
    }
  }
  
  func populateSubviews()
  {
    addSubview(backgroundView)
    
    for r in 0...8 {
      var row = [CellView]()
      for c in 0...8 {
        let cell = CellView(row:r, col:c)
        row.append(cell)
        backgroundView.addSubview(cell)
      }
      cellViews.append(row)
    }
  }
  
  override func layoutSubviews()
  {
    let viewWidth = self.bounds.width
    let viewHeight = self.bounds.height
    let gridSize = viewHeight < viewWidth ? viewHeight : viewWidth
    
    let xo = ( viewWidth - gridSize ) / 2
    let yo = ( viewHeight - gridSize ) / 2
    
    let cellSize = ( gridSize - 4 * boxBorder - 6 * cellBorder ) / 9
    
    backgroundView.frame = CGRect(x: xo, y: yo, width: gridSize, height: gridSize )
    
    var yi = gridSize - boxBorder - cellSize
    for i in 0...8 {
      var xj = boxBorder
      for j in 0...8 {
        self.cellViews[i][j].frame = CGRect(x:xj, y:yi, width:cellSize, height:cellSize)
        xj += cellSize + ( ( j%3 == 2 ) ? boxBorder : cellBorder)
      }
      yi -= cellSize + ( ( i%3 == 2 ) ? boxBorder : cellBorder )
    }
  }
  
  func clearAllCells()
  {
    for row in cellViews {
      for cell in row {
        cell.digit = nil
        cell.locked = false
        cell.conflicted = false
      }
    }
  }
  
  func clearUnlockedCells()
  {
    for row in cellViews {
      for cell in row {
        if cell.locked == false
        {
          cell.digit = nil
          cell.locked = false
          cell.conflicted = false
        }
      }
    }
    validateCells()
  }
  
  func clearCell(row:Int,col:Int)
  {
    setCell(row:row, col:col, digit:nil)
  }
  
  func lockCell(row:Int,col:Int,digit:Int)
  {
    setCell(row:row, col:col, digit:digit, locked:true)
  }
  
  func set(startingGrid:[(Int,Int,Int)])
  {
    clearAllCells()
    for (row,col,digit) in startingGrid
    {
      setCell(row:row, col:col, digit:digit, locked:true)
    }
  }
  
  func set(solutionGrid:[(Int,Int,Int)])
  {
    clearUnlockedCells()
    for (row,col,digit) in solutionGrid
    {
      setCell(row:row, col:col, digit:digit, locked:false)
    }
  }
  
  func setCell(row:Int, col:Int, digit:Int?, locked:Bool = false)
  {
    cellViews[row][col].digit = digit
    cellViews[row][col].locked = locked
    validateCells()
  }
  
  func validateCells()
  {
    for row in cellViews {
      for cell in row {
        validateCell(cell:cell)
      }
    }
  }
  
  fileprivate func validateCell(cell:CellView)
  {
    if let digit = cell.digit {
      let row = cell.row
      let col = cell.col
      
      for i in 0...8 {
        if i != row, cellViews[i][col].digit == digit {
          cell.conflicted = true
          return
        }
        
        if i != col, cellViews[row][i].digit == digit {
          cell.conflicted = true
          return
        }
        
        let boxRow = 3*(row/3) + i/3
        let boxCol = 3*(col/3) + i%3
        if boxRow != row, boxCol != col, cellViews[boxRow][boxCol].digit == digit {
          cell.conflicted = true
          return
        }
      }
    }
    
    cell.conflicted = false
  }
}


fileprivate class BackgroundView : UIView
{
  override func draw(_ dirtyRect: CGRect) {
    UIColor.black.setFill()
    UIBezierPath(rect: dirtyRect).fill()
  }
}


fileprivate class CellView : UIView
{
  let row : Int
  let col : Int
  
  var digit : Int?
  {
    didSet { setNeedsDisplay() }
  }
  
  var locked = false
  {
    didSet { setNeedsDisplay()}
  }
  
  var conflicted = false
  {
    didSet { setNeedsDisplay() }
  }
  
  init(row:Int,col:Int)
  {
    self.row = row
    self.col = col
    super.init(frame: CGRect.zero)
  }
  
  required init?(coder decoder: NSCoder)
  {
    self.row = -1
    self.col = -1
    super.init(coder:decoder)
  }
  
  override func draw(_ dirtyRect: CGRect) {
    UIColor.white.setFill()
    UIBezierPath(rect: dirtyRect).fill()
    
    if let d = digit, d>0, d<10
    {
      let cw = self.bounds.width
      let ch = self.bounds.height
      
      let fgColor = ( conflicted ? UIColor.red : locked ? UIColor.black : UIColor.blue )
      
      var attr = [ NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12.0),
                   NSAttributedString.Key.foregroundColor: fgColor ]
      
      let unscaledBounds = d.description.size(withAttributes: attr)
      let frac = max( unscaledBounds.width / cw, unscaledBounds.height / ch )
      
      attr[ NSAttributedString.Key.font ] = UIFont.boldSystemFont(ofSize: 9.0 / frac )
      
      let scaledBounds = d.description.size(withAttributes: attr)
      let pt = CGPoint(x: (cw - scaledBounds.width)/2, y: (ch-scaledBounds.height)/2)
      
      d.description.draw(at:pt ,withAttributes:attr)
    }
    
  }
}
