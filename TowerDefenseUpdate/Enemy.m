//
//  Enemies.m
//  gemtd
//
//  Created by Peter Holko on 13-06-30.
//  Copyright (c) 2013 Holko. All rights reserved.
//

#import "Enemy.h"
#import "Tower.h"
#import "Waypoint.h"

#define HEALTH_BAR_WIDTH 20
#define HEALTH_BAR_ORIGIN -10

@implementation Enemy

@synthesize mySprite, theGame, armorType, armor, armorPenaltyValue,
auraArmorPenaltyValue, auraSpeedPenaltyValue, active, flying, enemyId;

+(id)nodeWithTheGame:(Game *)_game enemyId:(int)_enemyId
{
    return [[self alloc] initWithTheGame:_game enemyId:_enemyId];
}

-(id)initWithTheGame:(Game *)_game enemyId:(int)_enemyId
{
	if (self=[super init])
    {
        theGame = _game;
        enemyId = _enemyId;
        
        active = FALSE;
        [self setVisible:FALSE];
        
        baseSpeed = BASE_SPEED;
        walkingSpeed = 0.50;
        iceModifier = 0;
        poisonModifier = 0;
        stunModifier = 0;
        armorPenaltyValue = 0;
        auraArmorPenaltyValue = 0;
        auraSpeedPenaltyValue = 0;
        
        //Set stats
        [self setEnemyStats];
        
        //Set sprite name before sprite
        [self setSpriteName];
        
        attackedBy = [[NSMutableArray alloc] init];
        
        currentHp = maxHp;
        
        [self scheduleUpdate];
	}
    
	return self;
}

-(void)setup
{
    //Add sprite to game layer
    [self setSprite];
}

-(void)setPath:(NSMutableArray *)_path
{
    path = _path;
    pathIndex = 1;
    
    NSValue *val = [path objectAtIndex:0];
    currentDest = [val CGPointValue];
    currentDest = ccp(currentDest.x * TILE_SIZE, currentDest.y * TILE_SIZE);
}

-(void)doActivate
{
    active = TRUE;
    
    [self setVisible:TRUE];
}

-(void)setSprite
{
    NSString *filename = [NSString stringWithFormat:@"%@.png", spriteName];
    mySprite = [CCSprite spriteWithFile: filename];
    [self addChild:mySprite];
    
    myWidth = [mySprite boundingBox].size.width;
    myHeight = [mySprite boundingBox].size.height;
    
    CGPoint pos = ccp(0 * TILE_SIZE + myWidth / 2,
                      35 * TILE_SIZE + myHeight / 2);
    myPosition = pos;
    [mySprite setPosition:pos];
    
    [theGame.gameLayer addChild:self];
}

-(void)setSpriteName
{
    if(flying)
    {
        spriteName = @"batman";
    }
    else
    {
        spriteName = @"axedwarf";
    }
}

-(void)changeSprite:(NSString *)fileName
{
    CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage: fileName];
    [mySprite setTexture: tex];
}

-(void)getAttacked:(Tower *)attacker
{
    [attackedBy addObject:attacker];
}

-(void)getDamaged:(int)damage
{
    if(currentHp > 0)
    {
        currentHp -=damage;
    
        if(currentHp <=0)
        {
            [self getRemoved:true];
        }
    }
}

-(void)applyIceSlow:(float)_modifier
{
    if(iceModifier == 0)
    {
        [self schedule:@selector(removeIce) interval: 1];
        
        iceModifier = _modifier;
        iceDuration = ICE_DURATION;
        numIce = 0;
        
        if(poisonModifier > 0)
        {
            [self changeSprite: [NSString stringWithFormat:@"%@_icepoison.png", spriteName]];
        }
        else
        {
            [self changeSprite: [NSString stringWithFormat:@"%@_ice.png", spriteName]];
        }
    }
    else
    {
        iceModifier = _modifier;
        iceDuration = ICE_DURATION;
        numIce = 0;
    }
}

