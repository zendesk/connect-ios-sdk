/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation

class QueueFile {
    
    private let fileHandle: FileHandle
    private var header: FileHeader = FileHeader.default
    private var firstElement: FileElement
    private var lastElement: FileElement
    private var modQueue = DispatchQueue(label: "QueueFile-\(UUID().uuidString)")
    private let fileSizeThreshold: UInt64
    private let loadPercentage: Double
    
    var isEmpty: Bool {
        return header.elementCount == 0
    }
    
    var size: UInt {
        return header.elementCount
    }
    
    deinit {
        fileHandle.closeFile()
    }
    
    init(fileHandle: FileHandle, fileSizeThreshold: UInt64 = 4_000_000, loadPercentage: Double = 0.75) {
        self.fileHandle = fileHandle
        if fileHandle.seekToEndOfFile() != 0 {
            header = readHeader(from: fileHandle)
        }
        firstElement = readElement(at: header.firstOffset, from: fileHandle)
        lastElement = readElement(at: header.lastOffset, from: fileHandle)
        
        self.fileSizeThreshold = fileSizeThreshold
        self.loadPercentage = loadPercentage
    }
    
    func close() {
        fileHandle.closeFile()
    }
    
    func add(_ entry: Data) {
        modQueue.sync {
            
            if shouldShrink() {
                shrinkFile()
            }
            
            // offset to end of current last element
            // if we're empty we use the default value for the last element
            let newOffset = isEmpty ? lastElement.offset : lastElement.next()
            
            // create new last element
            let newLastElement = FileElement(offset: newOffset,
                                             length: entry.count)
            
            // write new element to file
            write(element: newLastElement, to: fileHandle)
            
            // write new data to file
            fileHandle.syncWrite(entry, at: newLastElement.valueOffset())
            
            // update last element to be new last element
            lastElement = newLastElement
            if isEmpty {
                firstElement = lastElement
            }
            
            // update the file header with the new last element
            header = FileHeader(elementCount: header.elementCount + 1,
                                firstOffset: firstElement.offset,
                                lastOffset: lastElement.offset)
            
            write(header: header, to: fileHandle)
        }
    }

    func peek() -> Data? {
        guard isEmpty == false else { return nil }
        return readData(fileHandle, element: firstElement)
    }
    
    func remove() {
        remove(1)
    }
    
    func remove(_ n: UInt) {
        
        let amount = Swift.min(self.size, n)
        guard amount > 0 else { return }
        let newElementCount = header.elementCount - amount
        
        guard newElementCount != 0 else {
            clear()
            return
        }
        
        modQueue.sync {
            // take the first offset
            var newFirstElementOffset = firstElement.offset
            for _ in 1...amount {
                let element = readElement(at: newFirstElementOffset, from: fileHandle)
                newFirstElementOffset = element.next()
                
                let zeros = Data(repeating: 0, count: Int(newFirstElementOffset - element.offset))
                fileHandle.syncWrite(zeros, at: element.offset)
            }
            
            // load new first element
            firstElement = readElement(at: newFirstElementOffset, from: fileHandle)
            
            // update the file header with new element count
            header = FileHeader(elementCount: newElementCount,
                                firstOffset: firstElement.offset,
                                lastOffset: lastElement.offset)
            write(header: header, to: fileHandle)
        }
    }
    
    func clear() {
        modQueue.sync {
            
            // reset elements
            lastElement = FileElement(offset: FileHeader.headerLength,
                                      length: 0)
            firstElement = lastElement
            
            // write an element to file
            // in the default state both first and last elements
            // ocupy the same space in the file
            write(element: lastElement, to: fileHandle)
            
            // truncate file
            fileHandle.truncateFile(atOffset: lastElement.valueOffset())
            
            // update the file header with new element count
            header = FileHeader(elementCount: 0,
                                firstOffset: firstElement.offset,
                                lastOffset: lastElement.offset)
            write(header: header, to: fileHandle)
        }
    }
}

extension QueueFile {
    
    private func usedBytes() -> UInt64 {
        guard header.elementCount != 0 else { return FileHeader.headerLength }
        
        return FileHeader.headerLength
            + FileElement.headerLength + UInt64(lastElement.length)
            + (lastElement.offset - firstElement.offset)
    }
    
    private func shouldShrink() -> Bool {
        let eof = fileHandle.seekToEndOfFile()
        let used = usedBytes()
        let aboveFileSizeThreshold = eof > fileSizeThreshold
        let underLoaded = used < UInt64(Double(eof) * loadPercentage)
        return aboveFileSizeThreshold && underLoaded
    }
    
