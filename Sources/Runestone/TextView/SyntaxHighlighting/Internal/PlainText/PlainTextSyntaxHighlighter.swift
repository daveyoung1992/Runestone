import CoreGraphics
import Foundation
import UIKit

final class PlainTextSyntaxHighlighter: LineSyntaxHighlighter {
    var theme: any Theme = DefaultTheme()
    var font: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular)
    var kern: CGFloat = 0
    var canHighlight: Bool {
        false
    }

    func syntaxHighlight(_ input: LineSyntaxHighlighterInput) {}

    func syntaxHighlight(_ input: LineSyntaxHighlighterInput, completion: @escaping AsyncCallback) {
        completion(.success(()))
    }

    func cancel() {}
}
