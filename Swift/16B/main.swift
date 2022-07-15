//
//  main.swift
//  16B
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
  
  func value() -> Int {
    return literalValue()
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
  
  // Copy from here
  
  func perform(initialVal: Int, op: (Int, Int) -> Int) -> Int {
    var total = initialVal
    for i in literalSubpackets {
      total = op(total, i.value())
    }
    for i in countSubpackets {
      total = op(total, i.value())
    }
    for i in lengthSubpackets {
      total = op(total, i.value())
    }
    return total
  }
  
  func sum(total: Int, val: Int) -> Int {
    return total + val
  }
  
  func product(total: Int, val: Int) -> Int {
    return total * val
  }
  
  func min(total: Int, val: Int) -> Int {
    if total <= val {
      return total
    } else {
      return val
    }
  }
  
  func max(total: Int, val: Int) -> Int {
    if total >= val {
      return total
    } else {
      return val
    }
  }
  
  func greaterThan() -> Int {
    let firstPack = separatePackets()[0]
    let secondPack = separatePackets()[1]
    
    var firstVal: Int
    var secondVal: Int
    
    let typeBits = String(Array(firstPack)[3..<6])
    let type = Packet.valueFromBinary(string: typeBits)
    if type == 4 {
      firstVal = LiteralPacket(data: firstPack).value()
    } else {
      if String(Array(firstPack)[6]) == "0" {
        // Length
        firstVal = LengthOperatorPacket(data: firstPack).value()
      } else {
        // Count
        firstVal = CountOperatorPacket(data: firstPack).value()
      }
    }
    
    let typeBits2 = String(Array(secondPack)[3..<6])
    let type2 = Packet.valueFromBinary(string: typeBits2)
    if type2 == 4 {
      secondVal = LiteralPacket(data: secondPack).value()
    } else {
      if String(Array(secondPack)[6]) == "0" {
        // Length
        secondVal = LengthOperatorPacket(data: secondPack).value()
      } else {
        // Count
        secondVal = CountOperatorPacket(data: secondPack).value()
      }
    }
    
    if (firstVal > secondVal) {
      return 1
    }
    return 0
  }
  
  func lessThan() -> Int {
    let firstPack = separatePackets()[0]
    let secondPack = separatePackets()[1]
    
    var firstVal: Int
    var secondVal: Int
    
    let typeBits = String(Array(firstPack)[3..<6])
    let type = Packet.valueFromBinary(string: typeBits)
    if type == 4 {
      firstVal = LiteralPacket(data: firstPack).value()
    } else {
      if String(Array(firstPack)[6]) == "0" {
        // Length
        firstVal = LengthOperatorPacket(data: firstPack).value()
      } else {
        // Count
        firstVal = CountOperatorPacket(data: firstPack).value()
      }
    }
    
    let typeBits2 = String(Array(secondPack)[3..<6])
    let type2 = Packet.valueFromBinary(string: typeBits2)
    if type2 == 4 {
      secondVal = LiteralPacket(data: secondPack).value()
    } else {
      if String(Array(secondPack)[6]) == "0" {
        // Length
        secondVal = LengthOperatorPacket(data: secondPack).value()
      } else {
        // Count
        secondVal = CountOperatorPacket(data: secondPack).value()
      }
    }
    
    if (firstVal < secondVal) {
      return 1
    }
    return 0
  }
  
  func equalTo() -> Int {
    let firstPack = separatePackets()[0]
    let secondPack = separatePackets()[1]
    
    var firstVal: Int
    var secondVal: Int
    
    let typeBits = String(Array(firstPack)[3..<6])
    let type = Packet.valueFromBinary(string: typeBits)
    if type == 4 {
      firstVal = LiteralPacket(data: firstPack).value()
    } else {
      if String(Array(firstPack)[6]) == "0" {
        // Length
        firstVal = LengthOperatorPacket(data: firstPack).value()
      } else {
        // Count
        firstVal = CountOperatorPacket(data: firstPack).value()
      }
    }
    
    let typeBits2 = String(Array(secondPack)[3..<6])
    let type2 = Packet.valueFromBinary(string: typeBits2)
    if type2 == 4 {
      secondVal = LiteralPacket(data: secondPack).value()
    } else {
      if String(Array(secondPack)[6]) == "0" {
        // Length
        secondVal = LengthOperatorPacket(data: secondPack).value()
      } else {
        // Count
        secondVal = CountOperatorPacket(data: secondPack).value()
      }
    }
    
    if (firstVal == secondVal) {
      return 1
    }
    return 0
  }
  
  func value() -> Int {
    if typeId() == 0 {
      return perform(initialVal: 0, op: sum(total:val:))
    }
    if typeId() == 1 {
      return perform(initialVal: 1, op: product(total:val:))
    }
    if typeId() == 2 {
      return perform(initialVal: Int.max, op: min(total:val:))
    }
    if typeId() == 3 {
      return perform(initialVal: Int.min, op: max(total:val:))
    }
    if typeId() == 5 {
      return greaterThan()
    }
    if typeId() == 6 {
      return lessThan()
    }
    if typeId() == 7 {
      return equalTo()
    }
    return -1
  }
  
  
  
  // Down to here
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
  
  // Copy from here
  
  func perform(initialVal: Int, op: (Int, Int) -> Int) -> Int {
    var total = initialVal
    for i in literalSubpackets {
      total = op(total, i.value())
    }
    for i in countSubpackets {
      total = op(total, i.value())
    }
    for i in lengthSubpackets {
      total = op(total, i.value())
    }
    return total
  }
  
  func sum(total: Int, val: Int) -> Int {
    return total + val
  }
  
  func product(total: Int, val: Int) -> Int {
    return total * val
  }
  
  func min(total: Int, val: Int) -> Int {
    if total <= val {
      return total
    } else {
      return val
    }
  }
  
  func max(total: Int, val: Int) -> Int {
    if total >= val {
      return total
    } else {
      return val
    }
  }
  
  func greaterThan() -> Int {
    let firstPack = separatePackets()[0]
    let secondPack = separatePackets()[1]
    
    var firstVal: Int
    var secondVal: Int
    
    let typeBits = String(Array(firstPack)[3..<6])
    let type = Packet.valueFromBinary(string: typeBits)
    if type == 4 {
      firstVal = LiteralPacket(data: firstPack).value()
    } else {
      if String(Array(firstPack)[6]) == "0" {
        // Length
        firstVal = LengthOperatorPacket(data: firstPack).value()
      } else {
        // Count
        firstVal = CountOperatorPacket(data: firstPack).value()
      }
    }
    
    let typeBits2 = String(Array(secondPack)[3..<6])
    let type2 = Packet.valueFromBinary(string: typeBits2)
    if type2 == 4 {
      secondVal = LiteralPacket(data: secondPack).value()
    } else {
      if String(Array(secondPack)[6]) == "0" {
        // Length
        secondVal = LengthOperatorPacket(data: secondPack).value()
      } else {
        // Count
        secondVal = CountOperatorPacket(data: secondPack).value()
      }
    }
    
    if (firstVal > secondVal) {
      return 1
    }
    return 0
  }
  
  func lessThan() -> Int {
    let firstPack = separatePackets()[0]
    let secondPack = separatePackets()[1]
    
    var firstVal: Int
    var secondVal: Int
    
    let typeBits = String(Array(firstPack)[3..<6])
    let type = Packet.valueFromBinary(string: typeBits)
    if type == 4 {
      firstVal = LiteralPacket(data: firstPack).value()
    } else {
      if String(Array(firstPack)[6]) == "0" {
        // Length
        firstVal = LengthOperatorPacket(data: firstPack).value()
      } else {
        // Count
        firstVal = CountOperatorPacket(data: firstPack).value()
      }
    }
    
    let typeBits2 = String(Array(secondPack)[3..<6])
    let type2 = Packet.valueFromBinary(string: typeBits2)
    if type2 == 4 {
      secondVal = LiteralPacket(data: secondPack).value()
    } else {
      if String(Array(secondPack)[6]) == "0" {
        // Length
        secondVal = LengthOperatorPacket(data: secondPack).value()
      } else {
        // Count
        secondVal = CountOperatorPacket(data: secondPack).value()
      }
    }
    
    if (firstVal < secondVal) {
      return 1
    }
    return 0
  }
  
  func equalTo() -> Int {
    let firstPack = separatePackets()[0]
    let secondPack = separatePackets()[1]
    
    var firstVal: Int
    var secondVal: Int
    
    let typeBits = String(Array(firstPack)[3..<6])
    let type = Packet.valueFromBinary(string: typeBits)
    if type == 4 {
      firstVal = LiteralPacket(data: firstPack).value()
    } else {
      if String(Array(firstPack)[6]) == "0" {
        // Length
        firstVal = LengthOperatorPacket(data: firstPack).value()
      } else {
        // Count
        firstVal = CountOperatorPacket(data: firstPack).value()
      }
    }
    
    let typeBits2 = String(Array(secondPack)[3..<6])
    let type2 = Packet.valueFromBinary(string: typeBits2)
    if type2 == 4 {
      secondVal = LiteralPacket(data: secondPack).value()
    } else {
      if String(Array(secondPack)[6]) == "0" {
        // Length
        secondVal = LengthOperatorPacket(data: secondPack).value()
      } else {
        // Count
        secondVal = CountOperatorPacket(data: secondPack).value()
      }
    }
    
    if (firstVal == secondVal) {
      return 1
    }
    return 0
  }
  
  func value() -> Int {
    if typeId() == 0 {
      return perform(initialVal: 0, op: sum(total:val:))
    }
    if typeId() == 1 {
      return perform(initialVal: 1, op: product(total:val:))
    }
    if typeId() == 2 {
      return perform(initialVal: Int.max, op: min(total:val:))
    }
    if typeId() == 3 {
      return perform(initialVal: Int.min, op: max(total:val:))
    }
    if typeId() == 5 {
      return greaterThan()
    }
    if typeId() == 6 {
      return lessThan()
    }
    if typeId() == 7 {
      return equalTo()
    }
    return -1
  }
  
  
  
  // Down to here
}


// MARK: - Script
let inputName = "input"

let start = AOC.startTimer()

let input = AOC.getInputFromBundleFile(inputName)
let binary = Packet.convertToBinary(hex: input[0])
let generic = Packet(data: binary)

if generic.typeId() == 4 {
  let literal = LiteralPacket(data: binary)
  print(literal.value())
} else {
  if generic.bitAt(index: 6) == "0" {
    let length = LengthOperatorPacket(data: binary)
    print(length.value())
  } else {
    let count = CountOperatorPacket(data: binary)
    print(count.value())
  }
}


AOC.printElapsedTimeFrom(start: start)
