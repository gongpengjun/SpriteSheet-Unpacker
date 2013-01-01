//
//  HelloWorldLayer.m
//  SpriteSheet Unpacker
//
//  Created by Gong Pengjun on 12-12-31.
//  Copyright www.gongpengjun.com ©2012. All rights reserved.
//


// Import the interfaces
#import "SpritePreviewLayer.h"
#import "NSLog.h"

// HelloWorldLayer implementation
@implementation SpritePreviewLayer

@synthesize spriteName = spriteName_;

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]) ) {
        [self genBackground];
        self.isKeyboardEnabled = NO;
        self.isMouseEnabled = YES;
    }
	return self;
}

- (ccColor4F)randomBrightColor{
    while(true){
        float requiredBrightness = 192;
        ccColor4B randomColor = ccc4(arc4random()%255, arc4random()%255, arc4random()%255, 255);
        if(randomColor.r > requiredBrightness || randomColor.g > requiredBrightness || randomColor.b > requiredBrightness)
            return ccc4FFromccc4B(randomColor);
    }
}

- (ccColor4F)backgroundColor{
    ccColor4B randomColor = ccc4(192, 192, 192, 255);
    return ccc4FFromccc4B(randomColor);
}

- (CCSprite*)backgroundSpriteWithColor:(ccColor4F)color width:(float)width height:(float)height
{
    CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:width height:height];
    // set up OpenGL so that any further drawing draws into the CCRenderTexture 'rt'
    [rt beginWithClear:color.r g:color.g b:color.b a:color.a];
    
    // render the texture 'rt' and turn off drawing into the texture 'rt'
    [rt end];
    
    return [CCSprite spriteWithTexture:rt.sprite.texture];
}

- (void)genBackground
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    [_background removeFromParentAndCleanup:YES];
    
    ccColor4F bgColor = [self backgroundColor];
    _background = [self backgroundSpriteWithColor:bgColor width:winSize.width*5/5 height:winSize.height*5/5];
    
    _background.anchorPoint = ccp(0.5, 0.5);
    _background.position = ccp(winSize.width/2, winSize.height/2);
    
    [self addChild:_background z:-1];
}

- (CCSprite*)mainSprite
{
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    NSArray* spriteNameArray = [frameCache spriteFrameNameArray];
    NSUInteger count = [spriteNameArray count];
    if(count == 0)
        return nil;
    
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:spriteName_];
    CGSize contentSize = sprite.contentSize;
    
    //self.spriteName = spriteName;
    
    NSLog(@"%s,%d sprite.contentSize:%@", __FUNCTION__, __LINE__,NSStringFromSize(NSSizeFromCGSize(contentSize)));
    
    CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:contentSize.width height:contentSize.height];
    // set up OpenGL so that any further drawing draws into the CCRenderTexture 'rt'
    [rt begin];
    
    sprite.flipY = YES;
    sprite.position = ccp(contentSize.width/2, contentSize.height/2);
    [sprite visit];
    
    // render the texture 'rt' and turn off drawing into the texture 'rt'
    [rt end];
    
    return [CCSprite spriteWithTexture:rt.sprite.texture];
}

- (void)updateSpriteNamed:(NSString*)spriteName;
{
    self.spriteName = spriteName;
    [self genSprite];
}

- (void)genSprite
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    [_sprite removeFromParentAndCleanup:YES];
    
    _sprite = [self mainSprite];
    
    if(!_sprite)
        return;
    
    _sprite.position = ccp(winSize.width/2, winSize.height/2);
    
    [self addChild:_sprite];
}

