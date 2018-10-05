//
//  Enemies.h
//  gemtd
//
//  Created by Peter Holko on 13-06-30.
//  Copyright (c) 2013 Holko. All rights reserved.
//

#import "cocos2d.h"
#import "Game.h"
#import "DamageTable.h"

#define ICE_DURATION 5.0;
#define BASE_SPEED 265;

@class Game, Tower;

@interface Enemy: CCNode{
    
    
    
    CGPoint myPosition;
    int myWidth;
    int myHeight;
    
    int maxHp;
    int currentHp;
    
    NSString *enemyName;
    NSString *spriteName;
    
    float speedModifier;
    float walkingSpeed;
    float baseSpeed;
    
    float iceModifier;
    float iceDuration;
    int numIce;
    
    float poisonModifier;
    float poisonDamage;
    float poisonDuration;
    int numPoison;
    
    float stunModifier;
    float stunDuration;
    int numStun;

    float armorPenaltyDuration;
    int numArmorPenalty;
    
    NSMutableArray *attackedBy;
    
    NSMutableArray *path;
    int pathIndex;
    CGPoint currentDest;
}

@property (nonatomic,weak) Game *theGame;
@property (nonatomic,strong) CCSprite *mySprite;
@property (nonatomic,readonly) ArmorType armorType;
@property (nonatomic,readonly) int armor;
@property (nonatomic,readonly) int armorPenaltyValue;
@property (nonatomic,readonly) int auraArmorPenaltyValue;
@property (nonatomic,readonly) float auraSpeedPenaltyValue;
@property (nonatomic,readonly) BOOL active;
@property (nonatomic,readonly) BOOL flying;
@property (nonatomic,readonly) int enemyId;

+(id)nodeWithTheGame:(Game *)_game enemyId:(int)_enemyId;
-(id)initWithTheGame:(Game *)_game enemyId:(int)_enemyId;

-(void)setup;

-(void)setPath:(NSMutableArray *)_path;
-(void)doActivate;
-(void)changeSprite:(NSString *)fileName;

-(void)applyIceSlow:(float)_modifier;
-(void)applyPoison:(float)_modifier damage:(float)damage duration:(float)duration;
-(void)applyStun:(int)duration;
-(void)applyArmorPenalty:(int)penaltyValue duration:(int)duration;
-(void)applyAuraArmorPenalty:(int)penaltyValue;
-(void)removeAuraArmorPenalty;
-(void)applyAuraSpeedPenalty:(float)penaltyValue;
-(void)removeAuraSpeedPenalty;

-(void)applyPoisonDamage;
-(void)removeIce;
-(void)removeStun;
-(void)removeArmorPenalty;

-(void)setEnemyPosition;
-(float)calculateWalkingSpeed;
-(void)getDamaged:(int)damage;
-(void)getRemoved:(BOOL)killed;
-(void)getAttacked:(Tower *)attacker;
-(void)gotLostSight:(Tower *)attacker;
-(CGPoint)getPosition;

-(void)setEnemyStats;
-(void)setSurvivalLevels;

@end