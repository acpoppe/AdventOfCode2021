//
//  main.swift
//  16A
//
//  Created by Allison Poppe - Work on 14.07.22.
//

import Foundation


// MARK: - Structures
class Packet {
  
  let data: String
  
  init(data: String) {
    self.data = data
  }
  
  static func convertToBinary(hex: String) -> String {
    var bin = ""
    for c in hex {
      var nibble = String(Int(String(c), radix: 16)!, radix: 2)
      let padding = 4 - nibble.count
      for _ in 0..<padding {
        nibble.insert("0", at: nibble.startIndex)
      }
      bin += nibble
    }
    return bin
  }
  
  static func valueFromBinary(string: String) -> Int {
    var val = 0
    for c in string {
      if String(c) == "0" || String(c) == "1" {
        val = val << 1
        if String(c) == "1" {
          val = val | 1
        }
      }
    }
    return val
  }
  
  func version() -> Int {
    var build = ""
    let version = String(Array(data)[0..<3])
    for c in version {
      build += String(c)
    }
    return Packet.valueFromBinary(string: build)
  }
  
  func typeId() -> Int {
    var build = ""
    let type = String(Array(data)[3..<6])
    for c in type {
      build += String(c)
    }
    return Packet.valueFromBinary(string: build)
  }
  
  func bitAt(index: Int) -> String {
    return String(Array(data)[index])
  }
  
  func bitsInRange(startIndex: Int, endIndex: Int) -> String {
    return String(Array(data)[startIndex..<endIndex])
  }
  
  func bitsStartingAt(startIndex: Int, length: Int? = nil) -> String {
    var endIndex: Int
    if let length = length {
      endIndex = length + startIndex
    } else {
      endIndex = data.count
    }
    
    return bitsInRange(startIndex: startIndex, endIndex: endIndex)
  }
  
  func firstPacketFromSubpackets(subpackets: String) -> (first: String, remainingBits: String)? {
    var subs = Array(subpackets)
    var firstPacket = Array("")
    // let versionBits = String(Array(subpackets)[0..<3])
    // let version = Packet.valueFromBinary(string: versionBits)
    let typeBits = String(Array(subpackets)[3..<6])
    let type = Packet.valueFromBinary(string: typeBits)
    
    if type == 4 {
      firstPacket.append(contentsOf: subs[0..<6])
      subs.removeFirst(6)
      
      var keepGoing = String(subs[0]) == "1"
      while keepGoing {
        firstPacket.append(contentsOf: subs[0..<5])
        subs.removeFirst(5)
        keepGoing = String(subs[0]) == "1"
      }
      firstPacket.append(contentsOf: subs[0..<5])
      subs.removeFirst(5)
    } else {
      firstPacket.append(contentsOf: subs[0..<6])
      subs.removeFirst(6)
      
      if subs[0] == "0" {
        firstPacket.append(subs[0])
        subs.removeFirst()
        
        // LENGTH
        let length = Packet.valueFromBinary(string: String(subs[0..<15]))
        firstPacket.append(contentsOf: subs[0..<15])
        subs.removeFirst(15)
        
        firstPacket.append(contentsOf: subs[0..<length])
        subs.removeFirst(length)
        
      } else if subs[0] == "1" {
        firstPacket.append(subs[0])
        subs.removeFirst()
        
        
        // COUNT
        let count = Packet.valueFromBinary(string: String(subs[0..<11]))
        firstPacket.append(contentsOf: subs[0..<11])
        subs.removeFirst(11)
        
        for _ in 0..<count {
          var newPacket: String
          var remains: String
          if let results = firstPacketFromSubpackets(subpackets: String(subs)) {
            (newPacket, remains) = results
            firstPacket.append(contentsOf: Array(newPacket))
            subs = Array(remains)
          } else {
            break
          }
        }
        
      } else {
        print("*ALERT* Shouldn't hit this ever unless misunderstood *ALERT*")
      }
    }
    return (String(firstPacket), String(subs))
  }
}

class LiteralPacket: Packet {
  
  func literalValue() -> Int {
    var val = 0
    var contents = Array(data)
    
    contents.removeFirst(6)
    
    var shouldContinue = String(contents[0]) == "1"
    contents.remove(at: 0)
    
    while(shouldContinue) {
      for _ in 0..<4 {
        val = val << 1
        val = val | Int(String(contents[0]))!
        contents.remove(at: 0)
      }
      
      shouldContinue = String(contents[0]) == "1"
      contents.remove(at: 0)
    }
    
    for _ in 0..<4 {
      val = val << 1
      val = val | Int(String(contents[0]))!
      contents.remove(at: 0)
    }
    
    return val
  }
  
