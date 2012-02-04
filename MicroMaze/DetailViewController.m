//
//  DetailViewController.m
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "RecordsViewController.h"
#import "OptionsViewController.h"
#import "Ball.h"

@interface DetailViewController ()

@property (retain, nonatomic) NSString *levelFileName;
@property(readwrite, nonatomic) CGFloat levelRecord;

@property(retain, nonatomic) NSMutableArray *balls;
@property(retain, nonatomic) NSMutableArray *holes;
@property(retain, nonatomic) NSMutableArray *finishHoles;
@property(retain, nonatomic) NSMutableArray *bounds;

@property(retain, nonatomic) CMMotionManager *motionManager;

@property(retain, nonatomic) NSTimer *timer;
@property(retain, nonatomic) NSTimer *timerForColor;
@property(nonatomic) CGFloat playTime;
@property (retain, nonatomic) IBOutlet UITextField *timerTextField;
@property (retain, nonatomic) IBOutlet UITextField *recordTimeTextField;
@property (readwrite, nonatomic) BOOL textFieldIsFlashing;

- (void) loadLevel;

- (NSArray *) leftTopRightBottomBounds;
- (NSArray *) holeWithXcoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate;
- (Ball *) ballWithMass:(CGFloat)mass XCoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate;
- (CALayer *) boundWithXCoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate length:(NSInteger)length horisontal:(BOOL)horisontal;
- (CALayer *) finishHoleWithXcoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate;

- (void) updateTextFieldTimer:(NSTimer *)timer;
- (void) updateTextFieldColorTimer:(NSTimer *)timer;

- (void) handleBallInTheHoleNotification:(NSNotification *)notification;
- (void) handleBallInTheFinishHoleNotification:(NSNotification *)notification;

- (void)addToRecordsNotificationForPlayTime:(CGFloat)playTime;

+ (CGFloat) getTimeBeforRecordBeforeFlashing;
+ (CGFloat) getTextFieldFlashingFrequency;

+ (CGFloat) getBallSize;
+ (CGFloat) getHoleSize;
+ (CGFloat) getFinishHoleSize;
+ (CGFloat) getBoundSize;

+ (CGFloat) getWindowWidth;
+ (CGFloat) getWindowHeight;
+ (CGFloat) getMaxPlayTime;
+ (CGFloat) getTimerUpdateInterval;
+ (CGFloat) getTimerForColorUpdateInterval;
+ (CGFloat) getFreeFallAccelerationReal;

@end

@implementation DetailViewController

#pragma statics

static CGFloat const _timeBeforRecordBeforeFlashing = 5.0;
static CGFloat const _textFieldFlashingFrequency = 0.5;

static CGFloat const _ballSize = 40;
static CGFloat const _holeSize = 50;
static CGFloat const _finishHoleSize = 60;
static CGFloat const _boundSize = 10;

static CGFloat const _windowWidth = 320;
static CGFloat const _windowHeight = 416;
static CGFloat const _maxPlayTime = 99.99;
static CGFloat const _timerUpdateInterval = 0.2;
static CGFloat const _timerForColorUpdateInterval = 0.5;
static CGFloat const _freeFallAccelerationReal = 9.81;

+ (CGFloat) getTimeBeforRecordBeforeFlashing
{
    return _timeBeforRecordBeforeFlashing;
}

+ (CGFloat) getTextFieldFlashingFrequency
{
    return _textFieldFlashingFrequency;
}

+ (CGFloat) getBallSize
{
    return _ballSize;
}

+ (CGFloat) getHoleSize
{
    return _holeSize;
}

+ (CGFloat) getFinishHoleSize
{
    return _finishHoleSize;
}

+ (CGFloat) getBoundSize
{
    return _boundSize;
}

+ (CGFloat) getWindowWidth
{
    return _windowWidth;
}

+ (CGFloat) getWindowHeight
{
    return _windowHeight;
}

+ (CGFloat) getMaxPlayTime
{
    return _maxPlayTime;
}

+ (CGFloat) getTimerUpdateInterval
{
    return _timerUpdateInterval;
}

+ (CGFloat) getTimerForColorUpdateInterval
{
    return _timerForColorUpdateInterval;
}

