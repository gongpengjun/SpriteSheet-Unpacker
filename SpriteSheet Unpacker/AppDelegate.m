//
//  AppDelegate.m
//  SpriteSheet Unpacker
//
//  Created by Gong Pengjun on 12-12-31.
//  Copyright www.gongpengjun.com ©2012. All rights reserved.
//

#import "AppDelegate.h"
#import "SpritePreviewLayer.h"
#import "NSLog.h"

@implementation AppDelegate

@synthesize window=window_, glView=glView_, plistPath=plistPath_;
@synthesize spriteNameArray=spriteNameArray_, nameTableView=nameTableView_, previewLayer=previewLayer_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];

	// enable FPS and SPF
	[director setDisplayStats:NO];
	
	// connect the OpenGL view with the director
	[director setView:glView_];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[window_ center];
	
    CCScene *scene = [CCScene node];
	self.previewLayer = [SpritePreviewLayer node];
	[scene addChild: self.previewLayer];

	[director runWithScene:scene];
    
    [nameTableView_ setAllowsEmptySelection:NO];
    
    [self setupLocalEventMonitor];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
    [self removeLocalEventMonitor];
    [previewLayer_ release];
	[[CCDirector sharedDirector] end];
    [spriteNameArray_ release];
    [plistPath_ release];
    [nameTableView_ release];
	[window_ release];
	[super dealloc];
}

#define KEY_SPACE  49
#define KEY_ESCAPE 53
#define KEY_UP 126
#define KEY_DOWN 125
#define KEY_LEFT 123
#define KEY_RIGHT 124

- (void)setupLocalEventMonitor
{
    // Start watching events to figure out when 'space' key pressed
    NSAssert(eventMonitor_ == nil, @"eventMonitor_ should not be created yet");
    eventMonitor_ = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *incomingEvent) {
        NSEvent *result = incomingEvent;
        if ([incomingEvent type] == NSKeyDown) {
            NSLog(@"%s,%d %d", __FUNCTION__, __LINE__,[incomingEvent keyCode]);
            if([incomingEvent keyCode] == KEY_SPACE)
            {
                NSLog(@"%s,%d KEY_SPACE", __FUNCTION__, __LINE__);
                [self autoPlayAllSprites:nil];
                result = nil; // stop send this envent
            }
        }
        return result;
    }];
}

- (void)removeLocalEventMonitor
{
    if (eventMonitor_) {
        [NSEvent removeMonitor:eventMonitor_];
        eventMonitor_ = nil;
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.spriteNameArray count];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView* tableCellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    [[tableCellView textField] setStringValue:[self.spriteNameArray objectAtIndex:row]];
    return tableCellView;
}

- (NSString*)selectedSpriteName
{
    NSInteger selectedRow = [nameTableView_ selectedRow];
    if( 0 <= selectedRow && selectedRow < self.spriteNameArray.count )
    {
        return [self.spriteNameArray objectAtIndex:selectedRow];
    }
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    currentIndex_ = [nameTableView_ selectedRow];
    NSString* spriteName = [self selectedSpriteName];
    if(spriteName && spriteName.length > 0)
    {
        [previewLayer_ updateSpriteNamed:spriteName];
    }
}

#pragma mark AppDelegate - IBActions

- (void)windowDidResize:(NSNotification *)notification;
{
    [previewLayer_ genBackground];
    [previewLayer_ genSprite];
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

- (IBAction)loadSpriteSheet:(id)sender {
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setTreatsFilePackagesAsDirectories:YES];
    [panel setAllowedFileTypes:@[@"plist",@"PLIST"]];
    [panel setCanChooseDirectories:NO];
	NSInteger result = [panel runModal];
    
    // handle NSFileHandlingPanelCancelButton
	if (result == NSFileHandlingPanelCancelButton) {
        NSLog(@"%s,%d cancelled", __FUNCTION__, __LINE__);
		return;
	}
	
	// handle NSFileHandlingPanelOKButton
	NSURL *plistURL = [panel URL];
    NSLog(@"%s,%d plistURL:%@", __FUNCTION__, __LINE__,plistURL);
    NSURL* imageURL = [[plistURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"png"];
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache removeUnusedSpriteFrames];
    [frameCache addSpriteFramesWithFile:[plistURL path] textureFilename:[imageURL path]];
    
    //[previewLayer_ performSelector:@selector(genSprite) withObject:nil afterDelay:0];
    NSArray* array = [frameCache spriteFrameNameArray];
    self.spriteNameArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    currentIndex_ = 0;
    [nameTableView_ reloadData];
}

