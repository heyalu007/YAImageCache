

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YAImageCache : NSObject

+ (instancetype)sharedImageCache;

/**
 *  设置 cache 的上限
 *
 *  @param cacheSize cache 上限
 */
+ (void)setCacheSize:(NSInteger)cacheSize;

/**
 *  清空cache
 */
- (void)clearCache;

/**
 *  从 cache 中取得 key 对应的 image。
 *
 *  @param key key值
 *
 *  @return 对应的 image，如果取不到则返回 nil
 */
- (nullable UIImage *)getImageWithKey:(nonnull NSString *)key;

/**
 *  将 key 所对应的值设置为 image，如果原本有值，则将原本的值返回。
 *
 *  @param image 要存到对应 key 的 value
 *  @param key   要存的 key 值
 *
 *  @return 如果 key 本来对应有对象，则替换并返回原有对象，否则返回 nil
 */
- (nullable UIImage *)putImage:(nonnull UIImage *)image forKey:(nonnull NSString *)key;

NS_ASSUME_NONNULL_END

@end
