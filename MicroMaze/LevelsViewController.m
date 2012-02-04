//
//  LevelsViewController.m
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "LevelsViewController.h"
#import "DetailViewController.h"

@interface LevelsViewController()

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (retain, nonatomic) NSCache *levelsCache;

@end

@implementation LevelsViewController

#pragma non statics

@synthesize detailViewController = _detailViewController;
@synthesize levelsCache = _levelsCache;

- (void)dealloc
{
    self.detailViewController = nil;    
    self.levelsCache = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Levels", @"Levels");
        self.levelsCache = [[[NSCache alloc] init] autorelease];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);}

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
    NSString *levelFileName = [[MasterViewController getLevelFileNames] objectAtIndex:indexPath.row];
    self.detailViewController = [self.levelsCache objectForKey:levelFileName];
    if (!self.detailViewController)
    {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController"
                                                                            bundle:nil
                                                                     levelFileName:levelFileName] autorelease];
        [self.levelsCache setObject:self.detailViewController forKey:levelFileName];
    }
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
