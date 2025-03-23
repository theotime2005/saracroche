//
//  CallDirectoryHandler.swift
//  blocker
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    let sharedUserDefaults = UserDefaults(suiteName: "group.com.cbouvat.saracroche")
    
    // Tableau des plages de numéros à bloquer
    static let phoneNumberRanges: [(start: Int64, end: Int64)] = [
        (33162000000, 33162999999),
        (33163000000, 33163999999),
        (33271000000, 33271999999),
        (33377000000, 33377999999),
        (33378000000, 33378999999),
        (33424000000, 33424999999),
        (33425000000, 33425999999),
        (33568000000, 33568999999),
        (33569000000, 33569999999),
        (33948000000, 33948999999),
        (33947500000, 33947599999),
        (33947600000, 33947699999),
        (33947700000, 33947799999),
        (33947800000, 33947899999),
        (33947900000, 33947999999)
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
                blockPhoneNumbers(context: context, start: range.start, end: range.end, blockedNumbers: &blockedNumbers, totalBlockedNumbers: totalBlockedNumbers)
            }

            sharedUserDefaults?.set("finish", forKey: "updateStatus")
            sharedUserDefaults?.set(Date(), forKey: "lastUpdate")
        }

        context.completeRequest()
    }
    
    func blockPhoneNumbers(context: CXCallDirectoryExtensionContext, start: Int64, end: Int64, blockedNumbers: inout Int64, totalBlockedNumbers: Int64) {
        for number in start...end {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
            context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: "🚫 démarchage")
            blockedNumbers += 1
            if blockedNumbers % 20000 == 0 {
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

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        sharedUserDefaults?.set(false, forKey: "isSuccessfulUpdate")
        
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
