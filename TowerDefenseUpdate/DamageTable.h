//
//  DamageTable.h
//  gemtd
//
//  Created by Peter Holko on 13-07-28.
//  Copyright (c) 2013 Holko. All rights reserved.
//

@class Tower;

typedef enum {
    Red,
    Blazed,
    White,
    Green,
    Yellow,
    Blue,
    Pink,
} ArmorType;

extern NSString * const ArmorType_toString[7];

@interface DamageTable : NSObject
{
    float table[8][7];
    float armorTablePos[36];
    float armorTableNeg[15];
}

-(float)getDamageModifier:(int)damageType armorType:(int)armorType;
-(float)getArmorModifier:(int)_armorValue;
@end
