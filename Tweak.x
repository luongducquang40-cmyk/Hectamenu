#import <UIKit/UIKit.h>

// --- BIẾN TOÀN CỤC ---
static BOOL isAimbotEnabled = NO;
static BOOL isEspEnabled = NO;
static BOOL isSpeedEnabled = NO;
static BOOL isGodModeEnabled = NO;
static float currentFOV = 90.0;
static UIWindow *menuWindow = nil;
static UIImageView *globalLogoBtn = nil;
static UIView *globalPanelView = nil;

// --- GIAO DIỆN MENU (NẰM NGANG) ---
@interface MenuViewController : UIViewController
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // 1. NÚT LOGO NỔI
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
    
    // 2. BẢNG MENU NẰM NGANG (Kích thước 600x350)
    globalPanelView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 600, 350)];
    
    // Nền mờ
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = globalPanelView.bounds;
    blurView.layer.cornerRadius = 15;
    blurView.clipsToBounds = YES;
    [globalPanelView addSubview:blurView];
    
    globalPanelView.layer.cornerRadius = 15;
    globalPanelView.layer.borderWidth = 2.0;
    globalPanelView.layer.borderColor = [UIColor cyanColor].CGColor; // Viền xanh giống ảnh 2
    globalPanelView.hidden = YES;
    globalPanelView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panelPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [globalPanelView addGestureRecognizer:panelPan];
    [self.view addSubview:globalPanelView];
    
    // Tiêu đề (Giống ảnh 2)
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
    title.text = @"GROCK PANEL STORE";
    title.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.8 alpha:1.0]; // Màu xanh header
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    [globalPanelView addSubview:title];
    
    // Nút X (Đóng)
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(560, 5, 30, 30);
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [closeBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:closeBtn];
    
    // Hàm tạo hàng (Row)
    int startY = 50;
    int spacing = 40;
    
    // Row 1: Aimbot
    [self createRowWithTitle:@"Aimbot" tag:1 yPos:startY];
    // Row 2: ESP
    [self createRowWithTitle:@"ESP" tag:2 yPos:startY + spacing];
    // Row 3: Speed
    [self createRowWithTitle:@"Speed Hack" tag:3 yPos:startY + spacing * 2];
    // Row 4: God Mode
    [self createRowWithTitle:@"God Mode" tag:4 yPos:startY + spacing * 3];
    // Row 5: FOV
    [self createRowWithTitle:@"FOV Slider" tag:5 yPos:startY + spacing * 4];
    
    // Nút "AIM" và "SETTINGS" ở dưới cùng
    UIButton *aimBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    aimBtn.frame = CGRectMake(20, 300, 270, 35);
    [aimBtn setTitle:@"AIM" forState:UIControlStateNormal];
    aimBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [aimBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [globalPanelView addSubview:aimBtn];
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    setBtn.frame = CGRectMake(310, 300, 270, 35);
    [setBtn setTitle:@"SETTINGS" forState:UIControlStateNormal];
    setBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [setBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [globalPanelView addSubview:setBtn];
}

// Hàm tạo từng hàng (Text + Switch)
- (void)createRowWithTitle:(NSString *)title tag:(int)tag yPos:(int)y {
    // Chữ
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 300, 30)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16];
    [globalPanelView addSubview:label];
    
    if (tag != 5) {
        // Nút gạt (Toggle Switch)
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(530, y, 50, 30)];
        toggle.tag = tag;
        toggle.onTintColor = [UIColor cyanColor]; // Màu xanh cyan
        [toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [globalPanelView addSubview:toggle];
    } else {
        // Thanh trượt FOV
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(350, y+5, 220, 20)];
        slider.minimumValue = 10;
        slider.maximumValue = 180;
        slider.value = 90;
        slider.tag = 100;
        slider.tintColor = [UIColor cyanColor];
        [slider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
        [globalPanelView addSubview:slider];
    }
}

- (void)togglePanel {
    globalPanelView.hidden = !globalPanelView.hidden;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.view];
}

// Xử lý khi gạt công tắc
- (void)switchChanged:(UISwitch *)sender {
    if (sender.tag == 1) { isAimbotEnabled = sender.isOn; }
    else if (sender.tag == 2) { isEspEnabled = sender.isOn; }
    else if (sender.tag == 3) { isSpeedEnabled = sender.isOn; }
    else if (sender.tag == 4) { isGodModeEnabled = sender.isOn; }
}

- (void)fovChanged:(UISlider *)sender {
    currentFOV = sender.value;
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
