//
//  main.swift
//  14A
//
//  Created by Allison Poppe on 12/25/21.
//

import Foundation

let inputFileName = "input"

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

func step(template: String, times: Int) -> String {
    var templateCpy = Array(template)
    var modifiedTemplate = Array(template)
    
    for _ in 0..<times {
        for charIndex in 0..<templateCpy.count {
            if (charIndex < templateCpy.count - 1) {
                let check = String(templateCpy[charIndex]) + String(templateCpy[charIndex + 1])
                let insert = pairRules[check]!
                modifiedTemplate.insert(insert, at: charIndex+(1 * (charIndex + 1)))
            }
        }
        templateCpy = modifiedTemplate
    }
    
    return String(templateCpy)
}

func getCalc(polymer: String) -> Int {
    var charCounts: [Character: Int] = [:]
    
    for char in polymer {
        if (charCounts[char] != nil) {
            charCounts[char]! += 1
        } else {
            charCounts[char] = 1
        }
    }
    
    var sortedCharCounts = charCounts.sorted {
        return $0.value > $1.value
    }
    
    let most = sortedCharCounts.remove(at: 0)
    let least = sortedCharCounts.remove(at: sortedCharCounts.count - 1)
    
    return most.value - least.value
}

var input = getInputFromBundleFile(inputFileName, fileType: "txt")

let template = input[0]
var pairRules: [String: Character] = [:]

input.removeSubrange(0..<2)

for rule in input {
    let pair = rule.components(separatedBy: " -> ")
    pairRules[pair[0]] = Character(pair[1])
}

let newPolymer = step(template: template, times: 10)
print(newPolymer.count)


print(getCalc(polymer: newPolymer))
