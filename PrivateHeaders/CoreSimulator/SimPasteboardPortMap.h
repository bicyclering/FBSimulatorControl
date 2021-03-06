//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Feb 20 2016 22:04:40).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2015 by Steve Nygard.
//

#import <objc/NSObject.h>

@class NSArray;
@class NSMutableDictionary;
@protocol OS_dispatch_queue;

@interface SimPasteboardPortMap : NSObject
{
    NSArray *_pasteboardItems;
    NSMutableDictionary *_portToProxyMap;
    NSObject<OS_dispatch_queue> *_concurrentQueue;
}

+ (id)sharedManager;
@property (retain, nonatomic) NSObject<OS_dispatch_queue> *concurrentQueue;
@property (retain, nonatomic) NSMutableDictionary *portToProxyMap;
@property (nonatomic, copy) NSArray *pasteboardItems;
- (void).cxx_destruct;
- (id)createPortKey:(unsigned int)arg1;
- (void)setValue:(id)arg1 forPort:(unsigned int)arg2;
- (id)lookupWith:(unsigned int)arg1;
- (id)description;
- (id)init;

@end
