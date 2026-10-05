// 生成小黄鸭 App 图标(1024×1024 PNG),CoreGraphics 手绘,无图片资源依赖。
// 用法:icongen 输出路径.png(由 gen-icons.sh 编译运行)
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

static CGColorRef MakeColor(CGColorSpaceRef cs, CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    CGFloat comps[4] = {r, g, b, a};
    return CGColorCreate(cs, comps);
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        CGFloat S = 1024;
        CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        CGContextRef ctx = CGBitmapContextCreate(NULL, (size_t)S, (size_t)S, 8, 0, cs,
                                                 kCGImageAlphaPremultipliedLast);
        CGColorRef sky    = MakeColor(cs, 0.557, 0.847, 0.973, 1);
        CGColorRef water  = MakeColor(cs, 0.31,  0.62,  0.85,  1);
        CGColorRef foam   = MakeColor(cs, 1,     1,     1,     0.5);
        CGColorRef yellow = MakeColor(cs, 1.0,   0.851, 0.231, 1);
        CGColorRef shade  = MakeColor(cs, 0.949, 0.718, 0.208, 1);
        CGColorRef orange = MakeColor(cs, 1.0,   0.624, 0.11,  1);
        CGColorRef white  = MakeColor(cs, 1,     1,     1,     1);
        CGColorRef pupil  = MakeColor(cs, 0.23,  0.16,  0.10,  1);

        CGContextSetFillColorWithColor(ctx, sky);
        CGContextFillRect(ctx, CGRectMake(0, 0, S, S));
        CGContextSetFillColorWithColor(ctx, water);
        CGContextFillRect(ctx, CGRectMake(0, 0, S, S * 0.24));
        CGContextSetFillColorWithColor(ctx, foam);
        CGContextFillRect(ctx, CGRectMake(0, S * 0.24, S, S * 0.015));

        // 水面以上按 y 向上布局:身体、翅膀、头、嘴、眼睛
        CGContextSetFillColorWithColor(ctx, yellow);
        CGContextFillEllipseInRect(ctx, CGRectMake(S * 0.14, S * 0.18, S * 0.56, S * 0.40));
        CGContextSetFillColorWithColor(ctx, shade);
        CGContextFillEllipseInRect(ctx, CGRectMake(S * 0.22, S * 0.32, S * 0.22, S * 0.13));
        CGContextSetFillColorWithColor(ctx, yellow);
        CGContextFillEllipseInRect(ctx, CGRectMake(S * 0.53, S * 0.48, S * 0.31, S * 0.31));
        CGContextSetFillColorWithColor(ctx, orange);
        CGContextFillEllipseInRect(ctx, CGRectMake(S * 0.76, S * 0.54, S * 0.15, S * 0.085));
        CGContextSetFillColorWithColor(ctx, white);
        CGContextFillEllipseInRect(ctx, CGRectMake(S * 0.645, S * 0.65, S * 0.052, S * 0.052));
        CGContextSetFillColorWithColor(ctx, pupil);
        CGContextFillEllipseInRect(ctx, CGRectMake(S * 0.660, S * 0.658, S * 0.028, S * 0.028));
        CGContextSetFillColorWithColor(ctx, white);
        CGContextFillEllipseInRect(ctx, CGRectMake(S * 0.672, S * 0.672, S * 0.010, S * 0.010));

        CGImageRef image = CGBitmapContextCreateImage(ctx);
        NSString *outPath = argc > 1 ? [NSString stringWithUTF8String:argv[1]] : @"icon-1024.png";
        NSURL *outURL = [NSURL fileURLWithPath:outPath];
        CGImageDestinationRef dest = CGImageDestinationCreateWithURL((__bridge CFURLRef)outURL,
                                                                     CFSTR("public.png"), 1, NULL);
        if (!dest) return 2;
        CGImageDestinationAddImage(dest, image, NULL);
        CGImageDestinationFinalize(dest);
        printf("icon written: %s\n", outPath.UTF8String);
        return 0;
    }
}
