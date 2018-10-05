//
//  Game
//  GemTD
//
//  Created by Peter Holko on 29/6/13.
//  Copyright Peter Holko 2013. All rights reserved.
//
#define TILE_SIZE 13
#define DBL_TILE_SIZE 2 * TILE_SIZE
#define SPAWN_FREQ 1

#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Map.h"
#import "UI.h"
#import "DamageTable.h"

@class UI;

typedef enum{
    Place,
    Move,
    Select,
    Wave
} GamePhase;

typedef enum{
    None,
    Easy,
    Hard,
    Survival
} Difficulty;

@interface TowerTypeQuality : NSObject
@property (nonatomic, readwrite) int type;
@property (nonatomic, readwrite) int quality;
@property (nonatomic, readwrite) BOOL filled;
@end

@interface SpecialTower : NSObject
@property (nonatomic, readwrite) int type;
@property (nonatomic, strong) NSMutableArray *requiredTowers;
@end

// Game
@interface Game : CCLayer
{    
    Map *map;
    UI *ui;
    
    CGPoint prevTouch;
    
    NSMutableArray *roundTowers;
    NSMutableArray *specialTowers;
    NSMutableArray *specialFilledTowers;
    NSMutableArray *path;
    NSMutableArray *flyingPath;
    
    Tower *selectedTower;
    Tower *lastKeepCombineTower;
    SpecialTower *specialFoundTower;
    
    CCLabelBMFont *ui_wave_lbl;
    
    int wave;
    BOOL lost;
}

@property (nonatomic, readonly) CGSize winSize;
@property (nonatomic, strong) CCLayer *gameLayer;
@property (nonatomic, strong) CCLayer *uiLayer;
@property (nonatomic,strong) NSMutableDictionary *towers;
@property (nonatomic,strong) NSMutableArray *enemies;
@property (nonatomic, readonly) DamageTable *damageTable;
@property (nonatomic, readonly) BOOL flying;
@property (nonatomic, readonly) int level;
@property (nonatomic, readonly) GamePhase phase;
@property (nonatomic, readwrite) int armorLevel;
@property (nonatomic, readonly) int qualityLevel;
@property (nonatomic, readonly) int chippedChance;
@property (nonatomic, readonly) int flawedChance;
@property (nonatomic, readonly) int normalChance;
@property (nonatomic, readonly) int flawlessChance;
@property (nonatomic, readonly) int perfectChance;
@property (nonatomic, readonly) int gold;
@property (nonatomic, readonly) int score;
@property (nonatomic, readwrite) Difficulty difficulty;
@property (nonatomic, readonly) int lives;
@property (nonatomic, readonly) BOOL gameCenterEnabled;
@property (nonatomic, readonly) NSString *leaderboardID;

// returns a CCScene that contains the Game as the only child
+(CCScene *) scene;

-(void)reset;

-(void)setUpgradeChanceCost;
-(int)getUpgradeCost;

-(void)processPlacePhase:(CGPoint) location;
-(void)processMovePhase:(CGPoint) location;
-(void)processSelectPhase:(CGPoint)location;
-(void)processSelectWavePhase:(CGPoint)location;
-(void)processKeep;
-(void)processCombine;
-(void)processCombineSpecial;
-(void)processWavePhase;
-(void)processPlace;
-(void)processUpgradeChances;

-(void)setPath;
-(void)checkAuras;

-(void)setUIButtons;
-(BOOL)checkStandardCombine;

-(void)selectTower;
-(void)removeTower;
-(void)upgradeTower;

-(void)enemyGotKilled;
-(void)enemyReachedEnd;
-(void)createCrit:(int)crit pos:(CGPoint)_pos;
-(void)resetFilled:(SpecialTower *)specialTower;

-(TowerTypeQuality *)standardTower:(int)_quality _type:(int)_type;
-(SpecialTower *)specialTower:(int)_type;


-(void)loadWave;
-(BOOL)checkCollision:(CGPoint)center1 radius1:(float)radius1
              center2:(CGPoint)center2 radius2:(float)radius2;

void ccFillPoly(CGPoint *poli, int points, BOOL closePolygon);

-(void)authenticateLocalPlayer;
-(void)uploadScore;

@end

