//
//  Game
//  GemTD
//
//  Created by Peter Holko on 29/6/13.
//  Copyright Peter Holko 2013. All rights reserved.
//

// Import the interfaces
#import "Game.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "Tower.h"
#import "Waypoint.h"
#import "Enemy.h"
#import "Map.h"
#import "CritLabel.h"

#import <GameKit/GameKit.h>

#pragma mark - Game


@implementation TowerTypeQuality
@synthesize type, quality, filled;
@end

@implementation SpecialTower
@synthesize type, requiredTowers;
@end

// Game implementation
@implementation Game

@synthesize towers, gameLayer, uiLayer, enemies, winSize, damageTable, flying, level, phase, armorLevel;
@synthesize qualityLevel, chippedChance, flawedChance, normalChance, flawlessChance, perfectChance;
@synthesize gold, score, difficulty, lives, leaderboardID, gameCenterEnabled;

// Helper class method that creates a Scene with the Game as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Game *layer = [Game node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		// 0 - initialize
        self.touchEnabled = YES;
        winSize = [CCDirector sharedDirector].winSize;
        
        NSLog(@"Initializing map");
        map = [[Map alloc] init];
        damageTable = [[DamageTable alloc] init];
        
        // 1 - Reset
        [self reset];
        
        // 2 - Set background
        
        CCSprite * bg = [CCSprite spriteWithFile:@"bg.png"];
        
        gameLayer = [[CCLayer alloc] init];
        uiLayer = [[CCLayer alloc] init];

        bg.position = ccp([bg boundingBox].size.width / 2,
                          [bg boundingBox].size.height / 2);
        
        [gameLayer addChild:bg];
        [gameLayer setPosition: ccp(0, -210)];
        
        [self addChild:gameLayer z:-1];
        [self addChild:uiLayer z:0];
        
        //Setup UI
        ui = [UI nodeWithTheGame:self];
        
        // 3 - load restricted towers
        [self setRestrictedTiles];
        
        // 4 - set flyingPath
        flyingPath = [self findPath];
        
        NSLog(@"authenticateLocalPlayer");
        //[self authenticateLocalPlayer];

	}
	return self;
}

-(BOOL)canBuyTower
{
    return YES;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches )
    {
        NSLog(@"ccTouchMoved");
        CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
        CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
        
        oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
        oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
        
        CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
        CGPoint newPosition = ccpAdd(gameLayer.position, translation);
        
        [self setGameLayerPos: newPosition];
    }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(lives > 0 && difficulty != None)
    {
        for( UITouch *touch in touches )
        {
            CGPoint location = [touch locationInView: [touch view]];
            prevTouch = location;
            NSLog(@"TouchBegan: %f %f", location.x, location.y);
            
            location = [[CCDirector sharedDirector] convertToGL: location];
            
            if(phase == Place)
            {
                [self processPlacePhase:location];
            }
            else if(phase == Move)
            {
                [self processMovePhase:location];
            }
            else if(phase == Select)
            {
                [self processSelectPhase:location];
            }
            else if(phase == Wave)
            {
                [self processSelectWavePhase:location];
            }
                
        }
    }
}

-(void)initialize
{
    towers = [[NSMutableDictionary alloc] init];
    roundTowers = [[NSMutableArray alloc] init];
    specialTowers = [[NSMutableArray alloc] init];
    enemies = [[NSMutableArray alloc] init];
    
    [self initSpecialTowers];
    
    flying = FALSE;
    phase = Place;
    level = 1;
    armorLevel = 0;
    qualityLevel = 0;
    gold = 10;
    difficulty = None;
    lives = 10;
    score = 0;
    lost = FALSE;
    
    [self setUpgradeChanceCost];
}

-(void)reset
{
    [self clear];
    [self initialize];
    
    [ui showDifficultyButtons];
    [ui updateGoldText];
    [ui updateScoreText];
    [ui updateLevelText];
    [ui updateLivesText];
}

-(void)upgradeTower
{
    NSLog(@"upgradeTower gold: %d", selectedTower.upgradeCost);
    
    if(selectedTower.upgradesTo != Rock)
    {
    
        if(gold >= selectedTower.upgradeCost)
        {
            gold -= selectedTower.upgradeCost;
            [selectedTower changeTower:selectedTower.upgradesTo _quality:0];

            [ui setText: [selectedTower getInfoBox]];
            [ui updateGoldText];
        }
    }
}

-(void)removeTower
{
    if(selectedTower.towerType == Rock)
    {
        int tilex = selectedTower.tile.x;
        int tiley = selectedTower.tile.y;
        
        //Reopen tiles
        [map setOpenTile:tilex y:tiley];
        [map setOpenTile:tilex - 1 y:tiley];
        [map setOpenTile:tilex y:tiley - 1];
        [map setOpenTile:tilex - 1 y:tiley - 1] ;
        
        [selectedTower remove];
        
        NSNumber *removeIndex = [NSNumber numberWithInt:-1];
        
        for(NSNumber *index in towers)
        {
            Tower *tower = [towers objectForKey:index];
            
            if(selectedTower == tower)
            {
                removeIndex = index;
            }
        }
        
        [towers removeObjectForKey:removeIndex];
    }
}

-(void)clear
{
    //Clear towers
    for(NSNumber *index in towers)
    {
        Tower *tower = [towers objectForKey:index];
        [tower remove];
    }
    
    //Clear roundTowers
    for(Tower *roundTower in roundTowers)
    {
        [roundTower remove];
        
    }
}

