//
//  UI.m
//
//
//  Created by Peter Holko on 13-07-26.
//  Copyright 2013 Holko. All rights reserved.
//

#import "UI.h"

@implementation UI

@synthesize theGame, panelSprite, textareaSprite, topMenuSprite, keepButton, combineButton, combineSpecialButton, placeButton,
cannotBuildSprite, blockingSprite, upgradeButton, upgradeTextAreaSprite, yesButton, noButton, lostSprite, resetButton, removeButton,
easyButton, hardButton, survivalButton, upgradeGemButton, resetSmallButton;

+(id) nodeWithTheGame:(Game *)_game
{
    return [[self alloc] initWithTheGame:_game];
}

-(id) initWithTheGame:(Game *)_game
{
	if( (self=[super init]))
    {
		theGame = _game;
        
        [self setPanel];
        [self setTopMenu];
        [self initInfoSprites];
        [self initText];
        [self initKeepButton];
        [self initCombineButton];
        [self initCombineSpecialButton];
        [self initPlaceButton];
        [self initUpgradeButton];
        [self initUpgradePopup];
        [self initUpgradeText];
        [self initYesButton];
        [self initNoButton];
        [self initTopMenuText];
        [self initLostSprite];
        [self initResetButton];
        [self initResetSmallButton];
        [self initRemoveButton];
        [self initEasyButton];
        [self initHardButton];
        [self initSurvivalButton];
        [self initUpgradeGemButton];
        
        [self hideUpgradeTextArea];
        [self hideLost];
        
        [theGame.uiLayer addChild:self];
        
        [self scheduleUpdate];
	}
    
	return self;
}

-(void)setPanel
{
    panelSprite = [CCSprite spriteWithFile:@"panel.png"];
    textareaSprite = [CCSprite spriteWithFile:@"textarea.png"];

    
    panelSprite.position = ccp(theGame.winSize.width - [panelSprite boundingBox].size.width / 2,
                               [panelSprite boundingBox].size.height / 2 - 6);
    
    [panelSprite setVisible:FALSE];
    
    [self addChild:panelSprite];
    
    textareaSprite.position = ccp(5 + [textareaSprite boundingBox].size.width / 2,
                                  150 + [textareaSprite boundingBox].size.height / 2);
    
    [panelSprite addChild:textareaSprite];
}

-(void)setTopMenu
{
    topMenuSprite = [CCSprite spriteWithFile:@"top_menu.png"];
    
    topMenuSprite.position = ccp([topMenuSprite boundingBox].size.width / 2,
                                 (theGame.winSize.height - [topMenuSprite boundingBox].size.height / 2));
    
    [self addChild:topMenuSprite];
}

-(void)initUpgradePopup
{
    upgradeTextAreaSprite = [CCSprite spriteWithFile:@"textarea.png"];
    
    upgradeTextAreaSprite.position = ccp(165, 200);
    
    [self addChild:upgradeTextAreaSprite];
}

-(void)initInfoSprites
{
    cannotBuildSprite = [CCSprite spriteWithFile:@"cannotbuildthere.png"];
    blockingSprite = [CCSprite spriteWithFile:@"blocking.png"];
    
    cannotBuildSprite.position = ccp((theGame.winSize.width -
                                      [panelSprite boundingBox].size.width) / 2,
                                     theGame.winSize.height / 2);
    
    blockingSprite.position = ccp((theGame.winSize.width -
                                  [panelSprite boundingBox].size.width) / 2,
                                  theGame.winSize.height / 2);
    
    [cannotBuildSprite setVisible:FALSE];
    [blockingSprite setVisible:FALSE];
    
    [self addChild:cannotBuildSprite];
    [self addChild:blockingSprite];
}

