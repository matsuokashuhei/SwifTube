// Playground - noun: a place where people can play

import UIKit

var duration = "PT1S"

    func formatFromDuration(duration: String) -> String {
        let scanner = NSScanner(string: duration)
        scanner.charactersToBeSkipped = NSCharacterSet.letterCharacterSet()
        var scanned = [Int]()
        while !scanner.atEnd {
            var int: Int32 = 0
            scanner.scanInt(&int)
            scanned.append(Int(int))
        }
        switch scanned.count {
        case 3:
            return NSString(format: "%d:%02d:%02d", scanned[0], scanned[1], scanned[2])
        case 2:
            return NSString(format: "%d:%02d", scanned[0], scanned[1])
        case 1:
            return NSString(format: "0:%02d", scanned[0])
        default:
            return "00:00"
        }
    }

formatFromDuration(duration)