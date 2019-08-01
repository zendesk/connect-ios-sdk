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


/// Creates `URL`s in a application subirectory for Connect, as well as creating `FileHandle`s for those `URL`s.
///
/// - failedToGetApplicationSupport: Thrown when `FileUtility` is unable to get a `URL` for the application support directory.
/// - failedToCreateHandle: Thrown when `FileUtility` fails to create a `FileHandle`.
enum FileUtility: Error {
    
    case failedToGetApplicationSupport
    case failedToCreateHandle
    
    
    /// Creates a file `URL` in a directory of the application support directory.
    ///
    /// - Returns: A file `URL` with the last component being the name provided.
    /// - Throws: `FileUtility.failedToGetApplicationSupport`.
    static func url(name: String) throws -> URL {
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw FileUtility.failedToGetApplicationSupport
        }
        return url.appendingPathComponent("zendesk/connect/\(name)")
    }
    
    
    /// Creates a `FileHandle` for the given `URL`. This will attempt to create a file
    /// if no file exists at the provided `URL`.
    ///
    /// - Parameter url: File `URL` for creating the `FileHandle`.
    /// - Returns: A `FileHandle` for the given `URL`.
    /// - Throws: `FileUtility.failedToCreateHandle`.
    static func handle(url: URL) throws -> FileHandle {
        do {
            let handle = try FileHandle(forUpdating: url)
            Logger.debug("Created handle for \(url.lastPathComponent) file.")
            return handle
        } catch {
            Logger.debug("Failed to create handle for \(url.lastPathComponent) file. Attempting to create file at URL: \(url)")
            do {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                
                try "".data(using: .utf8)?.write(to: url, options: .withoutOverwriting)
                let handle = try FileHandle(forUpdating: url)
                Logger.debug("Created handle for \(url.lastPathComponent) file.")
                return handle
            } catch {
                throw FileUtility.failedToCreateHandle
            }
        }
    }
}
