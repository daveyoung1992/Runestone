//
//  EditorLayoutManager.swift
//  
//
//  Created by Simon Støvring on 01/12/2020.
//

import UIKit
import RunestoneObjC

protocol EditorLayoutManagerDelegate: AnyObject {
    func numberOfLinesIn(_ layoutManager: EditorLayoutManager) -> Int
    func editorLayoutManagerShouldEnumerateLineFragments(_ layoutManager: EditorLayoutManager) -> Bool
    func editorLayoutManagerDidEnumerateLineFragments(_ layoutManager: EditorLayoutManager)
    func editorLayoutManager(_ layoutManager: EditorLayoutManager, didEnumerate lineFragment: EditorLineFragment)
    func editorLayoutManager(_ layoutManager: EditorLayoutManager, shouldEnsureLayoutForGlyphRange glyphRange: NSRange)
}

final class EditorLayoutManager: NSLayoutManager {
    var font: UIFont?
    weak var editorDelegate: EditorLayoutManagerDelegate?

    private weak var editorTextStorage: EditorTextStorage?

    init(textStorage: EditorTextStorage) {
        self.editorTextStorage = textStorage
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func glyphRange(forBoundingRect bounds: CGRect, in container: NSTextContainer) -> NSRange {
        var range = super.glyphRange(forBoundingRect: bounds, in: container)
        if let textStorage = textStorage,
           range.length == 0,
           bounds.intersects(extraLineFragmentRect),
           let numberOfLines = editorDelegate?.numberOfLinesIn(self),
           numberOfLines > 1 {
            // Setting the range to the last character in the textStorage when dealing with the extra
            // line ensures that the layout manager has the correct size when drawing its background.
            // Thanks for sharing this snippet Alexsander Akers (http://twitter.com/a2)
            range = NSRange(location: textStorage.length - 1, length: 1)
        }
        return range
    }

    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        guard let editorDelegate = editorDelegate, editorDelegate.editorLayoutManagerShouldEnumerateLineFragments(self) else {
            return
        }
        enumerateLineFragments(forGlyphRange: glyphsToShow) { [weak self] rect, usedRect, textContainer, glyphRange, stop in
            if let self = self {
                let lineFragment = EditorLineFragment(rect: rect, usedRect: usedRect, textContainer: textContainer, glyphRange: glyphRange)
                self.editorDelegate?.editorLayoutManager(self, didEnumerate: lineFragment)
            }
        }
        editorDelegate.editorLayoutManagerDidEnumerateLineFragments(self)
    }

    override func setExtraLineFragmentRect(_ fragmentRect: CGRect, usedRect: CGRect, textContainer container: NSTextContainer) {
        if let font = font {
            var modifiedFragmentRect = fragmentRect
            modifiedFragmentRect.size.height = font.lineHeight
            super.setExtraLineFragmentRect(modifiedFragmentRect, usedRect: usedRect, textContainer: container)
        } else {
            super.setExtraLineFragmentRect(fragmentRect, usedRect: usedRect, textContainer: container)
        }
    }

    override func setLineFragmentRect(_ fragmentRect: CGRect, forGlyphRange glyphRange: NSRange, usedRect: CGRect) {
        let substring = editorTextStorage?.substring(in: glyphRange)
        if let font = font, substring == Symbol.lineFeed {
            var modifiedFragmentRect = fragmentRect
            modifiedFragmentRect.size.height = font.lineHeight
            var modifiedUsedRect = usedRect
            modifiedUsedRect.size.height = font.lineHeight
            super.setLineFragmentRect(modifiedFragmentRect, forGlyphRange: glyphRange, usedRect: modifiedUsedRect)
        } else {
            super.setLineFragmentRect(fragmentRect, forGlyphRange: glyphRange, usedRect: usedRect)
        }
    }

    override func ensureLayout(forGlyphRange glyphRange: NSRange) {
        editorDelegate?.editorLayoutManager(self, shouldEnsureLayoutForGlyphRange: glyphRange)
        super.ensureLayout(forGlyphRange: glyphRange)
    }
}
