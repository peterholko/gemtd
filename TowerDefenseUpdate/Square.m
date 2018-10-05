//
//  Square.m
//  gemtd
//
//  Created by Peter Holko on 2/3/2014.
//  Copyright (c) 2014 Holko. All rights reserved.
//

/*public var m_x;
public var m_y;

public var parentSquare:Array;
public var movementCost:Number;
public var heuristic:Number;
public var isOpen:Boolean;
public var isClosed:Boolean;

public function Square(xCoord:Number,yCoord:Number)
{
    m_x = xCoord;
    m_y = yCoord;
    parentSquare = null;
    movementCost = 0;
    heuristic = 0;
    isOpen = false;
    isClosed = false;
}*/

#import "Square.h"

@implementation Square

@synthesize x;
@synthesize y;
@synthesize movementCost;
@synthesize heuristic;
@synthesize isOpen;
@synthesize isClosed;
@synthesize parentSquare;

+(id) nodeWithPos:(int)_x y:(int)_y
{
    return [[self alloc] initWithPos:_x y:_y];
}

-(id) initWithPos:(int)_x y:(int)_y
{
	if( (self=[super init]))
    {
        x = _x;
        y = _y;
        movementCost = 0.0;
        heuristic = 0.0;
        isOpen = FALSE;
        isClosed = FALSE;
    }
    
    return self;
}

@end

