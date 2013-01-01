//
//  HelloWorldLayer.h
//  SpriteSheet Unpacker
//
//  Created by Gong Pengjun on 12-12-31.
//  Copyright www.gongpengjun.com ©2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface SpritePreviewLayer : CCLayer
{
    CCSprite* _background;
    CCSprite* _sprite;
    NSString* _spriteName;
}

@property (retain) NSString* spriteName;

- (void)updateSpriteNamed:(NSString*)spriteName;

- (void)genBackground;
- (void)genSprite;
- (BOOL)saveSpriteToPath:(NSString*)path;
- (BOOL)saveAllSpriteToFloder:(NSString*)folder;
- (void)animateSprites:(NSArray*)spriteNameArray delayPerUnit:(float)delayPerUnit;

@end