-(void)applyPoison:(float)_modifier damage:(float)damage duration:(float)duration
{
    if(poisonModifier == 0)
    {
        [self schedule:@selector(applyPoisonDamage) interval: 1];
        
        poisonDamage = damage;
        poisonModifier = _modifier;
        poisonDuration = duration;
        numPoison = 0;
     
        if(iceModifier > 0)
        {
            [self changeSprite: [NSString stringWithFormat:@"%@_icepoison.png", spriteName]];
        }
        else
        {
            [self changeSprite: [NSString stringWithFormat:@"%@_poison.png", spriteName]];
        }
    }
    else
    {
        poisonDamage = damage;
        poisonModifier = _modifier;
        poisonDuration = duration;
        numPoison = 0;
    }
}

-(void)applyPoisonDamage
{
    numPoison++;
    [self getDamaged:poisonDamage];
    
    if(numPoison > poisonDuration)
    {
        [self unschedule:@selector(applyPoisonDamage)];
        
        poisonModifier = 0;
        
        if(iceModifier > 0)
        {
            [self changeSprite: [NSString stringWithFormat:@"%@_ice.png", spriteName]];
        }
        else
        {
            [self changeSprite: [NSString stringWithFormat:@"%@.png", spriteName]];
        }
    }
}
    
-(void)removeIce
{
    numIce++;
    
    if(numIce > iceDuration)
    {
        [self unschedule:@selector(removeIce)];
        
        iceModifier = 0;
        
        if(poisonModifier > 0)
        {
            [self changeSprite: [NSString stringWithFormat:@"%@_poison.png", spriteName]];
        }
        else
        {
            [self changeSprite: [NSString stringWithFormat:@"%@.png", spriteName]];
        }
    }
}

-(void)applyStun:(int)duration
{
    if(stunModifier == 0)
    {
        [self schedule:@selector(removeStun) interval: 1];
    }

    stunModifier = 1;
    stunDuration = duration;
    numStun = 0;
}

-(void)removeStun
{
    numStun++;
    
    if(numStun > stunDuration)
    {
        [self unschedule:@selector(removeStun)];
        
        stunModifier = 0;
    }
}

-(void)applyArmorPenalty:(int)penaltyValue duration:(int)duration
{
    if(armorPenaltyValue == 0)
    {
        [self schedule:@selector(removeArmorPenalty) interval: 1];
    }
    
    armorPenaltyValue = penaltyValue;
    armorPenaltyDuration = duration;
    numArmorPenalty = 0;
}

-(void)removeArmorPenalty
{
    numArmorPenalty++;
    
    if(numArmorPenalty > armorPenaltyDuration)
    {
        [self unschedule:@selector(removeArmorPenalty)];
        
        armorPenaltyValue = 0;
    }
}

-(void)applyAuraArmorPenalty:(int)penaltyValue
{
    auraArmorPenaltyValue = penaltyValue;
}

-(void)removeAuraArmorPenalty
{
    auraArmorPenaltyValue = 0;
}

-(void)applyAuraSpeedPenalty:(float)penaltyValue
{
    auraSpeedPenaltyValue = penaltyValue;
}

-(void)removeAuraSpeedPenalty
{
    auraSpeedPenaltyValue = 0;
}

-(float)calculateWalkingSpeed
{
    if(stunModifier > 0)
    {
        return walkingSpeed * (1 - stunModifier);
    }
    
    if(iceModifier > 0 && poisonModifier > 0)
    {
        return walkingSpeed * (1 - iceModifier) * (1 - poisonModifier);
    }
    if(iceModifier > 0)
    {
        return walkingSpeed * (1 - iceModifier);
    }
    if(poisonModifier)
    {
        return walkingSpeed * (1 - poisonModifier);
    }
    else
    {
        return walkingSpeed;
    }
}

-(void)getRemoved:(BOOL)killed
{
    for(Tower * attacker in attackedBy)
    {
        [attacker targetKilled:self];
    }
    
    [self.parent removeChild:self cleanup:YES];
    [theGame.enemies removeObject:self];
    
    
    if(killed)
    {
        [theGame enemyGotKilled];
    }
    else
    {
        [theGame enemyReachedEnd];
    }
}

