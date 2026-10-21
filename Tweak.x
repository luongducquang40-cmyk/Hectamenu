#import <UIKit/UIKit.h>

// --- BIẾN TOÀN CỤC ---
static BOOL isAimbotEnabled = NO;
static BOOL isEspEnabled = NO;
static BOOL isSpeedEnabled = NO;
static BOOL isGodModeEnabled = NO;
static BOOL isAntibanEnabled = NO;
static float currentFOV = 90.0;
static UIWindow *menuWindow = nil;
static UIImageView *globalLogoBtn = nil;
static UIView *globalPanelView = nil;
static UIView *infoPanelView = nil;
static UIView *antibandPanelView = nil;
static UITextView *consoleTextView = nil;
static UILabel *statusLabel = nil;

// Lưu tham chiếu các nút gạt để cập nhật từ Web
static UISwitch *aimbotSwitch = nil;
static UISwitch *espSwitch = nil;
static UISwitch *speedSwitch = nil;
static UISwitch *godSwitch = nil;
static UISlider *fovSliderRef = nil;

// --- GIAO DIỆN MENU ---
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
    UIPanGestureRecognizer *panGesture [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [globalLogoBtn addGestureRecognizer:panGesture];
    [self.view addSubview:globalLogoBtn];
    
    // 2. BẢNG MENU CHÍNH
    globalPanelView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 600, 380)];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = globalPanelView.bounds;
    blurView.layer.cornerRadius = 15;
    blurView.clipsToBounds = YES;
    [globalPanelView addSubview:blurView];
    
    globalPanelView.layer.cornerRadius = 15;
    globalPanelView.layer.borderWidth = 2.0;
    globalPanelView.layer.borderColor = [UIColor cyanColor].CGColor;
    globalPanelView.hidden = YES;
    globalPanelView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panelPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [globalPanelView addGestureRecognizer:panelPan];
    [self.view addSubview:globalPanelView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 40)];
    title.text = @"GROCK PANEL STORE";
    title.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.8 alpha:1.0];
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    [globalPanelView addSubview:title];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(560, 5, 30, 30);
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [closeBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:closeBtn];
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 45, 560, 20)];
    statusLabel.text = @"Trạng thái Web: Đang kết nối...";
    statusLabel.textColor = [UIColor yellowColor];
    statusLabel.font = [UIFont systemFontOfSize:12];
    [globalPanelView addSubview:statusLabel];
    
    int startY = 70;
    int spacing = 40;
    
    // Lưu tham chiếu các nút gạt
    aimbotSwitch = [self createRowWithTitle:@"Aimbot" tag:1 yPos:startY];
    espSwitch = [self createRowWithTitle:@"ESP" tag:2 yPos:startY + spacing];
    speedSwitch = [self createRowWithTitle:@"Speed Hack" tag:3 yPos:startY + spacing * 2];
    godSwitch = [self createRowWithTitle:@"God Mode" tag:4 yPos:startY + spacing * 3];
    fovSliderRef = [self createSliderWithTitle:@"FOV Slider" tag:5 yPos:startY + spacing * 4];
    
    UIButton *antibanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    antibanBtn.frame = CGRectMake(20, 320, 270, 35);
    [antibanBtn setTitle:@"ANTIBAN" forState:UIControlStateNormal];
    antibanBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [antibanBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [antibanBtn addTarget:self action:@selector(showAntibanPanel) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:antibanBtn];
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    infoBtn.frame = CGRectMake(310, 320, 270, 35);
    [infoBtn setTitle:@"THÔNG TIN" forState:UIControlStateNormal];
    infoBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [infoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(showInfoPanel) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:infoBtn];
    
    // --- BẢNG THÔNG TIN ---
    // (Giữ nguyên phần thông tin và các nút mạng xã hội như cũ)
    infoPanelView = [[UIView alloc] initWithFrame:CGRectMake(150, 150, 400, 300)];
    UIVisualEffectView *infoBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    infoBlur.frame = infoPanelView.bounds;
    infoBlur.layer.cornerRadius = 15;
    infoBlur.clipsToBounds = YES;
    [infoPanelView addSubview:infoBlur];
    infoPanelView.layer.cornerRadius = 15;
    infoPanelView.layer.borderWidth = 2.0;
    infoPanelView.layer.borderColor = [UIColor greenColor].CGColor;
    infoPanelView.hidden = YES;
    [self.view addSubview:infoPanelView];
    
    UILabel *infoTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 400, 30)];
    infoTitle.text = @"THÔNG TIN CÁ NHÂN";
    infoTitle.textColor = [UIColor greenColor];
    infoTitle.font = [UIFont boldSystemFontOfSize:18];
    infoTitle.textAlignment = NSTextAlignmentCenter;
    [infoPanelView addSubview:infoTitle];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 360, 30)];
    nameLabel.text = @"👤 Tên: Lương Đức Quang";
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [infoPanelView addSubview:nameLabel];
    
    UIButton *fbBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    fbBtn.frame = CGRectMake(50, 100, 300, 45);
    [fbBtn setTitle:@"🌐 TRUY CẬP FACEBOOK" forState:UIControlStateNormal];
    [fbBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fbBtn.backgroundColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.8 alpha:1.0];
    fbBtn.layer.cornerRadius = 10;
    [fbBtn addTarget:self action:@selector(openFacebook) forControlEvents:UIControlEventTouchUpInside];
    [infoPanelView addSubview:fbBtn];
    
    UIButton *ttBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    ttBtn.frame = CGRectMake(50, 160, 300, 45);
    [ttBtn setTitle:@"🎵 TRUY CẬP TIKTOK" forState:UIControlStateNormal];
    [ttBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    ttBtn.backgroundColor = [UIColor blackColor];
    ttBtn.layer.cornerRadius = 10;
    ttBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    ttBtn.layer.borderWidth = 1.0;
    [ttBtn addTarget:self action:@selector(openTikTok) forControlEvents:UIControlEventTouchUpInside];
    [infoPanelView addSubview:ttBtn];
    
    UIButton *closeInfoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeInfoBtn.frame = CGRectMake(150, 230, 100, 30);
    [closeInfoBtn setTitle:@"Đóng" forState:UIControlStateNormal];
    [closeInfoBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeInfoBtn addTarget:self action:@selector(hideInfoPanel) forControlEvents:UIControlEventTouchUpInside];
    [infoPanelView addSubview:closeInfoBtn];
    
    // --- BẢNG ANTIBAN ---
    antibandPanelView = [[UIView alloc] initWithFrame:CGRectMake(150, 150, 400, 250)];
    UIVisualEffectView *abBlur = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    abBlur.frame = antibandPanelView.bounds;
    abBlur.layer.cornerRadius = 15;
    abBlur.clipsToBounds = YES;
    [antibandPanelView addSubview:abBlur];
    antibandPanelView.layer.cornerRadius = 15;
    antibandPanelView.layer.borderWidth = 2.0;
    antibandPanelView.layer.borderColor = [UIColor redColor].CGColor;
    antibandPanelView.hidden = YES;
    [self.view addSubview:antibandPanelView];
    
    UILabel *abTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 400, 30)];
    abTitle.text = @"ANTIBAN CONSOLE";
    abTitle.textColor = [UIColor redColor];
    abTitle.font = [UIFont boldSystemFontOfSize:18];
    abTitle.textAlignment = NSTextAlignmentCenter;
    [antibandPanelView addSubview:abTitle];
    
    consoleTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 50, 360, 130)];
    consoleTextView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    consoleTextView.textColor = [UIColor greenColor];
    consoleTextView.font = [UIFont fontWithName:@"Courier" size:12];
    consoleTextView.editable = NO;
    consoleTextView.text = @"> Waiting for command...";
    [antibandPanelView addSubview:consoleTextView];
    
    UIButton *abToggleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    abToggleBtn.frame = CGRectMake(100, 190, 200, 35);
    [abToggleBtn setTitle:@"BẬT BẢO VỆ" forState:UIControlStateNormal];
    abToggleBtn.backgroundColor = [UIColor darkGrayColor];
    [abToggleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    abToggleBtn.layer.cornerRadius = 8;
    [abToggleBtn addTarget:self action:@selector(toggleAntiban:) forControlEvents:UIControlEventTouchUpInside];
    [antibandPanelView addSubview:abToggleBtn];
    
    UIButton *closeAbBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeAbBtn.frame = CGRectMake(350, 10, 30, 30);
    [closeAbBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeAbBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeAbBtn addTarget:self action:@selector(hideAntibanPanel) forControlEvents:UIControlEventTouchUpInside];
    [antibandPanelView addSubview:closeAbBtn];

    // GỌI HÀM LẤY CONFIG TỪ WEB
    [self fetchConfigFromWeb];
}

