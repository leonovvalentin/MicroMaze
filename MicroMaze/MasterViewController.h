//
//  MasterViewController.h
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UIViewController

+ (NSArray *) getLevelFileNames;
+ (NSMutableDictionary *) getRecords;

@end
