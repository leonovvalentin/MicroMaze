//
//  DetailViewController.m
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h" // для FREE_FALL_ACCELERATION ??
#import "DetailViewController.h"
#import "Ball.h"

extern CGFloat FREE_FALL_ACCELERATION;
                                                                                    // Почистить константы !!
extern CGFloat const PIXELS_IN_METER;
extern CGFloat const REFRESH_TIME_INTERVAL;
//CGFloat const PH_G = 0.98; // free fall acceleration
CGFloat const TIMER_UPDATE_INTERVAL = 0.2;
CGFloat const MAX_PLAY_TIME = 99.99;
NSInteger const WINDOW_WIDTH = 320;
NSInteger const WINDOW_HIGHT = 416;
NSInteger const BALL_SIZE = 40;
NSInteger const HOLE_SIZE = 50;
NSInteger const BOUNDS_SIZE = 10;
NSInteger const FINISH_HOLE_SIZE = 60;

@interface DetailViewController ()

@property (retain, nonatomic) NSString *levelFileName;

@property(retain, nonatomic) CMMotionManager *motionManager;

@property(retain, nonatomic) NSTimer *timer;
@property(nonatomic) CGFloat playTime;
@property (retain, nonatomic) IBOutlet UITextField *timerTextField;

- (void) loadLevel;

- (NSArray *) leftTopRightBottomBounds;
- (NSArray *) holeWithXcoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate;
- (Ball *) ballWithMass:(CGFloat)mass XCoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate;
- (CALayer *) boundWithXCoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate length:(NSInteger)length horisontal:(BOOL)horisontal;
- (CALayer *) finishHoleWithXcoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate;

- (void) updateTimerTextField;

- (void) handleBallInTheHoleNotification:(NSNotification *)notification;
- (void) handleBallInTheFinishHoleNotification:(NSNotification *)notification;

- (void)addToRecordsNotificationForPlayTime:(CGFloat)playTime;

@end

@implementation DetailViewController

@synthesize balls = _balls, holes = _holes, finishHoles = _finishHoles, bounds = _bounds;
@synthesize levelFileName = _levelFileName;
@synthesize motionManager = _motionManager;
@synthesize timer = _timer, playTime = _playTime, timerTextField = _timerTextField;

- (void)dealloc
{
    self.balls = nil;
    self.holes = nil;
    self.bounds = nil;
    self.finishHoles = nil;
    
    self.levelFileName = nil;
    
    self.motionManager = nil;
    
    self.timer = nil;
    self.timerTextField = nil;
    
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
        
        // Accelerometer
        self.motionManager = [[[CMMotionManager alloc] init] autorelease];
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                     for (Ball *ball in self.balls) {
                                                         ball.force = VectorMake(ball.mass * accelerometerData.acceleration.x, -ball.mass * accelerometerData.acceleration.y);
                                                     }
                                                 }];
        
        self.playTime = 0.0;
    }
    
    return self;
}

//debug
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    Vector vector = VectorMake(([touch locationInView:self.view].x - self.view.center.x)/PIXELS_IN_METER, ([touch locationInView:self.view].y - self.view.center.y)/PIXELS_IN_METER);
    
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
    CALayer *leftBound = [self boundWithXCoordinate:BOUNDS_SIZE/2
                                        yCoordinate:BOUNDS_SIZE
                                             length:WINDOW_HIGHT - 2*BOUNDS_SIZE
                                         horisontal:NO];
    leftBound.zPosition = 1;
    // Top bound
    CALayer *topBound = [self boundWithXCoordinate:BOUNDS_SIZE
                                       yCoordinate:BOUNDS_SIZE/2
                                            length:WINDOW_WIDTH - 2*BOUNDS_SIZE
                                        horisontal:YES];
    topBound.zPosition = 1;
    // Right bound
    CALayer *rightBound = [self boundWithXCoordinate:WINDOW_WIDTH - BOUNDS_SIZE/2
                                         yCoordinate:BOUNDS_SIZE
                                              length:WINDOW_HIGHT - 2*BOUNDS_SIZE
                                          horisontal:NO];
    rightBound.zPosition = 1;
    // Bottom bound
    CALayer *bottomBound = [self boundWithXCoordinate:BOUNDS_SIZE
                                          yCoordinate:WINDOW_HIGHT - BOUNDS_SIZE/2
                                               length:WINDOW_WIDTH - 2*BOUNDS_SIZE
//                                                 length:BOUNDS_SIZE //debug
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
        bound.frame = CGRectMake(xCoordinate, yCoordinate - BOUNDS_SIZE/2, length, BOUNDS_SIZE);
    }
    else
    {
        bound.frame = CGRectMake(xCoordinate - BOUNDS_SIZE/2, yCoordinate, BOUNDS_SIZE, length);
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
    finishHole.frame = CGRectMake(xCoordinate - FINISH_HOLE_SIZE/2, yCoordinate - FINISH_HOLE_SIZE/2, FINISH_HOLE_SIZE, FINISH_HOLE_SIZE);
    finishHole.zPosition = -1;
    
    return finishHole;
}

