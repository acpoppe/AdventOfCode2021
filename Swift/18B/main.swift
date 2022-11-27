//
//  main.swift
//  18B
//
//  Created by Allison Poppe - Work on 25.11.22.
//

import Foundation

let fileName = "input"

let start = AOC.startTimer()

class Pair: NSObject {
    var left: PairPart {
        didSet {
            if case .pair(let nestedPair) = left {
                nestedPair.parent = self
            }
        }
    }
    var right: PairPart {
        didSet {
            if case .pair(let nestedPair) = right {
                nestedPair.parent = self
            }
        }
    }
    weak var parent: Pair?
    
    init(left: PairPart, right: PairPart, parent: Pair? = nil) {
        self.left = left
        self.right = right
        
        super.init()
        
        if case .pair(let nestedPair) = left {
            nestedPair.parent = self
        }
        if case .pair(let nestedPair) = right {
            nestedPair.parent = self
        }
    }
    
    override var description: String {
        return "[\(left.description),\(right.description)]"
    }
    
    var level: Int {
        guard let parent = parent else { return 0 }
        return parent.level + 1
    }
    
    var hasLiteralValue: Bool {
        if case .number = left {
            return true
        }
        if case .number = right {
            return true
        }
        return false
    }
    
    var copy: Pair {
        Pair(left: left.copy, right: right.copy)
    }

    var magnitude: Int {
        3 * left.magnitude + 2 * right.magnitude
    }
    
    var inorder: [Pair] {
        var leftInOrder: [Pair] {
            if case .pair(let pair) = left {
                return pair.inorder
            }
            return []
        }
        
        var rightInOrder: [Pair] {
            if case .pair(let pair) = right {
                return pair.inorder
            }
            
            return []
        }
        
        return leftInOrder + [self] + rightInOrder
    }
}

indirect enum PairPart: Equatable {
    case number(Int)
    case pair(Pair)
    
    var description: String {
        switch self {
        case .number(let value): return value.description
        case .pair(let pair): return pair.description
        }
    }
    
    var magnitude: Int {
        switch self {
        case .number(let value): return value
        case .pair(let pair): return pair.magnitude
        }
    }
    
    var copy: Self {
        switch self {
        case .number: return self
        case .pair(let pair): return .pair(pair.copy)
        }
    }
}

func explode(_ pair: Pair, in root: Pair) -> Bool {
    guard pair.level >= 4,
          case .number(let leftVal) = pair.left,
          case .number(let rightVal) = pair.right
    else {
        return false
    }
    
    let leafNodes = root.inorder
    if let next = leafNodes.drop(while: { $0 != pair }).dropFirst().first(where: { $0.hasLiteralValue }) {
        if case .number(let val) = next.left { next.left = .number(val + rightVal) }
        else if case .number(let val) = next.right { next.right = .number(val + rightVal) }
    }
    if let previous = leafNodes.reversed().drop(while: { $0 != pair }).dropFirst().first(where: { $0.hasLiteralValue }) {
        if case .number(let val) = previous.right { previous.right = .number(val + leftVal) }
        else if case .number(let val) = previous.left { previous.left = .number(val + leftVal) }
    }
    
    if case .pair(pair) = pair.parent?.left {
        pair.parent?.left = .number(0)
    } else {
        pair.parent?.right = .number(0)
    }
    return true
}

func split(_ pair: Pair) -> Bool {
    if case .number(let val) = pair.left, val >= 10 {
        pair.left = .pair(
            Pair(
                left: .number(Int((Double(val) / 2).rounded(.down))),
                right: .number(Int((Double(val) / 2).rounded(.up)))
            )
        )
        return true
    } else if case .number(let val) = pair.right, val >= 10 {
        pair.right = .pair(
            Pair(
                left: .number(Int((Double(val) / 2).rounded(.down))),
                right: .number(Int((Double(val) / 2).rounded(.up)))
            )
        )
        return true
    }
    return false
}

func reduce(_ root: Pair) -> Bool {
    // If any pair is nested inside four pairs, the leftmost such pair explodes.
    for pair in root.inorder {
        if explode(pair, in: root) {
            return true
        }
    }
    // If any regular number is 10 or greater, the leftmost such regular number splits.
    for pair in root.inorder {
        if split(pair) {
            return true
        }
    }
    
    // Nothing else needs to be done
    return false
}

func parse(_ input: inout Substring) -> Pair {
    input.removeFirst()
    
    var left: PairPart
    if input.first == "[" {
        left = .pair(parse(&input))
    } else {
        var number = 0
        while input.first!.isWholeNumber {
            number *= 10
            number += input.removeFirst().wholeNumberValue!
        }
        left = .number(number)
    }
    
    input.removeFirst()
    
    var right: PairPart
    if input.first == "[" {
        right = .pair(parse(&input))
    } else {
        var number = 0
        while input.first!.isWholeNumber {
            number *= 10
            number += input.removeFirst().wholeNumberValue!
        }
        right = .number(number)
    }
    
    input.removeFirst()
    
    return Pair(left: left, right: right)
}

let pairs = AOC.getRawInputFromBundleFile(fileName)
    .split(separator: "\n")
    .map { line -> Pair in
        var copy = line
        return parse(&copy)
    }

var maxMagnitude = Int.min

for pair in pairs {
    for other in pairs {
        guard pair != other else { continue }
        let root = Pair(left: .pair(pair.copy), right: .pair(other.copy))
        while reduce(root) {}
        maxMagnitude = max(maxMagnitude, root.magnitude)
    }
}

print(maxMagnitude.description)

AOC.printElapsedTimeFrom(start: start)
