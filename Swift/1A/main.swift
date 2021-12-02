//
//  main.swift
//  1A
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

for line in contentLines {
    if (currentIndex > 0) {
        if (Int(line) ?? 0 > Int(contentLines[currentIndex - 1]) ?? 0) {
            increaseCount += 1
        }
    }
    currentIndex += 1
}

print("Increases: \(increaseCount)")
