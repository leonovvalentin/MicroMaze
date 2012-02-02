//
//  MasterViewController.m
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "LevelsViewController.h"
#import "RecordsViewController.h"
#import "OptionsViewController.h"

@interface MasterViewController()

@property (strong, nonatomic) LevelsViewController *levelsViewController;
@property (strong, nonatomic) RecordsViewController *recordsViewController;
@property (strong, nonatomic) OptionsViewController *optionsViewController;

@property (retain, nonatomic) NSArray *levelFileNames;
@property (retain, nonatomic) NSMutableDictionary *records;

- (void)handleAddToRecordsNotification:(NSNotification *)notification;

@end

@implementation MasterViewController

@synthesize levelsViewController = _levelsViewController, recordsViewController = _recordsViewController, optionsViewController = _optionsViewController;
@synthesize playerName = _playerName, levelFileNames = _levelFileNames, records = _records;

- (void)dealloc
{
    self.levelsViewController = nil;
    self.recordsViewController = nil;
    self.optionsViewController = nil;
    
    self.playerName = nil;
    self.levelFileNames = nil;
    self.records = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Micro Maze", @"Micro Maze");
        self.playerName = @"Unknown player";

        // Load levels list
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *levelsFolderPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Levels"];
        self.levelFileNames = [fileManager contentsOfDirectoryAtPath:levelsFolderPath
                                                               error:nil];
        // Load records
        self.records = [[[NSMutableDictionary alloc] initWithCapacity:self.levelFileNames.count] autorelease];
        for (NSString *levelFileName in self.levelFileNames)
        {
            NSString *levelContentString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:levelFileName
                                                                                                              ofType:nil
                                                                                                         inDirectory:@"Levels"]
                                                                     encoding:NSUTF8StringEncoding
                                                                        error:nil];
            NSArray *levelContentArray = [levelContentString componentsSeparatedByString:@"\n"];
            NSInteger recordsCount = [[levelContentArray objectAtIndex:0] floatValue];
            NSMutableDictionary *levelRecords = [NSMutableDictionary dictionaryWithCapacity:recordsCount];
            for (NSInteger i = 1; i < 1 + recordsCount; i++)
            {
                NSArray *recordData = [[levelContentArray objectAtIndex:i] componentsSeparatedByString:@" "];
                [levelRecords setValue:[recordData objectAtIndex:1] forKey:[recordData objectAtIndex:0]];
            }
            
            [self.records setValue:levelRecords forKey:levelFileName];
        }
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddToRecordsNotification:)
                                                 name:@"addToRecords"
                                               object:nil];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"addToRecords"
                                                  object:nil];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)PlayGameButtonIsTouchedDown:(id)sender {
    if (!self.levelsViewController) {
        self.levelsViewController = [[[LevelsViewController alloc] initWithNibName:@"LevelsViewController"
                                                                            bundle:nil
                                                                    levelFileNames:self.levelFileNames
                                                                           records:self.records] autorelease];
    }
    [self.navigationController pushViewController:self.levelsViewController animated:YES];
}

- (IBAction)RecordsButtonIsTouchedDown:(id)sender {
    if (!self.recordsViewController) {
        self.recordsViewController = [[[RecordsViewController alloc] initWithNibName:@"RecordsViewController"
                                                                            bundle:nil
                                                                    levelFileNames:self.levelFileNames
                                                                           records:self.records] autorelease];
    }
    [self.navigationController pushViewController:self.recordsViewController animated:YES];
}

- (IBAction)OptionsButtonIsTouchedDown:(id)sender {
    if (!self.optionsViewController) {
        self.optionsViewController = [[[OptionsViewController alloc] initWithNibName:@"OptionsViewController"
                                                                              bundle:nil
                                                                 masterViewControlle:self] autorelease];
    }
    [self.navigationController pushViewController:self.optionsViewController animated:YES];
}

- (void)handleAddToRecordsNotification:(NSNotification *)notification
{
    
}

@end