//
//  Ball.m
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

@interface Ball()

@property (nonatomic) CGPoint initialPosition;

@property (nonatomic) Vector velocity;

@property (retain, nonatomic) NSTimer *redrawTimer;

- (void) reboundFromBound:(CALayer *)bound;
- (void) fallInTheHole:(CALayer *)hole;
- (void) fallInTheFinishHole:(CALayer *)finishHole;
//- (void) bumpWithBall:(Ball *)ball;

- (void)refreshPositionWithTimer:(NSTimer *)timer;

- (Vector) intersectionVectorWithRect:(CGRect)rect;

- (void) ballInTheHoleNotification;
- (void) ballInTheFinishHoleNotification;

@end

@implementation Ball

#pragma statics

static CGFloat const _pixelsInMeter = 6749.25;
static CGFloat const _refreshTimeInterval = 0.05/*0.01*/;
static CGFloat const _velocityCoefficientAfterImpact = 0.2;

+ (CGFloat) getPixelsInMeter
{
    return _pixelsInMeter;
}

+ (CGFloat) getRefreshTimeInterval
{
    return _refreshTimeInterval;
}

+ (CGFloat) getVelocityCoefficientAfterImpact
{
    return _velocityCoefficientAfterImpact;
}

#pragma non statics

@synthesize initialPosition = _initialPosition;
@synthesize redrawTimer = _redrawTimer;
@synthesize force = _force, mass = _mass, velocity = _velocity;;

- (void)dealloc
{
    self.redrawTimer = nil;
    [super dealloc];
}

- (id) initWithMass:(CGFloat)mass initialPosition:(CGPoint)initialPosition
{
    self = [super init];
    self.velocity = VectorMake(0, 0);
    _mass = mass;
    self.initialPosition = initialPosition;
    self.zPosition = 0;
    
    return self;
}

- (void) toInitialState
{
    [self.redrawTimer invalidate];
    self.position = self.initialPosition;
    self.velocity = VectorMake(0, 0);
    self.force = VectorMake(0, 0);
    self.zPosition = 0;
}

- (void) startWithBounds:(NSArray *)bounds Holes:(NSArray *)holes FinishHoles:(NSArray *)finishHoles
{
    NSDictionary *boundsHolesFinishHolesDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:bounds, holes, finishHoles, nil]
                                                                                 forKeys:[NSArray arrayWithObjects:@"Bounds", @"Holes", @"FinishHoles", nil]];

    self.redrawTimer = [NSTimer scheduledTimerWithTimeInterval:[Ball getRefreshTimeInterval]
                                                        target:self
                                                      selector:@selector(refreshPositionWithTimer:)
                                                      userInfo:boundsHolesFinishHolesDictionary
                                                       repeats:YES];
}

