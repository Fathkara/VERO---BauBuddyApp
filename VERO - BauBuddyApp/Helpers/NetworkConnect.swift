//
//  File.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 16.03.2023.
//

import Foundation
import Alamofire
class Connect {
    class func isConnected() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
