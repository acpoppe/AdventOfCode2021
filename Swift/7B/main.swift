//
//  main.swift
//  7B
//
//  Created by Allison Poppe on 12/6/21.
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

func getMedian(_ input: [Int]) -> Int {
    var values = input
    values.sort()
    
    return Int(round(Double(values[values.count / 2]) + Double(values[(values.count / 2) - 1]) / 2.0))
}

func getMean(_ input: [Int]) -> Int {
    var values = input
    values.sort()
    
    var total = 0
    for element in input {
        total += element
    }
    return Int(Double(total) / Double(values.count))
}

func getTotalFuelCostTo(_ dest: Int, input: [Int]) -> Int {
    var total = 0
    for element in input {
        total += abs(element - dest)
    }
    return total
}

func pt2GetTotalFuelCostTo(_ dest: Int, input: [Int]) -> Int {
    var total = 0
    for element in input {
        let movesToDest = abs(element - dest)
        total += movesToDest * (abs(element - dest) + 1) / 2
    }
    
    return total
}

let input = getInputFromBundleFile(inputFileName, fileType: "txt")[0].components(separatedBy: ",").map({ Int($0)! })

print(pt2GetTotalFuelCostTo(getMean(input), input: input))
