//
//  RecordsDetailViewController.h
//  MicroMaze
//
//  Created by Leonov Valentin on 29.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordsDetailViewController : UITableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil levelFileName:(NSString *)levelFileName levelRecords:(NSDictionary *)levelRecords;

@end