-(void)processPlacePhase:(CGPoint)location
{
    int localx = location.x - gameLayer.position.x;
    int localy = location.y - gameLayer.position.y;
    
    int tilex = floor(localx  / TILE_SIZE) ;
    int tiley = floor(localy / TILE_SIZE);
    int coordIndex = (tiley * TILE_SIZE) + tilex;
    
    NSLog(@"tile: %d %d", tilex, tiley);
    
    int towerLocation = [self checkTowerLocation:tilex y:tiley];
    
    if(towerLocation == OPEN)
    {
    
        selectedTower = [Tower nodeWithTheGame:self tile: ccp(tilex, tiley)];
        selectedTower.towerPlacedThisRound = TRUE;
        
        //Add tower to tower dictionary
        [towers setObject:selectedTower forKey: [NSNumber numberWithInt: coordIndex]];
        [roundTowers addObject:selectedTower];
        
        //Select tower
        [self selectTower];
        
        //Setup UI buttons
        [self setUIButtons];
        
        //Show UI
        [ui showPanel:TRUE];
        [ui setText: [selectedTower getInfoBox]];
        [ui showPlace];
        [ui showUpgrade];
        
        //Next Phase
        phase = Move;
    }
    else if(towerLocation == CLOSED)
    {
        selectedTower = [self findTower:localx localy:localy];
        NSLog(@"selectedTower: %@", selectedTower);
        
        if(selectedTower)
        {
            //Hide all previous buttons
            [ui hideAllButtons];
            
            //Show UI
            [ui showPanel:TRUE];
            [ui setText: [selectedTower getInfoBox]];
            
            //Select tower
            [self selectTower];
            
            //Check if tower can be combinedSpecial
            if([self checkSpecialCombinePlaced])
            {
                if(selectedTower == lastKeepCombineTower)
                {
                    [ui showCombineSpecial];
                }
            }
            
            //If Rock display remove button
            if(selectedTower.towerType == Rock)
            {
                [ui showRemove];
            }
            
            //Check if special tower is available for upgrade
            if(selectedTower.upgradesTo != Rock)
            {
                [ui showUpgradeGem];
            }
        }
    }
    else
    {
        //Show cannot build notification
        [ui showCannotBuild];
    }

}

-(void)processMovePhase:(CGPoint)location
{
    NSLog(@"Move Phase");
    NSLog(@"gameLayer: %f %f", gameLayer.position.x, gameLayer.position.y);
    
    int localx = location.x - gameLayer.position.x;
    int localy = location.y - gameLayer.position.y;
    
    int tilex = floor(localx  / TILE_SIZE) ;
    int tiley = floor(localy / TILE_SIZE);
    
    int towerLocation = [self checkTowerLocation:tilex y:tiley];
    
    if(towerLocation == OPEN)
    {
        int oldCoordIndex = (selectedTower.tile.y * TILE_SIZE) + selectedTower.tile.x;
        int newCoordIndex = (tiley * TILE_SIZE) + tilex;
        
        //Assume location is empty...
        [towers setObject:selectedTower forKey: [NSNumber numberWithInt: newCoordIndex]];
        [towers removeObjectForKey: [NSNumber numberWithInt: oldCoordIndex]];
        
        [selectedTower move:ccp(tilex, tiley)];
    }
    else if(towerLocation == RESTRICTED)
    {
        //Show cannot build notification
        [ui showCannotBuild];
    }
}

-(void)processSelectPhase:(CGPoint)location
{
    float localx = location.x - gameLayer.position.x;
    float localy = location.y - gameLayer.position.y;
    
    NSLog(@"local: %f %f", (location.x - gameLayer.position.x), (location.y - gameLayer.position.y));
    
    int tilex = floor(localx  / TILE_SIZE) ;
    int tiley = floor(localy / TILE_SIZE);
    
    NSLog(@"tile: %d %d", tilex, tiley);
    
    Tower *foundTower = [self findTower:localx localy:localy];
    
    if(foundTower)
    {
        selectedTower = foundTower;
        
        //Select tower
        [self selectTower];
     
        //Setup UI buttons
        [self setUIButtons];
        
        //Show UI
        [ui showPanel:TRUE];
        [ui setText: [selectedTower getInfoBox]];
    }
    else
    {
        NSLog(@"tower not found!");
    }
}

-(void)processSelectWavePhase:(CGPoint)location
{
    float localx = location.x - gameLayer.position.x;
    float localy = location.y - gameLayer.position.y;
    
    int tilex = floor(localx  / TILE_SIZE) ;
    int tiley = floor(localy / TILE_SIZE);
    
    NSLog(@"tile: %d %d", tilex, tiley);
    
    Tower *foundTower = [self findTower:localx localy:localy];
    
    if(foundTower)
    {
        //Hide all buttons
        [ui hideAllButtons];
        
        selectedTower = foundTower;
        
        //Select tower
        [self selectTower];
        
        //If Rock display remove button
        if(selectedTower.towerType == Rock)
        {
            [ui showRemove];
        }
        else
        {
            //Check if tower can be combinedSpecial
            if([self checkSpecialCombinePlaced])
            {
                if(selectedTower == lastKeepCombineTower)
                {
                    [ui showCombineSpecial];
                }
            }
        }
        
        //Show UI
        [ui showPanel:TRUE];
        [ui setText: [selectedTower getInfoBox]];
    }
    else
    {
        NSLog(@"tower not found!");
    }
}

-(int)checkTowerLocation:(int)tilex y:(int)tiley
{
    int tile1 = [map isValidTileCoord:tilex y:tiley];
    int tile2 = [map isValidTileCoord:tilex - 1 y:tiley];
    int tile3 = [map isValidTileCoord:tilex y:tiley - 1];
    int tile4 = [map isValidTileCoord:tilex - 1 y:tiley - 1];
    
    NSLog(@"tile1: %d tile2: %d tile3: %d tile4: %d", tile1, tile2, tile3, tile4);
    
    if(tile1 == OPEN && tile2 == OPEN && tile3 == OPEN && tile4 == OPEN)
    {
        return OPEN;
    }
    
    if(tile1 == CLOSED || tile2 == CLOSED || tile3 == CLOSED || tile4 == CLOSED)
    {
        return CLOSED;
    }
    
    return RESTRICTED;
}

