//
//  Tower
//  GemTD
//
//  Created by Peter Holko on 29/6/13.
//  Copyright Peter Holko 2013. All rights reserved.
//

#import "Tower.h"
#import "Enemy.h"

@implementation Tower

@synthesize towerSprite, theGame, tile, selectSprite, selected, bonusAura;
@synthesize speedAuraValue, speedAuraOpalRange, speedAuraOpalValue;
@synthesize damageAuraValue, damageAuraSpecialValue, damageAuraSpecialRange;
@synthesize towerPlacedThisRound, towerBaseType, towerQuality, towerType;
@synthesize upgradesTo, upgradeCost;

NSString * const TowerBaseType_toString[8] = {
    [Amethyst] = @"Amethyst",
    [Aquamarine] = @"Aquamarine",
    [Diamond] = @"Diamond",
    [Emerald] = @"Emerald",
    [Opal] = @"Opal",
    [Ruby] = @"Ruby",
    [Sapphire] = @"Sapphire",
    [Topaz] = @"Topaz"
};

NSString * const TowerQuality_toString[6] = {
    [Chipped] = @"Chipped",
    [Flawed] = @"Flawed",
    [Normal] = @"Normal",
    [Flawless] = @"Flawless",
    [Perfect] = @"Perfect",
    [Great] = @"Great"
};

NSString * const TowerType_toString[50] = {
    [Rock] = @"Rock",
    [Standard] = @"Standard",
    [BlackOpal] = @"BlackOpal",
    [MysticBlackOpal] = @"MysticBlackOpal",
    [BloodStone] = @"BloodStone",
    [AncientBloodStone] = @"AncientBloodStone",
    [DarkEmerald] = @"DarkEmerald",
    [EnchantedEmerald] = @"EnchantedEmerald",
    [Gold] = @"Gold",
    [EgyptianGold] = @"EgyptianGold",
    [Jade] = @"Jade",
    [AsianJade] = @"AsianJade",
    [LuckyAsianJade] = @"LuckyAsianJade",
    [Malachite] = @"Malachite",
    [VividMalachite] = @"VividMalachite",
    [MightyMalachite] = @"MightyMalachite",
    [Paraiba] = @"Paraiba",
    [ParaibaTourmalineFacet] = @"ParaibaTourmalineFacet",
    [PinkDiamond] = @"PinkDiamond",
    [GreatPinkDiamond] = @"GreatPinkDiamond",
    [RedCrystal] = @"RedCrystal",
    [RedCrystalFacet] = @"RedCrystalFacet",
    [RoseQuartzCrystal] = @"RoseQuartzCrystal",
    [Silver] = @"Silver",
    [SterlingSilver] = @"SterlingSilver",
    [SilverKnight] = @"SilverKnight",
    [StarRuby] = @"StarRuby",
    [BloodStar] = @"BloodStar",
    [FireStar] = @"FireStar",
    [Uranium235] = @"Uranium235",
    [Uranium238] = @"Uranium238",
    [YellowSapphire] = @"YellowSapphire",
    [StarYellowSapphire] = @"StarYellowSapphire",
    [UberStone] = @"UberStone"
    
};


+(id) nodeWithTheGame:(Game *)_game tile:(CGPoint)tile
{
    return [[self alloc] initWithTheGame:_game tile:tile];
}

-(id) initWithTheGame:(Game *)_game tile:(CGPoint)_tile
{
	if( (self=[super init]))
    {
		theGame = _game;
     
        NSString *str = TowerBaseType_toString[Opal];
        
        NSLog(@"str: %@", str);
        
        towerType = Standard;
        towerQuality = 0;
        towerLevel = 0;
        attacking = TRUE;
        
        numKills = 0;
        upgradeCost = 0;
        upgradesTo = Rock;
        
        tile = _tile;
        selected = FALSE;
        towerPlacedThisRound = FALSE;
        
        towerName = @"unknown";
        description = @"Unknown gem";
        
        //[self setSelect:selected];
        [self setSprite];
	}
    
	return self;
}

-(void)randomTower
{
    [self resetAbilities];
    
    [self randomType];
    [self randomQuality];
    [self setTowerName];
    [self changeTower:towerType _quality:towerQuality];
    [self setAttributes];
    [self calculateProjectileSpeed];
    [self setNumEnemies];
    
    [self scheduleUpdate];
}

-(void)resetAbilities
{
    attackRange = 200;
    cooldownModifier = 0;
    projectileModifier = 0;
    rangeModifier = 1;
    numDie = 1;
    
    attacksGround = TRUE;
    attacksFlying = TRUE;
    
    multiTargets = 1;
    
    aoe = FALSE;
    aoeFreeze = FALSE;
    aoeRange = 0;
    
    iceSlow = FALSE;
    iceSlowModifier = 0;
    
    poisonSlow = FALSE;
    poisonSlowModidier = 0;
    poisonDamage = 0;
    poisonDuration = 0;
    
    bonusAura = FALSE;
    speedAuraOpalRange = 0;
    speedAuraOpalValue = 0;
    speedAuraValue = 0;
    
    stunPossible = FALSE;
    stunChance = 0;
    stunDuration = 0;
    
    damageBurn = FALSE;
    
    armorPenalty = FALSE;
    armorPenaltyValue = 0;
    armorPenaltyDuration = 0;
    
    damageAuraValue = 0;
    damageAuraSpecialValue = 0;
    damageAuraSpecialValue = 0;
    
    proxAuraFlying = FALSE;
    proxAuraGround = FALSE;
    proxAuraRange = FALSE;
    proxAuraSpeedPenalty = 0;
    proxAuraArmorPenalty = 0;
}

-(void)randomType
{
    int randomType = arc4random_uniform(96);
    
    if(randomType >= 0 && randomType < 12)
    {
        towerBaseType = Amethyst;
    }
    else if(randomType >= 12 && randomType < 24)
    {
        towerBaseType = Aquamarine;
    }
    else if(randomType >= 24 && randomType < 36)
    {
        towerBaseType = Diamond;
    }
    else if(randomType >= 36 && randomType < 48)
    {
        towerBaseType = Emerald;
    }
    else if(randomType >= 48 && randomType < 60)
    {
        towerBaseType = Opal;
    }
    else if(randomType >= 60 && randomType < 72)
    {
        towerBaseType = Ruby;
    }
    else if(randomType >= 72 && randomType < 84)
    {
        towerBaseType = Sapphire;
    }
    else if(randomType >= 84 && randomType < 96)
    {
        towerBaseType = Topaz;
    }

    //DEBUG
    /*if(randomType >= 0 && randomType < 33)
    {
        towerBaseType = Diamond;
    }
    else if(randomType >= 33 && randomType < 66)
    {
        towerBaseType = Sapphire;
    }
    else if(randomType >= 66 && randomType < 96)
    {
        towerBaseType = Topaz;
    }*/
    
}

