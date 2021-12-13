//
//  main.swift
//  10A
//
//  Created by Allison Poppe on 12/12/21.
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

func getCorruptedCount(_ input: [String]) -> Int {
    var total = 0
    
    for line in input {
        var charsGiven: [Character] = []
    issue: for char in line {
            switch char {
            case ")":
                if charsGiven[charsGiven.count - 1] != "(" {
                    total += 3
                    break issue
                } else {
                    charsGiven.remove(at: charsGiven.count - 1)
                }
                break
            case "]":
                if charsGiven[charsGiven.count - 1] != "[" {
                    total += 57
                    break issue
                } else {
                    charsGiven.remove(at: charsGiven.count - 1)
                }
                break
            case "}":
                if charsGiven[charsGiven.count - 1] != "{" {
                    total += 1197
                    break issue
                } else {
                    charsGiven.remove(at: charsGiven.count - 1)
                }
                break
            case ">":
                if charsGiven[charsGiven.count - 1] != "<" {
                    total += 25137
                    break issue
                } else {
                    charsGiven.remove(at: charsGiven.count - 1)
                }
                break
            default:
                charsGiven.append(char)
            }
        }
    }
    
    return total
}

let input = getInputFromBundleFile(inputFileName, fileType: "txt")

print(getCorruptedCount(input))
