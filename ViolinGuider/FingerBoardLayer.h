//
//  FingerBoardLayer.h
//  ViolinGuider
//
//  Created by michael he on 4/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FingerBoardLayer : CCLayer {
    CCTMXTiledMap * map;
    CCTMXObjectGroup * objects;

    CCMenu * menu;
    CCMenuItemImage * backBtn;
    CCMenuItemImage * forwardBtn;
    
    NSMutableArray * displayedNotePoints;
    
    NSArray * notes;
    int currentIndex;
}

+(CCScene *)scene;

-(NSString *)readJsonFromFile;
-(void)showPoints:(NSString *)action;
-(void)showNextPoints:(UIEvent *)event;
-(void)showPrevPoints:(UIEvent *)event;

@end