-(void)randomQuality
{
    double randomQuality = ((double)arc4random() / ARC4RANDOM_MAX);
    
    NSLog(@"randomQuality: %f", randomQuality);
    
    if(theGame.qualityLevel == 0)
    {
        towerQuality = Chipped;
        
    }
    else if(theGame.qualityLevel == 1)
    {
        if(randomQuality >= 0 && randomQuality < 0.7)
        {
            towerQuality = Chipped;
        }
        else
        {
            towerQuality = Flawed;
        }
        
    }
    else if(theGame.qualityLevel == 2)
    {
        if(randomQuality >= 0 && randomQuality < 0.6)
        {
            towerQuality = Chipped;
        }
        else if(randomQuality >= 0.6 && randomQuality < 0.9)
        {
            towerQuality = Flawed;
        }
        else if(randomQuality >= 0.9 && randomQuality <= 1)
        {
            towerQuality = Normal;
        }
    }
    else if(theGame.qualityLevel == 3)
    {
        if(randomQuality >= 0 && randomQuality < 0.5)
        {
            towerQuality = Chipped;
        }
        else if(randomQuality >= 0.5 && randomQuality < 0.8)
        {
            towerQuality = Flawed;
        }
        else if(randomQuality >= 0.8 && randomQuality <= 1)
        {
            towerQuality = Normal;
        }
    }
    else if(theGame.qualityLevel == 4)
    {
        if(randomQuality >= 0 && randomQuality < 0.4)
        {
            towerQuality = Chipped;
        }
        else if(randomQuality >= 0.4 && randomQuality < 0.7)
        {
            towerQuality = Flawed;
        }
        else if(randomQuality >= 0.7 && randomQuality < 0.9)
        {
            towerQuality = Normal;
        }
        else if(randomQuality >= 0.9 && randomQuality <= 1)
        {
            towerQuality = Flawless;
        }
    }
    else if(theGame.qualityLevel == 5)
    {
        if(randomQuality >= 0 && randomQuality < 0.3)
        {
            towerQuality = Chipped;
        }
        else if(randomQuality >= 0.3 && randomQuality < 0.6)
        {
            towerQuality = Flawed;
        }
        else if(randomQuality >= 0.6 && randomQuality < 0.9)
        {
            towerQuality = Normal;
        }
        else if(randomQuality >= 0.9 && randomQuality <= 1)
        {
            towerQuality = Flawless;
        }
    }
    else if(theGame.qualityLevel == 6)
    {
        if(randomQuality >= 0 && randomQuality < 0.2)
        {
            towerQuality = Chipped;
        }
        else if(randomQuality >= 0.2 && randomQuality < 0.5)
        {
            towerQuality = Flawed;
        }
        else if(randomQuality >= 0.5 && randomQuality < 0.8)
        {
            towerQuality = Normal;
        }
        else if(randomQuality >= 0.8 && randomQuality <= 1)
        {
            towerQuality = Flawless;
        }
    }
    else if(theGame.qualityLevel == 7)
    {
        if(randomQuality >= 0 && randomQuality < 0.1)
        {
            towerQuality = Chipped;
        }
        else if(randomQuality >= 0.1 && randomQuality < 0.4)
        {
            towerQuality = Flawed;
        }
        else if(randomQuality >= 0.4 && randomQuality < 0.7)
        {
            towerQuality = Normal;
        }
        else if(randomQuality >= 0.7 && randomQuality <= 1)
        {
            towerQuality = Flawless;
        }
    }
    else if(theGame.qualityLevel == 8)
    {
        if(randomQuality >= 0 && randomQuality < 0.3)
        {
            towerQuality = Flawed;
        }
        else if(randomQuality >= 0.3 && randomQuality < 0.6)
        {
            towerQuality = Normal;
        }
        else if(randomQuality >= 0.6 && randomQuality < 0.9)
        {
            towerQuality = Flawless;
        }				
        else if(randomQuality >= 0.9 && randomQuality <= 1)
        {
            towerQuality = Perfect;
        }	
    }
}

-(void)setTowerName
{
    switch(towerType)
    {
        case Rock:
            towerName = TowerType_toString[Rock];
            break;
        case Standard:
  
            towerName = [NSString stringWithFormat:@"%@ %@",
                         TowerQuality_toString[towerQuality],
                         TowerBaseType_toString[towerBaseType]];
            break;
        default:
            [self setSpecialTowerName];
    }
    
    NSLog(@"TowerName: %@", towerName);
}

-(void)setSpecialTowerName
{
    NSString *unSplitName = TowerType_toString[towerType];
    NSMutableString *name = [NSMutableString stringWithString:unSplitName];
    BOOL isUppercase;
    
    //Ignore first character in string
    for (NSInteger i = 1; i < unSplitName.length; i++)
    {
        isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[unSplitName characterAtIndex:i]];
        
        if(isUppercase)
        {
            [name insertString:@" " atIndex:i];
        }
    }

    towerName = name;
}


-(void)setSprite
{
    NSString *stripTowerName = [towerName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *fileName = [NSString stringWithFormat:@"%@.png", [stripTowerName lowercaseString]];
    
    towerSprite = [CCSprite spriteWithFile: fileName];
    [self addChild:towerSprite];
    
    int gameLayerPosX = tile.x * TILE_SIZE;
    int gameLayerPosY = tile.y * TILE_SIZE;
    
    NSLog(@"new tower: %d %d", gameLayerPosX, gameLayerPosY);
    
    [towerSprite setPosition:ccp(gameLayerPosX, gameLayerPosY)];
    
    [theGame.gameLayer addChild:self];
}

-(void)remove
{
    [theGame.gameLayer removeChild:self];
}

-(void)move:(CGPoint)_tile
{
    tile = _tile;
    
    int gameLayerPosX = tile.x * TILE_SIZE;
    int gameLayerPosY = tile.y * TILE_SIZE;
    
    [towerSprite setPosition:ccp(gameLayerPosX, gameLayerPosY)];
}

-(void)setSelect:(BOOL)_selected
{
    selected = _selected;
    
    if(selected)
    {
        selectSprite = [CCSprite spriteWithFile:@"select.png"];
        selectSprite.position = ccp([towerSprite boundingBox].size.width / 2,
                                    [towerSprite boundingBox].size.height / 2);
        
        [towerSprite addChild:selectSprite];
    }
    else
    {
        if(select)
        {
            [towerSprite removeChild:selectSprite];
        }
    }
}

-(void)changeSprite:(NSString *)towerTypeName
{
    NSString *fileName = [NSString stringWithFormat:@"%@.png", [towerTypeName lowercaseString]];
    
    CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: fileName];
    [towerSprite setTexture: tex];
}