// HÀM KẾT NỐI WEB VÀ CẬP NHẬT NÚT GẠT
- (void)fetchConfigFromWeb {
    NSString *urlString = @"https://menu-wcuk.onrender.com/api/get_config?secret=OP_SECRET_KEY_123";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) {
                statusLabel.text = @"Trạng thái Web: Lỗi kết nối!";
                statusLabel.textColor = [UIColor redColor];
                return;
            }
            
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (json && !jsonError) {
                statusLabel.text = @"Trạng thái Web: Đã kết nối (Live)";
                statusLabel.textColor = [UIColor greenColor];
                
                // Lấy dữ liệu
                BOOL webAimbot = [json[@"aimbot"] boolValue];
                BOOL webEsp = [json[@"esp"] boolValue];
                float webFov = [json[@"fov"] floatValue];
                
                // Cập nhật trạng thái các nút gạt (UISwitch)
                [aimbotSwitch setOn:webAimbot animated:YES];
                [espSwitch setOn:webEsp animated:YES];
                fovSliderRef.value = webFov;
                
                // Cập nhật biến toàn cục
                isAimbotEnabled = webAimbot;
                isEspEnabled = webEsp;
                currentFOV = webFov;
                
            } else {
                statusLabel.text = @"Trạng thái Web: Dữ liệu sai!";
                statusLabel.textColor = [UIColor redColor];
            }
        });
    }];
    [task resume];
}