+ (CGFloat) getFreeFallAccelerationReal
{
    return _freeFallAccelerationReal;
}

#pragma non statics

@synthesize levelFileName = _levelFileName, levelRecord = _levelRecord;
@synthesize balls = _balls, holes = _holes, finishHoles = _finishHoles, bounds = _bounds;
@synthesize motionManager = _motionManager;
@synthesize timer = _timer, timerForColor = _timerForColor, playTime = _playTime, timerTextField = _timerTextField, recordTimeTextField = _recordTimeTextField, textFieldIsFlashing = _textFieldIsFlashing;

- (void)dealloc
{
    self.levelFileName = nil;
    
    self.balls = nil;
    self.holes = nil;
    self.bounds = nil;
    self.finishHoles = nil;
    
    self.motionManager = nil;
    
    self.timer = nil;
    self.timerTextField = nil;
    self.recordTimeTextField = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil levelFileName:(NSString *)levelFileName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.layer.contents = (id)[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Background"
                                                                                                        ofType:@"png"
                                                                                                   inDirectory:@"Images"]].CGImage;
        
        self.levelFileName = levelFileName;
        
        NSString *levelName = [self.levelFileName substringToIndex:self.levelFileName.length - 4];
        self.title = NSLocalizedString(levelName, levelName);
        
        [self loadLevel];
        
        self.motionManager = [[[CMMotionManager alloc] init] autorelease];
        self.playTime = 0.0;
        self.textFieldIsFlashing = NO;
    }
    
    return self;
}

//debug
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    Vector vector = VectorMake(([touch locationInView:self.view].x - self.view.center.x)/[Ball getPixelsInMeter], ([touch locationInView:self.view].y - self.view.center.y)/[Ball getPixelsInMeter]);
    
    for (Ball *ball in self.balls) {
        ball.force = VectorMake(ball.mass * vector.x, ball.mass * vector.y);
    }
}

- (void) loadLevel
{
    // Read from file
    NSString *levelContentString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.levelFileName
                                                                                                      ofType:nil
                                                                                                 inDirectory:@"Levels"]
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
    NSArray *levelContentArray = [levelContentString componentsSeparatedByString:@"\n"];
    NSInteger stringNumber = [[levelContentArray objectAtIndex:0] intValue] + 1;
    
    // Balls draw
    NSInteger ballsCount = [[levelContentArray objectAtIndex:stringNumber++] intValue];
    self.balls = [[[NSMutableArray alloc] initWithCapacity:ballsCount] autorelease];
    for (NSInteger i = stringNumber; i < stringNumber + ballsCount; i++)
    {
        NSArray *ballData = [[levelContentArray objectAtIndex:i] componentsSeparatedByString:@" "];
        Ball *ball = [self ballWithMass:[[ballData objectAtIndex:0] floatValue]
                            XCoordinate:[[ballData objectAtIndex:1] intValue]
                            yCoordinate:[[ballData objectAtIndex:2] intValue]];
        [self.balls addObject:ball];
        [self.view.layer addSublayer:ball];
    }
    stringNumber += ballsCount;
    
    // Holes draw
    NSInteger holesCount = [[levelContentArray objectAtIndex:stringNumber++] intValue];
    self.holes = [[[NSMutableArray alloc] initWithCapacity:holesCount] autorelease];
    for (NSInteger i = stringNumber; i < stringNumber + holesCount; i++)
    {
        NSArray *holeCoordinates = [[levelContentArray objectAtIndex:i] componentsSeparatedByString:@" "];
        NSArray *holeArray = [self holeWithXcoordinate:[[holeCoordinates objectAtIndex:0] intValue]
                                      yCoordinate:[[holeCoordinates objectAtIndex:1] intValue]];
        [self.holes addObject:[holeArray objectAtIndex:0]];

        for (CALayer *layer in holeArray)
        {
            [self.view.layer addSublayer:layer];
        }
    }
    stringNumber += holesCount;
    
    // Bounds Draw
    NSInteger boundsCount = [[levelContentArray objectAtIndex:stringNumber++] intValue]+4;
    self.bounds = [[[NSMutableArray alloc] initWithCapacity:boundsCount] autorelease];
    
    // Left, top, right and bottom bounds
    for (CALayer *layer in [self leftTopRightBottomBounds])
    {
        [self.bounds addObject:layer];
        [self.view.layer addSublayer:layer];
    }
    
    // Another bounds
    for (NSInteger i = stringNumber; i < stringNumber + boundsCount - 4; i++)
    {
        NSArray *boundData = [[levelContentArray objectAtIndex:i] componentsSeparatedByString:@" "];
        CALayer *bound = [self boundWithXCoordinate:[[boundData objectAtIndex:1] intValue]
                                        yCoordinate:[[boundData objectAtIndex:2] intValue]
                                             length:[[boundData objectAtIndex:3] intValue]
                                         horisontal:[[boundData objectAtIndex:0] boolValue]];
        [self.bounds addObject:bound];
        [self.view.layer addSublayer:bound];
    }
    stringNumber += boundsCount - 4;
    
    // Finish holes draw
    NSInteger finishHolesCount = [[levelContentArray objectAtIndex:stringNumber++] intValue];
    self.finishHoles = [[[NSMutableArray alloc] initWithCapacity:finishHolesCount] autorelease];
    for (NSInteger i = stringNumber; i < stringNumber + finishHolesCount; i++)
    {
        NSArray *finishHoleCoordinates = [[levelContentArray objectAtIndex:i] componentsSeparatedByString:@" "];
        CALayer *finishHole = [self finishHoleWithXcoordinate:[[finishHoleCoordinates objectAtIndex:0] intValue]
                                                  yCoordinate:[[finishHoleCoordinates objectAtIndex:1] intValue]];
        
        [self.finishHoles addObject:finishHole];
        [self.view.layer addSublayer:finishHole];
    }
}