-(void)changeTower:(TowerType)_type
          _quality:(TowerQuality)_quality
{
    towerType = _type;
    towerQuality = _quality;
    
    NSLog(@"towerType: %d towerQuality: %d", towerType, towerQuality);
    
    if(towerType == Rock)
    {
        attacking = FALSE;
        [self changeSprite:@"Rock"];
    }
    else if(towerType == Standard)
    {
        NSString *standardName = [NSString stringWithFormat:@"%@%@",
                                  TowerQuality_toString[_quality],
                                  TowerBaseType_toString[towerBaseType]];
        
        [self changeSprite:standardName];
    }
    else
    {
        NSLog(@"towerType: %u", towerType);
        
        [self changeSprite: TowerType_toString[towerType]];
    }
    
    //NSLog(@"towerType: %d towerQuality: %d", towerType, towerQuality);
    
    [self setTowerName];
    [self setAttributes];
    
    NSLog(@"Tower.getInfoBox: %@", [self getInfoBox]);
}

-(float)calculateRange
{
    return attackRange = 286 * rangeModifier;
}

-(float)calculateFireRate
{
    return (1 * cooldownModifier) - (1 * cooldownModifier * speedAuraValue);
}

-(void)calculateProjectileSpeed
{
    projectileSpeed = 500 * projectileModifier;
}

-(float)calculateDamage
{
    int enemyArmor = currentTarget.armor - currentTarget.armorPenaltyValue + theGame.armorLevel;
    
    float damageTypeModifier = [theGame.damageTable getDamageModifier:towerBaseType
                                                            armorType:currentTarget.armorType];
    
    float armorTypeModifier = [theGame.damageTable getArmorModifier:enemyArmor];
    
    int i = 0;
    float damageRoll;
    float damage;
    
    while(i < numDie)
    {
        damageRoll = arc4random_uniform(sidesPerDie) + 1;
        i++;
    }
    
    damage = damageRoll + damageBase;
    damage = damage * damageTypeModifier * armorTypeModifier * (1 + towerLevel / 10);
    damage = damage * (1 + damageAuraValue);
    
    if(critChance > 0)
    {
        float crit = ((double)arc4random() / ARC4RANDOM_MAX);
        
        if(crit < critChance)
        {
            damage = damage * critMultiplier;
            [theGame createCrit:(int)damage pos: [currentTarget getPosition]];
        }
    }
    
    return damage;
}

-(float) calculateDamageRange:(BOOL)lowerValue
{
    if(lowerValue)
    {
        return (damageBase + numDie) * (1 + towerLevel / 10) * (1 + damageAuraValue);
    }
    else
    {
        return (damageBase + numDie * sidesPerDie) * (1 + towerLevel / 10) * (1 + damageAuraValue);
    }
}

-(void)setNumEnemies
{
    chosenEnemies = [[NSMutableArray alloc] init];
}

-(void)attackEnemy
{
    if(attacking)
    {
        if(theGame.flying)
        {
            if(attacksFlying)
            {
                if(!damageBurn)
                    [self schedule:@selector(shootWeapon) interval: [self calculateFireRate]];
                else
                    [self schedule:@selector(damageBurnEnemy) interval: [self calculateFireRate]];
            }
        }
        else
        {
            if(attacksGround)
            {
                if(!damageBurn)
                    [self schedule:@selector(shootWeapon) interval: [self calculateFireRate]];
                else
                    [self schedule:@selector(damageBurnEnemy) interval: [self calculateFireRate]];
            }
        }
    }
}

-(void)attackStop
{
    if(damageBurn)
        [self unschedule:@selector(damageBurnEnemy)];
    else
        [self unschedule:@selector(shootWeapon)];
}

-(void)shootWeapon
{
    //Index for loop as the create projectile method
    //could remove an enemy from chosenEnemies
    for(int i = [chosenEnemies count] - 1; i >= 0; i--)
    {
        Enemy *enemy = [chosenEnemies objectAtIndex:i];
        
        currentTarget = enemy;
        
        [self createProjectile:enemy enemyId:enemy.enemyId];
    }
}
-(void)createProjectile:(Enemy *)enemy enemyId:(int)_enemyId
{
    NSString *projectileFilename = [NSString stringWithFormat:@"projectile_%@.png",  [TowerBaseType_toString[towerBaseType] lowercaseString]];
    
    CCSprite * projectile = [CCSprite spriteWithFile: projectileFilename];
    [theGame.gameLayer addChild:projectile];
    
    float timeToTarget = [self getTimeToPoint:enemy.mySprite.position
                                    fromPoint:towerSprite.position
                                        speed:projectileSpeed];
    
    [projectile setPosition: towerSprite.position];
    [projectile runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:timeToTarget position:enemy.mySprite.position],
                           [CCCallFuncND actionWithTarget:self selector:@selector(damageEnemy:data:) data:_enemyId],
                           [CCCallFuncN actionWithTarget:self selector:@selector(removeProjectile:)], nil]];
}

-(void)damageEnemy:(id)sender data:(void *)_enemyId
{
    Enemy *enemy = [self getEnemyFromId:(int)_enemyId];
    
    if(enemy)
    {
        if(aoe || aoeFreeze)
        {
            [self aoeDamage:aoeFreeze];
        }
        else if(iceSlow)
        {
            [self iceSlowDamage];
        }
        else if(poisonSlow)
        {
            [self poisonSlowDamage];
        }
        else if(stunPossible)
        {
            [self stunEnemy];
        }
        else if(armorPenalty)
        {
            [self armorPenaltyDamage];
        }
        else
        {
            [enemy getDamaged:[self calculateDamage]];
        }
    }
}

-(void)damageBurnEnemy
{
    //Index for loop as the create projectile method
    //could remove an enemy from chosenEnemies
    for(int i = [chosenEnemies count] - 1; i >= 0; i--)
    {
        Enemy *enemy = [chosenEnemies objectAtIndex:i];
        [enemy getDamaged:[self calculateDamage]];
    }
}

-(void)aoeDamage:(BOOL)freeze
{
    NSMutableArray *damageList = [[NSMutableArray alloc] init];
    
    for(Enemy *enemy in theGame.enemies)
    {
        if([theGame checkCollision:currentTarget.mySprite.position
                           radius1:aoeRange
                           center2:enemy.mySprite.position
                           radius2:1])
        {
            [damageList addObject:enemy];
        }
    }
    
    for(Enemy *enemy in damageList)
    {
        if(freeze)
        {
            [enemy applyIceSlow:iceSlowModifier];
        }
        
        [enemy getDamaged:[self calculateDamage]];
    }
}

