//
//  RecordsViewController.m
//  MicroMaze
//
//  Created by Leonov Valentin on 29.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "RecordsViewController.h"
#import "RecordsDetailViewController.h"

@interface RecordsViewController()

@property(retain, nonatomic) RecordsDetailViewController *recordsDetailViewController;

@end

@implementation RecordsViewController

# pragma statics

+ (CGFloat) getRecordForLevelFileName:(NSString *)levelFileName
{
    NSArray *levelRecords = [(NSDictionary *)[[MasterViewController getRecords] valueForKey:levelFileName] allValues];
    CGFloat record = CGFLOAT_MAX;
    
    for (NSString *playerTime in levelRecords) {
        if (record > [playerTime floatValue]) {
            record = [playerTime floatValue];
        }
    }
    
    return record;
}

#pragma non statics

@synthesize recordsDetailViewController = _recordsDetailViewController;

- (void)dealloc
{
    self.recordsDetailViewController = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Records", @"Records");
    }
    return self;
}

#pragma TableViewController

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [MasterViewController getLevelFileNames].count;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell.
    NSString *fullFileName = [[MasterViewController getLevelFileNames] objectAtIndex:indexPath.row];
    NSString *levelName = [fullFileName substringToIndex:fullFileName.length-4];
    cell.textLabel.text = NSLocalizedString(levelName, levelName);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *levelFileName = [[MasterViewController getLevelFileNames] objectAtIndex:indexPath.row];
    
    if (!self.recordsDetailViewController)
    {
        self.recordsDetailViewController = [[[RecordsDetailViewController alloc] initWithNibName:@"RecordsDetailViewController"
                                                                                          bundle:nil] autorelease];
    //                                                                               levelFileName:levelFileName
    //                                                                                levelRecords:[[MasterViewController getRecords] objectForKey:levelFileName]] autorelease];
    }
    
    self.recordsDetailViewController.levelFileName = [[MasterViewController getLevelFileNames] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.recordsDetailViewController animated:YES];
}

@end