- (NSArray *) holeWithXcoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate
{
    CALayer *holeUp = [[[CALayer alloc] init] autorelease];
    holeUp.contents = (id)[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Hole" 
                                                                                            ofType:@"gif"
                                                                                       inDirectory:@"Images"]] CGImage];
    holeUp.frame = CGRectMake(xCoordinate - HOLE_SIZE/2, yCoordinate - HOLE_SIZE/2, HOLE_SIZE, HOLE_SIZE);
    holeUp.shadowOpacity = 0.7;
    holeUp.shadowRadius = 3;
    holeUp.shadowOffset = CGSizeMake(-4, -4);
    holeUp.cornerRadius = HOLE_SIZE/2;
    holeUp.masksToBounds = YES;
    holeUp.zPosition = -1;
    
    CALayer *holeUnder = [[[CALayer alloc] init] autorelease];
    holeUnder.contents = (id)[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"HoleUnder" 
                                                                                               ofType:@"gif"
                                                                                          inDirectory:@"Images"]] CGImage];
    holeUnder.frame = CGRectMake(xCoordinate - HOLE_SIZE/2, yCoordinate - HOLE_SIZE/2, HOLE_SIZE, HOLE_SIZE);
    holeUnder.zPosition = -3;
    holeUnder.cornerRadius = HOLE_SIZE/2;
    holeUnder.masksToBounds = YES;
    
    return [[[NSArray alloc] initWithObjects:holeUp, holeUnder, nil] autorelease];
}

- (Ball *) ballWithMass:(CGFloat)mass XCoordinate:(NSInteger)xCoordinate yCoordinate:(NSInteger)yCoordinate
{
    Ball *ball = [[[Ball alloc] initWithMass:mass viewController:self initialPosition:(CGPointMake(xCoordinate, yCoordinate))] autorelease];
    ball.contents = (id)[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Ball" 
                                                                                          ofType:@"gif"
                                                                                     inDirectory:@"Images"]] CGImage];
    ball.frame = CGRectMake(xCoordinate - BALL_SIZE/2, yCoordinate - BALL_SIZE/2, BALL_SIZE, BALL_SIZE);
    ball.shadowOpacity = 0.5;
    ball.shadowRadius = 3;
    ball.shadowOffset = CGSizeMake(-2, -2);
    
    return ball;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBallInTheHoleNotification:)
                                                 name:@"BallInTheHole"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBallInTheFinishHoleNotification:)
                                                 name:@"BallInTheFinishHole"
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    for (Ball *ball in self.balls)
    {
        [ball start];
    }
    
    // Timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_UPDATE_INTERVAL
                                                  target:self
                                                selector:@selector(updateTimerTextField)
                                                userInfo:nil
                                                 repeats:YES];
    [super viewDidAppear:animated];
}

- (void) updateTimerTextField
{
    self.playTime += TIMER_UPDATE_INTERVAL;
    
    if (self.playTime > MAX_PLAY_TIME)
    {
        [self.timer invalidate];
        UIAlertView *alertOfBallInTheHole = [[[UIAlertView alloc] initWithTitle:@"You are losеr"
                                                                        message:@"It's too long..."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil, nil] autorelease];
        [alertOfBallInTheHole show];
    }
    
    self.timerTextField.text = [NSString stringWithFormat:@"%0.2f", self.playTime];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.timer invalidate];
    for (Ball *ball in self.balls)
    {
        [ball toInitialState];
    }
    self.playTime = 0.0;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BallInTheHole"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BallInTheFinishHole"
                                                  object:nil];
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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
    
    UIAlertView *alertOfBallInTheFinishHole = [[[UIAlertView alloc] initWithTitle:@"You are winner!"
                                                                  message:@"Congratulations! "
                                                                 delegate:self
                                                        cancelButtonTitle:@"Add to records"
                                                        otherButtonTitles:@"No, thanks", nil] autorelease];
    [alertOfBallInTheFinishHole show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
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

- (void)addToRecordsNotificationForPlayTime:(CGFloat)playTime
{
    NSMutableDictionary *notificationDictionary = [NSMutableDictionary dictionaryWithObject:self.levelFileName forKey:@"levelFileName"];
    [notificationDictionary setValue:[NSNumber numberWithFloat:playTime] forKey:@"playTime"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addToRecords"
                                                        object:self
                                                      userInfo:notificationDictionary];
}

@end
