#import <UIKit/UIKit.h>

// --- BIẾN TOÀN CỤC ---
static BOOL isAimbotEnabled = NO;
static BOOL isEspEnabled = NO;
static float currentFOV = 90.0;
static UIWindow *menuWindow = nil;

// --- GIAO DIỆN MENU ---
@interface MenuViewController : UIViewController
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIButton *aimbotBtn;
@property (nonatomic, strong) UIButton *espBtn;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // 1. TẠO NÚT LOGO (Thay cho chữ M)
    UIImageView *logoBtn = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 70, 70)];
    NSURL *url = [NSURL URLWithString:@"https://i.ibb.co/zTKMP8nv/image.png"]; // Link ảnh RROCK
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
        logoBtn.image = [UIImage imageWithData:data];
    }
    logoBtn.contentMode = UIViewContentModeScaleAspectFill;
    logoBtn.layer.cornerRadius = 35; // Bo tròn 50%
    logoBtn.clipsToBounds = YES;
    logoBtn.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.8].CGColor;
    logoBtn.layer.borderWidth = 2.0;
    logoBtn.userInteractionEnabled = YES; // Cho phép chạm vào ảnh
    
    // Thêm sự kiện chạm (Tap) để mở Menu
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePanel)];
    [logoBtn addGestureRecognizer:tapGesture];
    
    // Thêm sự kiện kéo thả (Pan) cho Logo
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [logoBtn addGestureRecognizer:panGesture];
    
    [self.view addSubview:logoBtn];
    
    // 2. Tạo bảng Menu (Hiệu ứng kính mờ Xám)
    self.panelView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 280, 380)];
    
    // Nền mờ
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.panelView.bounds;
    blurView.layer.cornerRadius = 15;
    blurView.clipsToBounds = YES;
    [self.panelView addSubview:blurView];
    
    self.panelView.layer.cornerRadius = 15;
    self.panelView.layer.borderWidth = 1.5;
    self.panelView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    self.panelView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.panelView.layer.shadowOpacity = 0.8;
    self.panelView.layer.shadowRadius = 10;
    self.panelView.hidden = YES;
    [self.view addSubview:self.panelView];
    
    // 3. Logo bên trong bảng Menu
    UIImageView *innerLogo = [[UIImageView alloc] initWithFrame:CGRectMake(65, 15, 150, 150)];
    if (data) {
        innerLogo.image = [UIImage imageWithData:data];
    }
    innerLogo.contentMode = UIViewContentModeScaleAspectFit;
    innerLogo.layer.cornerRadius = 75;
    innerLogo.clipsToBounds = YES;
    [self.panelView addSubview:innerLogo];
    
    // 4. Tiêu đề
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 175, 280, 30)];
    title.text = @"GROCK PANEL";
    title.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    title.font = [UIFont boldSystemFontOfSize:22];
    title.textAlignment = NSTextAlignmentCenter;
    [self.panelView addSubview:title];
    
    // 5. Nút Aimbot (Màu xám)
    self.aimbotBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.aimbotBtn.frame = CGRectMake(20, 220, 240, 40);
    [self.aimbotBtn setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
    self.aimbotBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [self.aimbotBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    self.aimbotBtn.layer.cornerRadius = 8;
    self.aimbotBtn.tag = 1;
    [self.aimbotBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [self.panelView addSubview:self.aimbotBtn];
    
    // 6. Nút ESP
    self.espBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.espBtn.frame = CGRectMake(20, 270, 240, 40);
    [self.espBtn setTitle:@"ESP: OFF" forState:UIControlStateNormal];
    self.espBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [self.espBtn setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    self.espBtn.layer.cornerRadius = 8;
    self.espBtn.tag = 2;
    [self.espBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [self.panelView addSubview:self.espBtn];
    
    // 7. Thanh trượt FOV
    UILabel *fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 320, 240, 20)];
    fovLabel.text = @"FOV: 90";
    fovLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    fovLabel.font = [UIFont systemFontOfSize:14];
    fovLabel.tag = 100;
    [self.panelView addSubview:fovLabel];
    
    UISlider *fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 345, 240, 20)];
    fovSlider.minimumValue = 10;
    fovSlider.maximumValue = 180;
    fovSlider.value = 90;
    fovSlider.tintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    [fovSlider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panelView addSubview:fovSlider];
}

- (void)togglePanel {
    self.panelView.hidden = !self.panelView.hidden;
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
    UILabel *label = [self.panelView viewWithTag:100];
    label.text = [NSString stringWithFormat:@"FOV: %.0f", currentFOV];
}
@end

// --- HÀM KHỞI TẠO ---
__attribute__((constructor))
static void setupMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        menuWindow.windowLevel = UIWindowLevelAlert + 1;
        menuWindow.backgroundColor = [UIColor clearColor];
        menuWindow.rootViewController = [[MenuViewController alloc] init];
        menuWindow.hidden = NO;
    });
}