- (IBAction)saveAllSpritesTo:(id)sender {
    [self pause];
	// get the file url and write it
	NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setPrompt:@"Save"];
	NSInteger result = [panel runModal];
    
    // handle NSFileHandlingPanelCancelButton
	if (result == NSFileHandlingPanelCancelButton) {
        NSLog(@"%s,%d cancelled", __FUNCTION__, __LINE__);
		return;
	}
	
	// handle NSFileHandlingPanelOKButton
	NSURL *url = [panel URL];
    NSString *path = [url path];
    [previewLayer_ saveAllSpriteToFloder:path];
}

- (IBAction)saveCurrentSpriteTo:(id)sender {
    [self pause];
	// get the file url and write it
	NSSavePanel * panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:previewLayer_.spriteName];
    [panel setAllowedFileTypes:@[@"png",@"PNG"]];
    [panel setCanCreateDirectories:YES];
    [panel setPrompt:@"Save"];
	NSInteger result = [panel runModal];
    
    // handle NSFileHandlingPanelCancelButton
	if (result == NSFileHandlingPanelCancelButton) {
        NSLog(@"%s,%d cancelled", __FUNCTION__, __LINE__);
		return;
	}
	
	// handle NSFileHandlingPanelOKButton
	NSURL *url = [panel URL];
    NSString *path = [url path];
    [previewLayer_ saveSpriteToPath:path];
}

- (void)showPreviousSprite
{
    if([spriteNameArray_ count] == 0)
        return;
    
    if(currentIndex_ <= 0 )
        currentIndex_ = [spriteNameArray_ count] - 1;
    else
        currentIndex_--;
    [nameTableView_ selectRowIndexes:[NSIndexSet indexSetWithIndex:currentIndex_] byExtendingSelection:NO];
}

- (void)showNextSprite
{
    if([spriteNameArray_ count] == 0)
        return;
    
    NSLog(@"%s,%d", __FUNCTION__, __LINE__);
    if(currentIndex_ >= [spriteNameArray_ count]-1)
        currentIndex_ = 0;
    else
        currentIndex_++;
    [nameTableView_ selectRowIndexes:[NSIndexSet indexSetWithIndex:currentIndex_] byExtendingSelection:NO];
}

- (IBAction)gotoPreviousSprite:(id)sender {
    NSLog(@"%s,%d", __FUNCTION__, __LINE__);
    [self pause];
    [self showPreviousSprite];
}

- (IBAction)gotoNextSprite:(id)sender {
    NSLog(@"%s,%d", __FUNCTION__, __LINE__);
    [self pause];
    [self showNextSprite];
}

- (void)pause
{
    autoPlaying_ = NO;
    NSLog(@"%s,%d state: %@", __FUNCTION__, __LINE__,autoPlaying_?@"playing":@"paused");
    [timer_ invalidate]; timer_ = nil;
}

- (void)repeatTimerFireMethod:(NSTimer*)theTimer
{
    [self showNextSprite];
}

- (IBAction)autoPlayAllSprites:(id)sender {
    if([spriteNameArray_ count] == 0)
        return;
    
    interval_ = 0.5; // seconds
    
    if(autoPlaying_)
        autoPlaying_ = NO;
    else
        autoPlaying_ = YES;
    NSLog(@"%s,%d state: %@", __FUNCTION__, __LINE__,autoPlaying_?@"playing":@"paused");
    if(autoPlaying_){
        timer_ = [NSTimer scheduledTimerWithTimeInterval:interval_ target:self selector:@selector(repeatTimerFireMethod:) userInfo:nil repeats:YES];
    } else {
        [timer_ invalidate]; timer_ = nil;
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)item {
    NSUInteger count = [spriteNameArray_ count];
    if ([item action] == @selector(gotoPreviousSprite:) && count == 0) {
        return NO;
    }
    if ([item action] == @selector(gotoNextSprite:) && count == 0) {
        return NO;
    }
    if ([item action] == @selector(autoPlayAllSprites:)) {
        if(count > 0) {
            if(autoPlaying_)
                [item setTitle:@"Pause"];
            else
                [item setTitle:@"Auto Play"];
            return YES;
        } else {
            [item setTitle:@"Auto Play"];
            return NO;
        }
    }
    return YES;
}

@end