-(void)gotLostSight:(Tower *)attacker
{
    [attackedBy removeObject:attacker];
}

-(CGPoint)getPosition
{
    return myPosition;
}

-(void)update:(ccTime)dt
{
    if(!active)
        return;
    
    if([theGame checkCollision:myPosition radius1:1 center2:currentDest radius2:1])
    {
        
        if(pathIndex < [path count])
        {
            NSValue *val = [path objectAtIndex:pathIndex];
            currentDest = [val CGPointValue];
            currentDest = ccp(currentDest.x * TILE_SIZE, currentDest.y * TILE_SIZE);
        
            pathIndex++;
        }
        else
        {
            //If path count reached, enemy has reached the end
            [self getRemoved:false];
            return;
        }
    }
    
    [self setEnemyPosition];
}

-(void)setEnemyPosition
{
    CGPoint targetPoint = currentDest;
    float movementSpeed = [self calculateWalkingSpeed];
    
    CGPoint normalized = ccpNormalize(ccp(targetPoint.x-myPosition.x,targetPoint.y-myPosition.y));
    
    float x = myPosition.x + normalized.x * movementSpeed;
    float y = myPosition.y + normalized.y * movementSpeed;
    
    myPosition = ccp(x, y);
    
    CGPoint offsetPos = ccp(x + myWidth / 2, y + myHeight / 2);
    
    [mySprite setPosition: offsetPos];
}

-(void)draw
{
    ccDrawSolidRect(ccp(myPosition.x+HEALTH_BAR_ORIGIN + myWidth / 2,
                        myPosition.y+16 + myHeight / 2),
                    ccp(myPosition.x+HEALTH_BAR_ORIGIN+HEALTH_BAR_WIDTH + myWidth / 2,
                        myPosition.y+14 + myHeight / 2),
                    ccc4f(1.0, 0, 0, 1.0));
    
    ccDrawSolidRect(ccp(myPosition.x+HEALTH_BAR_ORIGIN + myWidth / 2,
                        myPosition.y+16 + myHeight / 2),
                    ccp(myPosition.x+HEALTH_BAR_ORIGIN + (float)(currentHp * HEALTH_BAR_WIDTH)/maxHp + myWidth / 2,
                        myPosition.y+14 + myHeight / 2),
                    ccc4f(0, 1.0, 0, 1.0));
}