- (NSArray *) leftTopRightBottomBounds
{
    // Left bound
    CALayer *leftBound = [self boundWithXCoordinate:[DetailViewController getBoundSize]/2
                                        yCoordinate:[DetailViewController getBoundSize]
                                             length:[DetailViewController getWindowHeight] - 2*[DetailViewController getBoundSize]
                                         horisontal:NO];
    leftBound.zPosition = 1;
    // Top bound
    CALayer *topBound = [self boundWithXCoordinate:[DetailViewController getBoundSize]
                                       yCoordinate:[DetailViewController getBoundSize]/2
                                            length:[DetailViewController getWindowWidth] - 2*[DetailViewController getBoundSize]
                                        horisontal:YES];
    topBound.zPosition = 1;
    // Right bound
    CALayer *rightBound = [self boundWithXCoordinate:[DetailViewController getWindowWidth] - [DetailViewController getBoundSize]/2
                                         yCoordinate:[DetailViewController getBoundSize]
                                              length:[DetailViewController getWindowHeight] - 2*[DetailViewController getBoundSize]
                                          horisontal:NO];
    rightBound.zPosition = 1;
    // Bottom bound
    CALayer *bottomBound = [self boundWithXCoordinate:[DetailViewController getBoundSize]
                                          yCoordinate:[DetailViewController getWindowHeight] - [DetailViewController getBoundSize]/2
                                               length:[DetailViewController getWindowWidth] - 2*[DetailViewController getBoundSize]
                                           horisontal:YES];
    bottomBound.zPosition = 1;
    return [[[NSArray alloc] initWithObjects:leftBound, topBound, rightBound, bottomBound, nil] autorelease];
}

- (CALayer *) boundWithXCoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate length:(NSInteger)length horisontal:(BOOL)horisontal
{
    CALayer *bound = [[[CALayer alloc] init] autorelease];
    bound.contents = (id)[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Bound" 
                                                                                           ofType:@"gif"
                                                                                      inDirectory:@"Images"]] CGImage];
    if (horisontal)
    {
        bound.frame = CGRectMake(xCoordinate, yCoordinate - [DetailViewController getBoundSize]/2, length, [DetailViewController getBoundSize]);
    }
    else
    {
        bound.frame = CGRectMake(xCoordinate - [DetailViewController getBoundSize]/2, yCoordinate, [DetailViewController getBoundSize], length);
    }
    
    bound.shadowOpacity = 1.0;
    bound.zPosition = 1;
    return bound;
}