-(Tower *)findTower:(float)localx localy:(float)localy
{
    int tilex = floor(localx  / TILE_SIZE) ;
    int tiley = floor(localy / TILE_SIZE);
    
    for(NSNumber *index in towers)
    {
        Tower *tower = [towers objectForKey:index];
        NSLog(@"index: %d tile: %f %f", [index integerValue], tower.tile.x, tower.tile.y);
    }
    
    int coordIndex = (tiley * TILE_SIZE) + tilex;
    NSLog(@"coordIndex: %d", coordIndex);
    
    Tower *tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    coordIndex = (tiley * TILE_SIZE) + (tilex - 1);
    NSLog(@"coordIndex: %d", coordIndex);
    
    tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    coordIndex = ((tiley - 1) * TILE_SIZE) + (tilex);
    NSLog(@"coordIndex: %d", coordIndex);
    
    tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    coordIndex = ((tiley - 1) * TILE_SIZE) + (tilex - 1);
    NSLog(@"coordIndex: %d", coordIndex);
    
    tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    //
    
    coordIndex = ((tiley + 1) * TILE_SIZE) + (tilex - 0);
    NSLog(@"coordIndex: %d", coordIndex);
    
    tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    coordIndex = ((tiley + 1) * TILE_SIZE) + (tilex - 1);
    NSLog(@"coordIndex: %d", coordIndex);
    
    tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    coordIndex = ((tiley + 1) * TILE_SIZE) + (tilex + 1);
    NSLog(@"coordIndex: %d", coordIndex);
    
    tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    coordIndex = ((tiley - 1) * TILE_SIZE) + (tilex + 1);
    NSLog(@"coordIndex: %d", coordIndex);
    
    tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    coordIndex = ((tiley - 1) * TILE_SIZE) + (tilex + 0);
    NSLog(@"coordIndex: %d", coordIndex);
    
    tower = [towers objectForKey: [NSNumber numberWithInt: coordIndex]];
    
    if (tower)
    {
        return tower;
    }
    
    NSLog(@"foundTower tower: %@", tower);
    return tower;
}

-(void)processKeep
{
    //Turn towers into rocks
    for(Tower *roundTower in roundTowers)
    {
        roundTower.towerPlacedThisRound = FALSE;
        
        if(!roundTower.selected)
        {
            [roundTower changeTower:Rock _quality:0];
        }
    }
    
    //Assign lastKeepCombineTower
    lastKeepCombineTower = selectedTower;
    
    [self processWavePhase];
}

-(void)processPlace
{
    int tilex = selectedTower.tile.x;
    int tiley = selectedTower.tile.y;
    
    //Set closed tiles
    [map setClosedTile:tilex y:tiley];
    [map setClosedTile:tilex - 1 y:tiley];
    [map setClosedTile:tilex y:tiley - 1];
    [map setClosedTile:tilex - 1 y:tiley - 1] ;
    
    //Check if a valid path exists
    NSMutableArray *currPath = [self findPath];
    
    if(currPath != nil)
    {
        [ui hideAllButtons];
        
        //Randomize the tower
        [selectedTower randomTower];
        
        //Show UI
        [ui setText: [selectedTower getInfoBox]];
        
        NSLog(@"roundTowers count: %d", [roundTowers count]);
        
        //Check if 5 towers have been placed
        if([roundTowers count] == 5)
        {
            phase = Select;
            [self setUIButtons];
        }
        else
        {
            phase = Place;
            
        }
    }
    else
    {
        //Show blocking info 
        [ui showBlocking];
        
        //Reopen tiles
        [map setOpenTile:tilex y:tiley];
        [map setOpenTile:tilex - 1 y:tiley];
        [map setOpenTile:tilex y:tiley - 1];
        [map setOpenTile:tilex - 1 y:tiley - 1] ;
    }
}

-(void)processCombine
{
    for(Tower *roundTower in roundTowers)
    {
        roundTower.towerPlacedThisRound = FALSE;
        
        if(!roundTower.selected)
        {
            [roundTower changeTower:Rock _quality:0];
        }
    }
    
    [selectedTower changeTower:Standard
                      _quality:selectedTower.towerQuality + 1];
    
    //Assign lastKeepCombineTower
    lastKeepCombineTower = selectedTower;
    
    [ui setText: [selectedTower getInfoBox]];
    
    [self processWavePhase];
}

-(void)processCombineSpecial
{
    if(phase == Select)
    {
        NSLog(@"processCombineSpecial");
        
        for(Tower *roundTower in roundTowers)
        {
            roundTower.towerPlacedThisRound = FALSE;
            
            if(!roundTower.selected)
            {
                [roundTower changeTower:Rock _quality:0];
            }
        }

        [selectedTower changeTower:specialFoundTower.type
                          _quality:0];
        
        //Clear lastKeepCombineTower
        lastKeepCombineTower = Nil;

        [self processWavePhase];
    }
    else
    {
        for(Tower *filledTower in specialFilledTowers)
        {
            if(!filledTower.selected)
            {
                [filledTower changeTower:Rock _quality:0];
            }
        }
        
        [lastKeepCombineTower changeTower:specialFoundTower.type
                                 _quality:0];
        
        //Clear lastKeepCombineTower
        lastKeepCombineTower = Nil;
    }
    
    [ui setText: [selectedTower getInfoBox]];
    
    //Check if special tower is available for upgrade
    if(selectedTower.upgradesTo != Rock)
    {
        [ui showUpgradeGem];
    }
}

