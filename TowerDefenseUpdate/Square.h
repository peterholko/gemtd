//
//  Square.h
//  gemtd
//
//  Created by Peter Holko on 2/3/2014.
//  Copyright (c) 2014 Holko. All rights reserved.
//

#import "cocos2d.h"

@interface Square : NSObject
{
    int x;
    int y;
    float movementCost;
    float heuristic;
    BOOL isOpen;
    BOOL isClosed;
}

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) CGPoint parentSquare;
@property (nonatomic, assign) float movementCost;
@property (nonatomic, assign) float heuristic;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) BOOL isClosed;

+(id) nodeWithPos:(int)_x y:(int)_y;

@end
