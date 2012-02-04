//
//  RecordsDetailViewController.m
//  MicroMaze
//
//  Created by Leonov Valentin on 29.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "RecordsDetailViewController.h"

@interface RecordsDetailViewController()

@property(retain, nonatomic) NSDictionary *levelRecords;
@property(retain, nonatomic) NSArray *playersOrderedByRecord;

- (NSArray *)returnPlayersOrderedByRecord;

@end

@implementation RecordsDetailViewController

#pragma non statics

@synthesize levelFileName = _levelFileName, levelRecords = _levelRecords;
@synthesize playersOrderedByRecord = _playersOrderedByRecord;

- (void)dealloc
{
    self.levelFileName = nil;
    self.levelRecords = nil;
    
    self.playersOrderedByRecord = nil;
    
    [super dealloc];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//    }
//    return self;
//}

- (NSArray *)returnPlayersOrderedByRecord
{
    return [self.levelRecords keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 floatValue] == [obj2 floatValue]) {
            return NSOrderedSame;
        }
        return [obj1 floatValue] < [obj2 floatValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
}

#pragma view lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    self.levelRecords = [[MasterViewController getRecords] objectForKey:self.levelFileName];
    self.playersOrderedByRecord = [self returnPlayersOrderedByRecord];
    
    NSString *levelName = [self.levelFileName substringToIndex:self.levelFileName.length - 4];
    self.title = NSLocalizedString(levelName, levelName);
    
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma TableViewController

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.levelRecords.count + 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell.
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = NSLocalizedString(@"Player name", @"Player name");
        cell.detailTextLabel.text = @"Time";
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSMutableString *playerName = [NSMutableString stringWithString:[self.playersOrderedByRecord objectAtIndex:indexPath.row - 1]];
        NSMutableString *playerScore = [NSMutableString stringWithString:[self.levelRecords valueForKey:playerName]];
        
        cell.textLabel.text = NSLocalizedString(playerName, playerName);
        cell.detailTextLabel.text = playerScore;
    }
    
    return cell;
}

@end
