//
//  main.swift
//  04B
//
//  Created by Allison Poppe on 12/3/21.
//

import Foundation

struct Board {
    var boardMatrix: [[BoardCell]]
    var boardWon: Bool = false
    
    var description: String {
        var val = ""
        for row in boardMatrix {
            for cell in row {
                if (cell.isMarked) {
                    val += "\""
                }
                val += cell.value
                if (cell.isMarked) {
                    val += "\""
                }
                val += " "
            }
            val += "\n"
        }
        return val
    }
}

struct BoardCell {
    var value: String
    var isMarked: Bool = false
}

var boards: [Board] = []
var drawnNumbers: [String] = []
var winnerBoardExists = false
var lastDrawnIndex = -1
var mostRecentWinningBoardIndex = -1

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

func getBoardFromInput(_ input: String) {
    let board = input.replacingOccurrences(of: "  ", with: " ")
    let rows = board.components(separatedBy: "\n")
    var boardArray: [[BoardCell]] = []
    for row in rows {
        var rowArray: [BoardCell] = []
        let cells = row.components(separatedBy: " ")
        for cell in cells {
            let trimmedCell = cell.trimmingCharacters(in: .whitespaces)
            if (cell != "") {
                let boardCell = BoardCell(value: trimmedCell)
                rowArray.append(boardCell)
            }
        }
        boardArray.append(rowArray)
    }
    let boardStruct = Board(boardMatrix: boardArray)
    boards.append(boardStruct)
}

func markDrawnNumber(_ drawnNumber: String) {
    for (boardIndex, board) in boards.enumerated() {
        for (rowIndex, row) in board.boardMatrix.enumerated() {
            for (cellIndex, cell) in row.enumerated() {
                if (cell.value == drawnNumber) {
                    boards[boardIndex].boardMatrix[rowIndex][cellIndex].isMarked = true
                }
            }
        }
    }
}

func checkForBoardWin() -> Bool {
    var foundWin = false
    for (boardIndex, board) in boards.enumerated() {
        let boardWon = checkForHorizontalWin(board) || checkForVerticalWin(board)
        if (!boards[boardIndex].boardWon && boardWon) {
            mostRecentWinningBoardIndex = boardIndex
        }
        boards[boardIndex].boardWon = boardWon
        if (boardWon) {
            foundWin = true
            winnerBoardExists = true
        }
    }
    return foundWin
}

func checkForHorizontalWin(_ board: Board) -> Bool {
    
    var isWinBoard = false
    for rowIndex in 0..<5 {
        
        var isWinRow = true
        for columnIndex in 0..<5 {
            if (!board.boardMatrix[rowIndex][columnIndex].isMarked) {
                isWinRow = false
            }
        }
        if (isWinRow) {
            isWinBoard = true
        }
    }
    return isWinBoard
}

func checkForVerticalWin(_ board: Board) -> Bool {
    
    var isWinBoard = false
    for columnIndex in 0..<5 {
        
        var isWinRow = true
        for rowIndex in 0..<5 {
            if (!board.boardMatrix[rowIndex][columnIndex].isMarked) {
                isWinRow = false
            }
        }
        if (isWinRow) {
            isWinBoard = true
        }
    }
    return isWinBoard
}

func calculateScore() {
    for (boardIndex, board) in boards.enumerated() {
        if (board.boardWon) {
            let boardNumber = boardIndex + 1
            print("Board #\(boardNumber) Won!")
            
            var score = 0
            var unmarkedSum = 0
            for row in board.boardMatrix {
                for cell in row {
                    if (!cell.isMarked) {
                        unmarkedSum += Int(cell.value) ?? 0
                    }
                }
            }
            
            score = unmarkedSum * (Int(drawnNumbers[lastDrawnIndex]) ?? 0)
            print("Score \(score)")
        }
    }
}

func calculateScoreForBoard(_ board: Board) {
    var score = 0
    var unmarkedSum = 0
    for row in board.boardMatrix {
        for cell in row {
            if (!cell.isMarked) {
                unmarkedSum += Int(cell.value) ?? 0
            }
        }
    }
    
    score = unmarkedSum * (Int(drawnNumbers[lastDrawnIndex]) ?? 0)
    print("Score \(score)")
}


func didAllBoardsWin() -> Bool {
    var allBoardWon = true
    for board in boards {
        if (!board.boardWon) {
            allBoardWon = false
        }
    }
    return allBoardWon
}
var input = getInputFromBundleFile("input", fileType: "txt").components(separatedBy: "\n\n")
let drawnNumbersInput = input.remove(at: 0)
drawnNumbers = drawnNumbersInput.components(separatedBy: ",")

for boardInput in input {
    getBoardFromInput(boardInput)
}

for (drawIndex, _) in drawnNumbers.enumerated() {
    lastDrawnIndex += 1
    markDrawnNumber(drawnNumbers[drawIndex])
    checkForBoardWin()
    if (didAllBoardsWin()) {
        calculateScoreForBoard(boards[mostRecentWinningBoardIndex])
        print(mostRecentWinningBoardIndex + 1)
        break
    }
}
