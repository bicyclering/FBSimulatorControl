//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Feb 20 2016 22:04:40).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <CoreSimulator/NSObject-Protocol.h>

@class NSObject;
@class NSString;
@class SimPasteboardItem;
@protocol NSSecureCoding;

@protocol SimPasteboardItemDataProvider <NSObject>
- (NSObject<NSSecureCoding> *)retrieveValueForSimPasteboardItem:(SimPasteboardItem *)arg1 type:(NSString *)arg2;
@end
