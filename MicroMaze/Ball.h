//
//  Ball.h
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DetailViewController.h"
#import "Vector.h"

@interface Ball : CALayer

@property (nonatomic) struct Vector force;
@property (readonly, nonatomic) CGFloat mass;

- (id) initWithMass:(CGFloat)mass initialPosition:(CGPoint)initialPosition;
- (void) toInitialState;
- (void) startWithBounds:(NSArray *)bounds Holes:(NSArray *)holes FinishHoles:(NSArray *)finishHoles;

+ (CGFloat) getPixelsInMeter;

@end
