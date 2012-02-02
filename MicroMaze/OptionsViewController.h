//
//  OptionsViewController.h
//  MicroMaze
//
//  Created by admin on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionsViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil masterViewControlle:(MasterViewController *)masterViewController;
@property (retain, nonatomic) IBOutlet UITextField *playerName;

@end
