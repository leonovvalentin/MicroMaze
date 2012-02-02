//
//  Ball.m
//  MicroMaze
//
//  Created by admin on 25.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

CGFloat const PIXELS_IN_METER = 6749.25;
CGFloat const REFRESH_TIME_INTERVAL = 0.05;
CGFloat const PERMISSIBLE_XY_DIFFERENCE = 0.0;
CGFloat const COEF = 0.2;
CGFloat const BALL_RELATIVE_SIZE_IN_HOLLE = 0.7;

@interface Ball()

@property (strong, nonatomic) DetailViewController *viewController;
@property (nonatomic) CGPoint initialPosition;

@property (nonatomic) Vector velocity;

@property (retain, nonatomic) NSTimer *redrawTimer;

- (void) reboundFromBound:(CALayer *)bound;
- (void) fallInTheHole:(CALayer *)hole;
- (void) fallInTheFinishHole:(CALayer *)finishHole;
//- (void) bumpWithBall:(Ball *)ball;

- (void)refreshPosition;

- (Vector) intersectionVectorWithRect:(CGRect)rect;

- (void) ballInTheHoleNotification;
- (void) ballInTheFinishHoleNotification;

@end

@implementation Ball

@synthesize viewController = _viewController, initialPosition = _initialPosition;
@synthesize redrawTimer = _redrawTimer;
@synthesize force = _force, mass = _mass, velocity = _velocity;;

- (void)dealloc
{
    self.redrawTimer = nil;
    self.viewController = nil;
    
    [super dealloc];
}

- (id) initWithMass:(CGFloat)mass viewController:(DetailViewController *)viewController initialPosition:(CGPoint)initialPosition
{
    self = [super init];
    self.velocity = VectorMake(0, 0);
    self.viewController = viewController;
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

- (void) start
{
    self.redrawTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_TIME_INTERVAL
                                                        target:self
                                                      selector:@selector(refreshPosition)
                                                      userInfo:nil
                                                       repeats:YES];
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
        if (absOfNumber(xyDifference) <= PERMISSIBLE_XY_DIFFERENCE) // Square intersection
        {
            self.velocity = VectorMake(-self.velocity.x * COEF, -self.velocity.y * COEF);
        }

        else if (xyDifference < 0) // Horisintal intersection
        {
                self.velocity = VectorMake(self.velocity.x, -self.velocity.y * COEF);
        }
        else if (xyDifference > 0) // Vertical intersection
        {
                self.velocity = VectorMake(-self.velocity.x * COEF, self.velocity.y);
        }
    }
}

- (void)refreshPosition
{
    self.velocity = VectorMake(self.velocity.x + self.force.x * REFRESH_TIME_INTERVAL / self.mass, self.velocity.y + self.force.y * REFRESH_TIME_INTERVAL / self.mass);
    
    CGFloat xPosition = self.position.x + self.velocity.x * PIXELS_IN_METER * REFRESH_TIME_INTERVAL;
    CGFloat yPosition = self.position.y + self.velocity.y * PIXELS_IN_METER * REFRESH_TIME_INTERVAL;

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
    for (CALayer *bound in self.viewController.bounds)
    {
        [self reboundFromBound:bound];
    }
    
    // Hole intersection
    for (CALayer *hole in self.viewController.holes)
    {
        [self fallInTheHole:hole];
    }
    
    // Finish hole intersection
    for (CALayer *finishHole in self.viewController.finishHoles)
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
