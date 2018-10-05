//
//  ShortestPathStep.h
//  gemtd
//
//  Created by Peter Holko on 13-07-08.
//  Copyright (c) 2013 Holko. All rights reserved.
//



@interface ShortestPathStep : NSObject
{
    CGPoint position;
	int gScore;
	int hScore;

}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, assign) ShortestPathStep *parent;

- (id)initWithPosition:(CGPoint)pos;
- (int)fScore;

@end
