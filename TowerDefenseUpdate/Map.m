//
//  Map.m
//  gemtd
//
//  Created by Peter Holko on 13-07-09.
//  Copyright (c) 2013 Holko. All rights reserved.
//

#import "Map.h"

@interface Map ()
@property (nonatomic, retain) NSMutableArray *spOpenSteps;
@property (nonatomic, retain) NSMutableArray *spClosedSteps;
@end

@implementation Map

@synthesize spOpenSteps;
@synthesize spClosedSteps;

-(id)init
{
    self.spOpenSteps = nil;
    self.spClosedSteps = nil;
    
    [self initClosedTiles];
    
    return self;
}

- (int)isValidTileCoord:(int)x y:(int)y
{
    if (x < 0 || y < 0 ||
        x >= 40 || y >= 40)
    {
        return RESTRICTED;
    }
    else
    {
        if (closedTiles[x][y] == 0)
        {
            return OPEN;
        }
        else if(closedTiles[x][y] == 1)
        {
            return RESTRICTED;
        }
        else
        {
            return CLOSED;
        }
    }
}


-(void)initClosedTiles
{
    for(int i = 0; i < 40; i++)
    {
        for(int j = 0; j < 40; j++)
        {
            closedTiles[i][j] = 0;
            map[j][i] = 1;
        }
    }
}

-(void)setClosedTile:(int)x y:(int)y
{
    closedTiles[x][y] = 2;
    map[y][x] = 0;
}

-(void)setRestrictedTile:(int)x y:(int)y
{
    closedTiles[x][y] = 1;
}

-(void)setOpenTile:(int)x y:(int)y
{
    closedTiles[x][y] = 0;
    map[y][x] = 1;
}