-(void)setEnemyStats
{
    switch(theGame.level)
    {
        case 0:
        case 1:
            maxHp = 10;
            armor = 0;
            armorType = Yellow;
            speedModifier = 265/baseSpeed;
            break;
        case 2:
            maxHp = 30;
            armor = 0;
            armorType = Blazed;
            speedModifier = 265/baseSpeed;
            break;
        case 3:
            maxHp = 55;
            armor = 0;
            armorType = White;
            speedModifier = 265/baseSpeed;
            break;
        case 4:
            maxHp = 70;
            armor = 0;
            armorType = Pink;
            speedModifier = 230/baseSpeed;
            flying = true;
            break;
        case 5:
            maxHp = 90;
            armor = 0;
            armorType = Green;
            speedModifier = 275/baseSpeed;
            break;
        case 6:
            maxHp = 120;
            armor = 0;
            armorType = Green;
            speedModifier = 275/baseSpeed;
            break;
        case 7:
            maxHp = 178;
            armor = 0;
            armorType = Pink;
            speedModifier = 285/baseSpeed;
            break;
        case 8:
            maxHp = 240;
            armor = 0;
            armorType = Pink;
            speedModifier = 230/baseSpeed;
            flying = true;
            break;
        case 9:
            maxHp = 300;
            armor = 0;
            armorType = White;
            speedModifier = 285/baseSpeed;
            break;
        case 10:
            maxHp = 470;
            armor = 1;
            armorType = Blue;
            speedModifier = 285/baseSpeed;
            break;
        case 11:
            maxHp = 490;
            armor = 1;
            armorType = Green;
            speedModifier = 285/baseSpeed;
            break;
        case 12:
            maxHp = 450;
            armor = 1;
            armorType = Pink;
            speedModifier = 250/baseSpeed;
            flying = true;
            break;
        case 13:
            maxHp = 570;
            armor = 1;
            armorType = Yellow;
            speedModifier = 295/baseSpeed;
            break;
        case 14:
            maxHp = 650;
            armor = 1;
            armorType = Blazed;
            speedModifier = 295/baseSpeed;
            break;
        case 15:
            maxHp = 1000;
            armor = 0;
            armorType = Red;
            speedModifier = 295/baseSpeed;
            break;
        case 16:
            maxHp = 725;
            armor = 1;
            armorType = Pink;
            speedModifier = 250/baseSpeed;
            flying = true;
            break;
        case 17:
            maxHp = 1350;
            armor = 1;
            armorType = Red;
            speedModifier = 295/baseSpeed;
            break;
        case 18:
            maxHp = 1550;
            armor = 1;
            armorType = Pink;
            speedModifier = 300/baseSpeed;
            break;
        case 19:
            maxHp = 1950;
            armor = 1;
            armorType = Blue;
            speedModifier = 300/baseSpeed;
            break;
        case 20:
            maxHp = 1350;
            armor = 1;
            armorType = Pink;
            speedModifier = 280/baseSpeed;
            flying = true;
            break;
        case 21:
            maxHp = 2300;
            armor = 2;
            armorType = White;
            speedModifier = 315/baseSpeed;
            break;
        case 22:
            maxHp = 2530;
            armor = 2;
            armorType = Green;
            speedModifier = 315/baseSpeed;
            break;
        case 23:
            maxHp = 3000;
            armor = 2;
            armorType = Red;
            speedModifier = 300/baseSpeed;
            break;
        case 24:
            maxHp = 2500;
            armor = 1;
            armorType = Pink;
            speedModifier = 280/baseSpeed;
            flying = true;
            break;
        case 25:
            maxHp = 3750;
            armor = 2;
            armorType = Red;
            speedModifier = 335/baseSpeed;
            break;
        case 26:
            maxHp = 4500;
            armor = 2;
            armorType = Red;
            speedModifier = 340/baseSpeed;
            break;
        case 27:
            maxHp = 5000;
            armor = 2;
            armorType = Blue;
            speedModifier = 340/baseSpeed;
            break;
        case 28:
            maxHp = 4150;
            armor = 2;
            armorType = Pink;
            speedModifier = 275/baseSpeed;
            flying = true;
            break;
        case 29:
            maxHp = 6750;
            armor = 2;
            armorType = White;
            speedModifier = 345/baseSpeed;
            break;
        case 30:
            maxHp = 7150;
            armor = 3;
            armorType = Green;
            speedModifier = 350/baseSpeed;
            break;
        case 31:
            maxHp = 8000;
            armor = 3;
            armorType = Blazed;
            speedModifier = 350/baseSpeed;
            break;
        case 32:
            maxHp = 6250;
            armor = 2;
            armorType = Pink;
            speedModifier = 320/baseSpeed;
            flying = true;
            break;
        case 33:
            maxHp = 9550;
            armor = 3;
            armorType = Red;
            speedModifier = 355/baseSpeed;
            break;
        case 34:
            maxHp = 10200;
            armor = 3;
            armorType = Yellow;
            speedModifier = 355/baseSpeed;
            break;
        case 35:
            maxHp = 11500;
            armor = 3;
            armorType = Blue;
            speedModifier = 355/baseSpeed;
            break;
        case 36:
            maxHp = 8500;
            armor = 2;
            armorType = Pink;
            speedModifier = 320/baseSpeed;
            flying = true;
            break;
        case 37:
            maxHp = 13000;
            armor = 3;
            armorType = Yellow;
            speedModifier = 360/baseSpeed;
            break;
        case 38:
            maxHp = 15000;
            armor = 3;
            armorType = Red;
            speedModifier = 365/baseSpeed;
            break;
        case 39:
            maxHp = 17000;
            armor = 3;
            armorType = White;
            speedModifier = 375/baseSpeed;
            break;
        case 40:
            maxHp = 10500;
            armor = 2;
            armorType = Pink;
            speedModifier = 350/baseSpeed;
            break;
        case 41:
            maxHp = 19500;
            armor = 7;
            armorType = Green;
            speedModifier = 380/baseSpeed;
            break;			
        case 42:
            maxHp = 23000;
            armor = 18;
            armorType = Blue;
            speedModifier = 390/baseSpeed;
            break;	
        case 43:
            maxHp = 26000;
            armor = 15;
            armorType = Yellow;
            speedModifier = 400/baseSpeed;
            break;			
        case 44:
            maxHp = 13000;
            armor = 5;
            armorType = Pink;
            speedModifier = 370/baseSpeed;
            flying = true;
            break;	
        case 45:
            maxHp = 28500;
            armor = 15;
            armorType = Red;
            speedModifier = 400/baseSpeed;
            break;							
        case 46:
            maxHp = 30000;
            armor = 15;
            armorType = Blazed;
            speedModifier = 400/baseSpeed;
            break;	
        case 47:
            maxHp = 33000;
            armor = 15;
            armorType = White;
            speedModifier = 400/baseSpeed;
            break;			
        case 48:
            maxHp = 15000;
            armor = 5;
            armorType = Pink;
            speedModifier = 380/baseSpeed;
            flying = true;
            break;	
        case 49:
            maxHp = 35000;
            armor = 15;
            armorType = Green;
            speedModifier = 400/baseSpeed;
            break;						
        case 50:
            maxHp = 200000;
            armor = 15;
            armorType = Green;
            speedModifier = 400/baseSpeed;
            flying = true;
            break;
    }
}

