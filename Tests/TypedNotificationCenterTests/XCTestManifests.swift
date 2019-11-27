#if !canImport(ObjectiveC)
import XCTest

extension ApiTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ApiTests = [
        ("testDeallocateObserver", testDeallocateObserver),
        ("testFail", testFail),
        ("testInvalidateObserver", testInvalidateObserver),
        ("testNotificationWithDifferentObject", testNotificationWithDifferentObject),
        ("testNotificationWithoutObject", testNotificationWithoutObject),
        ("testNotificationWithSameObject", testNotificationWithSameObject),
        ("testValidityNotificationCenterDeallocated", testValidityNotificationCenterDeallocated),
        ("testValidityRemoved", testValidityRemoved),
        ("testValiditySenderDeallocated", testValiditySenderDeallocated),
    ]
}

extension AsyncApiTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AsyncApiTests = [
        ("testSendingFromDifferentQueue", testSendingFromDifferentQueue),
        ("testSuspendedQueue", testSuspendedQueue),
        ("testSuspendedQueueNilSender", testSuspendedQueueNilSender),
    ]
}

extension BridgedNotificationApiTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__BridgedNotificationApiTests = [
        ("testCrossSendingFromNotificationCenter", testCrossSendingFromNotificationCenter),
        ("testCrossSendingFromTypedNotificationCenter", testCrossSendingFromTypedNotificationCenter),
        ("testInvalidPayload", testInvalidPayload),
        ("testInvalidSender", testInvalidSender),
        ("testSending", testSending),
    ]
}

extension PerformanceTestsPosting {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__PerformanceTestsPosting = [
        ("testPerformance_1percent_apple", testPerformance_1percent_apple),
        ("testPerformance_1percent_own", testPerformance_1percent_own),
        ("testPerformance_20percent_apple", testPerformance_20percent_apple),
        ("testPerformance_20percent_own", testPerformance_20percent_own),
        ("testPerformance_all_apple", testPerformance_all_apple),
        ("testPerformance_all_own", testPerformance_all_own),
        ("testPerformance_all_own_concurrentPost", testPerformance_all_own_concurrentPost),
    ]
}

extension PerformanceTestsSubscribing {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__PerformanceTestsSubscribing = [
        ("testPerformance_100senders_apple", testPerformance_100senders_apple),
        ("testPerformance_100senders_own", testPerformance_100senders_own),
        ("testPerformance_2senders_apple", testPerformance_2senders_apple),
        ("testPerformance_2senders_own", testPerformance_2senders_own),
        ("testPerformance_nilSenders_apple", testPerformance_nilSenders_apple),
        ("testPerformance_nilSenders_own", testPerformance_nilSenders_own),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ApiTests.__allTests__ApiTests),
        testCase(AsyncApiTests.__allTests__AsyncApiTests),
        testCase(BridgedNotificationApiTests.__allTests__BridgedNotificationApiTests),
        testCase(PerformanceTestsPosting.__allTests__PerformanceTestsPosting),
        testCase(PerformanceTestsSubscribing.__allTests__PerformanceTestsSubscribing),
    ]
}
#endif
