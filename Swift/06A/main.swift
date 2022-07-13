//
//  main.swift
//  06A
//
//  Created by Allison Poppe on 12/5/21.
//

import Foundation

var fish: [Int] = []

func dayTick() {
    for (fishIndex, singleFish) in fish.enumerated() {
        if (singleFish == 0) {
            fish[fishIndex] = 6
            fish.append(8)
        } else {
            fish[fishIndex] -= 1
        }
    }
}

func getInputFromBundleFile(_ fileName: String, fileType: String) -> String {
    guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
        preconditionFailure("Couldn't get a path to input.txt")
    }

    guard FileManager.default.fileExists(atPath: path) else {
        preconditionFailure("The file input.txt is missing")
    }

    guard let content = try? String(contentsOfFile: path, encoding:String.Encoding.utf8) else {
        preconditionFailure("Could not get string data from the file")
    }
    
    return content
}

var input = getInputFromBundleFile("input", fileType: "txt").components(separatedBy: "\n")
if (input[input.count - 1] == "") {
    input.remove(at: input.count - 1)
}

var fishArray = input[0].components(separatedBy: ",")

for singleFish in fishArray {
    fish.append(Int(singleFish) ?? 0)
}

for _ in 0..<80 {
    dayTick()
}

print(fish.count)
