import Foundation
import UIKit

protocol HighlightNavigationControllerDelegate: AnyObject {
    func highlightNavigationController(
        _ controller: HighlightNavigationController,
        shouldNavigateTo highlightNavigationRange: HighlightNavigationRange, index: Int)
}

struct HighlightNavigationRange {
    enum LoopMode {
        case disabled
        case previousGoesToLast
        case nextGoesToFirst
    }

    let range: NSRange
    let loopMode: LoopMode
    let index: Int

    init(range: NSRange, loopMode: LoopMode = .disabled, index:Int) {
        self.range = range
        self.loopMode = loopMode
        self.index = index
    }
}

final class HighlightNavigationController {
    weak var delegate: HighlightNavigationControllerDelegate?
    var selectedRange: NSRange?
    var highlightedRanges: [HighlightedRange] = []
    var loopRanges = false

    private var previousNavigationRange: HighlightNavigationRange? {
        if let selectedRange = selectedRange {
            let reversedRanges = highlightedRanges.reversed()
            if let nextIndex = reversedRanges.firstIndex(where: { $0.range.upperBound <= selectedRange.lowerBound }){
                let nextRange = reversedRanges[nextIndex]
                return HighlightNavigationRange(range: nextRange.range, index: nextIndex.base)
            }
            else if loopRanges, let firstRange = reversedRanges.first {
                return HighlightNavigationRange(range: firstRange.range, loopMode: .previousGoesToLast, index: 0)
            } else {
                return nil
            }
        } else if let lastRange = highlightedRanges.last {
            return HighlightNavigationRange(range: lastRange.range, index: highlightedRanges.endIndex)
        } else {
            return nil
        }
    }
    private var nextNavigationRange: HighlightNavigationRange? {
        if let selectedRange = selectedRange {
            if let nextIndex = highlightedRanges.firstIndex(where: { $0.range.upperBound >= selectedRange.lowerBound }){
                let nextRange = highlightedRanges[nextIndex]
                return HighlightNavigationRange(range: nextRange.range, index: nextIndex)
            } else if loopRanges, let firstRange = highlightedRanges.first {
                return HighlightNavigationRange(range: firstRange.range, loopMode: .nextGoesToFirst,index: 0)
            } else {
                return nil
            }
        } else if let firstRange = highlightedRanges.first {
            return HighlightNavigationRange(range: firstRange.range,index: 0)
        } else {
            return nil
        }
    }

    func selectPreviousRange() {
        if let previousNavigationRange = previousNavigationRange {
            selectedRange = previousNavigationRange.range
            delegate?.highlightNavigationController(self, shouldNavigateTo: previousNavigationRange, index: previousNavigationRange.index)
        }
    }

    func selectNextRange() {
        if let nextNavigationRange = nextNavigationRange {
            selectedRange = nextNavigationRange.range
            delegate?.highlightNavigationController(self, shouldNavigateTo: nextNavigationRange, index: nextNavigationRange.index)
        }
    }

    func selectRange(at index: Int) {
        if index >= 0 && index < highlightedRanges.count {
            let highlightedRange = highlightedRanges[index]
            let navigationRange = HighlightNavigationRange(range: highlightedRange.range, index: index)
            selectedRange = highlightedRange.range
            delegate?.highlightNavigationController(self, shouldNavigateTo: navigationRange, index: index)
        } else {
            let count = highlightedRanges.count
            let countString = count == 1 ? "There is \(count) highlighted range" : "There are \(count) highlighted ranges"
            fatalError("Cannot select highlighted range at index \(index). \(countString)")
        }
    }
}