-(void)processWavePhase
{
    NSLog(@"processWavePhase");
    //Set gamePhase
    phase = Wave;
    
    //Hide panel
    [ui hideAllButtons];
    [ui showPanel:FALSE];
    
    NSLog(@"Calculating pathfinding");
    //Calculate pathfinding
    [self setPath];
    
    //Load wave
    [self loadWave];
    
    //Recalculate auras
    [self checkAuras];
    
    //Set towers to attack
    [self setActivateTowers];
    
    //Check if selected tower can be special combined with placed towers
    if([self checkSpecialCombinePlaced])
    {
        if(selectedTower == lastKeepCombineTower)
        {
            [ui showPanel:TRUE];
            [ui hideAllButtons];
            [ui showCombineSpecial];
        }
    }
    
    //Check if special tower available for upgrade
    if(selectedTower.upgradesTo != Rock)
    {
        [ui showUpgradeGem];
    }
}

-(void)selectTower
{
    for(NSNumber *index in towers)
    {
        Tower *tower = [towers objectForKey:index];
        [tower setSelect:FALSE];
    }
    
    [selectedTower setSelect:TRUE];
}

-(void)setUIButtons
{
    [ui hideAllButtons];
    
    if(phase == Select)
    {
        if(selectedTower.towerPlacedThisRound)
        {
            [ui showKeep];
            
            if([self checkStandardCombine])
            {
                NSLog(@"Standard Combine!");
                [ui showCombine];
            }
        
            if([self checkSpecialCombineRound])
            {
                NSLog(@"Special Combine!");
                [ui showCombineSpecial];
            }
        }
    }

    if(selectedTower.towerType == Rock)
    {
        [ui showRemove];
    }
}

-(void)setUpgradeChanceCost
{
    switch(qualityLevel)
    {
        case 0:
            chippedChance = 100;
            
            break;
        case 1:
            chippedChance = 70;
            flawedChance = 30;
            
            break;
        case 2:
            chippedChance = 60;
            flawedChance = 30;
            normalChance = 10;
            
            break;
        case 3:
            chippedChance = 50;
            flawedChance = 30;
            normalChance = 20;
            
            break;
        case 4:
            chippedChance = 40;
            flawedChance = 30;
            normalChance = 20;
            flawlessChance = 10;
        
            break;
        case 5:
            chippedChance = 30;
            flawedChance = 30;
            normalChance = 30;
            flawlessChance = 10;
            
            break;
        case 6:
            chippedChance = 20;
            flawedChance = 30;
            normalChance = 30;
            flawlessChance = 20;
            
            break;
        case 7:
            chippedChance = 10;
            flawedChance = 30;
            normalChance = 30;
            flawlessChance = 30;
            
            break;
        case 8:
            chippedChance = 0;
            flawedChance = 30;
            normalChance = 30;
            flawlessChance = 30;
            perfectChance = 10;
            
            break;
            
        default:
            chippedChance = 100;

    }
}

-(int)getUpgradeCost
{
    return 20 + 30 * qualityLevel;
}

-(void)processUpgradeChances
{
    if(gold >= [self getUpgradeCost])
    {
        gold -= [self getUpgradeCost];
        qualityLevel += 1;
        
        [self setUpgradeChanceCost];
        [ui updateGoldText];
    }
}

-(BOOL)checkStandardCombine
{
    int numCombine = 0;
    
    for(Tower *tower in roundTowers)
    {        
        if(selectedTower != tower)
        {
        
            if(selectedTower.towerQuality == tower.towerQuality &&
               selectedTower.towerBaseType == tower.towerBaseType)
            {
                
                numCombine++;
            }
        }
    }
    
    //Minimum combine has to be greater or equal to 2 because of double counting
    if(numCombine > 0)
        return TRUE;
    
    return FALSE;
}

-(BOOL)checkSpecialCombinePlaced
{
    NSLog(@"count towers: %d", [[towers allKeys] count]);
    
    for(SpecialTower *specialTower in specialTowers)
    {
        int numReqTowerFilled = 0;
        NSMutableArray *filledTowers = [[NSMutableArray alloc] init];
        [self resetFilled:specialTower];
        
        for(NSNumber *index in towers)
        {
            Tower *tower = [towers objectForKey:index];
            
            if(tower.towerPlacedThisRound)
            {
                //Skip if towerPlacedThisRound
                continue;
            }
            
            for(TowerTypeQuality *reqTower in specialTower.requiredTowers)
            {
                //NSLog(@"reqTower %d %d %d", reqTower.type, reqTower.quality, reqTower.filled);
                //NSLog(@"towerType %d %d", tower.towerBaseType, tower.towerQuality);
                if(tower.towerType == Standard)
                {
                    if(reqTower.type == tower.towerBaseType &&
                       reqTower.quality == tower.towerQuality)
                    {
                        if(!reqTower.filled)
                        {
                            numReqTowerFilled++;
                        }
                    
                        [filledTowers addObject:tower];
                        reqTower.filled = TRUE;
                    }
                }
            }
        }
        
        //NSLog(@"specialTower: %d", specialTower.type);
        //NSLog(@"contains: %hhd", [filledTowers containsObject:selectedTower]);
        //NSLog(@"numReqTowerFilled: %d", numReqTowerFilled);
        
        if([specialTower.requiredTowers count] == numReqTowerFilled &&
           [filledTowers containsObject:selectedTower])
        {
            specialFilledTowers = [[NSMutableArray alloc] init];
            specialFilledTowers = filledTowers;
            specialFoundTower = specialTower;
            
            for(Tower *tower in filledTowers)
            {
                NSLog(@"filledTower: %d", tower.towerBaseType);
            }

            return TRUE;
        }
        
    }
    
    return FALSE;
}