-(void)iceSlowDamage
{
    [currentTarget applyIceSlow:iceSlowModifier];
    [currentTarget getDamaged:[self calculateDamage]];
}

-(void)poisonSlowDamage
{
    [currentTarget applyPoison:poisonSlowModidier damage:poisonDamage duration:poisonDuration];
    [currentTarget getDamaged:[self calculateDamage]];
}

-(void)stunEnemy
{
    float random = ((double)arc4random() / ARC4RANDOM_MAX);
    
    if(random <= stunChance)
    {
        [currentTarget applyStun:stunDuration];
    }
    
    [currentTarget getDamaged:[self calculateDamage]];
}

-(void)armorPenaltyDamage
{
    [currentTarget applyArmorPenalty:armorPenaltyValue duration:armorPenaltyDuration];
    [currentTarget getDamaged:[self calculateDamage]];
}

-(void)targetKilled:(Enemy *)enemy
{
    [chosenEnemies removeObject:enemy];
}

-(void)removeProjectile:(CCSprite *)projectile
{
    [projectile.parent removeChild:projectile cleanup:YES];
}

-(Enemy *)getEnemyFromId:(int)enemyId
{
    for(Enemy *enemy in theGame.enemies)
    {
        if(enemy.enemyId == (int)enemyId)
        {
            return enemy;
        }
    }
    
    return Nil;
}

-(void)update:(ccTime)dt
{
    if(attacking)
    {
        NSMutableArray *discardList = [[NSMutableArray alloc] init];
        
        //Check if current target drop out of sight
        for(Enemy * chosenEnemy in chosenEnemies)
        {
            if(![theGame checkCollision:towerSprite.position radius1:[self calculateRange]
                                center2:chosenEnemy.mySprite.position radius2:1])
            {
                [chosenEnemy gotLostSight:self];
                [discardList addObject:chosenEnemy];
            }
        }
        
        [chosenEnemies removeObjectsInArray:discardList];
        
        //Check if new target is available up to num of multiTargets
        for(Enemy * enemy in theGame.enemies)
        {
            if(enemy.active)
            {
                if([chosenEnemies count] < multiTargets)
                {
                    if([theGame checkCollision:towerSprite.position radius1:[self calculateRange]
                                       center2:enemy.mySprite.position radius2:1])
                    {
                        if(![chosenEnemies containsObject:enemy])
                        {
                            [chosenEnemies addObject:enemy];
                            [enemy getAttacked:self];
                        }
                    }
                }

                //Check proximity auras
                [self checkProximityAuras:enemy];
            }
        }
    }
}

-(void)checkProximityAuras:(Enemy *)enemy
{
    if((!theGame.flying) && proxAuraGround)
    {
        [self checkProximitySpeedAura:enemy];
        [self checkProximityArmorAura:enemy];
    }
    
    if(theGame.flying && proxAuraFlying)
    {
        [self checkProximitySpeedAura:enemy];
        [self checkProximityArmorAura:enemy];
    }
}

-(void)checkProximitySpeedAura:(Enemy *)enemy
{
    if(proxAuraSpeedPenalty > enemy.auraSpeedPenaltyValue)
    {
        if([theGame checkCollision:towerSprite.position radius1:proxAuraRange
                           center2:enemy.mySprite.position radius2:1])
        {
            [enemy applyAuraSpeedPenalty:proxAuraSpeedPenalty];
        }
        else
        {
            [enemy removeAuraSpeedPenalty];
        }
    }
}

-(void)checkProximityArmorAura:(Enemy *)enemy
{
    if(proxAuraArmorPenalty > enemy.auraArmorPenaltyValue)
    {
        if([theGame checkCollision:towerSprite.position radius1:proxAuraRange
                           center2:enemy.mySprite.position radius2:1])
        {
            [enemy applyAuraArmorPenalty:proxAuraArmorPenalty];
        }
        else
        {
            [enemy removeAuraArmorPenalty];
        }
    }
}

-(void)draw
{
    if(selected)
    {
        ccDrawColor4B(37, 149, 215, 255);
        ccDrawCircle(towerSprite.position, [self calculateRange], 360, 60, false);
        [super draw];
    }
}

-(float)getTimeToPoint:(CGPoint)targetPoint
             fromPoint:(CGPoint)sourcePoint
                 speed:(int)travelSpeed
{
    return sqrt(pow((targetPoint.x-sourcePoint.x),2) +
                pow((targetPoint.y-sourcePoint.y),2) ) / travelSpeed;
}

-(NSString *)getInfoBox
{
    NSLog(@"Constructing infobox");
    float lowDamage = [self calculateDamageRange:TRUE];
    float highDamage = [self calculateDamageRange:FALSE];
    float fireRate = [self calculateFireRate];
    
    NSString *damageStr = [NSString stringWithFormat:@"Damage: %3.1f - %3.1f", lowDamage, highDamage];
    NSString *cooldownStr = [NSString stringWithFormat:@"Cooldown: %1.2f", fireRate];
    NSString *rangeStr = [NSString stringWithFormat:@"Range: %f", [self calculateRange]];
    NSString *towerLevelStr = [NSString stringWithFormat:@"Level: %d | Kills: %d", towerLevel, numKills];
    NSString *upgradeCostStr = [NSString stringWithFormat:@"Upgrade Cost: %d", upgradeCost];
    NSString *info;
    
    if(towerType == 0)
    {
        info = @"Rock";
    }
    else
    {
        info = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@",
                towerName,
                damageStr,
                cooldownStr,
                rangeStr,
                towerLevelStr,
                upgradeCostStr,
                description];
    }
    
    return info;
}

