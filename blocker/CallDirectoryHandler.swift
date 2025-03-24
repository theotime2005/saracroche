//
//  CallDirectoryHandler.swift
//  blocker
//

import CallKit
import Foundation

class CallDirectoryHandler: CXCallDirectoryProvider {

  let sharedUserDefaults = UserDefaults(suiteName: "group.com.cbouvat.saracroche")

  // Tableau des plages de numéros à bloquer
  static let phoneNumberRanges: [(start: Int64, end: Int64)] = [
    (33_162_000_000, 33_162_999_999),
    (33_163_000_000, 33_163_999_999),
    (33_271_000_000, 33_271_999_999),
    (33_377_000_000, 33_377_999_999),
    (33_378_000_000, 33_378_999_999),
    (33_424_000_000, 33_424_999_999),
    (33_425_000_000, 33_425_999_999),
    (33_568_000_000, 33_568_999_999),
    (33_569_000_000, 33_569_999_999),
    (33_948_000_000, 33_948_999_999),
    (33_947_500_000, 33_947_599_999),
    (33_947_600_000, 33_947_699_999),
    (33_947_700_000, 33_947_799_999),
    (33_947_800_000, 33_947_899_999),
    (33_947_900_000, 33_947_999_999),
  ]

  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    context.delegate = self

    if context.isIncremental {
      var blockedNumbers: Int64 = 0
      let totalBlockedNumbers = countAllBlockedNumbers()

      sharedUserDefaults?.set(blockedNumbers, forKey: "blockedNumbers")
      sharedUserDefaults?.set(totalBlockedNumbers, forKey: "totalBlockedNumbers")
      sharedUserDefaults?.set("start", forKey: "updateStatus")

      resetBlockPhoneNumbers(context: context)

      for range in CallDirectoryHandler.phoneNumberRanges {
        blockPhoneNumbers(
          context: context, start: range.start, end: range.end, blockedNumbers: &blockedNumbers)
      }

      sharedUserDefaults?.set("finish", forKey: "updateStatus")
      sharedUserDefaults?.set(Date(), forKey: "lastUpdate")
    }

    context.completeRequest()
  }

  func blockPhoneNumbers(
    context: CXCallDirectoryExtensionContext, start: Int64, end: Int64, blockedNumbers: inout Int64
  ) {
    for number in start...end {
      // Add the number to the blocking list
      context.addBlockingEntry(withNextSequentialPhoneNumber: number)
      // Add the number to the identification list
      context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: "🚫 démarchage")

      blockedNumbers += 1

      if blockedNumbers % 10 == 0 {
        sharedUserDefaults?.set(blockedNumbers, forKey: "blockedNumbers")
      }
    }
  }

  func resetBlockPhoneNumbers(context: CXCallDirectoryExtensionContext) {
    context.removeAllBlockingEntries()
    context.removeAllIdentificationEntries()
  }

  func countAllBlockedNumbers() -> Int64 {
    var totalCount: Int64 = 0

    // Compter tous les numéros en utilisant le tableau
    for range in CallDirectoryHandler.phoneNumberRanges {
      totalCount += (range.end - range.start + 1)
    }

    return totalCount
  }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

  func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error)
  {
    sharedUserDefaults?.set(false, forKey: "isSuccessfulUpdate")

    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
  }

}
