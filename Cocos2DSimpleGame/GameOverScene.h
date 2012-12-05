//
//  GameOverScene.h
//  Cocos2DSimpleGame
//
//  Created by Jeremiah Anderson on 12/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

// These two classes should REALLY be separated into different files for clarity and coding convention

// GameOverLayer INTERFACE
@interface GameOverLayer : CCLayerColor {
    CCLabelTTF *_label;
}
@property (nonatomic, retain) CCLabelTTF *label;

- (id)initWithWon:(BOOL)won;
- (void)gameOverDone;

@end


// GameOverScene INTERFACE
@interface GameOverScene : CCScene {
    GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;

- (id)initWithWon:(BOOL)won;

@end
