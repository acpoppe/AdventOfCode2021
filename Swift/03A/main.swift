//
//  main.swift
//  03A
//
//  Created by Allison Poppe on 12/2/21.
//

import Foundation

var gammaString = ""
var epsilonString = ""
var zeroCount = 0
var oneCount = 0

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

for position in 0..<lineLength {
    for line in contentLines {
        if (line[line.index(line.startIndex, offsetBy: position)] == "0") {
            zeroCount += 1
        } else if (line[line.index(line.startIndex, offsetBy: position)] == "1") {
            oneCount += 1
        }
    }
    if (zeroCount > oneCount) {
        gammaString = gammaString + "0"
        epsilonString = epsilonString + "1"
    } else {
        gammaString = gammaString + "1"
        epsilonString = epsilonString + "0"
    }
    zeroCount = 0
    oneCount = 0
}

guard let gammaRate = Int(gammaString, radix: 2) else {
    preconditionFailure("Conversion from Gamma String to Int failed")
}

guard let epsilonRate = Int(epsilonString, radix: 2) else {
    preconditionFailure("Conversion from Epsilon String to Int failed")
}

print("\(epsilonRate * gammaRate)")
