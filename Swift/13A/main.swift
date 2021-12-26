//
//  main.swift
//  13A
//
//  Created by Allison Poppe on 12/25/21.
//

import Foundation

let inputFileName = "input"

var foldInstructions: [[String]] = []
var map: [String] = []

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

func initMap(_ input: [String]) {
    var points: [String] = []
    var initPoints = true
    var ySet = false
    var xSet = false
    var y = 0
    var x = 0
    
    for line in input {
        if (line == "") {
            initPoints = false
            continue
        }
        if (initPoints) {
            points.append(line)
        } else if (line != "") {
            let fullInstruction = line.components(separatedBy: " ")[2]
            let instruction = fullInstruction.components(separatedBy: "=")
            if (!ySet && instruction[0] == "y") {
                y = (Int(instruction[1])! * 2) + 1
                ySet = true
            }
            if (!xSet && instruction[0] == "x") {
                x = (Int(instruction[1])! * 2) + 1
                xSet = true
            }
            foldInstructions.append(instruction)
        }
    }

    for _ in 0..<y {
        var row = ""
        for _ in 0..<x {
            row += "."
        }
        map.append(row)
    }
    
    for point in points {
        let xPos = Int(point.components(separatedBy: ",")[0])!
        let yPos = Int(point.components(separatedBy: ",")[1])!
        var arrRow = Array(map[yPos])
        arrRow[xPos] = "#"
        map[yPos] = String(arrRow)
    }
}

func fold(foldDirection: String, foldLine: Int) {
    if (foldDirection == "x") {
        var newMap: [String] = []
        for row in map {
            let rowArr = Array(row)
            let firstHalf = rowArr[0..<(rowArr.count / 2)]
            let secondHalf = rowArr[((rowArr.count / 2) + 1)..<rowArr.count]
            var newString = ""
            for charIndex in 0..<firstHalf.count {
                let firstChar = firstHalf[charIndex]
                let secondChar = secondHalf.reversed()[charIndex]
                if (firstChar == "#" || secondChar == "#") {
                    newString += "#"
                } else {
                    newString += "."
                }
            }
            newMap.append(String(newString))
        }
        map = newMap
    } else if (foldDirection == "y") {
        var newMap: [String] = []
        for rowIndex in 0..<((map.count - 1) / 2) {
            let topString = map[rowIndex]
            let botString = map[map.count - 1 - rowIndex]
            var newString = ""
            for charIndex in 0..<topString.count {
                if (Array(topString)[charIndex] == "#" ||
                    Array(botString)[charIndex] == "#") {
                    newString += "#"
                } else {
                    newString += "."
                }
            }
            newMap.append(newString)
        }
        map = newMap
    }
}

func countPoints() -> Int {
    var count = 0
    
    for row in map {
        for char in row {
            if (char == "#") {
                count += 1
            }
        }
    }
    
    return count
}

let input = getInputFromBundleFile(inputFileName, fileType: "txt")

initMap(input)

fold(foldDirection: foldInstructions[0][0], foldLine: Int(foldInstructions[0][1])!)
print(countPoints())
