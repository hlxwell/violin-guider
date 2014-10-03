//
//  NotePoint.m
//  ViolinGuider
//
//  Created by michael he on 4/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NotePoint.h"

@implementation NotePoint

+(id)spriteWithWord:(NSString *)word
{
    return [[[self alloc] initWithWord:word] autorelease];
}

-(id)initWithWord:(NSString *)word
{
    if( (self=[super init])) {
        CCSprite * point = [CCSprite spriteWithFile:@"point.png"];
        CCLabelTTF * wordLabel = [CCLabelTTF labelWithString:word
                                       fontName:@"Verdana"
                                       fontSize:14];
        [wordLabel setColor:ccBLUE];

        [self addChild:point];
        [self addChild:wordLabel];
    }
    return self;
}

@end
