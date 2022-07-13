//
//  main.swift
//  06B
//
//  Created by Allison Poppe on 12/5/21.
//

import Foundation

import Foundation

var fish: [FishGroup] = []

struct FishGroup {
    var daysTilSpawn: Int
    var fishInGroup = 0
}

func initFishGroups() {
    for day in 0...8 {
        fish.append(FishGroup(daysTilSpawn: day))
    }
}

func dayTick() {
    var fishToAddTo6 = 0
    for (fishIndex, fishGroup) in fish.enumerated() {
        if (fishGroup.daysTilSpawn == 0) {
            fish[fishIndex].daysTilSpawn = 8
            fishToAddTo6 = fish[fishIndex].fishInGroup
        } else {
            fish[fishIndex].daysTilSpawn -= 1
        }
    }
    
    for (fishIndex, fishGroup) in fish.enumerated() {
        if (fishGroup.daysTilSpawn == 6) {
            fish[fishIndex].fishInGroup += fishToAddTo6
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

initFishGroups()

for indivFish in fishArray {
    let fishInt = Int(indivFish) ?? 0
    for (fishIndex, fishGroup) in fish.enumerated() {
        if (fishGroup.daysTilSpawn == fishInt) {
            fish[fishIndex].fishInGroup += 1
        }
    }
}

for day in 0..<256 {
    print("Day \(day + 1)")
    dayTick()
}

var totalFish = 0
for fishGroup in fish {
    totalFish += fishGroup.fishInGroup
}
print(totalFish)
