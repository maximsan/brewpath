// Runs integration_test/*.dart through Xcode's own test runner: one XCTest per
// Dart test, results reported by XCTest. This is the body of the
// integration_test plugin's INTEGRATION_TEST_IOS_RUNNER macro, minus the
// screenshot attachments this app does not take.
//
// It deliberately does not `@import integration_test`. This project links its
// plugins as one static Swift package; importing it here would link a second
// copy of the plugin's classes into the test bundle, beside the copy already
// in the host app, and the two would not share the plugin instance the Dart
// tests report to. The host app's copy is reached through the runtime instead.
@import XCTest;
@import ObjectiveC.runtime;

typedef void (^BrewPathTestResult)(SEL testSelector, BOOL success, NSString *failureMessage);

/// The part of FLTIntegrationTestRunner this file calls; the class itself
/// lives in the host app.
@protocol BrewPathIntegrationTestRunner
- (void)testIntegrationTestWithResults:(BrewPathTestResult)testResult;
@end

@interface RunnerTests : XCTestCase
@end

@implementation RunnerTests

+ (NSArray<NSInvocation *> *)testInvocations {
  NSMutableArray<NSInvocation *> *testInvocations = [[NSMutableArray alloc] init];
  Class runnerClass = NSClassFromString(@"FLTIntegrationTestRunner");
  if (runnerClass == nil) {
    [testInvocations addObject:[self invocationFor:@"testIntegrationTestPluginMissing"
                                             block:^(id _self) {
      XCTFail(@"FLTIntegrationTestRunner is not in the host app: the integration_test plugin is not linked into Runner");
    }]];
    return testInvocations;
  }
  id<BrewPathIntegrationTestRunner> runner = [[runnerClass alloc] init];
  [runner testIntegrationTestWithResults:^(SEL testSelector, BOOL success, NSString *failureMessage) {
    [testInvocations addObject:[self invocationFor:NSStringFromSelector(testSelector)
                                             block:^(id _self) {
      XCTAssertTrue(success, @"%@", failureMessage);
    }]];
  }];
  return testInvocations;
}

/// Adds a test method named [name] that runs [block], and returns the
/// invocation XCTest needs to call it.
+ (NSInvocation *)invocationFor:(NSString *)name block:(void (^)(id _self))block {
  SEL selector = NSSelectorFromString(name);
  class_addMethod(self, selector, imp_implementationWithBlock(block), "v@:");
  NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  invocation.selector = selector;
  return invocation;
}

@end
