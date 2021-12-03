//
//  main.swift
//  3B
//
//  Created by Allison Poppe on 12/2/21.
//

import Foundation

var zeroCount = 0
var oneCount = 0

func getOxygenRating(lineLength: Int, contentLines: [Substring]) -> Substring {
    
    var inputLines = contentLines
    var keepLines: [Substring] = []
    
    for position in 0..<lineLength {
        if (inputLines.count != 1) {
            for line in inputLines {
                if (line[line.index(line.startIndex, offsetBy: position)] == "0") {
                    zeroCount += 1
                } else if (line[line.index(line.startIndex, offsetBy: position)] == "1") {
                    oneCount += 1
                }
            }
            
            if (zeroCount > oneCount) {
                for line in inputLines {
                    if (line[line.index(line.startIndex, offsetBy: position)] == "0") {
                        keepLines.append(line)
                    }
                }
            } else if (oneCount > zeroCount) {
                for line in inputLines {
                    if (line[line.index(line.startIndex, offsetBy: position)] == "1") {
                        keepLines.append(line)                   }
                }
            } else {
                for line in inputLines {
                    if (line[line.index(line.startIndex, offsetBy: position)] == "1") {
                        keepLines.append(line)
                    }
                }
            }
            inputLines = keepLines
            keepLines = []
        }
        zeroCount = 0
        oneCount = 0
    }
    
    if (inputLines.count == 1) {
        return inputLines[0]
    } else {
        preconditionFailure("Found too many results for Oxygen Rating")
    }
}

func getCO2Rating(lineLength: Int, contentLines: [Substring]) -> Substring {
    
    var inputLines = contentLines
    var keepLines: [Substring] = []
    
    for position in 0..<lineLength {
        if (inputLines.count != 1) {
            for line in inputLines {
                if (line[line.index(line.startIndex, offsetBy: position)] == "0") {
                    zeroCount += 1
                } else if (line[line.index(line.startIndex, offsetBy: position)] == "1") {
                    oneCount += 1
                }
            }
            
            if (zeroCount > oneCount) {
                for line in inputLines {
                    if (line[line.index(line.startIndex, offsetBy: position)] == "1") {
                        keepLines.append(line)
                    }
                }
            } else if (oneCount > zeroCount) {
                for line in inputLines {
                    if (line[line.index(line.startIndex, offsetBy: position)] == "0") {
                        keepLines.append(line)                   }
                }
            } else {
                for line in inputLines {
                    if (line[line.index(line.startIndex, offsetBy: position)] == "0") {
                        keepLines.append(line)
                    }
                }
            }
            inputLines = keepLines
            keepLines = []
        }
        zeroCount = 0
        oneCount = 0
    }
    
    if (inputLines.count == 1) {
        return inputLines[0]
    } else {
        preconditionFailure("Found too many results for CO2 Rating")
    }
}

guard let path = Bundle.main.path(forResource: "input", ofType: "txt") else {
    preconditionFailure("Couldn't get a path to input.txt")
}

guard FileManager.default.fileExists(atPath: path) else {
    preconditionFailure("The file input.txt is missing")
}

guard let content = try? String(contentsOfFile: path, encoding:String.Encoding.utf8) else {
    preconditionFailure("Could not get string data from the file")
}

let contentLines = content.split(separator: "\n")

let lineLength = contentLines[0].count

guard let oxyRate = Int(getOxygenRating(lineLength: lineLength, contentLines: contentLines), radix: 2) else {
    preconditionFailure("Conversion from Oxygen String to Int failed")
}

guard let cO2Rate = Int(getCO2Rating(lineLength: lineLength, contentLines: contentLines), radix: 2) else {
    preconditionFailure("Conversion from CO2 String to Int failed")
}

print("\(oxyRate * cO2Rate)")
