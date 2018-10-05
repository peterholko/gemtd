//
//  Waypoint.h
//  gemtd
//
//  Created by Peter Holko on 13-06-30.
//  Copyright (c) 2013 Holko. All rights reserved.
//

#import "cocos2d.h"
#import "Game.h"

@interface Waypoint: CCNode {
    Game *theGame;
}

@property (nonatomic,readwrite) CGPoint myPosition;
@property (nonatomic,assign) Waypoint *nextWaypoint;

+(id)nodeWithTheGame:(Game *)_game location:(CGPoint)location;
-(id)initWithTheGame:(Game *)_game location:(CGPoint)location;

@end