#import <UIKit/UIKit.h>

static BOOL isAimbotEnabled = NO;
static BOOL isEspEnabled = NO;
static UIWindow *menuWindow = nil;

// --- GIAO DIỆN MENU ---
@interface MenuViewController : UIViewController
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) UIButton *toggleBtn;
@end

@implementation MenuViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // 1. Tạo nút "M" để bật/tắt bảng Menu
    self.toggleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleBtn.frame = CGRectMake(20, 100, 60, 60);
    self.toggleBtn.backgroundColor = [UIColor redColor];
    self.toggleBtn.layer.cornerRadius = 30;
    [self.toggleBtn setTitle:@"M" forState:UIControlStateNormal];
    [self.toggleBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggleBtn];
    
    // 2. Tạo bảng Menu (Ẩn ban đầu)
    self.panelView = [[UIView alloc] initWithFrame:CGRectMake(90, 100, 250, 180)];
    self.panelView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.9];
    self.panelView.layer.cornerRadius = 15;
    self.panelView.layer.borderWidth = 2;
    self.panelView.layer.borderColor = [UIColor redColor].CGColor;
    self.panelView.hidden = YES;
    [self.view addSubview:self.panelView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 250, 30)];
    title.text = @"GROCK PANEL";
    title.textColor = [UIColor redColor];
    title.font = [UIFont boldSystemFontOfSize:20];
    title.textAlignment = NSTextAlignmentCenter;
    [self.panelView addSubview:title];
    
    UIButton *aimbotBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    aimbotBtn.frame = CGRectMake(20, 60, 210, 40);
    [aimbotBtn setTitle:@"Aimbot: OFF" forState:UIControlStateNormal];
    aimbotBtn.backgroundColor = [UIColor darkGrayColor];
    aimbotBtn.layer.cornerRadius = 8;
    aimbotBtn.tag = 1;
    [aimbotBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [self.panelView addSubview:aimbotBtn];
    
    UIButton *espBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    espBtn.frame = CGRectMake(20, 110, 210, 40);
    [espBtn setTitle:@"ESP: OFF" forState:UIControlStateNormal];
    espBtn.backgroundColor = [UIColor darkGrayColor];
    espBtn.layer.cornerRadius = 8;
    espBtn.tag = 2;
    [espBtn addTarget:self action:@selector(toggleBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [self.panelView addSubview:espBtn];
}

- (void)togglePanel {
    self.panelView.hidden = !self.panelView.hidden;
}

- (void)toggleBtnState:(UIButton *)sender {
    if (sender.tag == 1) {
        isAimbotEnabled = !isAimbotEnabled;
        [sender setTitle:isAimbotEnabled ? @"Aimbot: ON" : @"Aimbot: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = isAimbotEnabled ? [UIColor systemGreenColor] : [UIColor darkGrayColor];
    } else {
        isEspEnabled = !isEspEnabled;
        [sender setTitle:isEspEnabled ? @"ESP: ON" : @"ESP: OFF" forState:UIControlStateNormal];
        sender.backgroundColor = isEspEnabled ? [UIColor systemBlueColor] : [UIColor darkGrayColor];
    }
}
@end

// --- HÀM KHỞI TẠO ---
__attribute__((constructor))
static void setupMenu() {
    // Đợi 5 giây để game load xong
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        menuWindow.windowLevel = UIWindowLevelAlert + 1;
        menuWindow.backgroundColor = [UIColor clearColor];
        menuWindow.rootViewController = [[MenuViewController alloc] init];
        menuWindow.hidden = NO;
    });
}
