//
//  main.swift
//  8A
//
//  Created by Allison Poppe on 12/10/21.
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

func getOutputDigitsFrom(input: [String]) -> [[String]] {
    var export: [[String]] = []
    for line in input {
        let components = line.components(separatedBy: "|")
        let outputValues = components[1].components(separatedBy: " ")
        var outputRow: [String] = []
        for component in outputValues {
            let value = component.trimmingCharacters(in: .whitespacesAndNewlines)
            if value != "" && value != " " {
                outputRow.append(value)
            }
        }
        export.append(outputRow)
    }
    return export
}

func getUniqueSectionsDigitCount(_ input: [[String]]) -> Int {
    var count = 0
    for row in input {
        for digit in row {
            if digit.count == 2 || digit.count == 4 || digit.count == 3 || digit.count == 7 {
                count += 1
            }
        }
    }
    return count
}

func sumOfArrayInts(_ input: [Int]) -> Int {
    var count = 0
    for number in input {
        count += number
    }
    return count
}

var input = getInputFromBundleFile(inputFileName, fileType: "txt")

var outputDig = getOutputDigitsFrom(input: input)

var uniqueDigs = getUniqueSectionsDigitCount(outputDig)

print(uniqueDigs)