-(BOOL)checkSpecialCombineRound
{
    for(SpecialTower *specialTower in specialTowers)
    {
        int numReqTowerFilled = 0;
        NSMutableArray *filledTowers = [[NSMutableArray alloc] init];
        [self resetFilled:specialTower];
        
        for(Tower *tower in roundTowers)
        {
            for(TowerTypeQuality *reqTower in specialTower.requiredTowers)
            {
                //NSLog(@"reqTower %d %d %d", reqTower.type, reqTower.quality, reqTower.filled);
                //NSLog(@"towerType %d %d", tower.towerBaseType, tower.towerQuality);
                
                if(reqTower.type == tower.towerBaseType &&
                   reqTower.quality == tower.towerQuality)
                {
                    if(!reqTower.filled)
                    {
                        numReqTowerFilled++;
                    }
                    
                    [filledTowers addObject:tower];
                    reqTower.filled = TRUE;
                }
            }
        }
        
        if([specialTower.requiredTowers count] == numReqTowerFilled &&
           [filledTowers containsObject:selectedTower])
        {
            specialFoundTower = specialTower;
            return TRUE;
        }
           
    }
    
    return FALSE;
}

-(void)resetFilled:(SpecialTower *)specialTower
{
    for(TowerTypeQuality *reqTower in specialTower.requiredTowers)
    {
        reqTower.filled = FALSE;
    }
}

-(void)setRestrictedTiles
{
    //Set spawn point restricted
    [map setRestrictedTile:1 y:35];
    [map setRestrictedTile:1 y:34];
    [map setRestrictedTile:0 y:35];
    [map setRestrictedTile:0 y:34];
    
    //Set 1st restricted corner
    [map setRestrictedTile:6 y:35];
    [map setRestrictedTile:6 y:34];
    [map setRestrictedTile:5 y:35];
    [map setRestrictedTile:5 y:34];
    
    [map setRestrictedTile:8 y:35];
    [map setRestrictedTile:8 y:34];
    [map setRestrictedTile:7 y:35];
    [map setRestrictedTile:7 y:34];
    
    [map setRestrictedTile:10 y:35];
    [map setRestrictedTile:10 y:34];
    [map setRestrictedTile:9 y:35];
    [map setRestrictedTile:9 y:34];
    
    [map setRestrictedTile:8 y:33];
    [map setRestrictedTile:8 y:32];
    [map setRestrictedTile:7 y:33];
    [map setRestrictedTile:7 y:32];
    
    //Set 2nd restricted corner
    [map setRestrictedTile:8 y:20];
    [map setRestrictedTile:8 y:19];
    [map setRestrictedTile:7 y:20];
    [map setRestrictedTile:7 y:19];

    [map setRestrictedTile:8 y:18];
    [map setRestrictedTile:8 y:17];
    [map setRestrictedTile:7 y:18];
    [map setRestrictedTile:7 y:17];
    
    [map setRestrictedTile:8 y:16];
    [map setRestrictedTile:8 y:15];
    [map setRestrictedTile:7 y:16];
    [map setRestrictedTile:7 y:15];
    
    [map setRestrictedTile:10 y:18];
    [map setRestrictedTile:10 y:17];
    [map setRestrictedTile:9 y:18];
    [map setRestrictedTile:9 y:17];
    
    //Set 3rd restricted corner
    [map setRestrictedTile:30 y:18];
    [map setRestrictedTile:30 y:17];
    [map setRestrictedTile:29 y:18];
    [map setRestrictedTile:29 y:17];
    
    [map setRestrictedTile:32 y:18];
    [map setRestrictedTile:32 y:17];
    [map setRestrictedTile:31 y:18];
    [map setRestrictedTile:31 y:17];
    
    [map setRestrictedTile:32 y:20];
    [map setRestrictedTile:32 y:19];
    [map setRestrictedTile:31 y:20];
    [map setRestrictedTile:31 y:19];
    
    [map setRestrictedTile:32 y:16];
    [map setRestrictedTile:32 y:15];
    [map setRestrictedTile:31 y:16];
    [map setRestrictedTile:31 y:15];
    
    //Set 4th restricted corner
    [map setRestrictedTile:30 y:35];
    [map setRestrictedTile:30 y:34];
    [map setRestrictedTile:29 y:35];
    [map setRestrictedTile:29 y:34];
    
    [map setRestrictedTile:32 y:35];
    [map setRestrictedTile:32 y:34];
    [map setRestrictedTile:31 y:35];
    [map setRestrictedTile:31 y:34];
    
    [map setRestrictedTile:34 y:35];
    [map setRestrictedTile:34 y:34];
    [map setRestrictedTile:33 y:35];
    [map setRestrictedTile:33 y:34];
    
    [map setRestrictedTile:32 y:33];
    [map setRestrictedTile:32 y:32];
    [map setRestrictedTile:31 y:33];
    [map setRestrictedTile:31 y:32];
    
    //Set 5th restricted corner
    [map setRestrictedTile:22 y:35];
    [map setRestrictedTile:22 y:34];
    [map setRestrictedTile:21 y:35];
    [map setRestrictedTile:21 y:34];
    
    [map setRestrictedTile:20 y:35];
    [map setRestrictedTile:20 y:34];
    [map setRestrictedTile:19 y:35];
    [map setRestrictedTile:19 y:34];
    
    [map setRestrictedTile:18 y:35];
    [map setRestrictedTile:18 y:34];
    [map setRestrictedTile:17 y:35];
    [map setRestrictedTile:17 y:34];
    
    [map setRestrictedTile:20 y:33];
    [map setRestrictedTile:20 y:32];
    [map setRestrictedTile:19 y:33];
    [map setRestrictedTile:19 y:32];
    
    //Set 6th restricted corner
    [map setRestrictedTile:22 y:7];
    [map setRestrictedTile:22 y:6];
    [map setRestrictedTile:21 y:7];
    [map setRestrictedTile:21 y:6];
    
    [map setRestrictedTile:20 y:9];
    [map setRestrictedTile:20 y:8];
    [map setRestrictedTile:19 y:9];
    [map setRestrictedTile:19 y:8];
    
    [map setRestrictedTile:18 y:7];
    [map setRestrictedTile:18 y:6];
    [map setRestrictedTile:17 y:7];
    [map setRestrictedTile:17 y:6];
    
    [map setRestrictedTile:20 y:7];
    [map setRestrictedTile:20 y:6];
    [map setRestrictedTile:19 y:7];
    [map setRestrictedTile:19 y:6];
    
    //End two squares
    [map setRestrictedTile:39 y:7];
    [map setRestrictedTile:39 y:6];
}

