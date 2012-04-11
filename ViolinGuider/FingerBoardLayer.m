//
//  FingerBoardLayer.m
//  ViolinGuider
//
//  Created by michael he on 4/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FingerBoardLayer.h"
#import "SBJson.h"
#import "NotePoint.h"

@interface FingerBoardLayer() {
}

- (BOOL)hasHalfMark:(NSString *)noteName;
@end


@implementation FingerBoardLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	FingerBoardLayer *layer = [FingerBoardLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];

	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        currentIndex = -1;
        displayedNotePoints = [[NSMutableArray alloc] init];
    
        NSString * jsonData = [self readJsonFromFile];
        notes = [jsonData JSONValue];

        // Init menu
        backBtn = [CCMenuItemImage itemFromNormalImage:@"back.png" selectedImage:@"back.png" target:self selector:@selector(showPrevPoints:)];
        [backBtn setPosition:CGPointMake(-210, -300)];
        forwardBtn = [CCMenuItemImage itemFromNormalImage:@"forward.png" selectedImage:@"forward.png" target:self selector:@selector(showNextPoints:)];
        [forwardBtn setPosition:CGPointMake(210, -300)];
        menu    = [CCMenu menuWithItems:backBtn, forwardBtn, nil];

        // Init TMXTileMap
        map     = [CCTMXTiledMap tiledMapWithTMXFile:@"fingerboard.tmx"];
        objects = [map objectGroupNamed:@"objLayer"];

        [self addChild:map];
        [self addChild:menu];
	}
	return self;
}

-(NSString *)readJsonFromFile
{
    NSString * filePath     = [[NSBundle mainBundle] pathForResource:@"sample_parse_result" ofType:@"json"];
    NSString * fileContent  = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return fileContent;
}

-(void)showPrevPoints:(UIEvent *)event
{
    if (currentIndex > 0) {
        currentIndex--;
    }

    [self showPoints:@"prev"];
}

-(void)showNextPoints:(UIEvent *)event
{
    // don't why "([notes count] - 1) > currentIndex" always return false
    NSInteger maxIndex = [notes count] - 1;
    if (currentIndex < maxIndex) {
        currentIndex++;
    }

    [self showPoints:@"next"];
}

-(void)showPoints:(NSString *)action
{
    // each time get next one.
    if (currentIndex >= 0 && currentIndex <= ([notes count] - 1)) {
        // get one note
        NSArray * note = [notes objectAtIndex:currentIndex];

        NSString * bowDirection = [note objectAtIndex:0];
        NSString * noteName     = [note objectAtIndex:1];
        NSString * fingerIndex  = [note objectAtIndex:2];
        NSString * stringName   = [note objectAtIndex:3];

        // remove all displayed note hint points
        if ([displayedNotePoints count] > 0) {
            for (CCSprite * notePoint in displayedNotePoints) {
                [self removeChild:notePoint cleanup:YES];
            }
            [displayedNotePoints removeAllObjects];
        }

        // travers all fingerboard positions, and find the corresponding one.
        for (NSDictionary * dict in [objects objects]) {
            NSArray * notesOnFingerPoint = [[dict objectForKey: @"name"] componentsSeparatedByString:@","];
            NSString * currentStringName = [dict objectForKey:@"type"];
            
            // If has the note, show it.
            if ( ([stringName isEqualToString:@""] || [stringName isEqualToString:currentStringName]) && [notesOnFingerPoint containsObject:noteName])
            {
                float offset = [self hasHalfMark:noteName] ? 13.0 : 18.0;
                NotePoint * hintPoint = [NotePoint spriteWithWord:[fingerIndex stringByAppendingString:bowDirection]];
                [hintPoint setScale:1.0];
                [hintPoint setPosition:CGPointMake([[dict objectForKey:@"x"] floatValue] + offset,
                                                   [[dict objectForKey:@"y"] floatValue] + offset-1)];

                [displayedNotePoints addObject:hintPoint]; // should retain once?
                [self addChild:hintPoint];

                [hintPoint runAction:[CCSequence actions:
                                      [CCScaleTo actionWithDuration:0.2 scale:1.5],
                                      [CCScaleTo actionWithDuration:0.2 scale:1.0], nil]];
            }
        }
    }
}

- (BOOL)hasHalfMark:(NSString *)noteName
{
    NSArray * marks = [NSArray arrayWithObjects:@"#", @"b", nil];
    return [marks containsObject:[noteName substringFromIndex:([noteName length] - 1)]];
}

- (void) dealloc
{
	[map release];
    [objects release];
    [displayedNotePoints release];
    [notes release];

	[super dealloc];
}

@end