// Hàm tạo hàng gạt (trả về UISwitch để lưu tham chiếu)
- (UISwitch *)createRowWithTitle:(NSString *)title tag:(int)tag yPos:(int)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 300, 30)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16];
    [globalPanelView addSubview:label];
    
    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(530, y, 50, 30)];
    toggle.tag = tag;
    toggle.onTintColor = [UIColor cyanColor];
    [toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [globalPanelView addSubview:toggle];
    return toggle;
}

// Hàm tạo thanh trượt FOV
- (UISlider *)createSliderWithTitle:(NSString *)title tag:(int)tag yPos:(int)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 300, 30)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16];
    [globalPanelView addSubview:label];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(350, y+5, 220, 20)];
    slider.minimumValue = 10;
    slider.maximumValue = 180;
    slider.value = 90;
    slider.tag = tag;
    slider.tintColor = [UIColor cyanColor];
    [slider addTarget:self action:@selector(fovChanged:) forControlEvents:UIControlEventValueChanged];
    [globalPanelView addSubview:slider];
    return slider;
}

// Các hàm còn lại giữ nguyên
- (void)openFacebook { [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/share/1HwAsXZxFr/?mibextid=wwXIfr"] options:@{} completionHandler:nil]; }
- (void)openTikTok { [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.tiktok.com/@_luongducquang"] options:@{} completionHandler:nil]; }
- (void)togglePanel { globalPanelView.hidden = !globalPanelView.hidden; infoPanelView.hidden = YES; antibandPanelView.hidden = YES; }
- (void)showInfoPanel { infoPanelView.hidden = NO; antibandPanelView.hidden = YES; }
- (void)hideInfoPanel { infoPanelView.hidden = YES; }
- (void)showAntibanPanel { antibandPanelView.hidden = NO; infoPanelView.hidden = YES; }
- (void)hideAntibanPanel { antibandPanelView.hidden = YES; }

- (void)toggleAntiban:(UIButton *)sender {
    isAntibanEnabled = !isAntibanEnabled;
    if (isAntibanEnabled) {
        [sender setTitle:@"ĐANG BẢO VỆ..." forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor systemGreenColor];
        consoleTextView.text = @"> Khoi tao Antiban...\n";
        [self performSelector:@selector(addLog:) withObject:@"> Bypass TenProtect... OK" afterDelay:1.0];
        [self performSelector:@selector(addLog:) withObject:@"> Hide Dylib Signature... OK" afterDelay:2.0];
        [self performSelector:@selector(addLog:) withObject:@"> Randomize HWID... OK" afterDelay:3.0];
        [self performSelector:@selector(addLog:) withObject:@"> [STATUS] PROTECTED!" afterDelay:4.0];
    } else {
        [sender setTitle:@"BẬT BẢO VỆ" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor darkGrayColor];
        [self addLog:@"> Đã tắt bảo vệ."];
    }
}

- (void)addLog:(NSString *)log {
    consoleTextView.text = [consoleTextView.text stringByAppendingFormat:@"\n%@", log];
    NSRange range = NSMakeRange(consoleTextView.text.length - 1, 1);
    [consoleTextView scrollRangeToVisible:range];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.view];
}

- (void)switchChanged:(UISwitch *)sender {
    if (sender.tag == 1) { isAimbotEnabled = sender.isOn; }
    else if (sender.tag == 2) { isEspEnabled = sender.isOn; }
    else if (sender.tag == 3) { isSpeedEnabled = sender.isOn; }
    else if (sender.tag == 4) { isGodModeEnabled = sender.isOn; }
}
- (void)fovChanged:(UISlider *)sender { currentFOV = sender.value; }
@end

// --- HÀM KHỞI TẠO ---
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
    infoPanelView.hidden = YES;
    antibandPanelView.hidden = YES;
    if (isHidden) { globalLogoBtn.hidden = NO; }
}
@end
