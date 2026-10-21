#import <UIKit/UIKit.h>

// --- BIẾN TOÀN CỤC (Lưu trạng thái) ---
static BOOL isAimbotEnabled = NO;
static BOOL isEspEnabled = NO;
static BOOL isSpeedEnabled = NO;
static BOOL isGodModeEnabled = NO;
static float currentFOV = 90.0;
static UIWindow *menuWindow = nil;
static UIImageView *globalLogoBtn = nil;
static UIView *globalPanelView = nil;

// --- GIAO DIỆN MENU ---
@interface MenuViewController : UIViewController
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // 1. TẠO NÚT LOGO
    globalLogoBtn = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 70, 70)];
    NSURL *url = [NSURL URLWithString:@"https://i.ibb.co/zTKMP8nv/image.png"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) { globalLogoBtn.image = [UIImage imageWithData:data]; }
    globalLogoBtn.contentMode = UIViewContentModeScaleAspectFill;
    globalLogoBtn.layer.cornerRadius = 35;
    globalLogoBtn.clipsToBounds = YES;
    globalLogoBtn.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.8].CGColor;
    globalLogoBtn.layer.borderWidth = 2.0;
    globalLogoBtn.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePanel)];
    [globalLogoBtn addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [globalLogoBtn addGestureRecognizer:panGesture];
    [self.view addSubview:globalLogoBtn];
    
    // 2. TẠO BẢNG MENU (Tăng chiều cao lên để chứa thêm nút)
    globalPanelView = [[UIView alloc] initWithFrame:CGRectMake(100, 80, 280, 520)];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = globalPanelView.bounds;
    blurView.layer.cornerRadius = 15;
    blurView.clipsToBounds = YES;
    [globalPanelView addSubview:blurView];
    
    globalPanelView.layer.cornerRadius = 15;
    globalPanelView.layer.borderWidth = 1.5;
    globalPanelView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    globalPanelView.hidden = YES;
    globalPanelView.userInteractionEnabled = YES;
    
    // Kéo thả bảng menu
    UIPanGestureRecognizer *panelPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [globalPanelView addGestureRecognizer:panelPan];
    [self.view addSubview:globalPanelView];
    
    // Logo trong menu
    UIImageView *innerLogo = [[UIImageView alloc] initWithFrame:CGRectMake(65, 15, 150, 150)];
    if (data) { innerLogo.image = [UIImage imageWithData:data]; }
    innerLogo.contentMode = UIViewContentModeScaleAspectFit;
    innerLogo.layer.cornerRadius = 75;
    innerLogo.clipsToBounds = YES;
    [globalPanelView addSubview:innerLogo];
    
    // Nút X (Đóng)
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(240, 10, 30, 30);
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [closeBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:closeBtn];
    
    // Tiêu đề
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, 280, 30)];
    title.text = @"GROCK PANEL";
    title.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    title.font = [UIFont boldSystemFontOfSize:22];
    title.textAlignment = NSTextAlignmentCenter;
    [globalPanelView addSubview:title];
    
    // --- CÁC NÚT CHỨC NĂNG ---
    
    // 1. Aimbot
    UIButton *aimbotBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    aimbotBtn.frame = CGRectMake(20, 215, 240, 40);
    [aimbotBtn setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
    aimbotBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [aimbotBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    aimbotBtn.layer.cornerRadius = 8;
    aimbotBtn.tag = 1;
    [aimbotBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:aimbotBtn];
    
    // 2. ESP
    UIButton *espBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    espBtn.frame = CGRectMake(20, 265, 240, 40);
    [espBtn setTitle:@"ESP: OFF" forState:UIControlStateNormal];
    espBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [espBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    espBtn.layer.cornerRadius = 8;
    espBtn.tag = 2;
    [espBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:espBtn];
    
    // 3. Speed Hack
    UIButton *speedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    speedBtn.frame = CGRectMake(20, 315, 240, 40);
    [speedBtn setTitle:@"Speed: OFF" forState:UIControlStateNormal];
    speedBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [speedBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    speedBtn.layer.cornerRadius = 8;
    speedBtn.tag = 3;
    [speedBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:speedBtn];
    
    // 4. God Mode
    UIButton *godBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    godBtn.frame = CGRectMake(20, 365, 240, 40);
    [godBtn setTitle:@"God Mode: OFF" forState:UIControlStateNormal];
    godBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [godBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    godBtn.layer.cornerRadius = 8;
    godBtn.tag = 4;
    [godBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:godBtn];
    
    // 5. Thanh trượt FOV
    UILabel *fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 415, 240, 20)];
    fovLabel.text = @"FOV: 90";
    fovLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    fovLabel.font = [UIFont systemFontOfSize:16];
    fovLabel.tag = 100;
    [globalPanelView addSubview:fovLabel];
    
    UISlider *fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 445, 240, 20)];
    fovSlider.minimumValue = 10;
    fovSlider.maximumValue = 180;
    fovSlider.value = 90;
    fovSlider.tintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    [fovSlider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
    [globalPanelView addSubview:fovSlider];
}

- (void)togglePanel {
    globalPanelView.hidden = !globalPanelView.hidden;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.view];
}

- (void)toggleBtnState:(UIButton *)sender {
    BOOL isEnabled = !sender.isSelected;
    [sender setSelected:isEnabled];
    
    NSString *title = @"";
    if (sender.tag == 1) { isAimbotEnabled = isEnabled; title = isEnabled ? @"Aimbot: ON" : @"Aimbot: OFF"; }
    else if (sender.tag == 2) { isEspEnabled = isEnabled; title = isEnabled ? @"ESP: ON" : @"ESP: OFF"; }
    else if (sender.tag == 3) { isSpeedEnabled = isEnabled; title = isEnabled ? @"Speed: ON" : @"Speed: OFF"; }
    else if (sender.tag == 4) { isGodModeEnabled = isEnabled; title = isEnabled ? @"God Mode: ON" : @"God Mode: OFF"; }
    
    [sender setTitle:title forState:UIControlStateNormal];
    sender.backgroundColor = isEnabled ? [UIColor colorWithWhite:0.8 alpha:1.0] : [UIColor colorWithWhite:0.2 alpha:0.8];
    [sender setTitleColor:isEnabled ? [UIColor blackColor] : [UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
}

- (void)fovChanged:(UISlider *)sender {
    currentFOV = sender.value;
    UILabel *label = [globalPanelView viewWithTag:100];
    label.text = [NSString stringWithFormat:@"FOV: %.0f", currentFOV];
}
@end

// --- HÀM KHỞI TẠO VÀ 3 NGÓN TAY ---
__attribute__((constructor))
static void setupMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        menuWindow.windowLevel = UIWindowLevelAlert + 1;
        menuWindow.backgroundColor = [UIColor clearColor];
        
        MenuViewController *vc = [[MenuViewController alloc] init];
        menuWindow.rootViewController = vc;
        menuWindow.hidden = NO;
        
        UITapGestureRecognizer *threeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handleThreeFingerTap)];
        threeFingerTap.numberOfTouchesRequired = 3; 
        threeFingerTap.numberOfTapsRequired = 2;    
        [menuWindow addGestureRecognizer:threeFingerTap];
    });
}

@interface MenuViewController (Gesture)
- (void)handleThreeFingerTap;
@end

@implementation MenuViewController (Gesture)
- (void)handleThreeFingerTap {
    BOOL isHidden = globalLogoBtn.hidden;
    globalLogoBtn.hidden = !isHidden;
    globalPanelView.hidden = YES; 
    if (isHidden) { globalLogoBtn.hidden = NO; }
}
@end
