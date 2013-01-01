//
//  NSObject_NSLog.h
//  CoolIdeas
//
//  Created by Pengjun Gong on 6/28/12.
//  Copyright (c) 2012 Children's Story. All rights reserved.
//

#import <Foundation/NSObjCRuntime.h>

#define NSDEBUG 0

#if NSDEBUG
    #undef NSLog
    #define NSLog(...) NSLog(__VA_ARGS__)
#else
    #undef NSLog
    #define NSLog(...) do{}while(0)
#endif

#define NSTrace() NSLog(@"%s,%d",__FUNCTION__,__LINE__)
