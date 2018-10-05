//
//  Tower
//  GemTD
//
//  Created by Peter Holko on 29/6/13.
//  Copyright Peter Holko 2013. All rights reserved.
//

#import "cocos2d.h"
#import "Game.h"

#define BASE_RANGE 2000.0;
#define BASE_COOLDOWN 1.0;
#define BASE_PROJECTILE_SPEED 2000.0;
#define ARC4RANDOM_MAX      0x100000000

@class Game, Enemy;

typedef enum {
    Amethyst,
    Aquamarine,
    Diamond,
    Emerald,
    Opal,
    Ruby,
    Sapphire,
    Topaz
} TowerBaseType;

typedef enum{
    Chipped,
    Flawed,
    Normal,
    Flawless,
    Perfect,
    Great
} TowerQuality;

typedef enum {
    Rock,
    Standard,
    BlackOpal,
    MysticBlackOpal,
    BloodStone,
    AncientBloodStone,
    DarkEmerald,
    EnchantedEmerald,
    Gold,
    EgyptianGold,
    Jade,
    AsianJade,
    LuckyAsianJade,
    Malachite,
    VividMalachite,
    MightyMalachite,
    Paraiba,
    ParaibaTourmalineFacet,
    PinkDiamond,
    GreatPinkDiamond,
    RedCrystal,
    RedCrystalFacet,
    RoseQuartzCrystal,
    Silver,
    SterlingSilver,
    SilverKnight,
    StarRuby,
    BloodStar,
    FireStar,
    Uranium238,
    Uranium235,
    YellowSapphire,
    StarYellowSapphire,
    UberStone
} TowerType;

extern NSString * const TowerBaseType_toString[8];
extern NSString * const TowerQuality_toString[6];
extern NSString * const TowerType_toString[50];

@interface Tower: CCNode
{

    NSString *towerName;
    NSString *qualityName;
    
    CGPoint tile;
    
    int attackRange;
    int damageBase;
    int sidesPerDie;
    int numDie;
    int towerLevel;
    
    float projectileSpeed;
    
    float cooldownModifier;
    float rangeModifier;
    float projectileModifier;
    
    BOOL attacksFlying;
    BOOL attacksGround;
    
    int numKills;
    int multiTargets;

    
    BOOL aoe;
    BOOL aoeFreeze;
    int aoeRange;
    
    BOOL iceSlow;
    float iceSlowModifier;
    
    BOOL poisonSlow;
    float poisonSlowModidier;
    float poisonDamage;
    float poisonDuration;
    
    float critChance;
    int critMultiplier;
    
    BOOL stunPossible;
    float stunChance;
    float stunDuration;
    
    BOOL damageBurn;
    
    BOOL armorPenalty;
    int armorPenaltyValue;
    int armorPenaltyDuration;
    
    BOOL proxAuraFlying;
    BOOL proxAuraGround;
    float proxAuraRange;
    float proxAuraSpeedPenalty;
    int proxAuraArmorPenalty;
    
    BOOL attacking;
    Enemy *currentTarget;
    
    NSMutableArray *chosenEnemies;
    NSString *description;
    
}

@property (nonatomic,weak) Game *theGame;
@property (nonatomic,readonly) TowerBaseType towerBaseType;
@property (nonatomic,readonly) TowerType towerType;
@property (nonatomic,readonly) TowerQuality towerQuality;
@property (nonatomic,readonly) TowerType upgradesTo;
@property (nonatomic,readonly) int upgradeCost;
@property (nonatomic,strong) CCSprite *towerSprite;
@property (nonatomic,strong) CCSprite *selectSprite;
@property (nonatomic,readwrite) BOOL towerPlacedThisRound;
@property (nonatomic,readonly) CGPoint tile;
@property (nonatomic,readonly) BOOL selected;
@property (nonatomic,readonly) BOOL bonusAura;
@property (nonatomic,readwrite) float speedAuraValue;
@property (nonatomic,readwrite) float speedAuraOpalValue;
@property (nonatomic,readwrite) float speedAuraOpalRange;
@property (nonatomic,readwrite) float damageAuraValue;
@property (nonatomic,readwrite) float damageAuraSpecialValue;
@property (nonatomic,readwrite) float damageAuraSpecialRange;

+(id)nodeWithTheGame:(Game *)_game tile:(CGPoint)tile;
-(id)initWithTheGame:(Game *)_game tile:(CGPoint)tile;

-(void)randomType;
-(void)randomQuality;
-(void)randomTower;
-(void)setTowerName;
-(void)changeSprite:(NSString *)towerTypeName;
-(void)setSprite;
-(void)remove;
-(void)setSelect:(BOOL)_selected;
-(void)move:(CGPoint)_tile;

-(void)resetAbilities;
-(void)setAttributes;
-(void)setStandardAttributes;

-(float)calculateRange;
-(void)calculateProjectileSpeed;
-(float)calculateDamage;
-(float)calculateFireRate;

-(void)shootWeapon;
-(void)createProjectile:(Enemy *)enemy enemyId:(int)_enemyId;
-(void)damageEnemy:(id)sender data:(void *)_enemy;
-(void)aoeDamage:(BOOL)freeze;
-(void)iceSlowDamage;
-(void)armorPenaltyDamage;

-(void)removeProjectile:(CCSprite *)projectile;
-(void)attackEnemy;
-(void)attackStop;
-(void)targetKilled:(Enemy *)enemy;

-(void)checkProximityAuras:(Enemy *)enemy;
-(void)checkProximitySpeedAura:(Enemy *)enemy;
-(void)checkProximityArmorAura:(Enemy *)enemy;

-(void)changeTower:(TowerType)_type
          _quality:(TowerQuality)_quality;

-(float)getTimeToPoint:(CGPoint)targetPoint
             fromPoint:(CGPoint)sourcePoint
                 speed:(int)travelSpeed;

-(NSString *)getInfoBox;


@end