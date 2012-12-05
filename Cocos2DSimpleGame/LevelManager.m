//
//  LevelManager.m
//  Cocos2DSimpleGame
//
//  Created by Jeremiah Anderson on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LevelManager.h"

@implementation LevelManager
{
    NSArray* _levels;
    int _curLevelIdx;
}

+ (LevelManager*) sharedInstance
{
    // variables in a static method must be static
    // make sure only one LevelManager can be created ?
    static dispatch_once_t once;
    static LevelManager* sharedInstance; 
    // dispatch_once Executes a block object once and only once for the lifetime of an application.
    dispatch_once(&once, ^{               // block
        sharedInstance = [[self alloc] init];   // instantiate ourself calling init code below
    });
    return sharedInstance;
}

- (id) init
{
    if((self = [super init]))
    {
        _curLevelIdx = 0;
        Level* level1 = [[[Level alloc] initWithLevelNum:1 secsPerSpawn:2 backgroundColor:ccc4(255, 255, 255, 255)] autorelease];
        Level* level2 = [[[Level alloc] initWithLevelNum:2 secsPerSpawn:1 backgroundColor:ccc4(100, 150, 20, 255)] autorelease];
        _levels = [[NSArray arrayWithObjects:level1,level2,nil] retain];
    }
    return self;
}

- (Level*) curLevel
{
    if(_curLevelIdx >= _levels.count)
        return nil;
    return [_levels objectAtIndex:_curLevelIdx];
}

- (void) nextLevel
{
    _curLevelIdx++;
}

- (void) reset
{
    _curLevelIdx = 0;
}

- (void) dealloc
{
    [_levels release];
    _levels = nil;
    [super dealloc];
}


@end
