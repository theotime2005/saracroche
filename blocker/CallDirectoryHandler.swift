//
//  CallDirectoryHandler.swift
//  blocker
//

import CallKit
import Foundation

class CallDirectoryHandler: CXCallDirectoryProvider {

  let sharedUserDefaults = UserDefaults(suiteName: "group.com.cbouvat.saracroche")

  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    context.delegate = self

    if context.isIncremental {
      let action = sharedUserDefaults?.string(forKey: "action")

      if action == "reset" {
        print("Resetting all entries")
        context.removeAllBlockingEntries()
        context.removeAllIdentificationEntries()
      }

      if action == "addPrefix" {
        var blockedNumbers = Int64(sharedUserDefaults?.integer(forKey: "blockedNumbers") ?? 0)
        let start = Int64(sharedUserDefaults?.integer(forKey: "prefixesStart") ?? 0)
        let end = Int64(sharedUserDefaults?.integer(forKey: "prefixesEnd") ?? 0)
        
        if start != 0 && end != 0 {
          print("Blocking numbers from \(start) to \(end)")
          for number in start...end {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
            
            blockedNumbers += 1
            
            if blockedNumbers % 100000 == 0 {
              sharedUserDefaults?.set(blockedNumbers, forKey: "blockedNumbers")
            }
          }
        }
      }
    }

    context.completeRequest()
  }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

  func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error)
  {
    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
  }

}