- (void)refreshPositionWithTimer:(NSTimer *)timer
{
    NSDictionary *boundsHolesFinishHolesDictionary = timer.userInfo;
    
    self.velocity = VectorMake(self.velocity.x + self.force.x * [Ball getRefreshTimeInterval] / self.mass, self.velocity.y + self.force.y * [Ball getRefreshTimeInterval] / self.mass);

    CGFloat xPosition = self.position.x + self.velocity.x * [Ball getPixelsInMeter] * [Ball getRefreshTimeInterval];
    CGFloat yPosition = self.position.y + self.velocity.y * [Ball getPixelsInMeter] * [Ball getRefreshTimeInterval];

    [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.position = CGPointMake(xPosition, yPosition);
    [CATransaction commit];

//    // Ball intersection
//    {
//        for (Ball *ball in self.viewController.balls)
//        {
//            if (ball == self) {
//                continue;
//            }
//            [self bumpWithBall:ball];
//        }        
//    }
    
    // Bound intersection
    for (CALayer *bound in [boundsHolesFinishHolesDictionary valueForKey:@"Bounds"])
    {
        [self reboundFromBound:bound];
    }
    
    // Hole intersection
    for (CALayer *hole in [boundsHolesFinishHolesDictionary valueForKey:@"Holes"])
    {
        [self fallInTheHole:hole];
    }
   
    // Finish hole intersection
    for (CALayer *finishHole in [boundsHolesFinishHolesDictionary valueForKey:@"FinishHoles"])
    {
        [self fallInTheFinishHole:finishHole];
    }
}

//- (void) bumpWithBall:(Ball *)ball
//{
//    Vector vectorToBall = VectorMake(ball.position.x - self.position.x, ball.position.y - self.position.y);
//    CGFloat difference = vectorLength(vectorToBall) - self.bounds.size.width / 2 - ball.bounds.size.width / 2;
//    if (difference < 0)
//    {
//        difference = absOfNumber(difference);
//        // Normalize
//        Vector vectorSelfToBall = VectorMake(vectorToBall.x / vectorLength(vectorToBall), vectorToBall.y / vectorLength(vectorToBall));
//        Vector vectorOfCollision = VectorMake(vectorSelfToBall.y, -vectorSelfToBall.x);
//        
//        // Relative masses
//        CGFloat selfRelativeMass = self.mass / (self.mass + ball.mass);
//        CGFloat ballRelativeMass = ball.mass / (self.mass + ball.mass);
//        
//        // Remove intersection
//        Vector intersectionVector = VectorMake(difference * vectorSelfToBall.x,
//                                               difference * vectorSelfToBall.y);
//        [CATransaction begin];
//        [CATransaction setValue:(id)kCFBooleanTrue
//                         forKey:kCATransactionDisableActions];
//            self.position = CGPointMake(self.position.x - intersectionVector.x * ballRelativeMass,
//                                        self.position.y - intersectionVector.y * ballRelativeMass);
//            ball.position = CGPointMake(ball.position.x + intersectionVector.x * selfRelativeMass,
//                                        ball.position.y + intersectionVector.y * selfRelativeMass);
//        [CATransaction commit];
//        // Relative velocities
//        Vector selfRelativeVelocity = VectorMake(self.velocity.x - ball.velocity.x, self.velocity.y - ball.velocity.y);
//        Vector ballRelativeVelocity = VectorMake(vectorScalarProduct(selfRelativeVelocity, vectorSelfToBall) * vectorSelfToBall.x,
//                                         vectorScalarProduct(selfRelativeVelocity, vectorSelfToBall) * vectorSelfToBall.y);
//        selfRelativeVelocity = VectorMake(vectorScalarProduct(selfRelativeVelocity, vectorOfCollision) * vectorOfCollision.x,
//                                  vectorScalarProduct(selfRelativeVelocity, vectorOfCollision) * vectorOfCollision.y);
//        // Real velocities
//        self.velocity = VectorMake((selfRelativeVelocity.x * ballRelativeMass) + ball.velocity.x,
//                                   (selfRelativeVelocity.y * ballRelativeMass) + ball.velocity.y);
//        ballRelativeVelocity = VectorMake((ballRelativeVelocity.x * selfRelativeMass) + ball.velocity.x,
//                                  (ballRelativeVelocity.y * selfRelativeMass) + ball.velocity.y);
//        ball.velocity = ballRelativeVelocity;
//    }
//}

- (void) fallInTheHole:(CALayer *)hole
{
    Vector newForce = VectorMake(hole.position.x - self.position.x, hole.position.y - self.position.y);
    if (vectorLength(newForce) < hole.bounds.size.width / 2) {
        [self.redrawTimer invalidate];
        self.position = hole.position;
        self.zPosition = -2;
        [self ballInTheHoleNotification];
    }
}

- (void) fallInTheFinishHole:(CALayer *)finishHole
{
    Vector newForce = VectorMake(finishHole.position.x - self.position.x, finishHole.position.y - self.position.y);
    if (vectorLength(newForce) < finishHole.bounds.size.width / 2) {
        [self.redrawTimer invalidate];
        self.position = finishHole.position;
        [self ballInTheFinishHoleNotification];
    }
}

- (void) reboundFromBound:(CALayer *)bound
{
    CGRect intersectionRect = CGRectIntersection(self.frame, bound.frame);
    Vector intersectionVector = [self intersectionVectorWithRect:intersectionRect];
    if (vectorLength(intersectionVector) > 0)
    {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.position = CGPointMake(self.position.x - intersectionVector.x, self.position.y - intersectionVector.y);
        [CATransaction commit];
        
        CGFloat xyDifference  = (absOfNumber(intersectionVector.x) - absOfNumber(intersectionVector.y));
        if (absOfNumber(xyDifference) == 0) // Square intersection
        {
            self.velocity = VectorMake(-self.velocity.x * [Ball getVelocityCoefficientAfterImpact], -self.velocity.y * [Ball getVelocityCoefficientAfterImpact]);
        }
        
        else if (xyDifference < 0) // Horisintal intersection
        {
            self.velocity = VectorMake(self.velocity.x, -self.velocity.y * [Ball getVelocityCoefficientAfterImpact]);
        }
        else if (xyDifference > 0) // Vertical intersection
        {
            self.velocity = VectorMake(-self.velocity.x * [Ball getVelocityCoefficientAfterImpact], self.velocity.y);
        }
    }
}

- (Vector) intersectionVectorWithRect:(CGRect)rect
{
    if (rect.size.width * rect.size.height <= 0) {
        return VectorMake(0, 0);
    }
    
    CGFloat minDistance = MAXFLOAT;
    CGPoint minPoint = rect.origin;
    for (id pointId in eightRectPoints(rect))
    {
        CGPoint point = [pointId CGPointValue];
        if (minDistance > distanceBetweenPoints(self.position, point))
        {
            minDistance = distanceBetweenPoints(self.position, point);
            minPoint = point;
        }
    }

    Vector vectorFromBallCenterToMinPoint = VectorMake(minPoint.x - self.position.x, minPoint.y - self.position.y);;
    Vector vectorFromBallCenterToRadius = VectorMake((self.bounds.size.width / 2) * vectorFromBallCenterToMinPoint.x / vectorLength(vectorFromBallCenterToMinPoint),
                                                   (self.bounds.size.width / 2) * vectorFromBallCenterToMinPoint.y / vectorLength(vectorFromBallCenterToMinPoint));
    
    if (vectorLength(vectorFromBallCenterToMinPoint) > vectorLength(vectorFromBallCenterToRadius)) {
        return VectorMake(0, 0);
    }
    
    return VectorMake(vectorFromBallCenterToRadius.x - vectorFromBallCenterToMinPoint.x,
                      vectorFromBallCenterToRadius.y - vectorFromBallCenterToMinPoint.y);
}

#pragma Notifications

- (void) ballInTheHoleNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BallInTheHole"
                                                        object:self];
}

- (void) ballInTheFinishHoleNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BallInTheFinishHole"
                                                        object:self];
}
@end
