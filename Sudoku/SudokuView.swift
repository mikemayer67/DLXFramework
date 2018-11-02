//
//  SudokuView.swift
//  
//
//  Created by Mike Mayer on 10/31/18.
//

import Cocoa

fileprivate let boxBorder : CGFloat = 4.0
fileprivate let cellBorder : CGFloat = 2.0

class SudokuView: NSView
{
  fileprivate let backgroundView = BackgroundView()
  fileprivate var cellViews = [[CellView]]()
  
  override init(frame frameRect: NSRect)
  {
    super.init(frame:frameRect)
    populateSubviews()
  }
  
  required init?(coder decoder: NSCoder) {
    super.init(coder:decoder)
    populateSubviews()
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
    
    NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: self, queue: nil)
    { _ in
      let viewWidth = self.bounds.width
      let viewHeight = self.bounds.height
      let gridSize = viewHeight < viewWidth ? viewHeight : viewWidth
      
      let xo = ( viewWidth - gridSize ) / 2
      let yo = ( viewHeight - gridSize ) / 2
      
      let cellSize = ( gridSize - 4 * boxBorder - 6 * cellBorder ) / 9

      self.backgroundView.frame = NSRect(x: xo, y: yo, width: gridSize, height: gridSize )
      
      var xi = boxBorder
      for i in 0...8 {
        var yj = gridSize - boxBorder - cellSize
        for j in 0...8 {
          self.cellViews[i][j].frame = NSRect(x:xi, y:yj, width:cellSize, height:cellSize)
          yj -= cellSize + ( ( j%3 == 2 ) ? boxBorder : cellBorder )
        }
        xi += cellSize + ( ( i%3 == 2 ) ? boxBorder : cellBorder)
      }
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


fileprivate class BackgroundView : NSView
{
  override func draw(_ dirtyRect: NSRect) {
    NSColor.black.setFill()
    dirtyRect.fill()
  }
}


fileprivate class CellView : NSView
{
  let row : Int
  let col : Int
  
  var digit : Int?
  {
    didSet { needsDisplay = true }
  }
  
  var locked = false
  {
    didSet { needsDisplay = true }
  }
  
  var conflicted = false
  {
    didSet { needsDisplay = true }
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
  
  override func draw(_ dirtyRect: NSRect) {
    NSColor.white.setFill()
    dirtyRect.fill()
    
    if let d = digit, d>0, d<10
    {
      let cw = self.bounds.width
      let ch = self.bounds.height
      
      let fgColor = ( conflicted ? NSColor.red : locked ? NSColor.black : NSColor.blue )
      
      var attr = [ NSAttributedString.Key.font : NSFont.boldSystemFont(ofSize: 12.0),
                   NSAttributedString.Key.foregroundColor: fgColor ]
      
      let unscaledBounds = d.description.size(withAttributes: attr)
      let frac = max( unscaledBounds.width / cw, unscaledBounds.height / ch )
      
      attr[ NSAttributedString.Key.font ] = NSFont.boldSystemFont(ofSize: 9.0 / frac )
      
      let scaledBounds = d.description.size(withAttributes: attr)
      let pt = CGPoint(x: (cw - scaledBounds.width)/2, y: (ch-scaledBounds.height)/2)
      
      d.description.draw(at:pt ,withAttributes:attr)
    }
    
  }
}