- (CALayer *) finishHoleWithXcoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate
{
    CALayer *finishHole = [[[CALayer alloc] init] autorelease];
    finishHole.contents = (id)[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FinishHole1" 
                                                                                                ofType:@"gif"
                                                                                           inDirectory:@"Images"]] CGImage];
    finishHole.frame = CGRectMake(xCoordinate - [DetailViewController getFinishHoleSize]/2, yCoordinate - [DetailViewController getFinishHoleSize]/2, [DetailViewController getFinishHoleSize], [DetailViewController getFinishHoleSize]);
    finishHole.zPosition = -1;
    
    return finishHole;
}

- (NSArray *) holeWithXcoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate
{
    CALayer *holeUp = [[[CALayer alloc] init] autorelease];
    holeUp.contents = (id)[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Hole" 
                                                                                            ofType:@"gif"
                                                                                       inDirectory:@"Images"]] CGImage];
    holeUp.frame = CGRectMake(xCoordinate - [DetailViewController getHoleSize]/2, yCoordinate - [DetailViewController getHoleSize]/2, [DetailViewController getHoleSize], [DetailViewController getHoleSize]);
    holeUp.shadowOpacity = 0.7;
    holeUp.shadowRadius = 3;
    holeUp.shadowOffset = CGSizeMake(-4, -4);
    holeUp.cornerRadius = [DetailViewController getHoleSize]/2;
    holeUp.masksToBounds = YES;
    holeUp.zPosition = -1;
    
    CALayer *holeUnder = [[[CALayer alloc] init] autorelease];
    holeUnder.contents = (id)[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"HoleUnder" 
                                                                                               ofType:@"gif"
                                                                                          inDirectory:@"Images"]] CGImage];
    holeUnder.frame = CGRectMake(xCoordinate - [DetailViewController getHoleSize]/2, yCoordinate - [DetailViewController getHoleSize]/2, [DetailViewController getHoleSize], [DetailViewController getHoleSize]);
    holeUnder.zPosition = -3;
    holeUnder.cornerRadius = [DetailViewController getHoleSize]/2;
    holeUnder.masksToBounds = YES;
    
    return [[[NSArray alloc] initWithObjects:holeUp, holeUnder, nil] autorelease];
}

- (Ball *) ballWithMass:(CGFloat)mass XCoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate
{
    Ball *ball = [[[Ball alloc] initWithMass:mass initialPosition:(CGPointMake(xCoordinate, yCoordinate))] autorelease];
    ball.contents = (id)[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Ball" 
                                                                                          ofType:@"gif"
                                                                                     inDirectory:@"Images"]] CGImage];
    ball.frame = CGRectMake(xCoordinate - [DetailViewController getBallSize]/2, yCoordinate - [DetailViewController getBallSize]/2, [DetailViewController getBallSize], [DetailViewController getBallSize]);
    ball.shadowOpacity = 0.5;
    ball.shadowRadius = 3;
    ball.shadowOffset = CGSizeMake(-2, -2);
    
    return ball;
}

- (void) updateTextFieldTimer:(NSTimer *)timer
{
    self.playTime += [DetailViewController getTimerUpdateInterval];
    
    if (!self.textFieldIsFlashing)
    {
        if (self.playTime > self.levelRecord - [DetailViewController getTimeBeforRecordBeforeFlashing])
        {
            self.timerForColor = [NSTimer scheduledTimerWithTimeInterval:[DetailViewController getTimerForColorUpdateInterval]
                                             target:self
                                           selector:@selector(updateTextFieldColorTimer:)
                                           userInfo:nil
                                            repeats:YES];
            self.textFieldIsFlashing = YES;
        }
    }

    if (self.playTime > self.levelRecord)
    {
        [self.timerForColor invalidate];
        self.timerTextField.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.33];
    }
    
    if (self.playTime > [DetailViewController getMaxPlayTime])
    {
        for (Ball *ball in self.balls)
        {
            [ball toInitialState];
        }
        
        [self.timer invalidate];
        
        UIAlertView *alertOfTooLong = [[[UIAlertView alloc] initWithTitle:@"You are losеr"
                                                                  message:@"It's too long..."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Ok"
                                                        otherButtonTitles:nil, nil] autorelease];
        [alertOfTooLong show];
    }
    
    self.timerTextField.text = [NSString stringWithFormat:@"%0.1f", self.playTime];
}

