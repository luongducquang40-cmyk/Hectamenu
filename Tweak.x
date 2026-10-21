#import <UIKit/UIKit.h>

// Khai báo các biến lưu trạng thái
static BOOL isMenuVisible = NO;
static BOOL isAimbotEnabled = NO;
static float currentFov = 90.0;

@interface MyMenuView : UIView
@end

@implementation MyMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Cấu hình giao diện Menu
        self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
        self.layer.cornerRadius = 15.0;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor redColor].CGColor;
        
        // Tiêu đề
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        title.text = @"GROCK MENU";
        title.textColor = [UIColor redColor];
        title.font = [UIFont boldSystemFontOfSize:18];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        // Nút bật/tắt Aimbot
        UIButton *aimbotBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        aimbotBtn.frame = CGRectMake(15, 50, frame.size.width - 30, 40);
        [aimbotBtn setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
        [aimbotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        aimbotBtn.backgroundColor = [UIColor darkGrayColor];
        aimbotBtn.layer.cornerRadius = 8.0;
        [aimbotBtn addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:aimbotBtn];
        
        // Thanh trượt FOV
        UILabel *fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 100, 20)];
        fovLabel.text = @"FOV: 90";
        fovLabel.textColor = [UIColor whiteColor];
        fovLabel.tag = 100;
        [self addSubview:fovLabel];
        
        UISlider *fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(15, 125, frame.size.width - 30, 20)];
        fovSlider.minimumValue = 1;
        fovSlider.maximumValue = 180;
        fovSlider.value = 90;
        [fovSlider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:fovSlider];
        
        // Nút Đóng Menu
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(15, 160, frame.size.width - 30, 30);
        [closeBtn setTitle:@"Đóng" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
    }
    return self;
}

- (void)toggleAimbot:(UIButton *)sender {
    isAimbotEnabled = !isAimbotEnabled;
    NSString *status = isAimbotEnabled ? @"ON" : @"OFF";
    [sender setTitle:[NSString stringWithFormat:@"Aimbot: %@", status] forState:UIControlStateNormal];
    sender.backgroundColor = isAimbotEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
}

- (void)fovChanged:(UISlider *)sender {
    currentFov = sender.value;
    UILabel *label = [self viewWithTag:100];
    label.text = [NSString stringWithFormat:@"FOV: %.0f", currentFov];
}

- (void)closeMenu {
    self.hidden = YES;
    isMenuVisible = NO;
}
@end

// Hook vào UIWindow để chèn nút và Menu
%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    
    // Tạo nút nổi "MENU" ở góc trái trên
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 100, 60, 60);
    btn.backgroundColor = [UIColor redColor];
    btn.layer.cornerRadius = 30;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.borderWidth = 2.0;
    [btn setTitle:@"MENU" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    
    [btn addTarget:self action:@selector(toggleMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)toggleMenu:(UIButton *)sender {
    isMenuVisible = !isMenuVisible;
    
    // Nếu menu chưa có, tạo mới
    MyMenuView *menu = (MyMenuView *)[self viewWithTag:999];
    if (!menu) {
        menu = [[MyMenuView alloc] initWithFrame:CGRectMake(100, 100, 250, 200)];
        menu.tag = 999;
        menu.hidden = YES;
        [self addSubview:menu];
    }
    
    menu.hidden = !isMenuVisible;
}

%end