-(void)setGameLayerPos:(CGPoint)pos
{    
    if(pos.x > 260)
        pos.x = 260;

    if(pos.x < -260)
        pos.x = -260;
    
    if(pos.y < -260)
        pos.y = -260;

    if(pos.y > 260)
        pos.y = 260;
    
    [gameLayer setPosition: pos];
    
}

-(void)setPath
{    
    path = [self findPath];
}

-(NSMutableArray *)findPath
{
    NSMutableArray *fullpath = [[NSMutableArray alloc] init];
    NSMutableArray *waypoints = [[NSMutableArray alloc] init];

    [waypoints addObject: [NSValue valueWithCGPoint: ccp(0, 35)]];
    [waypoints addObject: [NSValue valueWithCGPoint: ccp(8, 35)]];
    [waypoints addObject: [NSValue valueWithCGPoint: ccp(8, 18)]];
    [waypoints addObject: [NSValue valueWithCGPoint: ccp(32, 18)]];
    [waypoints addObject: [NSValue valueWithCGPoint: ccp(32, 34)]];
    [waypoints addObject: [NSValue valueWithCGPoint: ccp(20, 34)]];
    [waypoints addObject: [NSValue valueWithCGPoint: ccp(20, 6)]];
    [waypoints addObject: [NSValue valueWithCGPoint: ccp(39, 6)]];
    
    int i = 1;
    NSValue *prev = [waypoints objectAtIndex:0];
    
    while(i < [waypoints count])
    {
        NSValue *curr = [waypoints objectAtIndex:i];
        
        CGPoint prevCoord = [prev CGPointValue];
        CGPoint currCoord = [curr CGPointValue];
        
        NSMutableArray *section = [map findPath2:prevCoord toTileCoord:currCoord];

        if(section == nil)
        {
            return nil;
        }
        
        NSArray *tempSection =  [[section reverseObjectEnumerator] allObjects];
        [fullpath addObjectsFromArray: tempSection];

        
        prev = curr;
        i++;
    }
    
    return fullpath;
}

-(void)loadWave
{
    for(int i = 0; i < 10; i++)
    {
        Enemy * enemy = [Enemy nodeWithTheGame:self enemyId:i];
        [enemy setup];
        
        if(enemy.flying)
        {
            flying = true;
            [enemy setPath:flyingPath];
        }
        else
        {
            flying = false;
            [enemy setPath:path];
        }
        
        NSLog(@"Adding enemy to list of enemies");
        [enemies addObject:enemy];
        [enemy schedule:@selector(doActivate) interval: (SPAWN_FREQ * i)];
    }

    [ui_wave_lbl setString:[NSString stringWithFormat:@"WAVE: %d",wave]];
    
}

-(void)setActivateTowers
{
    for(NSNumber *index in towers)
    {
        Tower *tower = [towers objectForKey:index];
        [tower attackEnemy];
    }
}

-(void)checkAuras
{    
    for(NSNumber *i in towers)
    {
        Tower *auraTower = [towers objectForKey:i];
        
        if(auraTower.bonusAura)
        {
            for(NSNumber *j in towers)
            {
                Tower *tower = [towers objectForKey:j];
                
                if(auraTower.speedAuraOpalValue > 0)
                {
                    if([self checkCollision:auraTower.position
                                    radius1:auraTower.speedAuraOpalRange
                                    center2:tower.position radius2:1])
                    {

                        tower.speedAuraValue = auraTower.speedAuraOpalValue;
                    }
                }
                else if(auraTower.damageAuraSpecialValue > 0)
                {
                    if([self checkCollision:auraTower.position
                                    radius1:auraTower.damageAuraSpecialRange
                                    center2:tower.position radius2:1])
                    {
                        
                        tower.damageAuraValue = auraTower.damageAuraSpecialValue;
                    }
                }
                
            }
        }
    }
}

-(void)enemyGotKilled
{
    gold++;
    score++;
    
    [ui updateGoldText];
    [ui updateScoreText];
    
    if ([enemies count] == 0)
    {
        //Stop attacking
        for(NSNumber *index in towers)
        {
            Tower *tower = [towers objectForKey:index];
            [tower attackStop];
        }
        
        [self resetRound];
    }
}

-(void)enemyReachedEnd
{
    lives--;
    [ui updateLivesText];
    
    if(lives <= 0 && (!lost))
    {
        lost = TRUE;
        
        [ui showLost];
        //[self uploadScore];
    }
    else if([enemies count] == 0)
    {
        [self resetRound];
    }
        
}

