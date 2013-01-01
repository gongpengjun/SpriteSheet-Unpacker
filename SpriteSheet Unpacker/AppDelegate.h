//
//  AppDelegate.h
//  SpriteSheet Unpacker
//
//  Created by Gong Pengjun on 12-12-31.
//  Copyright www.gongpengjun.com ©2012. All rights reserved.
//

#import "cocos2d.h"
#import "SpritePreviewLayer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
    NSTableView *nameTableView_;
    SpritePreviewLayer *previewLayer_;
    NSString    *plistPath_;
    NSArray     *spriteNameArray_;
    id          eventMonitor_;
    BOOL        autoPlaying_;
    NSUInteger  currentIndex_;
    NSTimer     *timer_;
    NSTimeInterval interval_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;
@property (retain) NSArray              *spriteNameArray;
@property (assign) IBOutlet NSTableView *nameTableView;
@property (retain) SpritePreviewLayer   *previewLayer;
@property (copy)   NSString             *plistPath;

- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)loadSpriteSheet:(id)sender;
- (IBAction)saveAllSpritesTo:(id)sender;
- (IBAction)saveCurrentSpriteTo:(id)sender;

@end