  func versionTotal() -> Int {
    return version()
  }
}

class OperatorPacket: Packet {
  
  func operatorPacketTypeBit() -> String {
    return bitAt(index: 6)
  }
}


class LengthOperatorPacket: OperatorPacket {
  
  var literalSubpackets: [LiteralPacket] = []
  var countSubpackets: [CountOperatorPacket] = []
  var lengthSubpackets: [LengthOperatorPacket] = []
  
  override init(data: String) {
    super.init(data: data)
    sortSubpackets()
  }
  
  func lengthOfSubpackets() -> Int {
    
    let bits = bitsStartingAt(startIndex: 7, length: 15)
    return Packet.valueFromBinary(string: bits)
  }
  
  func subpackets() -> String {
    let length = lengthOfSubpackets()
    return self.bitsStartingAt(startIndex: 22, length: length)
  }
  
  func separatePackets() -> [String] {
    var subs = subpackets()
    var packets: [String] = []
    
    while (subs.contains {
      $0 == "1"
    }) {
      var newPacket: String
      if let results = firstPacketFromSubpackets(subpackets: subs) {
        (newPacket, subs) = results
        packets.append(newPacket)
      } else {
        break
      }
    }
    
    return packets
  }
  
  func sortSubpackets() {
    let subpackets = separatePackets()
    for subpacketStr in subpackets {
      let typeBits = String(Array(subpacketStr)[3..<6])
      let type = Packet.valueFromBinary(string: typeBits)
      if type == 4 {
        literalSubpackets.append(LiteralPacket(data: subpacketStr))
      } else {
        if String(Array(subpacketStr)[6]) == "0" {
          // Length
          lengthSubpackets.append(LengthOperatorPacket(data: subpacketStr))
        } else {
          // Count
          countSubpackets.append(CountOperatorPacket(data: subpacketStr))
        }
      }
    }
  }
  
  func versionTotal() -> Int {
    var total = 0
    for i in literalSubpackets {
      total += i.version()
    }
    for i in countSubpackets {
      total += i.versionTotal()
    }
    for i in lengthSubpackets {
      total += i.versionTotal()
    }
    total += version()
    return total
  }
}

class CountOperatorPacket: OperatorPacket {
  
  var literalSubpackets: [LiteralPacket] = []
  var countSubpackets: [CountOperatorPacket] = []
  var lengthSubpackets: [LengthOperatorPacket] = []
  
  override init(data: String) {
    super.init(data: data)
    sortSubpackets()
  }
  
  func countOfSubpackets() -> Int {
    
    let bits = bitsStartingAt(startIndex: 7, length: 11)
    return Packet.valueFromBinary(string: bits)
  }
  
  func subpackets() -> String {
    return self.bitsStartingAt(startIndex: 18)
  }
  
  func separatePackets() -> [String] {
    var subs = subpackets()
    var packets: [String] = []
    
    for _ in 0..<countOfSubpackets() {
      var newPacket: String
      if let results = firstPacketFromSubpackets(subpackets: subs) {
        (newPacket, subs) = results
        packets.append(newPacket)
      } else {
        break
      }
    }
    
    return packets
  }
  
  func sortSubpackets() {
    let subpackets = separatePackets()
    for subpacketStr in subpackets {
      let typeBits = String(Array(subpacketStr)[3..<6])
      let type = Packet.valueFromBinary(string: typeBits)
      if type == 4 {
        literalSubpackets.append(LiteralPacket(data: subpacketStr))
      } else {
        if String(Array(subpacketStr)[6]) == "0" {
          // Length
          lengthSubpackets.append(LengthOperatorPacket(data: subpacketStr))
        } else {
          // Count
          countSubpackets.append(CountOperatorPacket(data: subpacketStr))
        }
      }
    }
  }
  
  func versionTotal() -> Int {
    var total = 0
    for i in literalSubpackets {
      total += i.version()
    }
    for i in countSubpackets {
      total += i.versionTotal()
    }
    for i in lengthSubpackets {
      total += i.versionTotal()
    }
    total += version()
    return total
  }
}


// MARK: - Script
let inputName = "input"

let start = AOC.startTimer()

let input = AOC.getInputFromBundleFile(inputName)
let binary = Packet.convertToBinary(hex: input[0])
let generic = Packet(data: binary)

if generic.typeId() == 4 {
  let literal = LiteralPacket(data: binary)
  print(literal.versionTotal())
} else {
  if generic.bitAt(index: 6) == "0" {
    let length = LengthOperatorPacket(data: binary)
    print(length.versionTotal())
  } else {
    let count = CountOperatorPacket(data: binary)
    print(count.versionTotal())
  }
}


AOC.printElapsedTimeFrom(start: start)