-(void)setSurvivalLevels
{
    switch(theGame.level)
    {
        case 11:
            maxHp = 650;
            armor = 1;
            armorType = Green;
            speedModifier = 285/baseSpeed;
            break;
        case 12:
            maxHp = 550;
            armor = 1;
            armorType = Pink;
            speedModifier = 250/baseSpeed;
            flying = true;
            break;
        case 13:

            maxHp = 800;
            armor = 1;
            armorType = Yellow;
            speedModifier = 295/baseSpeed;
            break;
        case 14:
            maxHp = 925;
            armor = 1;
            armorType = Blazed;
            speedModifier = 295/baseSpeed;
            break;
        case 15:
            maxHp = 1350;
            armor = 0;
            armorType = Red;
            speedModifier = 295/baseSpeed;
            break;
        case 16:
            maxHp = 850;
            armor = 1;
            armorType = Pink;
            speedModifier = 250/baseSpeed;
            flying = true;
            break;
        case 17:
            armor = 1;
            armorType = Red;
            speedModifier = 325/baseSpeed;
            break;
        case 18:
            maxHp = 2000;
            armor = 1;
            armorType = Pink;
            speedModifier = 325/baseSpeed;
            break;
        case 19:
            maxHp = 2500;
            armor = 1;
            armorType = Blue;
            speedModifier = 350/baseSpeed;
            break;
        case 20:
            maxHp = 1550;
            armor = 1;
            armorType = Pink;
            speedModifier = 280/baseSpeed;
            flying = true;
            break;
        case 21:
            maxHp = 3250;
            armor = 2;
            armorType = White;
            speedModifier = 400/baseSpeed;
            break;
    }
    
    if(theGame.level > 21)
    {
        maxHp = 7500 * (1 + (0.1 * (theGame.level - 21)));
        
        if(theGame.level % 4 == 0)
        {
            maxHp = maxHp * 0.3333;
            armorType = Pink;
            armor = (int)(theGame.level / 5);
        }
        else
        {
            armorType = (int)arc4random_uniform(6);
            armor = (int)(theGame.level / 4);
        }
        
        speedModifier = 550/baseSpeed;
    }
}


@end