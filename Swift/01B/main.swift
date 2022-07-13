//
//  main.swift
//  01B
//
//  Created by Allison Poppe on 12/2/21.
//

import Foundation

var currentIndex = 0;
var increaseCount = 0;

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

for _ in contentLines {
    if (currentIndex > 2) {
        let firstValue = (Int(contentLines[currentIndex - 1]) ?? 0) + (Int(contentLines[currentIndex - 2]) ?? 0) + (Int(contentLines[currentIndex - 3]) ?? 0)
        let secondValue = (Int(contentLines[currentIndex]) ?? 0) + (Int(contentLines[currentIndex - 1]) ?? 0) + (Int(contentLines[currentIndex - 2]) ?? 0)
        
        if (secondValue > firstValue) {
            increaseCount += 1
        }
    }
    currentIndex += 1
}

print("Increases: \(increaseCount)")
