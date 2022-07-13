//
//  main.swift
//  09B
//
//  Created by Allison Poppe on 12/11/21.
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

func getSumOfThreatLevels(_ input: [[Int]]) -> Int {
    var count = 0
    
    let iterInput = input
    for (rowIndex, row) in iterInput.enumerated() {
        for (columnIndex, _) in row.enumerated() {
            if isLowestAdjacent(row: rowIndex, column: columnIndex, input: input) {
                count += input[rowIndex][columnIndex] + 1
            }
        }
    }
    
    return count
}

func getThreeLargestBasinsProduct(_ input: [[Int]]) -> Int {
    var basins: [Int] = []
    
    let iterInput = input
    for (rowIndex, row) in iterInput.enumerated() {
        for (columnIndex, _) in row.enumerated() {
            if isLowestAdjacent(row: rowIndex, column: columnIndex, input: input) {
                basins.append(getBasinSize(row: rowIndex, column: columnIndex, input: input))
            }
        }
    }
    basins.sort(by: >)
    return basins[0] * basins[1] * basins[2]
}

func getBasinSize(row: Int, column: Int, input: [[Int]]) -> Int {
    struct Location: Equatable {
        var rowIndex: Int = 0
        var columnIndex: Int = 0
        var height: Int = 0
    }
    
    var locationsInBasin: [Location] = [Location(rowIndex: row, columnIndex: column, height: input[row][column])]
    var newlyAddedLocs: [Location] = [Location(rowIndex: row, columnIndex: column, height: input[row][column])]
    
    while (true) {
        if newlyAddedLocs.isEmpty {
            break
        }
        let iterNewlyAddedLocs = newlyAddedLocs
        newlyAddedLocs.removeAll()
        for loc in iterNewlyAddedLocs {
            for r in loc.rowIndex-1...loc.rowIndex+1 {
                for c in loc.columnIndex-1...loc.columnIndex+1 {
                    if (r == loc.rowIndex && c == loc.columnIndex) ||
                        (r != loc.rowIndex && c != loc.columnIndex) ||
                        r < 0 || c < 0 || r > input.count - 1 ||
                        c > input[row].count - 1 {
                        // Don't check location
                        continue
                    } else {
                        let newLoc = Location(rowIndex: r, columnIndex: c, height: input[r][c])
                        if !locationsInBasin.contains(newLoc) &&
                            input[r][c] >= loc.height &&
                            input[r][c] != 9 {
                            locationsInBasin.append(newLoc)
                            newlyAddedLocs.append(newLoc)
                        }
                    }
                }
            }
        }
    }
    
    return locationsInBasin.count
}

func isLowestAdjacent(row: Int, column: Int, input: [[Int]]) -> Bool {
    for rowIndex in row-1...row+1 {
        for columnIndex in column-1...column+1 {
            if (rowIndex == row && columnIndex == column) ||
                rowIndex < 0 || columnIndex < 0 || rowIndex > input.count - 1 ||
                columnIndex > input[row].count - 1 {
                // Don't handle or count against, is out of bounds or not evaluated
                continue
            } else {
                if input[row][column] >= input[rowIndex][columnIndex] {
                    return false
                }
            }
        }
    }
    
    return true
}

let stringInput = getInputFromBundleFile(inputFileName, fileType: "txt")
var input: [[Int]] = []
for line in stringInput {
    var row: [Int] = []
    for char in line {
        row.append(Int(String(char)) ?? 0)
    }
    input.append(row)
}

print(getThreeLargestBasinsProduct(input))
