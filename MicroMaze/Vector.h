//
//  Vector.h
//  MicroMaze
//
//  Created by admin on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef MicroMaze_Vector_h
#define MicroMaze_Vector_h

struct Vector
{
    CGFloat x;
    CGFloat y;
};
typedef struct Vector Vector;

static inline Vector
VectorMake(CGFloat x, CGFloat y)
{
    Vector vector;
    vector.x = x;
    vector.y = y;
    return vector;
}

static inline CGFloat
vectorScalarProduct(Vector vector0, Vector vector1)
{
    return vector0.x * vector1.x + vector0.y * vector1.y;
};

static inline NSInteger
signOfNumber(CGFloat number)
{
    if (number != 0) {
        number = (number < 0) ? -1 : +1;
    }
    
    return number;
};

static inline CGFloat
absOfNumber(CGFloat number)
{
    return number < 0 ? -number : number;
};


static inline CGFloat
distanceBetweenPoints(CGPoint point1, CGPoint point2)
{
    CGFloat dx = point1.x - point2.x;
    CGFloat dy = point1.y - point2.y;
    
    return sqrtf(dx*dx + dy*dy);
};

static inline CGFloat
vectorLength(Vector vector)
{
    return distanceBetweenPoints(CGPointMake(0, 0), CGPointMake(vector.x, vector.y));
};

static inline NSArray *
eightRectPoints(CGRect rect)
{
    CGPoint point0 = rect.origin;
    CGPoint point1 = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y);
    CGPoint point2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    CGPoint point3 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height / 2);
    CGPoint point4 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CGPoint point5 = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height);
    CGPoint point6 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    CGPoint point7 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height / 2);
    
    return [NSArray arrayWithObjects:[NSValue valueWithCGPoint:point0],
            [NSValue valueWithCGPoint:point1],
            [NSValue valueWithCGPoint:point2],
            [NSValue valueWithCGPoint:point3],
            [NSValue valueWithCGPoint:point4],
            [NSValue valueWithCGPoint:point5],
            [NSValue valueWithCGPoint:point6],
            [NSValue valueWithCGPoint:point7], nil];
}

#endif
