//
//  main.swift
//  15A
//
//  Created by Allison Poppe on 13.07.22.
//

import Foundation

let inputFileName = "input"

struct Point {
  let x: Int
  let y: Int
}

struct Node: Hashable {
  
  let point: Point
  let dangerOnPoint: Int
  
  var dangerToReach = 0
  var visited = false
  
  var path: [Point] = []
  
  func neighbors() -> [Point] {
    var neighbors: [Point] = []
    neighbors.append(Point(x: point.x - 1, y: point.y))
    neighbors.append(Point(x: point.x + 1, y: point.y))
    neighbors.append(Point(x: point.x, y: point.y + 1))
    neighbors.append(Point(x: point.x, y: point.y - 1))
    
    return neighbors
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(point.x)
    hasher.combine(point.y)
    hasher.combine(dangerOnPoint)
  }
  
  static func == (lhs: Node, rhs: Node) -> Bool {
    return lhs.point.x == rhs.point.x && lhs.point.y == rhs.point.y
  }
}

struct Grid {
  var grid: [[Node]]
  var width: Int {
    get {
      return grid[0].count
    }
  }
  var height: Int {
    get {
      return grid.count
    }
  }
  
  var visited = Set<Node>()
  var visitedCount = 0
  
  mutating func visitNode(_ node: Node, from: Node?) {
    visitedCount += 1
    if (from == nil) {
      visited.insert(node)
    } else {
      var path = from!.path
      path.append(node.point)
      let newNode = Node(point: node.point, dangerOnPoint: node.dangerOnPoint, dangerToReach: from!.dangerToReach + node.dangerOnPoint, visited: true, path: path)
      grid[node.point.y][node.point.x] = newNode
      visited.insert(newNode)
    }
  }
  
  func getNodeAt(x: Int, y: Int) -> Node? {
    if isPointValid(x: x, y: y) {
      return grid[y][x]
    }
    return nil
  }
  
  func getNodeAt(_ point: Point) -> Node? {
    if isPointValid(x: point.x, y: point.y) {
      return grid[point.y][point.x]
    }
    return nil
  }
  
  func isPointValid(x: Int, y: Int) -> Bool {
    let yInt = y
    let xInt = x
    
    if (xInt < 0 || yInt < 0 || xInt >= width || yInt >= height) {
      return false
    }
    
    return true
  }
}

func run() -> Int {
  map.visitNode(map.grid[0][0], from: nil)
  print("Width: \(map.width)")
  print("Height: \(map.height)")
  print("Area: \(map.width * map.height)")
  
  var percentCompleted = 0
  
  // Run until we have visited all the points
  while (map.visitedCount <= (map.width * map.height)) {
    // print("Visited Count: \(map.visitedCount)")
    let currentPercent = Int(Double(map.visitedCount) / Double(map.width * map.height) * 100)
    if currentPercent > percentCompleted {
      percentCompleted = currentPercent
      print("Percent completed: \(percentCompleted)")
    }
    
    // Set values to track for each visit
    var visitedFromNode: Node? = nil
    var nextNodeToVisit: Node? = nil
    var nextNodeTotal = 0
    
    
    for visitedNode in map.visited {
      
      // Get all of the possible node coordinates next to each visited, not all are valid
      let neighborsCoords = visitedNode.neighbors()
      
      var allNeighborsVisited = true
      
      // For each of those neighbors
      for neighborCoords in neighborsCoords {
        
        // Get that neighbor or nil if it is invalid
        let toCheck = map.getNodeAt(x: neighborCoords.x, y: neighborCoords.y)
        
        // If neighbor is invalid (IE nil) or has already been visited
        if (toCheck != nil && !toCheck!.visited && !map.visited.contains(toCheck!)) {
          
          allNeighborsVisited = false
          
          // See what the path danger would be
          let possibleNodeTotal = visitedNode.dangerToReach + toCheck!.dangerOnPoint
          
          // If we don't have an option already, this will be the lowest, if we do then save it as the option if it is the lowest danger path
            if (possibleNodeTotal < nextNodeTotal || nextNodeToVisit == nil) {
              nextNodeToVisit = toCheck
              visitedFromNode = visitedNode
              nextNodeTotal = possibleNodeTotal
          }
        }
      }
      if allNeighborsVisited {
        map.visited.remove(visitedNode)
      }
    }
    if nextNodeToVisit != nil {
      map.visitNode(nextNodeToVisit!, from: visitedFromNode)
    }
  }
  return map.grid[map.height - 1][map.width - 1].dangerToReach
}

let start = AOC.startTimer()
let input = AOC.getInputFromBundleFile(inputFileName, fileType: "txt")
var grid: [[Node]] = []
for yTileIndex in 0..<5 {
  for (yIndex, row) in input.enumerated() {
    var gridRow: [Node] = []
    for xTileIndex in 0..<5 {
      for (xIndex, char) in row.enumerated() {
        var dangerOnPoint = (Int(String(char))! + xTileIndex + yTileIndex)
        var tens = 0
        while dangerOnPoint > 9 {
          dangerOnPoint = dangerOnPoint - 10
          tens += 1
        }
        dangerOnPoint += tens
        let xPos = xIndex + (row.count * xTileIndex)
        let yPos =  yIndex + (input.count * yTileIndex)
        gridRow.append(Node(point: Point(x: xPos, y: yPos), dangerOnPoint: dangerOnPoint))
      }
    }
    grid.append(gridRow)
  }
}

var map = Grid(grid: grid)
print(run())
AOC.printElapsedTimeFrom(start: start)
