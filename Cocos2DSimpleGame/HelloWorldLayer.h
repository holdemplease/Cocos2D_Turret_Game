//
//  HelloWorldLayer.h
//  Cocos2DSimpleGame
//
//  Created by Jeremiah Anderson on 12/3/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor // <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    NSMutableArray* _monsters;
    NSMutableArray* _projectiles;
    CCSprite* _player;
    CCSprite* _nextProjectile;
    
    int _projectilesDestroyed;
}

// STUDY ordinarily in healthy code, we should make probably make getters and setters using @property here and @synthesize in .m file

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void) spriteMoveFinished:(id)sender;
-(void) addTarget;
-(void) gameLogic:(ccTime)dt;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) update:(ccTime)dt;
-(void) finishShoot;

@end
