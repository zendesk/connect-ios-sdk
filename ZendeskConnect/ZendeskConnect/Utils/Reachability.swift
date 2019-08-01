/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import SystemConfiguration
import Foundation


/// Configure reachability for testing or production.
protocol ReachabilityConfig {
    
    /// The implementation of `HostStatus` to use.
    static var statusType: HostStatus.Type {get}
}

protocol HostStatus {
    
    /// By default this returns whether the provided host is reachable.
    /// `SCNetworkReachabilityFlags` can be passed in the flags param to test for
    /// other statuses.
    ///
    /// - Parameters:
    ///   - host: The host to test against.
    ///   - flags: Flags to check for, defaults to .reachable.
    /// - Returns: Whether the network rechability of the host contains all of the flags.
    static func status(for host: String, flags: SCNetworkReachabilityFlags) -> Bool
}

extension HostStatus where Self: ReachabilityConfig {
    internal static func status(for host: String, flags: SCNetworkReachabilityFlags = .reachable) -> Bool {
        return statusType.status(for: host, flags: flags)
    }
}


/// Used for testing only.
enum TestingStatus: HostStatus {
    static var reachable = false
    static func status(for host: String, flags: SCNetworkReachabilityFlags = .reachable) -> Bool {
        return reachable
    }
}


/// Actual reachability implementation.
/// Tests against flags returned by `SCNetworkReachabilityGetFlags`.
enum ProductionStatus: HostStatus {
    
    static func status(for host: String, flags: SCNetworkReachabilityFlags = .reachable) -> Bool {
        guard let ref = SCNetworkReachabilityCreateWithName(nil, host) else { return false }
        var networkFlags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(ref, &networkFlags)
        return networkFlags.contains(flags)
    }
}

/// Check the reachability status of a host.
enum Reachability: HostStatus, ReachabilityConfig {
    
    /// Defaults to false. For testing this can be flipped
    /// to optionally use TestingStatus in unit tests.
    #if DEBUG
    static var testing = false
    #else
    static let testing = false
    #endif

    static var statusType: HostStatus.Type {
        return testing ? TestingStatus.self : ProductionStatus.self
    }
}