-(void)setAttributes
{
    switch(towerType)
    {
        case Rock:
            attackRange = 0;
            rangeModifier = 0;
            break;
        case Standard:
            [self setStandardAttributes];
            break;
        case Silver:
            towerBaseType = Sapphire;
            
            rangeModifier = 550 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1800 / BASE_PROJECTILE_SPEED;
            damageBase = 19;
            sidesPerDie = 2;
            
            aoeFreeze = TRUE;
            aoeRange = 36;
            iceSlowModifier = 0.20;
            iceSlow = TRUE;
            
            upgradeCost = 25;
            upgradesTo = SterlingSilver;
            
            description = @"Attacks will slow targets within a splash area.";
            break;
            
        case SterlingSilver:
            towerBaseType = Sapphire;
            
            rangeModifier = 650 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1800 / BASE_PROJECTILE_SPEED;
            damageBase = 39;
            sidesPerDie = 1;
            
            aoeFreeze = TRUE;
            aoeRange = 36;
            iceSlowModifier = 0.20;
            iceSlow = true;
            
            upgradeCost = 300;
            upgradesTo = SilverKnight;
            
            description = @"Attacks will slow targets within a splash area.";
            break;
            
        case SilverKnight:
            towerBaseType = Sapphire;
            
            rangeModifier = 750 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1300 / BASE_PROJECTILE_SPEED;
            damageBase = 149;
            sidesPerDie = 1;
            
            aoeFreeze = TRUE;
            aoeRange = 36;
            iceSlowModifier = 0.20;
            iceSlow = true;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"Attacks will slow targets within a splash area.";
            break;
            
        case Malachite:
            towerBaseType = Emerald;
            
            rangeModifier = 750 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1300 / BASE_PROJECTILE_SPEED;
            damageBase = 5;
            sidesPerDie = 1;
            
            multiTargets = 3;
            
            upgradeCost = 25;
            upgradesTo = VividMalachite;
            
            description = @"Malachite can attack three targets.";
            break;
            
        case VividMalachite:
            towerBaseType = Emerald;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1300 / BASE_PROJECTILE_SPEED;
            damageBase = 10;
            sidesPerDie = 1;
            
            multiTargets = 4;
            
            upgradeCost = 280;
            upgradesTo = MightyMalachite;
            
            description = @"Vivid Malachite can attack four targets.";
            break;
            
        case MightyMalachite:
            towerBaseType = Emerald;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1300 / BASE_PROJECTILE_SPEED;
            damageBase = 44;
            sidesPerDie = 1;
            
            multiTargets = 10;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"Mighty Malachite can attack all targets.";
            break;
            
        case Jade:
            towerBaseType = Aquamarine;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 0.5 / BASE_COOLDOWN;
            projectileModifier = 2000 / BASE_PROJECTILE_SPEED;
            damageBase = 29;
            sidesPerDie = 6;
            
            poisonSlowModidier = 0.50;
            poisonDuration = 2;
            poisonDamage = 5;
            
            upgradeCost = 45;
            upgradesTo = AsianJade;
            
            description = @"Poison attack deals 5 damage per second, and slows the target enemy's movement by 50%. Lasts 2 seconds.";
            break;
            
        case AsianJade:
            towerBaseType = Aquamarine;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 0.5 / BASE_COOLDOWN;
            projectileModifier = 2000 / BASE_PROJECTILE_SPEED;
            damageBase = 49;
            sidesPerDie = 1;
            
            poisonSlowModidier = 0.50;
            poisonDuration = 3;
            poisonDamage = 10;
            
            upgradeCost = 250;
            upgradesTo = LuckyAsianJade;
            
            description = @"Poison attack deals 10 damage per second, and slows the target enemy's movement by 50%. Lasts 3 seconds.";
            break;
            
        case LuckyAsianJade:
            towerBaseType = Aquamarine;
            
            rangeModifier = 850 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 2000 / BASE_PROJECTILE_SPEED;
            damageBase = 54;
            sidesPerDie = 1;
            
            poisonSlowModidier = 0.50;
            poisonDuration = 4;
            poisonDamage = 10;
            
            critChance = 0.05;
            critMultiplier = 4;
            
            stunPossible = TRUE;
            stunChance = 0.01;
            stunDuration = 2;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"Poison attack deals 10 damage per second, and slows the target enemy's movement by 50%. Lasts 4 seconds. 5% chance to deal 4x damage.  1% chance to gain half the current level in gold per attack.";
            break;
            
        case StarRuby:
            towerBaseType = Ruby;
            
            rangeModifier = 265 / BASE_RANGE;
            cooldownModifier = 0.25 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 10;
            sidesPerDie = 1;
            
            damageBurn = TRUE;
            multiTargets = 10;
            
            upgradeCost = 30;
            upgradesTo = BloodStar;
            
            description = [NSString stringWithFormat:@"Any enemy within %f range of the Star Ruby will receive 40 damage per second.", floor(rangeModifier)];

            break;
            
        case BloodStar:
            towerBaseType = Ruby;
            
            rangeModifier = 500 / BASE_RANGE;
            cooldownModifier = 0.25 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 12;
            sidesPerDie = 1;
            
            damageBurn = TRUE;
            multiTargets = 10;
            
            upgradeCost = 290;
            upgradesTo = FireStar;
            
            description = [NSString stringWithFormat:@"Any enemy within %f range of the Blood Star will receive 50 damage per second.", floor(rangeModifier)];
            break;
            
        case FireStar:
            towerBaseType = Ruby;
            
            rangeModifier = 600 / BASE_RANGE;
            cooldownModifier = 0.5 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 64;
            sidesPerDie = 1;
            
            damageBurn = TRUE;
            multiTargets = 10;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = [NSString stringWithFormat:@"Any enemy within %f range of the Fire Star will receive 100 damage per second.", floor(rangeModifier)];
            break;
            
        case PinkDiamond:
            towerBaseType = Diamond;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 0.75 / BASE_COOLDOWN;
            projectileModifier = 1200 / BASE_PROJECTILE_SPEED;
            damageBase = 149;
            sidesPerDie = 26;

            attacksFlying = FALSE;
            critChance = 0.10;
            critMultiplier = 5;
            
            upgradeCost = 175;
            upgradesTo = Rock;
            
            description = [NSString stringWithFormat:@"Attacks ground only and has %d%% chance to deal x%d damage.", (int)(critChance * 100), critMultiplier];
            break;
            
        case GreatPinkDiamond:
            towerBaseType = Diamond;
            
            rangeModifier = 850 / BASE_RANGE;
            cooldownModifier = 0.65 / BASE_COOLDOWN;
            projectileModifier = 1800 / BASE_PROJECTILE_SPEED;
            damageBase = 174;
            sidesPerDie = 51;
            
            attacksFlying = FALSE;
            critChance = 0.10;
            critMultiplier = 8;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = [NSString stringWithFormat:@"Attacks ground only and has %d%% chance to deal x%d damage.", (int)(critChance * 100), critMultiplier];
            break;
            
        case DarkEmerald:
            towerBaseType = Emerald;
            
            rangeModifier = 550 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 2000 / BASE_PROJECTILE_SPEED;
            damageBase = 89;
            sidesPerDie = 61;
            
            stunPossible = TRUE;
            stunChance = 0.125;
            stunDuration = 1;
    
            upgradeCost = 250;
            upgradesTo = EnchantedEmerald;
            
            description = @"Has a 12.5% chance to stun for 1.5 seconds per attack.";
            break;
            
        case EnchantedEmerald:
            towerBaseType = Emerald;
            
            rangeModifier = 700 / BASE_RANGE;
            cooldownModifier = 0.7 / BASE_COOLDOWN;
            projectileModifier = 2000 / BASE_PROJECTILE_SPEED;
            damageBase = 98;
            sidesPerDie = 51;
            numDie = 2;
            
            critChance = 0.15;
            critMultiplier = 4;
            
            stunPossible = TRUE;
            stunChance = 0.15;
            stunDuration = 2;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"15% Chance to stun for 2 seconds and 15% chance to do 4x damage.";
            break;

        case Gold:
            towerBaseType = Amethyst;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 159;
            sidesPerDie = 31;
            
            critChance = 0.25;
            critMultiplier = 2;
            
            armorPenalty = TRUE;
            armorPenaltyValue = 5;
            armorPenaltyDuration = 5;
            
            upgradeCost = 210;
            upgradesTo = EgyptianGold;
            
            description = @"25% Chance to do 2x damage. Applies -5 armor to targets it attacks.";
            break;
        
        case EgyptianGold:
            towerBaseType = Amethyst;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 0.75 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 159;
            sidesPerDie = 41;
            
            critChance = 0.30;
            critMultiplier = 2;
            
            armorPenalty = TRUE;
            armorPenaltyValue = 8;
            armorPenaltyDuration = 5;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"30% Chance to do 2x damage. Applies -8 armor to targets it attacks.";
            break;
            
        case YellowSapphire:
            towerBaseType = Sapphire;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 99;
            sidesPerDie = 1;
            
            aoeFreeze = TRUE;
            aoeRange = 57;
            iceSlowModifier = 0.20;
            iceSlow = TRUE;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"Attacks will slow targets within a huge splash area.";
            break;
        
        case StarYellowSapphire:
            towerBaseType = Sapphire;
            
            rangeModifier = 850 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 179;
            sidesPerDie = 1;
            
            aoeFreeze = TRUE;
            aoeRange = 57;
            iceSlowModifier = 0.20;
            iceSlow = TRUE;
            
            bonusAura = TRUE;
            damageAuraSpecialValue = 0.05;
            damageAuraSpecialRange = 171;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"Attacks will slow targets within a huge splash area and gives 5% more damage to towers nearby.";
            break;
            
        case BlackOpal:
            towerBaseType = Opal;
            
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 800 / BASE_PROJECTILE_SPEED;
            damageBase = 24;
            sidesPerDie = 1;

            bonusAura = TRUE;
            damageAuraSpecialValue = 0.30;
            damageAuraSpecialRange = 143;
            
            upgradeCost = 300;
            upgradesTo = MysticBlackOpal;
            
            description = [NSString stringWithFormat: @"Gives 30% more damage to towers within %d range.", (int)damageAuraSpecialRange];
        
            break;
            
        case MysticBlackOpal:
            towerBaseType = Opal;
            
            rangeModifier = 1000 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED;
            damageBase = 49;
            sidesPerDie = 1;
            
            bonusAura = TRUE;
            damageAuraSpecialValue = 0.40;
            damageAuraSpecialRange = 171;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = [NSString stringWithFormat: @"Gives 40% more damage to towers within %d range.", (int)damageAuraSpecialRange];
            break;
            
        case RedCrystal:
            towerBaseType = Amethyst;
            
            rangeModifier = 1300 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 2000 / BASE_PROJECTILE_SPEED;
            damageBase = 49;
            sidesPerDie = 26;
            
            attacksGround = FALSE;
            
            proxAuraFlying = TRUE;
            proxAuraArmorPenalty = 5;
            proxAuraRange = 200;
            
            upgradeCost = 100;
            upgradesTo = RedCrystalFacet;
            
            description = @"Gives -4 armor to air units within a large area. Can only attack air units.";
            break;
            
        case RedCrystalFacet:
            towerBaseType = Amethyst;
            
            rangeModifier = 1400 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 2000 / BASE_PROJECTILE_SPEED;
            damageBase = 74;
            sidesPerDie = 26;
            
            attacksGround = FALSE;
            
            proxAuraFlying = TRUE;
            proxAuraArmorPenalty = 6;
            proxAuraRange = 200;
            
            upgradeCost = 100;
            upgradesTo = RoseQuartzCrystal;
            
            description = @"Gives -5 armor to air units within a large area. Can only attack air units.";
            break;
            
        case RoseQuartzCrystal:
            towerBaseType = Amethyst;
            
            rangeModifier = 1500 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 2000 / BASE_PROJECTILE_SPEED;
            damageBase = 99;
            sidesPerDie = 26;
            
            attacksGround = FALSE;
            
            proxAuraFlying = TRUE;
            proxAuraArmorPenalty = 7;
            proxAuraRange = 214;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"Gives -6 armor to air units within a large area. Can only attack air units.";
            break;
            
        case Uranium238:
            towerBaseType = Topaz;
            
            rangeModifier = 450 / BASE_RANGE;
            cooldownModifier = 0.25 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 47;
            sidesPerDie = 1;
            
            multiTargets = 10;
            
            proxAuraGround = TRUE;
            proxAuraFlying = TRUE;
            proxAuraArmorPenalty = 0.5;
            proxAuraRange = 64;
            
            upgradeCost = 190;
            upgradesTo = Uranium235;
            
            description = @"Any unit within range of uranium is slowed by 50%.  Uranium will burn enemies for 190 damage per second.";
            break;
            
        case Uranium235:
            towerBaseType = Topaz;
            
            rangeModifier = 600 / BASE_RANGE;
            cooldownModifier = 0.25 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 64;
            sidesPerDie = 1;
            
            multiTargets = 10;
            
            proxAuraGround = TRUE;
            proxAuraFlying = TRUE;
            proxAuraArmorPenalty = 0.5;
            proxAuraRange = 64;
            
            upgradeCost = 0;
            upgradesTo = Rock;

            description = @"Any unit within range of uranium is slowed by 50%.  Uranium will burn enemies for 260 damage per second.";
            break;
            
        case BloodStone:
            towerBaseType = Ruby;
            
            rangeModifier = 700 / BASE_RANGE;
            cooldownModifier = 0.50 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 67;
            sidesPerDie = 1;
            
            aoe = true;
            aoeRange = 57;
            multiTargets = 10;
            
            upgradeCost = 250;
            upgradesTo = AncientBloodStone;
            
            description = @"Does 135 damage per second to nearby enemies and has splash damage.";
            break;
            
        case AncientBloodStone:
            towerBaseType = Ruby;
            
            rangeModifier = 700 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 81;
            sidesPerDie = 1;

            critChance = 0.15;
            critMultiplier = 3;
            
            upgradeCost = 0;
            upgradesTo = Rock;
            
            description = @"15% Chance to do 3x damage.";
            break;
            
        case Paraiba:
            towerBaseType = Aquamarine;
            
            rangeModifier = 850 / BASE_RANGE;
            cooldownModifier = 0.75 / BASE_COOLDOWN;
            projectileModifier = 1750 / BASE_PROJECTILE_SPEED;
            damageBase = 5;
            numDie = 5;
            sidesPerDie = 79;
            
            upgradeCost = 350;
            upgradesTo = ParaibaTourmalineFacet;
            
            //description = "Gives -4 armor to ground units within " + towerAbilities.proximityAuraRange + " range. Additionally, it has a 20% chance to cast a 200 damage frost nova per attack costing 5 mana.";
            break;
            
        case ParaibaTourmalineFacet:
            towerBaseType = Aquamarine;
            
            rangeModifier = 850 / BASE_RANGE;
            cooldownModifier = 0.75 / BASE_COOLDOWN;
            projectileModifier = 1750 / BASE_PROJECTILE_SPEED;
            damageBase = 25;
            numDie = 5;
            sidesPerDie = 79;
            
            //"Gives -6 armor to ground units within " + towerAbilities.proximityAuraRange + " range. Additionally, it has a 20% chance to cast a 250 damage frost nova per attack costing 5 mana.";
            
            break;
            
        case UberStone:
            towerBaseType = Amethyst;
            
            rangeModifier = 850 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 1000;
            sidesPerDie = 1;
            
            
            description = @"Only the very lucky have the chance ever to see this stone of pure damage.";
            break;
            
    }
}

