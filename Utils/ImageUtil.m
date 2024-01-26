//
//  ImageUtil.m
//  Vē
//
//  Created by Alexandra Aurora Göttlicher
//

#import "ImageUtil.h"

@implementation ImageUtil
/**
 * Checks if an image has an alpha channel.
 *
 * @param image The image to check.
 *
 * @return Whether the image has an alpha channel.
 */
+ (BOOL)imageHasAlpha:(UIImage *)image {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo([image CGImage]);
    return (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
}
@end
