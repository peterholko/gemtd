//
//  UI.h
//  gemtd
//
//  Created by Peter Holko on 13-07-26.
//  Copyright 2013 Holko. All rights reserved.
//

#import "cocos2d.h"
#import "Game.h"

#define TOP_MENU_FONT_SIZE 16

@class Game;

@interface UI : CCNode
{
    CCLabelTTF *label;
    CCLabelTTF *upgradeLabel;
    CCLabelTTF *diffLabel;
    CCLabelTTF *levelLabel;
    CCLabelTTF *livesLabel;
    CCLabelTTF *goldLabel;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *resetGameLabel;
    
    NSString *text;
    NSString *upgradeText;
}

@property (nonatomic,weak) Game *theGame;
@property (nonatomic,strong) CCSprite *panelSprite;
@property (nonatomic,strong) CCSprite *textareaSprite;
@property (nonatomic,strong) CCSprite *topMenuSprite;
@property (nonatomic,strong) CCSprite *upgradeTextAreaSprite;
@property (nonatomic,strong) CCMenuItem *keepButton;
@property (nonatomic,strong) CCMenuItem *combineButton;
@property (nonatomic,strong) CCMenuItem *combineSpecialButton;
@property (nonatomic,strong) CCMenuItem *placeButton;
@property (nonatomic,strong) CCMenuItem *upgradeButton;
@property (nonatomic,strong) CCMenuItem *yesButton;
@property (nonatomic,strong) CCMenuItem *noButton;
@property (nonatomic,strong) CCMenuItem *resetButton;
@property (nonatomic,strong) CCMenuItem *resetSmallButton;
@property (nonatomic,strong) CCMenuItem *removeButton;
@property (nonatomic,strong) CCMenuItem *easyButton;
@property (nonatomic,strong) CCMenuItem *hardButton;
@property (nonatomic,strong) CCMenuItem *survivalButton;
@property (nonatomic,strong) CCMenuItem *upgradeGemButton;
@property (nonatomic,strong) CCSprite *cannotBuildSprite;
@property (nonatomic,strong) CCSprite *blockingSprite;
@property (nonatomic,strong) CCSprite *lostSprite;

+(id) nodeWithTheGame:(Game *)_game;
-(id) initWithTheGame:(Game *)_game;

-(void)setPanel;
-(void)initText;
-(void)initUpgradeText;
-(void)initKeepButton;
-(void)initPlaceButton;
-(void)initUpgradeButton;
-(void)initUpgradePopup;
-(void)initYesButton;
-(void)initNoButton;
-(void)initResetButton;
-(void)initRemoveButton;
-(void)initEasyButton;
-(void)initHardButton;
-(void)initSurvivalButton;

-(void)setText:(NSString *)_text;
-(void)showPanel:(BOOL)visible;
-(void)showKeep;
-(void)showCombine;
-(void)showCombineSpecial;
-(void)showPlace;
-(void)showUpgrade;
-(void)showUpgradeGem;
-(void)showCannotBuild;
-(void)showBlocking;
-(void)showLost;
-(void)showRemove;

-(void)updateGoldText;
-(void)updateScoreText;
-(void)updateLevelText;
-(void)updateLivesText;

-(void)hideAllButtons;
-(void)hideUpgradeTextArea;
-(void)showDifficultyButtons;

-(void)resetClick;

@end
