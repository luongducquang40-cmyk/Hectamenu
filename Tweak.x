#import <UIKit/UIKit.h>

// --- BIẾN TOÀN CỤC ---
static BOOL isAimbotEnabled = NO;
static BOOL isEspEnabled = NO;
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
    
    // 2. TẠO BẢNG MENU
    globalPanelView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 280, 450)];
    
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
    
    UIPanGestureRecognizer *panelPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [globalPanelView addGestureRecognizer:panelPan];
    [self.view addSubview:globalPanelView];
    
    // Logo trong menu
    UIImageView *innerLogo = [[UIImageView alloc] initWithFrame:CGRectMake(65, 20, 150, 150)];
    if (data) { innerLogo.image = [UIImage imageWithData:data]; }
    innerLogo.contentMode = UIViewContentModeScaleAspectFit;
    innerLogo.layer.cornerRadius = 75;
    innerLogo.clipsToBounds = YES;
    [globalPanelView addSubview:innerLogo];
    
    // Nút X
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(240, 10, 30, 30);
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [closeBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:closeBtn];
    
    // Tiêu đề
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 280, 30)];
    title.text = @"GROCK PANEL";
    title.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    title.font = [UIFont boldSystemFontOfSize:22];
    title.textAlignment = NSTextAlignmentCenter;
    [globalPanelView addSubview:title];
    
    // Nút Aimbot
    UIButton *aimbotBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    aimbotBtn.frame = CGRectMake(20, 230, 240, 45);
    [aimbotBtn setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
    aimbotBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [aimbotBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    aimbotBtn.layer.cornerRadius = 8;
    aimbotBtn.tag = 1;
    [aimbotBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:aimbotBtn];
    
    // Nút ESP
    UIButton *espBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    espBtn.frame = CGRectMake(20, 290, 240, 45);
    [espBtn setTitle:@"ESP: OFF" forState:UIControlStateNormal];
    espBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [espBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    espBtn.layer.cornerRadius = 8;
    espBtn.tag = 2;
    [espBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:espBtn];
    
    // FOV
    UILabel *fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 350, 240, 20)];
    fovLabel.text = @"FOV: 90";
    fovLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    fovLabel.font = [UIFont systemFontOfSize:16];
    fovLabel.tag = 100;
    [globalPanelView addSubview:fovLabel];
    
    UISlider *fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 380, 240, 20)];
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
    if (sender.tag == 1) {
        isAimbotEnabled = !isAimbotEnabled;
        [sender setTitle:isAimbotEnabled ? @"Aimbot: ON" : @"Aimbot: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = isAimbotEnabled ? [UIColor colorWithWhite:0.8 alpha:1.0] : [UIColor colorWithWhite:0.2 alpha:0.8];
        [sender setTitleColor:isAimbotEnabled ? [UIColor blackColor] : [UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    } else {
        isEspEnabled = !isEspEnabled;
        [sender setTitle:isEspEnabled ? @"ESP: ON" : @"ESP: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = isEspEnabled ? [UIColor colorWithWhite:0.8 alpha:1.0] : [UIColor colorWithWhite:0.2 alpha:0.8];
        [sender setTitleColor:isEspEnabled ? [UIColor blackColor] : [UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    }
}

- (void)fovChanged:(UISlider *)sender {
    currentFOV = sender.value;
    UILabel *label = [globalPanelView viewWithTag:100];
    label.text = [NSString stringWithFormat:@"FOV: %.0f", currentFOV];
}
@end

// --- HÀM KHỞI TẠO VÀ CƠ CHẾ 3 NGÓN TAY ---
__attribute__((constructor))
static void setupMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        menuWindow.windowLevel = UIWindowLevelAlert + 1;
        menuWindow.backgroundColor = [UIColor clearColor];
        
        MenuViewController *vc = [[MenuViewController alloc] init];
        menuWindow.rootViewController = vc;
        menuWindow.hidden = NO;
        
        // CƠ CHẾ 3 NGÓN TAY CHẠM 2 LẦN
        UITapGestureRecognizer *threeFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handleThreeFingerTap)];
        threeFingerTap.numberOfTouchesRequired = 3; // Yêu cầu 3 ngón tay
        threeFingerTap.numberOfTapsRequired = 2;    // Chạm 2 lần
        [menuWindow addGestureRecognizer:threeFingerTap];
    });
}

// Thêm hàm xử lý 3 ngón tay vào MenuViewController
@interface MenuViewController (Gesture)
- (void)handleThreeFingerTap;
@end

@implementation MenuViewController (Gesture)
- (void)handleThreeFingerTap {
    // Ẩn/hiện cả Logo và Bảng Menu
    BOOL isHidden = globalLogoBtn.hidden;
    globalLogoBtn.hidden = !isHidden;
    globalPanelView.hidden = YES; // Khi ẩn Logo thì ẩn luôn bảng Menu
    
    // Nếu đang ẩn mà bật lên thì hiện Logo thôi
    if (isHidden) {
        globalLogoBtn.hidden = NO;
    }
}
@end
