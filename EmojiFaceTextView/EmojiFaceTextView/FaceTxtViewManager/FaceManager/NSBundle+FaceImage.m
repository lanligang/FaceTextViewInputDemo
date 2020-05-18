//
//  NSBundle+FaceImage.m
//  LGCHAT
//
//  Created by ios2 on 2019/10/29.
//  Copyright © 2019 CY. All rights reserved.
//

#import "NSBundle+FaceImage.h"
#import "FaceTextManager.h"

@implementation NSBundle (FaceImage)

+ (instancetype)faceSouceBundle {
    static NSBundle *guideSouceBundle = nil;
    if (guideSouceBundle == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[FaceTextManager manager].boundleName ofType:@"bundle"];
        guideSouceBundle = [NSBundle bundleWithURL:[NSURL fileURLWithPath:path]];
    }
    return guideSouceBundle;
}

+ (UIImage *)faceImage:(NSString *)name {
    NSString *path = [[self faceSouceBundle] pathForResource:name ofType:@"png"];
    if (!path)
        return nil;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

@end
