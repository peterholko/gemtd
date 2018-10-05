//
//  CritLabel.h
//  gemtd
//
//  Created by Peter Holko on 2014-05-19.
//  Copyright 2014 Holko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CritLabel : CCNode
{
    CCLabelTTF *critLabel;
}

+(id) nodeWithTheGame:(int)critValue pos:(CGPoint)_pos;
-(id) initWithTheGame:(int)critValue pos:(CGPoint)_pos;

@end

