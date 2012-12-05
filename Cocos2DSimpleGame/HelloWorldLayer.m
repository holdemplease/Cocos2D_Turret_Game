//
//  HelloWorldLayer.m
//  Cocos2DSimpleGame
//
//  Created by Jeremiah Anderson on 12/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
// sound effects baby!
#import "SimpleAudioEngine.h"

// Import OUR interfaces
#import "HelloWorldLayer.h"
#import "GameOverScene.h"
#import "Monster.h"
#import "LevelManager.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) update:(ccTime)dt
{
    NSMutableArray* projectilesToDelete = [[NSMutableArray alloc] init];
    for(CCSprite* projectile in _projectiles)
    {
        // draw a rectangle corresponding to the projectile's current position
        //CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2), 
          //                                 projectile.position.y - (projectile.contentSize.height/2), 
          //                                 projectile.contentSize.width, 
          //                                 projectile.contentSize.height);
        // no need to use above since
        // bounding box is the same as a CGRect created from the image dimensions
        //CGRect projectileRect = projectile.boundingBox;

        //CGRectEqualToRect(aProjectileRect, projectileRect) ? NSLog(@"Rects ARE equal") : NSLog(@"Rects NOT equal");
        
        BOOL monsterHit = false;
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for(Monster* monster in _monsters)
        {
            if(CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox))
            {
                monsterHit = true;
                monster.hp--;
                if(monster.hp <= 0)
                    [monstersToDelete addObject:monster];
                break;
            }
            // draw a rectangle corresponding to the target's current position
            //CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2),
              //                             target.position.y - (target.contentSize.height/2),
              //                             target.contentSize.width,
              //                             target.contentSize.height);
            //CGRect monsterRect = monster.boundingBox;
            //if(CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox))
               // [monstersToDelete addObject:monster];
        }
        
        for(Monster* monster in monstersToDelete)
        {
            [_monsters removeObject:monster];
            [self removeChild:monster cleanup:YES];
            
            // THIS COULD TRANSITION OUR "SCENE" ABRUPTLY, WIN //
            _projectilesDestroyed++;
            if(_projectilesDestroyed > 2)
            {
                //GameOverScene* gameOverScene = [GameOverScene node];  // old
                GameOverScene* gameOverScene = [[GameOverScene alloc] initWithWon:YES];
                _projectilesDestroyed = 0;
                // WHY doesn't GameOverLayer's code in init constructor not run BEFORE these next lines???
                // STUDY: Assuming that all actions of a scene (the new GameOverScene) are placed on a queue until the scene is transitioned to in code as below's CCDirector replaceScene call???

               // [gameOverScene.layer.label setString:@"You Win!"]; // CHECK
                [[CCDirector sharedDirector] replaceScene:gameOverScene]; // CHECK
            }
            
        }
        
        if(monsterHit)
        {
            [projectilesToDelete addObject:projectile];
            [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.caf"];
        }
        if(monstersToDelete.count > 0)
            [projectilesToDelete addObject:projectile];
        [monstersToDelete release];
    }
    
    for(CCSprite* projectile in projectilesToDelete)
    {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
        
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_nextProjectile != nil) return;
    
    // Choose one of the touches to work with
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];  // GCPoint is a simple struct with x, y position
    location = [[CCDirector sharedDirector] convertToGL:location]; // converts the coordinate to current layout (landscape)
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize]; // method name winSize same as our variable name winSize

    _nextProjectile = [[CCSprite spriteWithFile:@"Projectile2.jpg"] retain];
    _nextProjectile.position = ccp(20, winSize.height/2);
    
