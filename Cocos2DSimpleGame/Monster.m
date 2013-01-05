//
//  Monster.m
//  Cocos2DSimpleGame
//
//  Created by Jeremiah Anderson on 12/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Monster.h"


@implementation Monster

@synthesize hp;
@synthesize maxMoveDuration;
@synthesize minMoveDuration;

// STUDY OVERRIDE - we are overriding the CCSprite's initWithFile method, which is why we have to call the super class's [super initWithFile:file]
- (id)initWithFile:(NSString *)file hp:(int)theHp minMoveDuration:(int)theMinMoveDuration maxMoveDuration:(int)theMaxMoveDuration
{    
    // First, initialize the CCSprite parent object (it's already instantiated) with the image file passed to the constructor (here)
    // this is the same as CCSprite* target = [CCSprite spriteWithFile:@"Target.png"], just for an already instantiated object
    if((self = [super initWithFile:file]))
    {
        self.hp = theHp;
        self.minMoveDuration = theMinMoveDuration;
        self.maxMoveDuration = theMaxMoveDuration;
    }
    return self;

}
@end


@implementation WeakAndFastMonster

- (id)init
{
    if((self = [super initWithFile:@"Monster.png" hp:1 minMoveDuration:3 maxMoveDuration:5]))
    {
        // nothin', just need to initialize the member variables
    }
    return self;
}
@end


@implementation StrongAndSlowMonster

- (id)init
{
    if((self = [super initWithFile:@"monster2.png" hp:3 minMoveDuration:6 maxMoveDuration:12]))
    {
        // nothin', just need to initialize the member variables
    }
    return self;
}
@end