-(void)initEasyButton
{
    CCSprite *easySprite = [CCSprite spriteWithFile:@"easy1.png"];
    CCSprite *easyPressSprite = [CCSprite spriteWithFile:@"easy2.png"];
    
    easyButton = [CCMenuItemSprite itemWithNormalSprite:easySprite
                                         selectedSprite:easyPressSprite
                                                 target:self
                                               selector:@selector(easyClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:easyButton, nil];
    menu.position = ccp(theGame.winSize.width / 2,
                        theGame.winSize.height / 2 + 50);
    
    [self addChild:menu];
}

-(void)initHardButton
{
    CCSprite *hardSprite = [CCSprite spriteWithFile:@"hard1.png"];
    CCSprite *hardPressSprite = [CCSprite spriteWithFile:@"hard2.png"];
    
    hardButton = [CCMenuItemSprite itemWithNormalSprite:hardSprite
                                         selectedSprite:hardPressSprite
                                                 target:self
                                               selector:@selector(hardClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:hardButton, nil];
    menu.position = ccp(theGame.winSize.width / 2,
                        theGame.winSize.height / 2);
    
    [self addChild:menu];
}

-(void)initSurvivalButton
{
    CCSprite *survivalSprite = [CCSprite spriteWithFile:@"survival1.png"];
    CCSprite *survivalPressSprite = [CCSprite spriteWithFile:@"survival2.png"];
    
    survivalButton = [CCMenuItemSprite itemWithNormalSprite:survivalSprite
                                         selectedSprite:survivalPressSprite
                                                 target:self
                                               selector:@selector(survivalClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:survivalButton, nil];
    menu.position = ccp(theGame.winSize.width / 2,
                        theGame.winSize.height / 2 - 50);
    
    [self addChild:menu];
}

-(void)initKeepButton
{
    CCSprite *keepSprite = [CCSprite spriteWithFile:@"keep1.png"];
    CCSprite *keepPressSprite = [CCSprite spriteWithFile:@"keep2.png"];
    
    keepButton = [CCMenuItemSprite itemWithNormalSprite:keepSprite
                                         selectedSprite:keepPressSprite
                                                 target:self
                                               selector:@selector(keepClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:keepButton, nil];
    menu.position = ccp(5 + [keepSprite boundingBox].size.width / 2,
                        55 + [keepSprite boundingBox].size.height / 2);
    
    [panelSprite addChild:menu];
}

-(void)initCombineSpecialButton
{
    CCSprite *combineSpecialSprite = [CCSprite spriteWithFile:@"combinespecial1.png"];
    CCSprite *combineSpecialPressSprite = [CCSprite spriteWithFile:@"combinespecial2.png"];
    
    combineSpecialButton = [CCMenuItemSprite itemWithNormalSprite:combineSpecialSprite
                                         selectedSprite:combineSpecialPressSprite
                                                 target:self
                                               selector:@selector(combineSpecialClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:combineSpecialButton, nil];
    menu.position = ccp(5 + [combineSpecialSprite boundingBox].size.width / 2,
                        102 + [combineSpecialSprite boundingBox].size.height / 2);
    
    [panelSprite addChild:menu];
}

-(void)initCombineButton
{
    CCSprite *combineSprite = [CCSprite spriteWithFile:@"combine1.png"];
    CCSprite *combinePressSprite = [CCSprite spriteWithFile:@"combine2.png"];
    
    combineButton = [CCMenuItemSprite itemWithNormalSprite:combineSprite
                                         selectedSprite:combinePressSprite
                                                 target:self
                                               selector:@selector(combineClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:combineButton, nil];
    menu.position = ccp(5 + [combineSprite boundingBox].size.width / 2,
                        10 + [combineSprite boundingBox].size.height / 2);
    
    [panelSprite addChild:menu];
}

-(void)initPlaceButton
{
    CCSprite *placeSprite = [CCSprite spriteWithFile:@"placegem1.png"];
    CCSprite *placePressSprite = [CCSprite spriteWithFile:@"placegem2.png"];
    
    placeButton = [CCMenuItemSprite itemWithNormalSprite:placeSprite
                                           selectedSprite:placePressSprite
                                                  target:self
                                                selector:@selector(placeClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:placeButton, nil];
    menu.position = ccp(5 + [placeSprite boundingBox].size.width / 2,
                        55 + [placeSprite boundingBox].size.height / 2);
    
    [panelSprite addChild:menu];
}

-(void)initUpgradeButton
{
    CCSprite *upgradeSprite = [CCSprite spriteWithFile:@"upgradechances1.png"];
    CCSprite *upgradePressSprite = [CCSprite spriteWithFile:@"upgradechances2.png"];
    
    upgradeButton = [CCMenuItemSprite itemWithNormalSprite:upgradeSprite
                                          selectedSprite:upgradePressSprite
                                                  target:self
                                                selector:@selector(upgradeClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:upgradeButton, nil];
    menu.position = ccp(5 + [upgradeSprite boundingBox].size.width / 2,
                        102 + [upgradeSprite boundingBox].size.height / 2);
    
    [panelSprite addChild:menu];
}

-(void)initUpgradeGemButton
{
    CCSprite *upgradeGemSprite = [CCSprite spriteWithFile:@"upgradegem1.png"];
    CCSprite *upgradeGemPressSprite = [CCSprite spriteWithFile:@"upgradegem2.png"];
    
    upgradeGemButton = [CCMenuItemSprite itemWithNormalSprite:upgradeGemSprite
                                            selectedSprite:upgradeGemPressSprite
                                                    target:self
                                                  selector:@selector(upgradeGemClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:upgradeGemButton, nil];
    menu.position = ccp(5 + [upgradeGemSprite boundingBox].size.width / 2,
                        10 + [upgradeGemSprite boundingBox].size.height / 2);
    
    [panelSprite addChild:menu];
}

-(void)initResetButton
{
    CCSprite *resetSprite = [CCSprite spriteWithFile:@"resetgame1.png"];
    CCSprite *resetPressSprite = [CCSprite spriteWithFile:@"resetgame2.png"];
    
    resetButton = [CCMenuItemSprite itemWithNormalSprite:resetSprite
                                            selectedSprite:resetPressSprite
                                                    target:self
                                                  selector:@selector(resetClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:resetButton, nil];
    menu.position = ccp([lostSprite boundingBox].size.width / 2,
                        25 + [resetButton boundingBox].size.height / 2);
    
    [lostSprite addChild:menu];
}

-(void)initResetSmallButton
{
    CCSprite *resetSprite = [CCSprite spriteWithFile:@"resetsmall1.png"];
    CCSprite *resetPressSprite = [CCSprite spriteWithFile:@"resetsmall1.png"];
    
    resetSmallButton = [CCMenuItemSprite itemWithNormalSprite:resetSprite
                                          selectedSprite:resetPressSprite
                                                  target:self
                                                selector:@selector(resetClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:resetSmallButton, nil];
    menu.position = ccp([diffLabel boundingBox].size.width / 2 + 500, 10);
    
    [topMenuSprite addChild:menu];
}


-(void)initRemoveButton
{
    CCSprite *removeSprite = [CCSprite spriteWithFile:@"removegem1.png"];
    CCSprite *removePressSprite = [CCSprite spriteWithFile:@"removegem2.png"];
    
    removeButton = [CCMenuItemSprite itemWithNormalSprite:removeSprite
                                           selectedSprite:removePressSprite
                                                   target:self
                                                 selector:@selector(removeClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:removeButton, nil];
    menu.position = ccp(5 + [removeSprite boundingBox].size.width / 2,
                        10 + [removeSprite boundingBox].size.height / 2);
    
    [panelSprite addChild:menu];
}

-(void)initYesButton
{
    CCSprite *yesSprite = [CCSprite spriteWithFile:@"yes1.png"];
    CCSprite *yesPressSprite = [CCSprite spriteWithFile:@"yes2.png"];
    
    yesButton = [CCMenuItemSprite itemWithNormalSprite:yesSprite
                                            selectedSprite:yesPressSprite
                                                    target:self
                                                  selector:@selector(yesClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:yesButton, nil];
    menu.position = ccp(30 + [yesSprite boundingBox].size.width / 2,
                        -1 * ([yesSprite boundingBox].size.height / 2 + 5));
    
    [upgradeTextAreaSprite addChild:menu];
}

-(void)initNoButton
{
    CCSprite *noSprite = [CCSprite spriteWithFile:@"no1.png"];
    CCSprite *noPressSprite = [CCSprite spriteWithFile:@"no2.png"];
    
    noButton = [CCMenuItemSprite itemWithNormalSprite:noSprite
                                            selectedSprite:noPressSprite
                                                    target:self
                                                  selector:@selector(noClick)];
    
    CCMenu *menu = [CCMenu menuWithItems:noButton, nil];
    menu.position = ccp(90 + [noSprite boundingBox].size.width / 2,
                        -1 * ([noSprite boundingBox].size.height / 2 + 5));
    
    [upgradeTextAreaSprite addChild:menu];
}

-(void)initLostSprite
{
    lostSprite = [CCSprite spriteWithFile:@"lost.png"];
    
    lostSprite.position = ccp(theGame.winSize.width / 2,
                              theGame.winSize.height / 2);
    
    
    [lostSprite setVisible:TRUE];
    
    [self addChild:lostSprite];
}

-(void)initText
{
    text = @"";
    
    CGSize maxSize = { 160, 140 };
    
    // Set the font size for the label text
    float fontSize = 12;

    // Create the label with our text (text1) and the container we created
    label = [CCLabelTTF labelWithString: text
                               fontName: @"Marker Felt"
                               fontSize:fontSize
                             dimensions:maxSize
                             hAlignment:kCCTextAlignmentLeft
                             vAlignment:kCCVerticalTextAlignmentTop
                          lineBreakMode:UILineBreakModeWordWrap];
    
    label.color = ccc3(0,0,0);
    
    label.position = ccp([label boundingBox].size.width / 2 + 6,
                          [textareaSprite boundingBox].size.height -
                          [label boundingBox].size.height / 2 - 6);
    
    NSLog(@"label size: %f %f", [label boundingBox].size.width, [label boundingBox].size.height);
    
    [textareaSprite addChild: label];
}

-(void)initUpgradeText
{
    [self setUpgradeText];

    CGSize maxSize = { 160, 140 };
    
    // Set the font size for the label text
    float fontSize = 12;
    
    // Create the label with our text (text1) and the container we created
    upgradeLabel = [CCLabelTTF labelWithString: upgradeText
                               fontName: @"Marker Felt"
                               fontSize:fontSize
                             dimensions:maxSize
                             hAlignment:kCCTextAlignmentLeft
                             vAlignment:kCCVerticalTextAlignmentTop
                          lineBreakMode:UILineBreakModeWordWrap];
    
    upgradeLabel.color = ccc3(0,0,0);
    
    upgradeLabel.position = ccp([upgradeLabel boundingBox].size.width / 2 + 6,
                                [textareaSprite boundingBox].size.height -
                                [upgradeLabel boundingBox].size.height / 2 - 6);
    
    [upgradeTextAreaSprite addChild: upgradeLabel];
}

-(void)initTopMenuText
{
    diffLabel = [self createTopMenuText: [self setDiffText]];
    diffLabel.position = ccp([diffLabel boundingBox].size.width / 2 + 3, 10);
    
    levelLabel = [self createTopMenuText: [NSString stringWithFormat:@"Level: %d", theGame.level]];
    levelLabel.position = ccp([diffLabel boundingBox].size.width / 2 + 100, 10);
    
    livesLabel = [self createTopMenuText: [NSString stringWithFormat:@"Lives: %d", theGame.lives]];
    livesLabel.position = ccp([diffLabel boundingBox].size.width / 2 + 200, 10);
    
    goldLabel = [self createTopMenuText: [NSString stringWithFormat:@"Gold: %d", theGame.gold]];
    goldLabel.position = ccp([diffLabel boundingBox].size.width / 2 + 300, 10);
    
    scoreLabel = [self createTopMenuText: [NSString stringWithFormat:@"Score: %d", 0]];
    scoreLabel.position = ccp([diffLabel boundingBox].size.width / 2 + 400, 10);
    
    //resetGameLabel = [self createTopMenuText: @"Reset Game"];
    //resetGameLabel.position = ccp([diffLabel boundingBox].size.width / 2 + 500, 10);
}

-(CCLabelTTF *)createTopMenuText:(NSString *)initText
{
    CCLabelTTF *topMenuLabel = [CCLabelTTF labelWithString: initText fontName: @"Marker Felt" fontSize: TOP_MENU_FONT_SIZE];
    topMenuLabel.color = ccc3(255,255,255);
    
    [topMenuSprite addChild:topMenuLabel];
    
    return topMenuLabel;
}

-(void)setText:(NSString *)_text
{
    NSLog(@"Setting UI text");
    [label setString: _text];
    
    label.position = ccp([label boundingBox].size.width / 2 + 6,
                         [textareaSprite boundingBox].size.height -
                         [label boundingBox].size.height / 2 - 6);
}

-(void)setUpgradeText
{
    upgradeText = [NSString stringWithFormat: @"Increase the chance to get better gems:\n"
                   " Chipped: %d%%\n Flawed: %d%% \n Normal: %d%% \n Flawless: %d%% \n Perfect: %d%%\n\n"
                   "Cost to Upgrade: %d gold", theGame.chippedChance, theGame.flawedChance, theGame.normalChance,
                   theGame.flawlessChance, theGame.perfectChance, [theGame getUpgradeCost]];
    
    [upgradeLabel setString:upgradeText];
}
                                
-(NSString *)setDiffText
{
    NSString *diffText;
    
    switch(theGame.difficulty)
    {
        case None:
            diffText = @"None";
            break;
        case Easy:
            diffText = @"Easy";
            break;
        case Hard:
            diffText = @"Hard";
            break;
        case Survival:
            diffText = @"Survival";
            break;
        default:
            diffText = @"None";
    }
    
    return diffText;
}

-(void)updateDiffText
{
    NSString *diffText = [self setDiffText];
    [diffLabel setString: diffText];
    diffLabel.position = ccp([diffLabel boundingBox].size.width / 2 + 3, 10);
}

-(void)updateGoldText
{
    NSString *goldText = [NSString stringWithFormat: @"Gold: %d", theGame.gold];
    [goldLabel setString: goldText];
}

-(void)updateLevelText
{
    NSString *levelText = [NSString stringWithFormat: @"Level: %d", theGame.level];
    [levelLabel setString: levelText];
}

-(void)updateLivesText
{
    NSString *livesText = [NSString stringWithFormat: @"Lives: %d", theGame.lives];
    [livesLabel setString: livesText];
}

-(void)updateScoreText
{
    NSString *scoreText = [NSString stringWithFormat: @"Score: %d", theGame.score];
    [scoreLabel setString: scoreText];
}

-(void)showPanel:(BOOL)visible
{
    [panelSprite setVisible:visible];
}

-(void)showKeep
{
    [keepButton setVisible:TRUE];
}

-(void)showCombine
{
    [combineButton setVisible:TRUE];
}

-(void)showCombineSpecial
{
    [combineSpecialButton setVisible:TRUE];
}

-(void)showPlace
{
    [placeButton setVisible:TRUE];
}

-(void)showUpgrade
{
    [upgradeButton setVisible:TRUE];
}

-(void)showUpgradeGem
{
    [upgradeGemButton setVisible:TRUE];
}

-(void)showUpgradeTextArea
{
    [upgradeTextAreaSprite setVisible:TRUE];
}

-(void)showCannotBuild
{
    [cannotBuildSprite setVisible:TRUE];
    
    [self schedule:@selector(hideCannotBuild) interval: 2];
}

-(void)showBlocking
{
    [blockingSprite setVisible:TRUE];
    
    [self schedule:@selector(hideBlocking) interval: 2];

}

-(void)showLost
{
    [lostSprite setVisible:TRUE];
}

-(void)showRemove
{
    [removeButton setVisible:TRUE];
}

-(void)hideBlocking
{
    [blockingSprite setVisible:FALSE];
    
    [self unschedule:@selector(hideBlocking)];
}

-(void)hideCannotBuild
{
    [cannotBuildSprite setVisible:FALSE];
    
    [self unschedule:@selector(hideCannotBuild)];
}

-(void)hideUpgradeTextArea
{
    [upgradeTextAreaSprite setVisible:FALSE];
}

-(void)hideAllButtons
{
    [keepButton setVisible:FALSE];
    [combineButton setVisible:FALSE];
    [combineSpecialButton setVisible:FALSE];
    [placeButton setVisible:FALSE];
    [upgradeButton setVisible:FALSE];
    [removeButton setVisible:FALSE];
    [upgradeGemButton setVisible:FALSE];
}

-(void)hideLost
{
    [lostSprite setVisible:FALSE];
}

-(void)hideCritText:(CCLabelTTF *)critLabel
{
    [critLabel setVisible:FALSE];
}

-(void)keepClick
{
    if(theGame.phase == Select)
    {
        [theGame processKeep];
    }
}

-(void)combineClick
{
    if(theGame.phase == Select)
    {
        [theGame processCombine];
    }
}

-(void)combineSpecialClick
{
    [theGame processCombineSpecial];
}

-(void)placeClick
{
    if(theGame.phase == Move)
    {
        [theGame processPlace];
    }
}

-(void)upgradeClick
{
    [self showUpgradeTextArea];
}

-(void)upgradeGemClick
{
    [theGame upgradeTower];
}

-(void)yesClick
{
    [theGame processUpgradeChances];
    [self setUpgradeText];
}

-(void)noClick
{
    [self hideUpgradeTextArea];
}

-(void)resetClick
{
    [self hideLost];
    [theGame reset];
}

-(void)removeClick
{
    [theGame removeTower];
}

-(void)hideDifficultyButtons
{
    [easyButton setVisible:FALSE];
    [hardButton setVisible:FALSE];
    [survivalButton setVisible:FALSE];
}

-(void)easyClick
{
    [self hideDifficultyButtons];
    theGame.difficulty = Easy;
    theGame.armorLevel = 0;
    [self updateDiffText];
}

-(void)hardClick
{
    [self hideDifficultyButtons];
    theGame.difficulty = Hard;
    theGame.armorLevel = 8;
    [self updateDiffText];
}

-(void)survivalClick
{
    [self hideDifficultyButtons];
    theGame.difficulty = Survival;
    theGame.armorLevel = 13;
    [self updateDiffText];
}

-(void)showDifficultyButtons
{
    [easyButton setVisible:TRUE];
    [hardButton setVisible:TRUE];
    [survivalButton setVisible:TRUE];
}

@end
