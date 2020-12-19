//
//  Parser.swift
//  
//
//  Created by Simon Støvring on 05/12/2020.
//

import TreeSitter

public protocol ParserDelegate: AnyObject {
    func parser(_ parser: Parser, substringAtByteIndex byteIndex: uint, point: SourcePoint) -> String?
}

public final class Parser {
    public weak var delegate: ParserDelegate?
    public var language: Language? {
        didSet {
            if language !== oldValue {
                if let language = language {
                    ts_parser_set_language(parser, language.pointer)
                } else {
                    ts_parser_set_language(parser, nil)
                }
            }
        }
    }
    public private(set) var latestTree: Tree?

    private let encoding: SourceEncoding
    private var parser: OpaquePointer
    private var query: Query?

    public init(encoding: SourceEncoding) {
        self.encoding = encoding
        self.parser = ts_parser_new()
    }

    deinit {
        ts_parser_delete(parser)
    }

    public func parse(_ string: String) {
        let newTreePointer = string.withCString { stringPointer in
            return ts_parser_parse_string(parser, latestTree?.pointer, stringPointer, UInt32(string.count))
        }
        if let newTreePointer = newTreePointer {
            latestTree = Tree(newTreePointer)
        }
    }

    public func parse() {
        let input = SourceInput(encoding: encoding) { [weak self] byteIndex, point in
            if let self = self {
                let str = self.delegate?.parser(self, substringAtByteIndex: byteIndex, point: point)
                return str?.cString(using: self.encoding.swiftEncoding)?.dropLast() ?? []
            } else {
                return nil
            }
        }
        let newTreePointer = ts_parser_parse(parser, latestTree?.pointer, input.rawInput)
        input.deallocate()
        if let newTreePointer = newTreePointer {
            latestTree = Tree(newTreePointer)
        }
    }

    @discardableResult
    public func apply(_ inputEdit: InputEdit) -> Bool {
        if let latestTree = latestTree {
            latestTree.apply(inputEdit)
            return true
        } else {
            return false
        }
    }
}
