

#import "YAImageCache.h"

const NSInteger kDefaultMaxSize = 960*640*10;

@interface YAImageCache ()

@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSMutableOrderedSet *keys;
@property (nonatomic) NSInteger maxSize;
@property (nonatomic) NSInteger currentSize;

@end

@implementation YAImageCache

+ (YAImageCache *)sharedImageCache
{
    static dispatch_once_t pred;
    static YAImageCache *sharedManager = nil;
    dispatch_once(&pred, ^{
        sharedManager = [[YAImageCache alloc] init];
    });
    return sharedManager;
}

+ (void)setCacheSize:(NSInteger)cacheSize
{
    [[self sharedImageCache] resize:cacheSize];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.imageCache = [[NSMutableDictionary alloc] init];
        self.keys = [[NSMutableOrderedSet alloc] init];
        self.maxSize = kDefaultMaxSize;
    }
    return self;
}

- (void)clearCache
{
    @synchronized(self){
        [self.imageCache removeAllObjects];
        [self.keys removeAllObjects];
    }
}

- (UIImage *)getImageWithKey:(NSString *)key
{
    if (key == nil) {
        [NSException raise:@"Null Pointer" format:@"key == nil"];
    }
    NSString *cKey = [key copy];
    @synchronized(self) {
        UIImage *image = _imageCache[cKey];
        if (image != nil) {
            [_keys removeObject:cKey];
            [_keys insertObject:cKey atIndex:0];
            return image;
        }
    }
    return nil;
}

- (UIImage *)putImage:(UIImage *)image forKey:(NSString *)key
{
    if (key == nil || image == nil) {
        [NSException raise:@"Null Pointer" format:@"key == nil || image == nil"];
    }
    NSString *cKey = [key copy];
    UIImage *previous;
    @synchronized (self) {
        self.currentSize += image.size.width * image.size.height;
        previous = self.imageCache[cKey];
        if (previous != nil) {
            self.currentSize -= previous.size.width * previous.size.height;
        }
        [self.imageCache setObject:image forKey:cKey];
        [_keys removeObject:cKey];
        [_keys insertObject:cKey atIndex:0];
    }
    [self trimToSize:self.maxSize];
    return previous;
}

- (void)trimToSize:(NSInteger)maxSize
{
    while (YES) {
        @synchronized (self) {
            if (self.currentSize < 0 || ([self.imageCache count] == 0 && self.currentSize != 0)) {
                [NSException raise:@"Illegal State" format:@"inconsistent size."];
            }
            
            if (self.currentSize <= maxSize || [self.imageCache count] == 0) {
                break;
            }
            
            NSString *key = [_keys lastObject];
            UIImage *image = self.imageCache[key];
            if (image == nil) {
                [NSException raise:@"Illegal State" format:@"inconsistent key-value set."];
            }
            
            [_keys removeObject:key];
            [self.imageCache removeObjectForKey:key];
            self.currentSize -= image.size.height * image.size.width;
        }
    }
}

- (void)resize:(NSInteger)maxSize
{
    if (maxSize <= 0) {
        [NSException raise:@"Illegal Argument" format:@"maxSize <= 0"];
    }
    
    @synchronized (self) {
        self.maxSize = maxSize;
    }
    [self trimToSize:maxSize];
}

@end
