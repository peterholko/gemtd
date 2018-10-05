//
//  CritLabel.m
//  gemtd
//
//  Created by Peter Holko on 2014-05-19.
//  Copyright 2014 Holko. All rights reserved.
//

#import "CritLabel.h"

@implementation CritLabel

+(id) nodeWithTheGame:(int)critValue pos:(CGPoint)_pos
{
    return [[self alloc] initWithTheGame:critValue pos:_pos];
}

-(id) initWithTheGame:(int)critValue pos:(CGPoint)_pos
{
	if( (self=[super init]))
    {
        NSString *critText = [NSString stringWithFormat:@"%d!", critValue];
        NSLog(@"createCritText %@ pos: %f %f", critText, _pos.x, _pos.y);
        critLabel = [CCLabelTTF labelWithString: critText
                                       fontName: @"Marker Felt"
                                       fontSize: 16];
        
        critLabel.color = ccc3(255, 0, 0);
        critLabel.position = ccp(_pos.x, _pos.y);
        
        [self addChild:critLabel];
        [self setVisible:TRUE];
        
        [self schedule:@selector(hideCritLabel) interval:1];
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)hideCritLabel
{
    [self setVisible:FALSE];
    [self unschedule:@selector(hideCritLabel)];
}

@end