    private func shrinkFile() {
        fileHandle.seek(toFileOffset: firstElement.offset)
        let contents = fileHandle.readDataToEndOfFile()
        
        let newFirstElement = FileElement(offset: FileHeader.headerLength,
                                          length: firstElement.length)
        
        let newEOF = FileHeader.headerLength + UInt64(contents.count)
        let newLastOffset = newEOF - (UInt64(lastElement.length) + FileElement.headerLength)
        let newLastElement = FileElement(offset: newLastOffset,
                                         length: lastElement.length)
        
        let newHeader = FileHeader(elementCount: header.elementCount,
                                   firstOffset: newFirstElement.offset,
                                   lastOffset: newLastElement.offset)
        
        firstElement = newFirstElement
        lastElement = newLastElement

        write(header: newHeader, to: fileHandle)
        fileHandle.seek(toFileOffset: FileHeader.headerLength)
        fileHandle.write(contents)
        fileHandle.truncateFile(atOffset: newEOF)
        
    }
}

extension QueueFile: Sequence {
    typealias Iterator = FileElementIterator
    typealias Element = Data
    
    struct FileElementIterator: IteratorProtocol {
        typealias Element = Data
        var fileHandle: FileHandle
        var fileElement: FileElement?

        mutating func next() -> Element? {
            
            guard
                let current = fileElement,
                current.isEmpty == false,
                let data = readData(fileHandle, element: current) else { return nil }

            if fileHandle.seekToEndOfFile() > current.next() {
                fileElement = readElement(at: current.next(), from: fileHandle)
            } else {
                fileElement = nil
            }

            return data
        }
    }
    
    func makeIterator() -> Iterator {
        return FileElementIterator(fileHandle: self.fileHandle, fileElement: self.firstElement)
    }
}


private extension FileHandle {
    
    /// Seeks to the offset provided before writing the data
    /// and synchronizing.
    ///
    /// - Parameters:
    ///   - data: data to write.
    ///   - offset: offset in file to write from.
    func syncWrite(_ data: Data, at offset: UInt64 = 0) {
        seek(toFileOffset: offset)
        write(data)
        synchronizeFile()
    }
    
    
    /// Checks if offset is within the bounds of the file.
    ///
    /// - Parameters:
    ///   - offset: offset to test.
    ///   - fileHandle: file to be tested.
    /// - Returns: true if the offset is within the file. false otherwise.
    func boundsCheck(_ offset: UInt64) -> Bool {
        return seekToEndOfFile() >= offset
    }
}

/// Writes an Element to the file handle. Seeks to the first possition of
/// the file and then writes the bytes of the file header to the file.
///
/// - Parameters:
///   - header: FileHeader to write.
///   - fileHandle: File to write to.
private func write(header: FileHeader, to fileHandle: FileHandle) {
    var header = header
    withUnsafeBytes(of: &header) { bytes in
        fileHandle.syncWrite(Data(bytes))
    }
}

/// Writes an Element to the file handle. Seeks to the element
/// offset and then writes the bytes of the element to the file.
///
/// - Parameters:
///   - element: Element to write.
///   - fileHandle: File to write to.
private func write(element: FileElement, to fileHandle: FileHandle) {
    var element = element
    let offset = element.offset
    withUnsafeBytes(of: &element) { bytes in
        fileHandle.syncWrite(Data(bytes), at: offset)
    }
}


/// Reads a FileHeader from the file handle.
/// Assumes a file header is found at the first position in the file.
///
/// - Parameter fileHandle: The file to read from.
/// - Returns: A file header.
private func readHeader(from fileHandle: FileHandle) -> FileHeader {
    guard let header: FileHeader = read(from: fileHandle) else {
        return FileHeader.default
    }
    return header
}


/// Reads an Element from the file handle at the offset provided.
/// Used whene reading elements specified in a FileHeader.
///
/// - Parameters:
///   - offset: Where in the file to read.
///   - fileHandle: The file to read from.
/// - Returns: An element.
private func readElement(at offset: UInt64, from fileHandle: FileHandle) -> FileElement {
    guard let element: FileElement = read(from: fileHandle, at: offset) else {
        return FileElement(offset: FileHeader.default.firstOffset,
                           length: 0)
    }
    return element
}


/// Reads a T from file handle. Seeks in the file to the offset provided,
/// reading N bytes from the file. N is determined by using MemoryLayout.size.
/// The data read from the file is then marsheled into an object using UnsafeRawBufferPointer.load().
///
/// - Parameters:
///   - fileHandle: file to read from.
///   - offset: where in the file to start reading from.
/// - Returns: a T loaded from data in the file.
private func read<T>(from fileHandle: FileHandle, at offset: UInt64 = 0) -> T? {
    let length = MemoryLayout<T>.size
    guard fileHandle.boundsCheck(offset + UInt64(length)) else { return nil }
    fileHandle.seek(toFileOffset: offset)
    var data = fileHandle.readData(ofLength: length)
    return data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
        let buffer = UnsafeRawBufferPointer.init(start: bytes, count: data.count)
        return buffer.load(as: T.self)
    }
}

/// Reads data associated with an element from the file handle.
///
/// - Parameters:
///   - fileHandle: file to read from.
///   - element: element to read.
/// - Returns: data if the element is located in the file. Nil otherwise.
private func readData(_ fileHandle: FileHandle, element: FileElement) -> Data? {
    guard fileHandle.boundsCheck(element.next()) else { return nil }
    
    fileHandle.seek(toFileOffset: element.valueOffset())
    return fileHandle.readData(ofLength: element.length)
}