- (void) updateTextFieldColorTimer:(NSTimer *)timer
{
    UIColor *greenColor_ = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.33];
    UIColor *redColor_ = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.33];
//    UIColor *greenColor = [UIColor greenColor];
//    UIColor *redColor = [UIColor redColor];

    if ([self.timerTextField.backgroundColor isEqual:greenColor_])
    {
        self.timerTextField.backgroundColor = redColor_;
    }
    else
    {
        self.timerTextField.backgroundColor = greenColor_;
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma view lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.levelRecord = [RecordsViewController getRecordForLevelFileName:self.levelFileName];
    
    if (self.levelRecord < CGFLOAT_MAX) {
        self.recordTimeTextField.text = [NSString stringWithFormat:@"%.1f", self.levelRecord];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBallInTheHoleNotification:)
                                                 name:@"BallInTheHole"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBallInTheFinishHoleNotification:)
                                                 name:@"BallInTheFinishHole"
                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    for (Ball *ball in self.balls)
    {
        [ball startWithBounds:self.bounds Holes:self.holes FinishHoles:self.finishHoles];
    }
    
    // Timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[DetailViewController getTimerUpdateInterval]
                                                  target:self
                                                selector:@selector(updateTextFieldTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    
    // Accelerometer
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 for (Ball *ball in self.balls) {
                                                     CGFloat aX = accelerometerData.acceleration.x * [OptionsViewController getFreeFallAcceleration] / [DetailViewController getFreeFallAccelerationReal];
                                                     CGFloat aY = -accelerometerData.acceleration.y * [OptionsViewController getFreeFallAcceleration] / [DetailViewController getFreeFallAccelerationReal];
                                                     ball.force = VectorMake(ball.mass * aX, ball.mass * aY);
                                                 }
                                             }];
    self.textFieldIsFlashing = NO;
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.motionManager stopAccelerometerUpdates];
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self.timer invalidate];
    [self.timerForColor invalidate];
    
    for (Ball *ball in self.balls)
    {
        [ball toInitialState];
    }
    self.playTime = 0.0;
    self.timerTextField.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.33];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BallInTheHole"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BallInTheFinishHole"
                                                  object:nil];
	[super viewDidDisappear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma AlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.title == @"You are losеr")
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (alertView.title == @"You are winner!")
    {        
        if (buttonIndex == 0) {
            [self addToRecordsNotificationForPlayTime:self.playTime];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma handling notifications

- (void) handleBallInTheHoleNotification:(NSNotification *)notification
{
    [self.timer invalidate];
    UIAlertView *alertOfBallInTheHole = [[[UIAlertView alloc] initWithTitle:@"You are losеr"
                                                            message:@"You have fallen into the hole"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil] autorelease];
    [alertOfBallInTheHole show];
}

- (void) handleBallInTheFinishHoleNotification:(NSNotification *)notification
{
    [self.timer invalidate];
    
    UIAlertView *alertOfBallInTheFinishHole;
    if (self.playTime < self.levelRecord) {
        alertOfBallInTheFinishHole = [[[UIAlertView alloc] initWithTitle:@"You are winner!"
                                                                              message:@"It's a new Record! Congratulations! "
                                                                             delegate:self
                                                                    cancelButtonTitle:@"Add to records"
                                                                    otherButtonTitles:@"No, thanks", nil] autorelease];
    }
    else
    {
        alertOfBallInTheFinishHole = [[[UIAlertView alloc] initWithTitle:@"You are winner!"
                                                                      message:@"Congratulations! "
                                                                     delegate:self
                                                            cancelButtonTitle:@"Add to records"
                                                            otherButtonTitles:@"No, thanks", nil] autorelease];
    }
    
    [alertOfBallInTheFinishHole show];
}

#pragma notifications

- (void) addToRecordsNotificationForPlayTime:(CGFloat)playTime
{
    NSMutableDictionary *notificationDictionary = [NSMutableDictionary dictionaryWithObject:self.levelFileName forKey:@"levelFileName"];
    [notificationDictionary setValue:[NSNumber numberWithFloat:playTime] forKey:@"playTime"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addToRecords"
                                                        object:self
                                                      userInfo:notificationDictionary];
}

@end
