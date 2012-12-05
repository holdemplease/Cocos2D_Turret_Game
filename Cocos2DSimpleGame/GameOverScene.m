//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Jeremiah Anderson on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameOverScene.h"
#import "HelloWorldLayer.h"
#import "LevelManager.h"

// GameOverScene IMPLEMENTATION HERE - separate to other file later

@implementation GameOverScene
@synthesize layer = _layer;

- (id)initWithWon:(BOOL)won 
{
    if((self = [super init]))
    {
        // just makes a layer GameOverLayer and adds it to ourself (the GameOverScene)
//        self.layer = [GameOverLayer node]; // instantiation causes init (constructor) below to be implemented
        self.layer = [[GameOverLayer alloc] initWithWon:won]; // instantiation causes init (constructor) below to be implemented

        [self addChild:_layer];
        // [self addChild:[self layer]]; // STUDY, could have used this instead, using getter method instead of directly referring to the _layer member variable
    }
    return self;
}

-(void) dealloc
{
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end


// GameOverLayer IMPLEMENTATION HERE - separate to other file later
@implementation GameOverLayer
@synthesize label = _label;

-(id) init
{
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
        _label.color = ccc3(0,0,0);
        _label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_label];
        
        // WHY doesn't this run BEFORE HelloWorldLayer.m 's setting of the label text and scene transition???
        // STUDY: Assuming that all actions of a scene are placed on a queue until the scene is transitioned to???
        [self runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:3],
                         [CCCallFunc actionWithTarget:self selector:@selector(gameOverDone)],
                         nil]];
        
    }	
    return self;
}

- (id)initWithWon:(BOOL)won 
{
    if ((self = [super initWithColor:ccc4(255, 255, 255, 255)]))
    {    
        NSString * message;
        if(won)
        {
            [[LevelManager sharedInstance] nextLevel];
            Level* curLevel = [[LevelManager sharedInstance] curLevel];
            if(curLevel)
                message = [NSString stringWithFormat:@"Get ready for level %d!", curLevel.levelNum];
            else
            {
                message = @"You won!";
                [[LevelManager sharedInstance] reset];
            }
        } else {
            message = @"You Lose :[";
            [[LevelManager sharedInstance] reset];
        }
            
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF* label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:16];
        label.color = ccc3(0,0,0);
        label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:label];
     
        [self runAction:
         [CCSequence actions:
          [CCDelayTime actionWithDuration:3],
          [CCCallBlockN actionWithBlock:^(CCNode *node) {
             [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
         }],
          nil]];
        
    }
    return self;
}

- (void)gameOverDone {
    
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    
}

- (void)dealloc {
    [_label release];
    _label = nil;
    [super dealloc];
}

@end