-(NSMutableArray *)findPath2:(CGPoint)fromTileCoord toTileCoord:(CGPoint)toTileCoord
{
    mapStatus = [[NSMutableArray alloc] init];
    
    int startX = fromTileCoord.x;
    int startY = fromTileCoord.y;
    
    int endX = toTileCoord.x;
    int endY = toTileCoord.y;
    
    int nowX;
    int nowY;
    
    int flatCoord;
    
    for(int y = 0; y < MAP_HEIGHT; y++)
    {
        for(int x = 0; x < MAP_WIDTH; x++)
        {
            Square* square = [Square nodeWithPos:x y:y];
        
            [mapStatus addObject:square];
        }
    }
    
    openList = [[NSMutableArray alloc] init];
    
    //NSLog(@"Opening starter square");
    [self openSquare:startX y:startY parentSquare:ccp(-1, -1) movementCost:0 heuristic:0 replacing:FALSE];
    

    //NSLog(@"openList count: %d", [openList count]);
    //NSLog(@"isClosed: %d", [self isClosed:endY x:endX]);
    while([openList count] > 0 && ![self isClosed:endY x:endX])
    {
        //NSLog(@"openList count: %d", [openList count]);
        
        // Browse through open squares
        int i = [self nearerSquare];
        
        //NSLog(@"i: %d", i);
        NSValue *val = [openList objectAtIndex:i];
        CGPoint now = [val CGPointValue];
        // Closes current square as it has done its purpose...
        [self closeSquare:now openListIndex:i];
        
        nowX = (int)now.x;
        nowY = (int)now.y;
        
        // Opens all nearby squares, ONLY if:
        for (int j = nowY - 1; j < nowY + 2; j++)
        {
            for (int k = nowX - 1; k < nowX + 2; k++)
            {
                if (j >= 0 && j < MAP_HEIGHT && k >= 0 && k < MAP_WIDTH && !(j == nowY && k == nowX) && (j == nowY || k == nowX) && (j == nowY || k == nowX || (map[j][nowX] != 0 && map[nowY][k])))
                {
                    //NSLog(@"map[%d][%d]: %d", j, k, map[j][k]);
                    
                    
                    if (map[j][k] != 0)
                    {
                        flatCoord = j * MAP_HEIGHT + k;
                        Square *squareJK = [mapStatus objectAtIndex:flatCoord];
                        //NSLog(@"squareJK.isClosed: %hhd", squareJK.isClosed);
                        if (!squareJK.isClosed)
                        {
                            //var movementCost = mapStatus[nowY][nowX].movementCost + ((j==nowY || k==nowX ? HV_COST : D_COST) * map[j][k]);
                            int flatCoord = nowY * MAP_HEIGHT + nowX;
                            Square *squareNow = [mapStatus objectAtIndex:flatCoord];
                            int cost;
                            
                            if(j == nowY || k == nowX)
                            {
                                cost = HV_COST;
                            }
                            else
                            {
                                cost = D_COST;
                            }
                            
                            
                            float movementCost = squareNow.movementCost + cost;
                            //NSLog(@"squareJK.isOpen: %hhd", squareJK.isOpen);
                            if(squareJK.isOpen)
                            {
                                //NSLog(@"movementCost: %f squareJK.movementCost: %f", movementCost, squareJK.movementCost);
                                
                                // Already opened: check if it's ok to re-open (cheaper)
                                if (movementCost < squareJK.movementCost)
                                {
                                    // Cheaper: simply replaces with new cost and parent.
                                    [self openSquare:k y:j parentSquare:ccp(nowX, nowY) movementCost:movementCost heuristic:0 replacing:TRUE];
                                    // heuristic not passed: faster, not needed 'cause it's already set
                                }
                            }
                            else
                            {
                                //Empty: open
                                //NSLog(@"Opening: %d %d", k, j);
                                float heuristic = (abs (j - endY) + abs (k - endX)) * 10;
                                [self openSquare:k y:j parentSquare:ccp(nowX, nowY) movementCost:movementCost heuristic:heuristic replacing:FALSE];
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // Ended
    BOOL pFound = [self isClosed:endY x:endX]; // Was the path found?
    
    // Clean up temporary functions
    if (pFound)
    {
        // Ended with path found; generates return path
        NSMutableArray *returnPath = [[NSMutableArray alloc] init];
        nowY = endY;
        nowX = endX;
        
        while ((nowY != startY || nowX != startX))
        {
            NSValue *coord = [NSValue valueWithCGPoint: ccp(nowX,nowY)];
            [returnPath addObject: coord];
            
            int flatCoord = nowY * MAP_HEIGHT + nowX;
            Square *squareNow = [mapStatus objectAtIndex:flatCoord];
            
            int newX = squareNow.parentSquare.x;
            int newY = squareNow.parentSquare.y;

            nowY = newY;
            nowX = newX;
        }
        
        NSValue *coord = [NSValue valueWithCGPoint: ccp(startX,startY)];
        [returnPath addObject: coord];
        
        // First START, last END
        
        return returnPath;
    }
    else
    {
        return nil;
    }
}

-(void)openSquare:(int)_x y:(int)_y parentSquare:(CGPoint)_parentSquare movementCost:(float)_movementCost
        heuristic:(float)_heuristic replacing:(BOOL)replacing
{
    int flatCoord = _y * MAP_HEIGHT + _x;
    
    Square* square = [mapStatus objectAtIndex:flatCoord];
    
    if(!replacing)
    {
        NSValue *coord = [NSValue valueWithCGPoint: ccp(_x,_y)];
        [openList addObject: coord];
        
        square.heuristic = _heuristic;
        square.isOpen = TRUE;
        square.isClosed = TRUE;
    }
    
    square.parentSquare = _parentSquare;
    square.movementCost = _movementCost;
}

-(BOOL)isClosed:(int)_y x:(int)_x
{
    int flatCoord = _y * MAP_HEIGHT + _x;
    Square* square = [mapStatus objectAtIndex:flatCoord];
    
    return square.isClosed;
}

-(void)closeSquare:(CGPoint)coord openListIndex:(int)index
{
    int flatCoord = coord.y * MAP_HEIGHT + coord.x;
    
    Square *square = [mapStatus objectAtIndex:flatCoord];
    
    square.isClosed = TRUE;
    square.isOpen = FALSE;
    
    [openList removeObjectAtIndex:index];
}

 -(int)nearerSquare
 {
     int minimum = 999999;
     int indexFound = 0;
     int thisF = 0;
     int i = [openList count];
     int flatCoord;
     Square *thisSquare;
     
     while (i-- > 0)
     {
         NSValue *val = [openList objectAtIndex:i];
         CGPoint coord = [val CGPointValue];
         flatCoord =  coord.y * MAP_HEIGHT + coord.x;

         thisSquare = [mapStatus objectAtIndex:flatCoord];
         thisF = thisSquare.heuristic + thisSquare.movementCost;
         
         if (thisF <= minimum)
         {
             minimum = thisF;
             indexFound = i;
         }
     }
     
     return indexFound;
 }

@end
