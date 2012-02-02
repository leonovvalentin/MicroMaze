//
//  OptionsViewController.m
//  MicroMaze
//
//  Created by admin on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "OptionsViewController.h"

@interface OptionsViewController()

@property(retain, nonatomic) MasterViewController *masterViewConrtroller;

@end

@implementation OptionsViewController
@synthesize playerName = _playerName;

@synthesize masterViewConrtroller = _masterViewConrtroller;

- (void)dealloc
{
    self.masterViewConrtroller = nil;
    
    [_playerName release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil masterViewControlle:(MasterViewController *)masterViewController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.masterViewConrtroller = masterViewController;
    }
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setPlayerName:nil];
    [super viewDidUnload];
}
@end
