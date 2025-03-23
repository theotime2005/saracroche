//
//  CallDirectoryHandler.swift
//  blocker
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        if context.isIncremental {
            print("Incremental update")
            resetBlockPhoneNumbers(context: context)
            blockPhoneNumbers(context: context, start: 33162000000, end: 33162999999)
            blockPhoneNumbers(context: context, start: 33163000000, end: 33163999999)
            blockPhoneNumbers(context: context, start: 33271000000, end: 33271999999)
            blockPhoneNumbers(context: context, start: 33377000000, end: 33377999999)
            blockPhoneNumbers(context: context, start: 33378000000, end: 33378999999)
            blockPhoneNumbers(context: context, start: 33424000000, end: 33424999999)
            blockPhoneNumbers(context: context, start: 33425000000, end: 33425999999)
            blockPhoneNumbers(context: context, start: 33568000000, end: 33568999999)
            blockPhoneNumbers(context: context, start: 33569000000, end: 33569999999)
            blockPhoneNumbers(context: context, start: 33948000000, end: 33948999999)
            blockPhoneNumbers(context: context, start: 33947500000, end: 33947599999)
            blockPhoneNumbers(context: context, start: 33947600000, end: 33947699999)
            blockPhoneNumbers(context: context, start: 33947700000, end: 33947799999)
            blockPhoneNumbers(context: context, start: 33947800000, end: 33947899999)
            blockPhoneNumbers(context: context, start: 33947900000, end: 33947999999)
        } else {
            print("No incremental update")
        }

        context.completeRequest()
    }
    
    func blockPhoneNumbers(context: CXCallDirectoryExtensionContext, start: Int64, end: Int64) {
        print("Blocking numbers from \(start) to \(end)")
        for number in start...end {
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
            context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: "🚫 démarchage")
        }
    }

    func resetBlockPhoneNumbers(context: CXCallDirectoryExtensionContext) {
        context.removeAllBlockingEntries()
        context.removeAllIdentificationEntries()
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
