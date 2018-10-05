//
//  Map.h
//  gemtd
//
//  Created by Peter Holko on 13-07-09.
//  Copyright (c) 2013 Holko. All rights reserved.
//

#import "ShortestPathStep.h"
#import "Square.h"
#import "cocos2d.h"

#define MAP_HEIGHT 40
#define MAP_WIDTH 40
#define HV_COST 10
#define D_COST 14
#define OPEN 0
#define RESTRICTED 1
#define CLOSED 2

@interface Map : NSObject
{
    int closedTiles[MAP_WIDTH][MAP_HEIGHT];
    int restrictedTiles[MAP_WIDTH][MAP_HEIGHT];
    
    int map[MAP_WIDTH][MAP_HEIGHT];
    
    NSMutableArray *mapStatus;
    NSMutableArray *openList;
    
@private
	NSMutableArray *spOpenSteps;
	NSMutableArray *spClosedSteps;
}

- (id)init;

- (int)isValidTileCoord:(int)x y:(int)y;
- (void)initClosedTiles;

- (void)setClosedTile:(int)x y:(int)y;
- (void)setRestrictedTile:(int)x y:(int)y;
- (void)setOpenTile:(int)x y:(int)y;

-(NSMutableArray *)findPath2:(CGPoint)fromTileCoord toTileCoord:(CGPoint)toTileCoord;
-(int)nearerSquare;
-(void)closeSquare:(CGPoint)coord openListIndex:(int)index;
-(BOOL)isClosed:(int)_y x:(int)_x;
@end



