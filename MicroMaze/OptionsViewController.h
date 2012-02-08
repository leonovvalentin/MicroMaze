
//  OptionsViewController.h
//  MicroMaze
//
//  Created by admin on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface OptionsViewController : UIViewController <UITextFieldDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

+ (NSString *) getPlayerName;
+ (CGFloat) getFreeFallAcceleration;
+ (BOOL) getWithShadows;

@end
