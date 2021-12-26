//
//  main.swift
//  14B
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
    
    for time in 0..<times {
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

func stepV2(template: String, times: Int) -> Int {
    var pairs: [String: Int] = [:]
    var newPairs: [String: Int] = [:]
    var charCounts: [String: Int] = [:]
    let firstStringChar = template.first!
    let lastStringChar = template.last!
    
    for charIndex in 0..<template.count {
        if (charIndex < template.count - 1) {
            let pair = String(Array(template)[charIndex]) + String(Array(template)[charIndex + 1])
            if (pairs[pair] != nil) {
                pairs[pair]! += 1
            } else {
                pairs[pair] = 1
            }
        }
    }
    
    for _ in 0..<times {
        newPairs = [:]
        for pair in pairs {
            let insert = pairRules[pair.key]
            let newPair = String(pair.key.dropLast()) + String(insert!)
            let newPair2 = String(insert!) + String(pair.key.dropFirst())
            if (newPairs[newPair] != nil) {
                newPairs[newPair]! += pair.value
            } else {
                newPairs[newPair] = pair.value
            }
            if (newPairs[newPair2] != nil) {
                newPairs[newPair2]! += pair.value
            } else {
                newPairs[newPair2] = pair.value
            }
        }
        pairs = newPairs
    }
    
    for pair in pairs {
        let firstChar = String(pair.key.dropLast())
        let secondChar = String(pair.key.dropFirst())
        if (charCounts[firstChar] != nil) {
            charCounts[firstChar]! += pair.value
        } else {
            charCounts[firstChar] = pair.value
        }
        if (charCounts[secondChar] != nil) {
            charCounts[secondChar]! += pair.value
        } else {
            charCounts[secondChar] = pair.value
        }
    }
    
    for charCount in charCounts {
        if (charCount.key == String(firstStringChar) ||
            charCount.key == String(lastStringChar)) {
            charCounts[charCount.key] = charCount.value + 1
        }
        charCounts[charCount.key] = charCounts[charCount.key]! / 2
    }
    
    var sortedCharCounts = charCounts.sorted {
        return $0.value > $1.value
    }
    
    let most = sortedCharCounts.remove(at: 0)
    let least = sortedCharCounts.remove(at: sortedCharCounts.count - 1)
    
    return most.value - least.value
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

let subtracted = stepV2(template: template, times: 40)
print(subtracted)
