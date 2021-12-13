//
//  main.swift
//  11A
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

func step() -> Int {
    var totalFlashes = 0
    var moreFlashes: Bool
    
    var octopiCopy = octopi
    for (rIndex, row) in octopiCopy.enumerated() {
        for (index, _) in row.enumerated() {
            octopi[rIndex][index] += 1
        }
    }
    
    repeat {
        moreFlashes = false
        
        octopiCopy = octopi
        for (rIndex, row) in octopiCopy.enumerated() {
            for (index, _) in row.enumerated() {
                if !didFlash[rIndex][index] &&
                    octopiCopy[rIndex][index] > 9 {
                    didFlash[rIndex][index] = true
                    affectNeighbors(rIndex: rIndex, cIndex: index)
                    moreFlashes = true
                }
            }
        }
    } while(moreFlashes)
    
    octopiCopy = octopi
    for (rIndex, row) in octopiCopy.enumerated() {
        for (index, _) in row.enumerated() {
            if didFlash[rIndex][index] {
                octopi[rIndex][index] = 0
                totalFlashes += 1
            }
            didFlash[rIndex][index] = false
        }
    }
    
    return totalFlashes
}

func affectNeighbors(rIndex: Int, cIndex: Int) {
    for r in rIndex-1...rIndex+1 {
        for c in cIndex-1...cIndex+1 {
            if r >= 0 && r < octopi.count &&
                c >= 0 && c < octopi[r].count &&
                !(r == rIndex && c == cIndex) {
                octopi[r][c] += 1
            }
        }
    }
}

let input = getInputFromBundleFile(inputFileName, fileType: "txt")

var octopi: [[Int]] = []
var didFlash: [[Bool]] = []

for line in input {
    var octoRow: [Int] = []
    var neighborsRow: [Bool] = []
    for energyString in line {
        octoRow.append(Int(String(energyString)) ?? 0)
        neighborsRow.append(false)
    }
    octopi.append(octoRow)
    didFlash.append(neighborsRow)
}

var total = 0
for _ in 0...99 {
    total += step()
}

for (index, _) in octopi.enumerated() {
    print(octopi[index])
}


print (total)
