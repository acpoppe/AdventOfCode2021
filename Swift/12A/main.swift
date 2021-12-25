//
//  main.swift
//  12A
//
//  Created by Allison Poppe on 12/24/21.
//

import Foundation

let inputFileName = "input"

var caveValues: [String: [String]] = [:]

func getInputFromBundleFile(_ fileName: String, fileType: String) -> [String] {
    guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
        preconditionFailure("Couldn't get a path to input.txt")
    }
    
    guard FileManager.default.fileExists(atPath: path) else {
        preconditionFailure("The file input.txt is missing")
    }
    
    guard let content = try? String(contentsOfFile: path, encoding:String.Encoding.utf8) else {
        preconditionFailure("Could not get string data from the file")
    }
    
    var input = content.components(separatedBy: "\n")

    if (input[input.count - 1] == "") {
        input = input.dropLast()
    }
    
    return input
}

func getIntInputFromBundleFile(_ fileName: String, fileType: String) -> [Int] {
    let input = getInputFromBundleFile(fileName, fileType: fileType)
    
    var IntInput: [Int] = []
    
    for element in input {
        IntInput.append(Int(element) ?? 0)
    }
    
    return IntInput
}

func addCave(_ input: String) {
    let caves = input.components(separatedBy: "-")
    caveValues[caves[0]] = []
    caveValues[caves[1]] = []
}

func fillConnections(_ input: String) {
    let caves = input.components(separatedBy: "-")
    caveValues[caves[0]]?.append(caves[1])
    caveValues[caves[1]]?.append(caves[0])
}

func findPathCount(fromRoom: String, visited: [String]) -> Int {
    var count = 0
    var newVisited = visited
    newVisited.append(fromRoom)
    
    if (fromRoom == "end") {
        return 1
    }
    
    for room in caveValues[fromRoom]! {
        if (!visited.contains(room.lowercased())) {
            count += findPathCount(fromRoom: room, visited: newVisited)
        }
    }
    
    return count
}

var input = getInputFromBundleFile(inputFileName, fileType: "txt")

for line in input {
    addCave(line)
}

for line in input {
    fillConnections(line)
}

print(findPathCount(fromRoom: "start", visited: []))
