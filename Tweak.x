#import <UIKit/UIKit.h>

%hook UIWindow
- (void)makeKeyAndVisible {
    %orig;
    
    // Tạo nút Menu nổi ở góc màn hình
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 100, 60, 60);
    btn.backgroundColor = [UIColor redColor];
    btn.layer.cornerRadius = 30;
    [btn setTitle:@"MENU" forState:UIControlStateNormal];
    
    [self addSubview:btn];
}
%end
