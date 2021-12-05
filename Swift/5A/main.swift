//
//  main.swift
//  5A
//
//  Created by Allison Poppe on 12/4/21.
//

import Foundation

struct Line {
    let startPoint: CGPoint
    let endPoint: CGPoint
}

var map: [[Int]] = []
var lines: [Line] = []

func getInputFromBundleFile(_ fileName: String, fileType: String) -> String {
    guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
        preconditionFailure("Couldn't get a path to input.txt")
    }

    guard FileManager.default.fileExists(atPath: path) else {
        preconditionFailure("The file input.txt is missing")
    }

    guard let content = try? String(contentsOfFile: path, encoding:String.Encoding.utf8) else {
        preconditionFailure("Could not get string data from the file")
    }
    
    return content
}

func initMap(input: [String]) {
    var highestX = 0
    var highestY = 0
    for rawLine in input {
        let points = rawLine.components(separatedBy: " -> ")
        let rawStartPoint = points[0].components(separatedBy: ",")
        let rawEndPoint = points[1].components(separatedBy: ",")
        let startPointXInt = Int(rawStartPoint[0]) ?? 0
        let startPointYInt = Int(rawStartPoint[1]) ?? 0
        let endPointXInt = Int(rawEndPoint[0]) ?? 0
        let endPointYInt = Int(rawEndPoint[1]) ?? 0
        if (startPointXInt > highestX) {
            highestX = startPointXInt
        }
        if (endPointXInt > highestX) {
            highestX = endPointXInt
        }
        if (startPointYInt > highestY) {
            highestY = startPointYInt
        }
        if (endPointYInt > highestY) {
            highestY = endPointYInt
        }
        let startPoint = CGPoint(x: startPointXInt, y: startPointYInt)
        let endPoint = CGPoint(x: endPointXInt, y: endPointYInt)
        lines.append(Line(startPoint: startPoint, endPoint: endPoint))
    }
    
    for _ in 0...highestY {
        var columnArray: [Int] = []
        for _ in 0...highestX {
            columnArray.append(0)
        }
        map.append(columnArray)
    }
}

func getHorizAndVertLines(lines: [Line]) -> [Line] {
    var horizAndVertLines: [Line] = []
    for line in lines {
        if (line.startPoint.x == line.endPoint.x || line.startPoint.y == line.endPoint.y) {
            horizAndVertLines.append(line)
        }
    }
    return horizAndVertLines
}

func addLinesToMap(lines: [Line]) {
    for line in lines {
        if (line.startPoint.x == line.endPoint.x) {
            var startYInt = Int(line.startPoint.y)
            var endYInt = Int(line.endPoint.y)
            if (startYInt >= endYInt) {
                let temp = startYInt
                startYInt = endYInt
                endYInt = temp
            }
            for yVal in startYInt...endYInt {
                map[yVal][Int(line.startPoint.x)] += 1
            }
        } else if (line.startPoint.y == line.endPoint.y) {
            var startXInt = Int(line.startPoint.x)
            var endXInt = Int(line.endPoint.x)
            if (startXInt >= endXInt) {
                let temp = startXInt
                startXInt = endXInt
                endXInt = temp
            }
            for xVal in startXInt...endXInt {
                map[Int(line.startPoint.y)][xVal] += 1
            }
        }
    }
}

func getIntersectedPointCountOnMap() -> Int {
    var intersectionCount = 0
    for (rowIndex, row) in map.enumerated() {
        for (columnIndex, _) in row.enumerated() {
            if (map[rowIndex][columnIndex] > 1) {
                intersectionCount += 1
            }
        }
    }
    
    return intersectionCount
}

var input = getInputFromBundleFile("input", fileType: "txt").components(separatedBy: "\n")
if (input[input.count - 1] == "") {
    input.remove(at: input.count - 1)
}

initMap(input: input)
addLinesToMap(lines: getHorizAndVertLines(lines: lines))
print(getIntersectedPointCountOnMap())
