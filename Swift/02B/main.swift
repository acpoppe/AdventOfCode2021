//
//  main.swift
//  02B
//
//  Created by Allison Poppe on 12/2/21.
//

import Foundation

var currentHorizontalPosition = 0
var currentDepth = 0
var currentAim = 0

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

for line in contentLines {
    let currentCommand = line.split(separator: " ")
    if (currentCommand[0] == "forward") {
        currentHorizontalPosition += Int(currentCommand[1]) ?? 0
        currentDepth += currentAim * (Int(currentCommand[1]) ?? 0)
    }
    if (currentCommand[0] == "up") {
        currentAim -= Int(currentCommand[1]) ?? 0
    }
    if (currentCommand[0] == "down") {
        currentAim += Int(currentCommand[1]) ?? 0
    }
}

let multiplied = currentHorizontalPosition * currentDepth
print("Multiplied Height and Depth: \(multiplied)")
