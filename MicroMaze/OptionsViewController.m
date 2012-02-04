//
//  OptionsViewController.m
//  MicroMaze
//
//  Created by admin on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "OptionsViewController.h"

@interface OptionsViewController()

@property (readwrite) CGFloat distanceToMoveView;

@property (retain, nonatomic) IBOutlet UITextField *playerNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *freeFallAccelerationTextField;

- (void) returnViewToInitialState;

+ (CGFloat) getViewAnimateDuration;
+ (NSString *) getPlayerNameDefault;
+ (void) setPlayerName:(NSString *)newPlayerName;
+ (CGFloat) getFreeFallAccelerationDefault;
+ (void) setFreeFallAcceleration:(CGFloat)newFreeFallAcceleration;

@end

@implementation OptionsViewController

#pragma statics

static CGFloat const _viewAnimateDuration = 0.4;

static NSString * const _playerNameDefault = @"Unknown player";
static NSString *_playerName;

static CGFloat const _freeFallAccelerationDefault = 9.81;
static CGFloat _freeFallAcceleration;

+ (void)initialize
{
    [super initialize];
    
    [OptionsViewController setPlayerName:[[NSUserDefaults standardUserDefaults] stringForKey:@"playerName"]];
    if (![OptionsViewController getPlayerName]) {
        [OptionsViewController setPlayerName:[OptionsViewController getPlayerNameDefault]];
    }
    
    [OptionsViewController setFreeFallAcceleration:[[NSUserDefaults standardUserDefaults] floatForKey:@"freeFallAcceleration"]];
    if (![OptionsViewController getFreeFallAcceleration]) {
        [OptionsViewController setFreeFallAcceleration:[OptionsViewController getFreeFallAccelerationDefault]];
    }

}

+ (CGFloat) getViewAnimateDuration
{
    return _viewAnimateDuration;
}

+ (NSString *) getPlayerNameDefault
{
    return _playerNameDefault;
}

+ (NSString *) getPlayerName
{
    return _playerName;
}

+ (void) setPlayerName:(NSString *)newPlayerName
{
    [newPlayerName retain];
    [_playerName release];
    _playerName = newPlayerName;
    [[NSUserDefaults standardUserDefaults] setValue:newPlayerName
                                              forKey:@"playerName"];
}

+ (CGFloat) getFreeFallAccelerationDefault
{
    return _freeFallAccelerationDefault;
}

+ (CGFloat) getFreeFallAcceleration
{
    return _freeFallAcceleration;
}

+ (void) setFreeFallAcceleration:(CGFloat)newFreeFallAcceleration
{
    if (newFreeFallAcceleration > 9.82) {
        [[[UIAlertView alloc] initWithTitle:@"Incorrect value"
                                    message:@"Sorry, it's too big acceleration"
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
    }
    else
    {
        _freeFallAcceleration = newFreeFallAcceleration;
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:newFreeFallAcceleration]
                                                  forKey:@"freeFallAcceleration"];
    }
}

#pragma non statics

@synthesize distanceToMoveView = _distanceToMoveView;
@synthesize playerNameTextField = _playerNameTextField, freeFallAccelerationTextField = _freeFallAccelerationTextField;

- (void)dealloc
{
    self.playerNameTextField = nil;
    self.freeFallAccelerationTextField = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.distanceToMoveView = 0;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playerNameTextField.text = [OptionsViewController getPlayerName];
    self.freeFallAccelerationTextField.text = [NSString stringWithFormat:@"%.2f", [OptionsViewController getFreeFallAcceleration]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.playerNameTextField resignFirstResponder];
    [self.freeFallAccelerationTextField resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.playerNameTextField resignFirstResponder];
    [self.freeFallAccelerationTextField resignFirstResponder];
}

- (void) returnViewToInitialState
{
    [UIView animateWithDuration:[OptionsViewController getViewAnimateDuration] animations:^{
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + self.distanceToMoveView);
    }];
    self.distanceToMoveView = 0;
}

#pragma TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.distanceToMoveView = textField.center.y - self.view.center.y + textField.bounds.size.height;
    
    [UIView animateWithDuration:[OptionsViewController getViewAnimateDuration] animations:^{
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - self.distanceToMoveView);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self returnViewToInitialState];
}

#pragma Outlets actions

- (IBAction)playerNameEditingDidEnd:(id)sender {
    [OptionsViewController setPlayerName:self.playerNameTextField.text];
}

- (IBAction)freeFallAccelerationEditingDidEnd:(id)sender {
    [OptionsViewController setFreeFallAcceleration: [self.freeFallAccelerationTextField.text floatValue]];
}

- (IBAction)toDefaultSettingsButtonIsTouchedDown:(id)sender {
    self.distanceToMoveView = 0;
    
    self.playerNameTextField.text = [OptionsViewController getPlayerNameDefault];
    [OptionsViewController setPlayerName:self.playerNameTextField.text];
    [self playerNameEditingDidEnd:self];
    
    self.freeFallAccelerationTextField.text = [NSString stringWithFormat:@"%.2f", [OptionsViewController getFreeFallAccelerationDefault]];
    [OptionsViewController setFreeFallAcceleration:[self.freeFallAccelerationTextField.text floatValue]];
    [self freeFallAccelerationEditingDidEnd:self];
}

@end
