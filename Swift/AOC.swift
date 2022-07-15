//
//  AOC.swift
//  15A
//
//  Created by Allison Poppe - Work on 14.07.22.
//

import Foundation

class AOC {
  static func getInputFromBundleFile(_ fileName: String, fileType: String = "txt") -> [String] {
    guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
      preconditionFailure("Couldn't get a path to \(fileName).\(fileType)")
    }
    
    guard FileManager.default.fileExists(atPath: path) else {
      preconditionFailure("The file \(fileName).\(fileType) is missing")
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
  
  static func getIntInputFromBundleFile(_ fileName: String, fileType: String = "txt") -> [Int] {
    let input = getInputFromBundleFile(fileName, fileType: fileType)
    
    var intInput: [Int] = []
    
    for element in input {
      intInput.append(Int(element) ?? 0)
    }
    
    return intInput
  }
  
  static func startTimer() -> DispatchTime {
    return DispatchTime.now()
  }
  
  static func timeDifferenceToNow(start: DispatchTime) -> Double  {
    let end = DispatchTime.now()
    return Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / Double(1_000_000_000)
  }
  
  static func printElapsedTimeFrom(start: DispatchTime)  {
    let end = DispatchTime.now()
    print("Elapsed time: \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / Double(1_000_000_000)) seconds")
  }
}
