//
//  DocumentParser.swift
//  CHCSVParser
//
//  Created by Dave DeLong on 9/19/15.
//
//

import Foundation

internal struct DocumentParser {
    let recordParser = RecordParser()
    
    func parse(stream: PeekingGenerator<Character>, configuration: CSVParserConfiguration) throws {
        let disposition = configuration.onBeginDocument?() ?? .Continue
        
        guard disposition == .Continue else {
            configuration.onEndDocument?()
            return
        }
        
        var currentLine: UInt = 0
        while stream.peek() != nil {
            let recordDisposition = try recordParser.parse(stream, configuration: configuration, line: currentLine)
            if recordDisposition == .Cancel { break }
            
            currentLine++
            
            guard stream.peek() == nil || stream.peek()?.isNewline == true else {
                throw CSVError(kind: .UnexpectedRecordTerminator, line: currentLine, field: 0, characterIndex: stream.currentIndex)
            }
            
            stream.next() // consume the newline
        }
        
        configuration.onEndDocument?()
    }
}