//    CCSprite* projectile = [CCSprite spriteWithFile:@"Projectile2.jpg"]; //retain];
//    projectile.position = ccp(20, winSize.height/2); // position projectile in center left side of screen
    
    // Determine offset of location to projectile
    int offX = location.x - _nextProjectile.position.x;
    int offY = location.y - _nextProjectile.position.y;
    
    // Bail out if we are shooting down or backwards
    if (offX <= 0) return;
    
    // Sound effect for the projectile!
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    
    // Determine where we wish to shoot the projectile to
    int realX = winSize.width + (_nextProjectile.contentSize.width/2);
    float ratio = (float) offY / (float) offX;
    int realY = (realX * ratio) + _nextProjectile.position.y;
    CGPoint realDest = ccp(realX, realY);   // put the destination in the CGPoint struct
    
    // Determine the length of how far we're shooting
    int offRealX = realX - _nextProjectile.position.x;
    int offRealY = realY - _nextProjectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    // Determine angle for turret to face
    // basic trig stuff using touch info a character position calculations from above
    float angleRadians = atanf((float)offRealY / (float)offRealX);
    float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
    float cocosAngle = -1 * angleDegrees;
    float rotateSpeed = 3 / M_PI; // Would take 0.5 seconds to rotate 0.5 radians, or half a circle
    float rotateDuration = fabs(angleRadians * rotateSpeed);    
    //_player.rotation = cocosAngle;  // Simple rotation member variable NOT a method call, so it's a constant state not an action  // old style before turret

    // IMPORTANT STUDY It looks like this code is reached during the before the execution of the rotation runAction, but that
    // it's just queued in the Sprite until _nextProjective is is added as a child of our layer/scene nodes,
    // when then all the runActions are performed in sequence.
    // This was verified by placing the _nextProjectile runAction before the _player runAction code

    // Queue Move projectile to actual endpoint
    [_nextProjectile runAction:[CCSequence actions:
                                [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                                [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                                nil]];

    // tag it so it can be removed from the correct array later when it hits a dude or goes off screen in spriteMoveFinished()
    _nextProjectile.tag = 2;
    
    // STUDY this runAction uses CCCallFunc, next runAction uses CCCallFuncN - what is the difference?
    [_player runAction:[CCSequence actions:
                        [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
                        [CCCallFunc actionWithTarget:self selector:@selector(finishShoot)],
                        nil]];
}

-(void) finishShoot
{
    // Ok to add now - we've finished rotation!
    [self addChild:_nextProjectile];
    [_projectiles addObject:_nextProjectile];
    
    // STUDY OK, this release is confusing. So we are releasing just the pointer? not the allocated memory?
    // does addObject above make a copy of the object or does it point to the same place in memory?
    // release
    [_nextProjectile release];
    _nextProjectile = nil;
}

// how does this method get the (id) passed in? why is no parameter passed in selector:@selector(spriteMoveFinished:) above?
-(void) spriteMoveFinished:(id)sender
{
    CCSprite* sprite = (CCSprite*)sender;

    if(sprite.tag == 1) // target sprite
    {
        [_monsters removeObject:sprite];

        // THIS COULD TRANSITION OUR "SCENE" ABRUPTLY, LOSE //
        // Since this code will only be reached for targets (enemies) if their move is completed and they get past you
        //GameOverScene* gameOverScene = [GameOverScene node];
        GameOverScene* gameOverScene = [[GameOverScene alloc] initWithWon:NO];
        //[gameOverScene.layer.label setString:@"You Lose :("];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }
    else if(sprite.tag == 2) // projectile sprite
        [_projectiles removeObject:sprite];
    
    [self removeChild:sprite cleanup:YES];  // pop the sprite off the layer node

}

-(void) addTarget 
{
    // create enemy sprite
    //CCSprite* target = [CCSprite spriteWithFile:@"Target.png"]; //retain]; // old way
    Monster* monster = nil;
    if(arc4random() % 2 == 0)  // 50% chance for to spawn each type of monster!
        monster = [[[WeakAndFastMonster alloc] init] autorelease];
    else
        monster = [[[StrongAndSlowMonster alloc] init] autorelease];
    
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = monster.contentSize.height/2;
    int maxY = winSize.height - monster.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;

    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = ccp(winSize.width + (monster.contentSize.width/2), actualY);
    [self addChild:monster];
    
    // Determine speed of target
    int minDuration = monster.minMoveDuration; // 2.0 old
    int maxDuration = monster.maxMoveDuration; // 4.0 old
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-monster.contentSize.width/2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    // now that we're done playing with our target sprite, add it to the member array
    monster.tag = 1;
    [_monsters addObject:monster];
}

// how does this method get the (ccTime) passed in? why is no parameter passed in init's schedule:@selector(gameLogic:)
-(void) gameLogic:(ccTime)dt
{
    [self addTarget];
}


-(id) init
{
//    if((self = [super initWithColor:ccc4(255, 255, 255, 255)]))  // old
    if ((self = [super initWithColor:[LevelManager sharedInstance].curLevel.backgroundColor]))
    {
        // initialize member variables
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // startup the music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        
        // create our sprite
        // STUDY WTF is retain/assing/copy - something to do with memory management and who / what manages it...
        // STUDY do we need to call retain on the sprites or not??
        // STUDY auother uses retain on the player sprite, but calls to nothing for the other sprites. WTF?
        _player = [[CCSprite spriteWithFile:@"Player2.jpg"] retain];
        _player.position = ccp(_player.contentSize.width/2, winSize.height/2);
        [self addChild:_player];
                
        // schedules the callback function gameLogic to be called every interval (1.0) seconds
        //[self schedule:@selector(gameLogic:) interval:1.0]; // old
        [self schedule:@selector(gameLogic:) interval:[LevelManager sharedInstance].curLevel.secsPerSpawn];  // new
        // STUDY HOW often / what determines when the update function is called?
        [self schedule:@selector(update:)]; // this supposedly schedules the udpate method to run as often as possible
        self.isTouchEnabled = YES;  // enable touch events!
    }
    return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{

    // in case you have something to dealloc, do it in this method
	// cocos2d will automatically release all the children (Label)

    [_monsters release];
    _monsters = nil;
    // STUDY: these projectiles could be children of the layer node, yet we release them before dealloc'ing the parent.
    // Doesn't this mean that our "parent" layer node has a bad reference right after this release?
    // Hopefully this kind of thing will not have to worry about using the automatic memory management version
    [_projectiles release];
    _projectiles = nil;
	[_player release];  // you can only release objects that have been "retained" with the retain method call, ie, Sprites
    _player = nil;
    
    // don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
