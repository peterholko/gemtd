
//
//  DamageTable.m
//  gemtd
//
//  Created by Peter Holko on 13-07-28.
//  Copyright (c) 2013 Holko. All rights reserved.
//

#import "DamageTable.h"
#import "Tower.h"

@implementation DamageTable

NSString * const ArmorType_toString[7] = {
    [Red] = @"Red",
    [Blazed] = @"Blazed",
    [White] = @"White",
    [Green] = @"Green",
    [Yellow] = @"Yellow",
    [Blue] = @"Blue",
    [Pink] = @"Pink",
};

-(id)init
{
    table[Amethyst][Red] = 0.8;
    table[Amethyst][Blazed] = 0.8;
    table[Amethyst][White] = 0.8;
    table[Amethyst][Green] = 0.8;
    table[Amethyst][Yellow] = 0.8;
    table[Amethyst][Blue] = 0.8;
    table[Amethyst][Pink] = 1.75;
    
    table[Aquamarine][Red] = 1;
    table[Aquamarine][Blazed] = 1.9;
    table[Aquamarine][White] = 0.8;
    table[Aquamarine][Green] = 0.7;
    table[Aquamarine][Yellow] = 1;
    table[Aquamarine][Blue] = 0.4;
    table[Aquamarine][Pink] = 1;
    
    table[Diamond][Red] = 1.2;
    table[Diamond][Blazed] = 1;
    table[Diamond][White] = 1.6;
    table[Diamond][Green] = 0.6;
    table[Diamond][Yellow] = 1;
    table[Diamond][Blue] = 0.75;
    table[Diamond][Pink] = 0.2;
    
    table[Emerald][Red] = 0.7;
    table[Emerald][Blazed] = 0.7;
    table[Emerald][White] = 0.7;
    table[Emerald][Green] = 1.7;
    table[Emerald][Yellow] = 0.7;
    table[Emerald][Blue] = 0.7;
    table[Emerald][Pink] = 1.5;
    
    table[Opal][Red] = 1;
    table[Opal][Blazed] = 1.9;
    table[Opal][White] = 0.8;
    table[Opal][Green] = 0.7;
    table[Opal][Yellow] = 1;
    table[Opal][Blue] = 0.4;
    table[Opal][Pink] = 1;
    
    table[Ruby][Red] = 1.8;
    table[Ruby][Blazed] = 0.8;
    table[Ruby][White] = 1;
    table[Ruby][Green] = 0.5;
    table[Ruby][Yellow] = 1;
    table[Ruby][Blue] = 1;
    table[Ruby][Pink] = 0.8;
    
    table[Sapphire][Red] = 1;
    table[Sapphire][Blazed] = 1;
    table[Sapphire][White] = 1;
    table[Sapphire][Green] = 1;
    table[Sapphire][Yellow] = 1;
    table[Sapphire][Blue] = 1.75;
    table[Sapphire][Pink] = 1;
    
    table[Topaz][Red] = 0.5;
    table[Topaz][Blazed] = 1;
    table[Topaz][White] = 0.6;
    table[Topaz][Green] = 0.7;
    table[Topaz][Yellow] = 1.6;
    table[Topaz][Blue] = 1;
    table[Topaz][Pink] = 1.2;
    
	armorTablePos[0] = 1;
	armorTablePos[1] = 0.943;
	armorTablePos[2] = 0.893;
	armorTablePos[3] = 0.847;
	armorTablePos[4] = 0.806;
	armorTablePos[5] = 0.769;
	armorTablePos[6] = 0.735;
	armorTablePos[7] = 0.704;
	armorTablePos[8] = 0.676;
	armorTablePos[9] = 0.649;
	armorTablePos[10] = 0.625;
	armorTablePos[11] = 0.602;
	armorTablePos[12] = 0.581;
	armorTablePos[13] = 0.562;
	armorTablePos[14] = 0.543;
	armorTablePos[15] = 0.526;
	armorTablePos[16] = 0.510;
	armorTablePos[17] = 0.495;
	armorTablePos[18] = 0.481;
	armorTablePos[19] = 0.467;
	armorTablePos[20] = 0.455;
	armorTablePos[21] = 0.442;
	armorTablePos[22] = 0.431;
	armorTablePos[23] = 0.420;
	armorTablePos[24] = 0.410;
	armorTablePos[25] = 0.400;
	armorTablePos[26] = 0.391;
	armorTablePos[27] = 0.382;
	armorTablePos[28] = 0.373;
	armorTablePos[29] = 0.365;
	armorTablePos[30] = 0.357;
	armorTablePos[31] = 0.350;
	armorTablePos[32] = 0.342;
	armorTablePos[33] = 0.336;
	armorTablePos[34] = 0.329;
	armorTablePos[35] = 0.323;
    
	armorTableNeg[1] = 1.060;
	armorTableNeg[2] = 1.116;
	armorTableNeg[3] = 1.169;
	armorTableNeg[4] = 1.219;
	armorTableNeg[5] = 1.266;
	armorTableNeg[6] = 1.310;
	armorTableNeg[7] = 1.352;
	armorTableNeg[8] = 1.390;
	armorTableNeg[9] = 1.427;
	armorTableNeg[10] = 1.461;
    
    return self;
}

-(float)getDamageModifier:(int)damageType armorType:(int)armorType
{
    return table[damageType][armorType];
}

-(float)getArmorModifier:(int)_armorValue
{
    int armorValue = _armorValue;
    
    if(armorValue >= 0)
    {
        return armorTablePos[_armorValue];
    }
    else
    {
        armorValue = armorValue * -1;
        if(armorValue > 10)
        {
            //-10 armor is the highest in the armorTable
            return armorTableNeg[10];
        }
        else
        {
            return armorTableNeg[armorValue];
        }
    }
}

@end