- (BOOL)saveSpriteToPath:(NSString*)path
{
    CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:self.spriteName];
    CGSize contentSize = sprite.contentSize;
    NSLog(@"%s,%d sprite.contentSize:%@", __FUNCTION__, __LINE__,NSStringFromSize(NSSizeFromCGSize(contentSize)));
    CCRenderTexture *render = [CCRenderTexture renderTextureWithWidth:contentSize.width height:contentSize.height];
    [render begin];
    sprite.position = ccp(contentSize.width/2, contentSize.height/2);
    [sprite visit];
    [render end];
    
    NSString* fullpath = nil;
    BOOL isDir;
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir){
        NSLog(@"%s,%d path:%@ IS directory", __FUNCTION__, __LINE__,path);
        fullpath = [path stringByAppendingPathExtension:self.spriteName];
    } else {
        fullpath = path;
    }
    BOOL success = [render saveToFile:path];
    NSLog(@"%s,%d save to %@ success:%@", __FUNCTION__, __LINE__,path,success?@"YES":@"NO");
    return success;
}

- (BOOL)saveAllSpriteToFloder:(NSString*)folder;
{
    BOOL allSuccess = YES;
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    NSArray* spriteNameArray = [frameCache spriteFrameNameArray];
    for(NSString* spriteName in spriteNameArray)
    {
        CCSprite* sprite = [CCSprite spriteWithSpriteFrameName:spriteName];
        CGSize contentSize = sprite.contentSize;
        NSLog(@"%s,%d sprite.contentSize:%@", __FUNCTION__, __LINE__,NSStringFromSize(NSSizeFromCGSize(contentSize)));
        CCRenderTexture *render = [CCRenderTexture renderTextureWithWidth:contentSize.width height:contentSize.height];
        [render begin];
        sprite.position = ccp(contentSize.width/2, contentSize.height/2);
        [sprite visit];
        [render end];
        
        NSString* fullpath = [folder stringByAppendingPathComponent:spriteName];
        BOOL success = [render saveToFile:fullpath];
        NSLog(@"%s,%d save %@ success:%@", __FUNCTION__, __LINE__,spriteName,success?@"YES":@"NO");
        if(!success)
            allSuccess = NO;
    }
    return allSuccess;
}

- (void)animateSprites:(NSArray*)spriteNameArray delayPerUnit:(float)delayPerUnit
{
    CCSpriteFrame *frame = nil;
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    NSMutableArray* animFrames = [NSMutableArray arrayWithCapacity:[spriteNameArray count]];
    for( NSString *frameName in spriteNameArray ) {
        frame = [frameCache spriteFrameByName:frameName];
        CCAnimationFrame *animFrame = [[CCAnimationFrame alloc] initWithSpriteFrame:frame delayUnits:1 userInfo:nil];
        [animFrames addObject:animFrame];
    }
    // create animation from the sprite frames
    CCAnimation* animation = [CCAnimation animationWithAnimationFrames:animFrames delayPerUnit:delayPerUnit loops:1];
    CCAnimate* animate = [CCAnimate actionWithAnimation:animation];
    [_sprite runAction:animate];
}

-(BOOL) ccKeyDown:(NSEvent*)theEvent;
{
    BOOL swallowed = NO;
    NSString*   const   character   =   [theEvent charactersIgnoringModifiers];
    if([character length] != 1) return NO;
    unichar     const   code        =   [character characterAtIndex:0];
    NSLog(@"%s,%d key code:0x%X", __FUNCTION__, __LINE__,code);
    switch (code) {
        case NSUpArrowFunctionKey:
        case NSLeftArrowFunctionKey:
            NSLog(@"%s,%d NSUpArrowFunctionKey or NSLeftArrowFunctionKey", __FUNCTION__, __LINE__);
            [self genBackground];
            break;
        case NSDownArrowFunctionKey:
        case NSRightArrowFunctionKey:
            NSLog(@"%s,%d NSDownArrowFunctionKey or NSRightArrowFunctionKey", __FUNCTION__, __LINE__);
            [self genBackground];
            break;
        case 0x20:
            NSLog(@"%s,%d space key", __FUNCTION__, __LINE__);
            break;
        default:
            swallowed = NO;
            break;
    }
    return swallowed;
}

-(BOOL) ccMouseDown:(NSEvent*)event;
{
    [self genBackground];
    return YES;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[spriteName_ release];
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
