//
//  main.swift
//  8B
//
//  Created by Allison Poppe on 12/10/21.
//

import Foundation

enum Positions {
    case top
    case topLeft
    case topRight
    case center
    case botLeft
    case botRight
    case bot
}

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

func getUniqueSectionsDigitCount(_ input: [[String]]) -> Int{
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

func getOutput(_ input: String) -> Int {
    var digitString = input.components(separatedBy: "|")[0]
    digitString = digitString.trimmingCharacters(in: .whitespacesAndNewlines)
    let digits = digitString.components(separatedBy: " ")
    var outputString = input.components(separatedBy: "|")[1]
    outputString = outputString.trimmingCharacters(in: .whitespacesAndNewlines)
    let output = outputString.components(separatedBy: " ")
    
    var charCount: [Character: Int] = ["a": 0, "b": 0, "c": 0, "d": 0, "e": 0, "f": 0, "g": 0]
    
    for digit in digits {
        for char in digit {
            charCount[char] = charCount[char]! + 1
        }
    }
    
    let botLeft = charCount.first(where: { (key: Character, value: Int) -> Bool in
        return value == 4
    })!.0
    charCount.removeValue(forKey: botLeft)
    
    let topLeft = charCount.first(where: { (key: Character, value: Int) -> Bool in
        return value == 6
    })!.0
    charCount.removeValue(forKey: topLeft)
    
    let botRight = charCount.first(where: { (key: Character, value: Int) -> Bool in
        return value == 9
    })!.0
    charCount.removeValue(forKey: botRight)
    
    var topRight: Character = "p"
    for digit in digits {
        if digit.count == 2 {
            for char in digit {
                if charCount[char] != nil {
                    topRight = char
                }
            }
        }
    }
    charCount.removeValue(forKey: topRight)
    
    let top = charCount.first(where: { (key: Character, value: Int) -> Bool in
        return value == 8
    })!.0
    charCount.removeValue(forKey: top)
    
    var center: Character = "p"
    for digit in digits {
        if digit.count == 4 {
            for char in digit {
                if charCount[char] != nil {
                    center = char
                }
            }
        }
    }
    charCount.removeValue(forKey: center)
    
    let bot = charCount.first!.0
    charCount.removeValue(forKey: bot)
    
    let lights = [top, topLeft, topRight, center, botLeft, botRight, bot]
    
    let firstDig = getDigit(output[0], lights: lights)
    let secondDig = getDigit(output[1], lights: lights)
    let thirdDig = getDigit(output[2], lights: lights)
    let fourthDig = getDigit(output[3], lights: lights)
    
    let count = (firstDig * 1000) + (secondDig * 100) + (thirdDig * 10) + fourthDig
    
    return count
}

func getDigit(_ input: String, lights: [Character]) -> Int {
    let topOn = input.contains(lights[0])
    let topLeftOn = input.contains(lights[1])
    let topRightOn = input.contains(lights[2])
    let centerOn = input.contains(lights[3])
    let botLeftOn = input.contains(lights[4])
    let botRightOn = input.contains(lights[5])
    let botOn = input.contains(lights[6])
    
    if input.count == 7 {
        return 8
    } else if input.count == 6 {
        if topOn && topLeftOn && topRightOn && !centerOn && botLeftOn && botRightOn && botOn {
            return 0
        } else if topOn && topLeftOn && !topRightOn && centerOn && botLeftOn && botRightOn && botOn {
            return 6
        } else if topOn && topLeftOn && topRightOn && centerOn && !botLeftOn && botRightOn && botOn {
            return 9
        }
    } else if input.count == 5 {
        if topOn && topLeftOn && !topRightOn && centerOn && !botLeftOn && botRightOn && botOn {
            return 5
        } else if topOn && !topLeftOn && topRightOn && centerOn && !botLeftOn && botRightOn && botOn {
            return 3
        } else if topOn && !topLeftOn && topRightOn && centerOn && botLeftOn && !botRightOn && botOn {
            return 2
        }
    } else if input.count == 4 {
        return 4
    } else if input.count == 3 {
        return 7
    } else if input.count == 2 {
        return 1
    }
    return -1
}

var input = getInputFromBundleFile(inputFileName, fileType: "txt")

var outputDig = getOutputDigitsFrom(input: input)

var uniqueDigs = getUniqueSectionsDigitCount(outputDig)

var outputValues: [Int] = []


for entry in input {
    let val = getOutput(entry)
    print(val)
    outputValues.append(val)
}

print(sumOfArrayInts(outputValues))
