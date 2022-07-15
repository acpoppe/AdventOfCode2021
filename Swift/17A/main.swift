//
//  main.swift
//  17A
//
//  Created by Allison Poppe - Work on 15.07.22.
//

import Foundation

// MARK: - Helpers

struct Target {
  let minX: Int
  let maxX: Int
  let minY: Int
  let maxY: Int
  
  func posInRange(x: Int, y: Int) -> Bool {
    return x <= maxX && x >= minX && y >= minY && y <= maxY
  }
}

struct ArcHeight: Hashable {
  let velX: Int
  let velY: Int
  let maxY: Int
}

func stepFromCurrentPos(x: Int, y: Int, xVelocity: Int, yVelocity: Int) -> (x: Int, y: Int, xVelocity: Int, yVelocity: Int) {
  
  
  // The probe's x position increases by its x velocity.
  let newX = x + xVelocity
  // The probe's y position increases by its y velocity.
  let newY = y + yVelocity
  
  
  // Due to drag, the probe's x velocity changes by 1 toward the value 0; that is, it decreases by 1 if it is greater than 0, increases by 1 if it is less than 0, or does not change if it is already 0.
  var newXVelocity: Int = 0
  if xVelocity > 0 {
    newXVelocity = xVelocity - 1
  } else if xVelocity < 0 {
    newXVelocity = xVelocity + 1
  }
  
  // Due to gravity, the probe's y velocity decreases by 1.
  let newYVelocity = yVelocity - 1
  
  return (newX, newY, newXVelocity, newYVelocity)
}

// Return nil for miss, otherwise max Height
func maxHeightAcheived(xVelocity: Int, yVelocity: Int, target: Target) -> Int? {
  
  var xPos = 0
  var yPos = 0
  var xVeloc = xVelocity
  var yVeloc = yVelocity
  
  var maxHeight = 0
  
  
  while (yVeloc >= 0 || yPos > target.minY) && !(xVeloc > 0 && xPos > target.maxX) && !(xVeloc < 0 && xPos < target.minX) {
    // print("X: \(xPos) - Y: \(yPos) - xVeloc: \(xVeloc) - yVeloc: \(yVeloc)")
    (xPos, yPos, xVeloc, yVeloc) = stepFromCurrentPos(x: xPos, y: yPos, xVelocity: xVeloc, yVelocity: yVeloc)
    if (yPos > maxHeight) {
      maxHeight = yPos
    }
    if (xPos >= target.minX) && (xPos <= target.maxX) && (yPos >= target.minY) && (yPos <= target.maxY) {
      // print(maxHeight)
      return maxHeight
    }
  }
  
  return nil
}




// MARK: - Script

let filename = "input"

let start = AOC.startTimer()

let input = AOC.getInputFromBundleFile(filename)[0]
let inputParts = input.components(separatedBy: "=")
let xRange = inputParts[1].description.components(separatedBy: ",")[0]
let yRange = inputParts[2]

let xMin = Int(xRange.components(separatedBy: "..")[0])!
let xMax = Int(xRange.components(separatedBy: "..")[1])!
let yMin = Int(yRange.components(separatedBy: "..")[0])!
let yMax = Int(yRange.components(separatedBy: "..")[1])!

print("X - Min: \(xMin), Max: \(xMax)")
print("Y - Min: \(yMin), Max: \(yMax)")

//var xVelocity = 7
//var yVelocity = 2

let target = Target(minX: xMin, maxX: xMax, minY: yMin, maxY: yMax)
var successfulArcs = Set<ArcHeight>()

var xVelocStart = 0
var xVelocEnd = 0
if (target.minX > 0 && target.maxX > 0) {
  xVelocStart = 0
  xVelocEnd = target.maxX
} else if (target.maxX < 0 && target.minX < 0) {
  xVelocStart = target.minX
  xVelocEnd = 0
} else {
  xVelocStart = target.minX
  xVelocEnd = target.maxX
}

var yVelocStart = target.maxY
var yVelocEnd = abs(target.minY)
if target.maxY > abs(target.minY) {
  yVelocStart = abs(target.minY)
  yVelocEnd = target.maxY
}

print(yVelocStart)
print(yVelocEnd)

for xVeloc in xVelocStart...xVelocEnd {
  for yVeloc in yVelocStart...yVelocEnd {
    let result = maxHeightAcheived(xVelocity: xVeloc, yVelocity: yVeloc, target: target)
    // print(result)
    if let maxHeight = result {
      // print(maxHeight)
      let arc = ArcHeight(velX: xVeloc, velY: yVeloc, maxY: maxHeight)
      successfulArcs.insert(arc)
    }
  }
}

var max = 0
var successfulX = 0
var successfulY = 0
for i in successfulArcs {
  if i.maxY > max {
    max = i.maxY
    successfulX = i.velX
    successfulY = i.velY
  }
}

print("Highest = \(max) |||| X: \(successfulX) - Y: \(successfulY)")


// Check if velocity will hit in target range after stepping

AOC.printElapsedTimeFrom(start: start)
