//
//  LevelManager.h
//  Cocos2DSimpleGame
//
//  Created by Jeremiah Anderson on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"

@interface LevelManager : NSObject

+ (LevelManager*) sharedInstance;
- (Level*) curLevel;
- (void) nextLevel;
- (void) reset;

@end