-(void)resetRound
{
    phase = Place;
    
    level++;
    [ui updateLevelText];
    
    //Clear roundTowers
    roundTowers = [[NSMutableArray alloc] init];
}

-(void)createCrit:(int)crit pos:(CGPoint)_pos
{
    NSString *critText = [NSString stringWithFormat:@"%d!", crit];
    NSLog(@"createCritText %@ pos: %f %f", critText, _pos.x, _pos.y);
    CritLabel *critLabel = [CritLabel nodeWithTheGame:crit pos:_pos];
    
    [gameLayer addChild:critLabel];
}

-(BOOL)checkCollision:(CGPoint)center1 radius1:(float)radius1
center2:(CGPoint)center2 radius2:(float)radius2
{
    float xdif = center1.x - center2.x;
    float ydif = center1.y - center2.y;
    
    float distance = sqrt(xdif*xdif+ydif*ydif);
    
    if(distance <= radius1+radius2)
        return YES;
    
    return NO;
}

-(TowerTypeQuality *)standardTower:(int)_quality _type:(int)_type
{
    TowerTypeQuality *tower = [[TowerTypeQuality alloc] init];
    tower.type = _type;
    tower.quality = _quality;
    tower.filled = FALSE;
    
    return tower;
}

-(SpecialTower *)specialTower:(int)_type
{
    SpecialTower *tower = [[SpecialTower alloc] init];
    
    tower.requiredTowers = [[NSMutableArray alloc] init];
    tower.type = _type;
    
    return tower;
}

