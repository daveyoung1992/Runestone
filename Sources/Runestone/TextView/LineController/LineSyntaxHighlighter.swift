import CoreGraphics
import Foundation
import UIKit

extension NSAttributedString.Key {
    static let isBold = NSAttributedString.Key("runestone_isBold")
    static let isItalic = NSAttributedString.Key("runestone_isItalic")
}

struct LineSyntaxHiglighterSetAttributesResult {
    let isSizingInvalid: Bool
}

final class LineSyntaxHighlighterInput {
    let attributedString: NSMutableAttributedString
    let byteRange: ByteRange

    init(attributedString: NSMutableAttributedString, byteRange: ByteRange) {
        self.attributedString = attributedString
        self.byteRange = byteRange
    }
}

protocol LineSyntaxHighlighter: AnyObject {
    typealias AsyncCallback = (Result<Void, Error>) -> Void
    var theme: any Theme { get set }
    var font: UIFont { get set }
    var canHighlight: Bool { get }
    func syntaxHighlight(_ input: LineSyntaxHighlighterInput)
    func syntaxHighlight(_ input: LineSyntaxHighlighterInput, completion: @escaping AsyncCallback)
    func cancel()
}
