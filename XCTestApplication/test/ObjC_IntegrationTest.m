//
//  IntegrationTest.m
//  XCTestApplication
//
//  Created by Ilham Andrian on 10/21/19.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

@interface ObjC_IntegrationTest : XCTestCase

@end

@implementation ObjC_IntegrationTest

-(void)setUp
{
    [super setUp];
}

-(void)test1 {XCTAssertTrue(YES);}
-(void)test2 {XCTAssertTrue(NO);}
-(void)test3 {XCTAssertTrue(YES);}
-(void)test4 {XCTAssertTrue(NO);}
-(void)test5 {XCTAssertTrue(YES);}
-(void)test6 {
    XCTAssertTrue(NO, "This should be true");
}

-(void)testOnBackground {
    for(int i=0;i<5;i++) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"Handler should be called."];
        [self onBackgroundWithCompletionHandler:^(NSMutableArray * _Nullable result) {
            [expectation fulfill];
        }];
        [self waitForExpectations:@[expectation] timeout:1000];
    }
}

-(void)onBackgroundWithCompletionHandler:(void(^_Nonnull)(NSMutableArray * _Nullable result))completionHandler {
    NSMutableArray *data = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2.0f];
        for(int i=0;i<1000;i++) {
            [data addObject:[NSString stringWithFormat:@"test-%d", i]];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completionHandler(data);
        });
    });
}

@end