-(void)initSpecialTowers
{
    //BlackOpal Tower
    SpecialTower *blackOpal = [self specialTower:BlackOpal];
    
    TowerTypeQuality *perfectOpal = [self standardTower:Perfect _type:Opal];
    TowerTypeQuality *flawlessDiamond = [self standardTower:Flawless _type:Diamond];
    TowerTypeQuality *normalAquamarine = [self standardTower:Normal _type:Aquamarine];
    
    [blackOpal.requiredTowers addObject:perfectOpal];
    [blackOpal.requiredTowers addObject:flawlessDiamond];
    [blackOpal.requiredTowers addObject:normalAquamarine];
    
    [specialTowers addObject:blackOpal];
    
    //Bloodstone Tower
    SpecialTower *bloodStone = [self specialTower:BloodStone];
    
    TowerTypeQuality *perfectRuby = [self standardTower:Perfect _type:Ruby];
    TowerTypeQuality *flawlessAquamarine = [self standardTower:Flawless _type:Aquamarine];
    TowerTypeQuality *normalAmethyst = [self standardTower:Normal _type:Amethyst];
    
    [bloodStone.requiredTowers addObject:perfectRuby];
    [bloodStone.requiredTowers addObject:flawlessAquamarine];
    [bloodStone.requiredTowers addObject:normalAmethyst];
    
    [specialTowers addObject:bloodStone];
    
    //Dark Emerald
    SpecialTower *darkEmerald = [self specialTower:BloodStone];
    
    TowerTypeQuality *perfectEmerald = [self standardTower:Perfect _type:Emerald];
    TowerTypeQuality *flawlessSapphire = [self standardTower:Flawless _type:Sapphire];
    TowerTypeQuality *flawedTopaz = [self standardTower:Flawed _type:Topaz];
    
    [darkEmerald.requiredTowers addObject:perfectEmerald];
    [darkEmerald.requiredTowers addObject:flawlessSapphire];
    [darkEmerald.requiredTowers addObject:flawedTopaz];
    
    [specialTowers addObject:darkEmerald];
    
    //Gold
    SpecialTower *goldTower = [self specialTower:Gold];
    
    TowerTypeQuality *perfectAmethyst = [self standardTower:Perfect _type:Amethyst];
    TowerTypeQuality *flawlessAmethyst = [self standardTower:Flawless _type:Amethyst];
    TowerTypeQuality *flawedDiamond = [self standardTower:Flawed _type:Diamond];
    
    [goldTower.requiredTowers addObject:perfectAmethyst];
    [goldTower.requiredTowers addObject:flawlessAmethyst];
    [goldTower.requiredTowers addObject:flawedDiamond];
    
    [specialTowers addObject:goldTower];
    
    //Jade
    SpecialTower *jade = [self specialTower:Jade];
    
    TowerTypeQuality *normalEmerald = [self standardTower:Normal _type:Emerald];
    TowerTypeQuality *normalOpal = [self standardTower:Normal _type:Opal];
    TowerTypeQuality *flawedSapphire = [self standardTower:Flawed _type:Sapphire];
    
    [jade.requiredTowers addObject:normalEmerald];
    [jade.requiredTowers addObject:normalOpal];
    [jade.requiredTowers addObject:flawedSapphire];
    
    [specialTowers addObject:jade];
    
    //Malachite
    SpecialTower *malachite = [self specialTower:Malachite];
    
    TowerTypeQuality *chippedOpal = [self standardTower:Chipped _type:Opal];
    TowerTypeQuality *chippedEmerald = [self standardTower:Chipped _type:Emerald];
    TowerTypeQuality *chippedAquamarine = [self standardTower:Chipped _type:Aquamarine];
    
    [malachite.requiredTowers addObject:chippedOpal];
    [malachite.requiredTowers addObject:chippedEmerald];
    [malachite.requiredTowers addObject:chippedAquamarine];
    
    [specialTowers addObject:malachite];
    
    //Paraiba
    SpecialTower *paraiba = [self specialTower:Paraiba];
    
    TowerTypeQuality *perfectAquamarine = [self standardTower:Perfect _type:Aquamarine];
    TowerTypeQuality *flawlessOpal = [self standardTower:Flawless _type:Opal];
    TowerTypeQuality *flawedEmerald = [self standardTower:Emerald _type:Flawed];
    
    [paraiba.requiredTowers addObject:perfectAquamarine];
    [paraiba.requiredTowers addObject:flawlessOpal];
    [paraiba.requiredTowers addObject:flawedEmerald];
    
    [specialTowers addObject:paraiba];
    
    //PinkDiamond
    SpecialTower *pinkdiamond = [self specialTower:PinkDiamond];
    
    TowerTypeQuality *perfectDiamond = [self standardTower:Perfect _type:Diamond];
    TowerTypeQuality *normalTopaz = [self standardTower:Normal _type:Topaz];
    TowerTypeQuality *normalDiamond = [self standardTower:Normal _type:Diamond];
    
    [pinkdiamond.requiredTowers addObject:perfectDiamond];
    [pinkdiamond.requiredTowers addObject:normalTopaz];
    [pinkdiamond.requiredTowers addObject:normalDiamond];
    
    [specialTowers addObject:pinkdiamond];
    
    //RedCrystal
    SpecialTower *redCrystal = [self specialTower:RedCrystal];
    
    TowerTypeQuality *flawlessEmerald = [self standardTower:Flawless _type:Emerald];
    TowerTypeQuality *normalRuby = [self standardTower:Normal _type:Ruby];
    TowerTypeQuality *flawedAmethyst = [self standardTower:Flawed _type:Amethyst];
    
    [redCrystal.requiredTowers addObject:flawlessEmerald];
    [redCrystal.requiredTowers addObject:normalRuby];
    [redCrystal.requiredTowers addObject:flawedAmethyst];
    
    [specialTowers addObject:redCrystal];
    
    //Silver Tower
    SpecialTower *silver = [self specialTower:Silver];
    
    TowerTypeQuality *chippedShappire = [self standardTower:Chipped _type:Sapphire];
    TowerTypeQuality *chippedTopaz = [self standardTower:Chipped _type:Topaz];
    TowerTypeQuality *chippedDiamond = [self standardTower:Chipped _type:Diamond];
    
    [silver.requiredTowers addObject:chippedShappire];
    [silver.requiredTowers addObject:chippedTopaz];
    [silver.requiredTowers addObject:chippedDiamond];
    
    [specialTowers addObject:silver];
    
    //Star Ruby
    SpecialTower *starRuby = [self specialTower:StarRuby];
    
    TowerTypeQuality *chippedRuby = [self standardTower:Chipped _type:Ruby];
    TowerTypeQuality *chippedAmethyst = [self standardTower:Chipped _type:Amethyst];
    TowerTypeQuality *flawedRuby = [self standardTower:Flawed _type:Ruby];
    
    [starRuby.requiredTowers addObject:chippedRuby];
    [starRuby.requiredTowers addObject:chippedAmethyst];
    [starRuby.requiredTowers addObject:flawedRuby];
    
    [specialTowers addObject:starRuby];
    
    //Uranium
    SpecialTower *uranium = [self specialTower:Uranium238];
    
    TowerTypeQuality *perfectTopaz = [self standardTower:Perfect _type:Topaz];
    TowerTypeQuality *flawedOpal = [self standardTower:Flawed _type:Opal];
    TowerTypeQuality *normalSapphire = [self standardTower:Normal _type:Sapphire];
    
    [uranium.requiredTowers addObject:perfectTopaz];
    [uranium.requiredTowers addObject:flawedOpal];
    [uranium.requiredTowers addObject:normalSapphire];
    
    [specialTowers addObject:uranium];
    
    //Yellow Sapphire
    SpecialTower *yellowSapphire = [self specialTower:YellowSapphire];
    
    TowerTypeQuality *perfectSapphire = [self standardTower:Perfect _type:Sapphire];
    TowerTypeQuality *flawlessTopaz = [self standardTower:Flawless _type:Topaz];
    TowerTypeQuality *flawlessRuby = [self standardTower:Flawless _type:Ruby];
    
    [yellowSapphire.requiredTowers addObject:perfectSapphire];
    [yellowSapphire.requiredTowers addObject:flawlessTopaz];
    [yellowSapphire.requiredTowers addObject:flawlessRuby];
    
    [specialTowers addObject:yellowSapphire];
}

-(void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        
        NSLog(@"viewController: %@", viewController);
        NSLog(@"localplayer: %hhd", [GKLocalPlayer localPlayer].authenticated);
        if ([GKLocalPlayer localPlayer].authenticated)
        {
            gameCenterEnabled = TRUE;
            
            // Get the default leaderboard identifier.
            [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error)
            {
                if (error != nil)
                {
                    NSLog(@"%@", [error localizedDescription]);
                }
                else
                {
                    NSLog(@"%@", leaderboardIdentifier);
                    leaderboardID = leaderboardIdentifier;
                }
            }];
        }
        else
        {
            gameCenterEnabled = FALSE;
        }
    };
}

-(void)uploadScore
{
    NSString *boardID;
    
    if(difficulty == Easy)
    {
        boardID = @"gem_defense_easy";
    }
    else if(difficulty == Hard)
    {
        boardID = @"gem_defense_hard";
    }
    else if(difficulty == Survival)
    {
        boardID = @"gem_defense_survival";
    }
    
    
    GKScore *GKscore = [[GKScore alloc] initWithLeaderboardIdentifier:boardID];
    GKscore.value = score;
    
    [GKScore reportScores:@[GKscore] withCompletionHandler:^(NSError *error)
    {
        NSLog(@"Uploaded score");
        if (error != nil)
        {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}


@end
