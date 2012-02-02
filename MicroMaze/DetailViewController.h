//
//  DetailViewController.h
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

@interface DetailViewController : UIViewController <UIAlertViewDelegate>

@property(retain, nonatomic) NSMutableArray *balls;
@property(retain, nonatomic) NSMutableArray *holes;
@property(retain, nonatomic) NSMutableArray *finishHoles;
@property(retain, nonatomic) NSMutableArray *bounds;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil levelFileName:(NSString *)levelFileName;

@end