-(void)setStandardAttributes
{
    if(towerBaseType == Amethyst)
    {
        if(towerQuality == Chipped)
        {
            rangeModifier = 1000 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 1200 / BASE_PROJECTILE_SPEED;
            damageBase = 8;
            sidesPerDie = 5;
        }
        else if(towerQuality == Flawed)
        {
            rangeModifier = 1125 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1400 / BASE_PROJECTILE_SPEED;
            damageBase = 17;
            sidesPerDie = 8;
        }
        else if(towerQuality == Normal)
        {
            rangeModifier = 1250 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 29;
            sidesPerDie = 11;
        }
        else if(towerQuality == Flawless)
        {
            rangeModifier = 1300 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1800 / BASE_PROJECTILE_SPEED;
            damageBase = 59;
            sidesPerDie = 16;
        }
        else if(towerQuality == Perfect)
        {
            rangeModifier = 1500 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1900 / BASE_PROJECTILE_SPEED;
            damageBase = 139;
            sidesPerDie = 11;
        }
        else if(towerQuality == Great)
        {
            rangeModifier = 1650 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1900 / BASE_PROJECTILE_SPEED;
            damageBase = 349;
            sidesPerDie = 51;
        }
        
        attacksGround = FALSE;
        description = @"Attacks air only";
    }
    else if(towerBaseType == Aquamarine)
    {
        if(towerQuality == Chipped)
        {
            rangeModifier = 350 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED;
            damageBase = 5;
            sidesPerDie = 3;
        }
        else if(towerQuality == Flawed)
        {
            rangeModifier = 365 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED
            damageBase = 11;
            sidesPerDie = 4;
        }
        else if(towerQuality == Normal)
        {
            rangeModifier = 380 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED
            damageBase = 23;
            sidesPerDie = 7;
        }
        else if(towerQuality == Flawless)
        {
            rangeModifier = 425 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED
            damageBase = 47;
            sidesPerDie = 8;
        }
        else if(towerQuality == Perfect)
        {
            rangeModifier = 550 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED
            damageBase = 99;
            sidesPerDie = 21;
        }
        else if(towerQuality == Great)
        {
            rangeModifier = 600 / BASE_RANGE;
            cooldownModifier = 0.35 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED
            damageBase = 279;
            sidesPerDie = 1;
        }
        
        description = @"Fast attack speed";
    }
    else if(towerBaseType == Diamond)
    {
        if(towerQuality == Chipped)
        {
            rangeModifier = 900 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 7;
            sidesPerDie = 5;
            critChance = 0.25;
            critMultiplier = 2;
        }
        else if(towerQuality == Flawed)
        {
            rangeModifier = 550 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 15;
            sidesPerDie = 3;
            critChance = 0.25;
            critMultiplier = 2;
        }
        else if(towerQuality == Normal)
        {
            rangeModifier = 600 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 850 / BASE_PROJECTILE_SPEED;
            damageBase = 29;
            sidesPerDie = 8;
            critChance = 0.25;
            critMultiplier = 2;
        }
        else if(towerQuality == Flawless)
        {
            rangeModifier = 650 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 57;
            sidesPerDie = 8;
            critChance = 0.25;
            critMultiplier = 2;
        }
        else if(towerQuality == Perfect)
        {
            rangeModifier = 750 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 139;
            sidesPerDie = 11;
            critChance = 0.25;
            critMultiplier = 2;
        }
        else if(towerQuality == Great)
        {
            rangeModifier = 850 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 299;
            sidesPerDie = 51;
            critChance = 0.25;
            critMultiplier = 2;
        }
        
        attacksFlying = FALSE;
        description = [NSString stringWithFormat:@"Attacks ground only and has %d%% chance to deal x%d",
                       (int)(critChance * 100), critMultiplier];
    }
    else if(towerBaseType == Emerald)
    {
        poisonSlow = TRUE;
        
        if(towerQuality == Chipped)
        {
            rangeModifier = 500 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 3;
            sidesPerDie = 4;
            

            poisonSlowModidier = 0.15;
            poisonDuration = 3;
            poisonDamage = 2;
        }
        else if(towerQuality == Flawed)
        {
            rangeModifier = 550 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 750 / BASE_PROJECTILE_SPEED;
            damageBase = 9;
            sidesPerDie = 4;
            
            poisonSlowModidier = 0.20;
            poisonDuration = 4;
            poisonDamage = 3;
        }
        else if(towerQuality == Normal)
        {
            rangeModifier = 600 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 14;
            sidesPerDie = 11;
            
            poisonSlowModidier = 0.25;
            poisonDuration = 5;
            poisonDamage = 5;
        }
        else if(towerQuality == Flawless)
        {
            rangeModifier = 700 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 29;
            sidesPerDie = 9;
            
            poisonSlowModidier = 0.35;
            poisonDuration = 6;
            poisonDamage = 8;
        }
        else if(towerQuality == Perfect)
        {
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 700 / BASE_PROJECTILE_SPEED;
            damageBase = 79;
            sidesPerDie = 11;
            
            poisonSlowModidier = 0.50;
            poisonDuration = 8;
            poisonDamage = 16;
        }
        else if(towerQuality == Great)
        {
            rangeModifier = 900 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 79;
            sidesPerDie = 11;
            
            poisonSlowModidier = 0.50;
            poisonDuration = 8;
            poisonDamage = 16;
        }


        
        description = [NSString stringWithFormat:@"Deals a poison attack that does %d damage per second, and slows the target enemy's movement by %d%%.  Lasts %d seconds.", (int)poisonDamage, (int)(poisonSlowModidier * 100), (int)poisonDuration];
    }
    else if(towerBaseType == Opal)
    {
        if(towerQuality == Chipped)
        {
            rangeModifier = 600 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 600 / BASE_PROJECTILE_SPEED;
            damageBase = 4;
            sidesPerDie = 1;
            
            bonusAura = true;
            speedAuraOpalValue = 0.1;
            speedAuraOpalRange = 86;
        }
        else if(towerQuality == Flawed)
        {
            rangeModifier = 700 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1200 / BASE_PROJECTILE_SPEED;
            damageBase = 9;
            sidesPerDie = 1;
            
            bonusAura = true;
            speedAuraOpalValue = 0.15;
            speedAuraOpalRange = 100;
        }
        else if(towerQuality == Normal)
        {
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED;
            damageBase = 19;
            sidesPerDie = 1;
            
            bonusAura = true;
            speedAuraOpalValue = 0.20;
            speedAuraOpalRange = 115;
        }
        else if(towerQuality == Flawless)
        {
            rangeModifier = 900 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 39;
            sidesPerDie = 1;
            
            bonusAura = true;
            speedAuraOpalValue = 0.25;
            speedAuraOpalRange = 129;
        }
        else if(towerQuality == Perfect)
        {
            rangeModifier = 1000 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED;
            damageBase = 84;
            sidesPerDie = 1;
            
            bonusAura = true;
            speedAuraOpalValue = 0.35;
            speedAuraOpalRange = 143;
        }
        else if(towerQuality == Great)
        {
            rangeModifier = 1500 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1200 / BASE_PROJECTILE_SPEED;
            damageBase = 179;
            sidesPerDie = 1;
            
            bonusAura = true;
            speedAuraOpalValue = 0.50;
            speedAuraOpalRange = 214;
        }
        
        description = [NSString stringWithFormat:@"Gives an aura to other gems within %d range which increases their attack speeds by %d%%", (int)speedAuraOpalRange, (int)(speedAuraOpalValue * 100)];
    }
    else if(towerBaseType == Ruby)
    {
        if(towerQuality == Chipped)
        {
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1300 / BASE_PROJECTILE_SPEED;
            damageBase = 7;
            sidesPerDie = 2;
            
            aoe = TRUE;
            aoeRange = 25;
        }
        else if(towerQuality == Flawed)
        {
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1400 / BASE_PROJECTILE_SPEED;
            damageBase = 12;
            sidesPerDie = 4;
            
            aoe = TRUE;
            aoeRange = 25;
        }
        else if(towerQuality == Normal)
        {
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1500 / BASE_PROJECTILE_SPEED;
            damageBase = 19;
            sidesPerDie = 6;
            
            aoe = TRUE;
            aoeRange = 30;
        }
        else if(towerQuality == Flawless)
        {
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1600 / BASE_PROJECTILE_SPEED;
            damageBase = 37;
            sidesPerDie = 8;
            
            aoe = TRUE;
            aoeRange = 30;
        }
        else if(towerQuality == Perfect)
        {
            rangeModifier = 900 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1700 / BASE_PROJECTILE_SPEED;
            damageBase = 79;
            sidesPerDie = 25;
            
            aoe = TRUE;
            aoeRange = 30;
        }
        else if(towerQuality == Great)
        {
            rangeModifier = 900 / BASE_RANGE;
            cooldownModifier = 0.75 / BASE_COOLDOWN;
            projectileModifier = 1700 / BASE_PROJECTILE_SPEED;
            damageBase = 139;
            sidesPerDie = 1;
            
            aoe = TRUE;
            aoeRange = 30;
        }
        
        description = @"Attacks cause splash damage";
        
    }
    else if(towerBaseType == Sapphire)
    {
        if(towerQuality == Chipped)
        {
            rangeModifier = 500 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 1000 / BASE_PROJECTILE_SPEED;
            damageBase = 4;
            sidesPerDie = 4;
            
            iceSlowModifier = 0.20;
            iceSlow = true;
            
            bonusAura = TRUE;
            damageAuraSpecialValue = 0.50;
            damageAuraSpecialRange = 171;
        }
        else if(towerQuality == Flawed)
        {
            rangeModifier = 750 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1300 / BASE_PROJECTILE_SPEED;
            damageBase = 9;
            sidesPerDie = 4;
            
            iceSlowModifier = 0.20;
            iceSlow = true;
        }
        else if(towerQuality == Normal)
        {
            rangeModifier = 800 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1300 / BASE_PROJECTILE_SPEED;
            damageBase = 15;
            sidesPerDie = 6;
            
            iceSlowModifier = 0.20;
            iceSlow = true;
        }
        else if(towerQuality == Flawless)
        {
            rangeModifier = 850 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1200 / BASE_PROJECTILE_SPEED;
            damageBase = 29;
            sidesPerDie = 11;
            
            iceSlowModifier = 0.20;
            iceSlow = true;
        }
        else if(towerQuality == Perfect)
        {
            rangeModifier = 1400 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1300 / BASE_PROJECTILE_SPEED;
            damageBase = 59;
            sidesPerDie = 16;
            
            iceSlowModifier = 0.20;
            iceSlow = true;
        }
        else if(towerQuality == Great)
        {
            rangeModifier = 2000 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 1900 / BASE_PROJECTILE_SPEED;
            damageBase = 199;
            sidesPerDie = 1;
            
            iceSlowModifier = 0.20;
            iceSlow = true;
        }
        
        description = @"Attacks will slow target's movement speed";
    }
    else if(towerBaseType == Topaz)
    {
        if(towerQuality == Chipped)
        {
            rangeModifier = 500 / BASE_RANGE;
            cooldownModifier = 0.8 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 3;
            sidesPerDie = 1;
            
            multiTargets = 3;
        }
        else if(towerQuality == Flawed)
        {
            rangeModifier = 500 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 7;
            sidesPerDie = 1;
            
            multiTargets = 3;
        }
        else if(towerQuality == Normal)
        {
            rangeModifier = 500 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 13;
            sidesPerDie = 1;
            
            multiTargets = 4;
        }
        else if(towerQuality == Flawless)
        {
            rangeModifier = 500 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 24;
            sidesPerDie = 1;
            
            multiTargets = 4;
        }
        else if(towerQuality == Perfect)
        {
            rangeModifier = 600 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 74;
            sidesPerDie = 1;
            
            multiTargets = 5;
        }
        else if(towerQuality == Great)
        {
            rangeModifier = 700 / BASE_RANGE;
            cooldownModifier = 1 / BASE_COOLDOWN;
            projectileModifier = 900 / BASE_PROJECTILE_SPEED;
            damageBase = 249;
            sidesPerDie = 1;
            
            multiTargets = 7;
        }
        
        description = @"Attacks multiple targets";
    }
}

@end