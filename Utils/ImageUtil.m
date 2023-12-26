//
//  ImageUtil.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "ImageUtil.h"

@implementation ImageUtil
+ (BOOL)imageHasAlpha:(UIImage *)image {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo([image CGImage]);
    return (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
}
@end
