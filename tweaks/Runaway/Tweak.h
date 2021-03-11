@interface _UIStatusBarPillView: UIView
@property (copy) CALayer* pulseLayer;
@end

@interface _UIStatusBarStringView: UILabel
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nullable, nonatomic, copy) NSAttributedString* attributedText;
@property(nonatomic) BOOL adjustsFontSizeToFitWidth;
- (void)setText:(NSString *)arg1;
@end

@interface _UIStatusBarRoundedCornerView: UIView
@end