//
//  Level.m
//  Cocos2DSimpleGame
//
//  Created by Jeremiah Anderson on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Level.h"

@implementation Level

@synthesize levelNum;
@synthesize secsPerSpawn;
@synthesize backgroundColor;

- (id)initWithLevelNum:(int)theLevelNum secsPerSpawn:(float)theSecsPerSpawn backgroundColor:(ccColor4B)theBackgroundColor
{
    if((self = [super init]))
    {
        self.levelNum = theLevelNum;
        self.secsPerSpawn = theSecsPerSpawn;
        self.backgroundColor = theBackgroundColor;
    }
    return self;
}

@end
