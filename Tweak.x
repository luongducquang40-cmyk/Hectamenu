#import <UIKit/UIKit.h>

// --- BIẾN TOÀN CỤC ---
static UIWindow *menuWindow = nil;
static UIView *globalPanelView = nil;
static UIButton *globalOpenBtn = nil;

// --- GIAO DIỆN MENU ---
@interface MenuViewController : UIViewController
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // 1. NÚT BẬT MENU (Hình tròn nhỏ, nằm ở góc trái)
    globalOpenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    globalOpenBtn.frame = CGRectMake(20, 100, 50, 50);
    globalOpenBtn.backgroundColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0]; // Đỏ
    globalOpenBtn.layer.cornerRadius = 25;
    globalOpenBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    globalOpenBtn.layer.borderWidth = 2.0;
    [globalOpenBtn setTitle:@"M" forState:UIControlStateNormal];
    globalOpenBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [globalOpenBtn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    // Kéo thả nút M
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [globalOpenBtn addGestureRecognizer:panGesture];
    [self.view addSubview:globalOpenBtn];
    
    // 2. BẢNG MENU CHÍNH (Ban đầu ẩn)
    globalPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 350)];
    globalPanelView.center = self.view.center;
    globalPanelView.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.95];
    globalPanelView.layer.cornerRadius = 15;
    globalPanelView.layer.borderWidth = 2.0;
    globalPanelView.layer.borderColor = [UIColor cyanColor].CGColor;
    globalPanelView.hidden = YES;
    [self.view addSubview:globalPanelView];
    
    // Tiêu đề
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
    title.text = @"GROCK PANEL";
    title.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.8 alpha:1.0];
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    [globalPanelView addSubview:title];
    
    // Nút X (Đóng Menu để chơi game)
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(460, 5, 30, 30);
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [globalPanelView addSubview:closeBtn];
    
    // Các hàng chức năng
    [self createRowWithTitle:@"Aimbot" tag:1 yPos:60];
    [self createRowWithTitle:@"ESP" tag:2 yPos:110];
    [self createRowWithTitle:@"Speed Hack" tag:3 yPos:160];
    [self createRowWithTitle:@"God Mode" tag:4 yPos:210];
    
    // Thanh trượt FOV
    UILabel *fovLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, 150, 30)];
    fovLabel.text = @"FOV Slider";
    fovLabel.textColor = [UIColor whiteColor];
    [globalPanelView addSubview:fovLabel];
    
    UISlider *fovSlider = [[UISlider alloc] initWithFrame:CGRectMake(180, 260, 280, 30)];
    fovSlider.minimumValue = 10;
    fovSlider.maximumValue = 180;
    fovSlider.value = 90;
    fovSlider.tintColor = [UIColor cyanColor];
    [globalPanelView addSubview:fovSlider];
}

- (void)createRowWithTitle:(NSString *)title tag:(int)tag yPos:(int)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 300, 30)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16];
    [globalPanelView addSubview:label];
    
    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(430, y, 50, 30)];
    toggle.tag = tag;
    toggle.onTintColor = [UIColor cyanColor];
    [globalPanelView addSubview:toggle];
}

- (void)showMenu {
    globalPanelView.hidden = NO;
    globalOpenBtn.hidden = YES; // Ẩn nút M đi khi Menu hiện
}

- (void)hideMenu {
    globalPanelView.hidden = YES;
    globalOpenBtn.hidden = NO; // Hiện lại nút M để bấm Cập nhật game
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.view];
}
@end

// --- HÀM KHỞI TẠO (GẮN TRỰC TIẾP VÀO GAME WINDOW) ---
__attribute__((constructor))
static void setupMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        // Tìm cửa sổ của game
        UIWindow *gameWindow = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) {
                        gameWindow = w;
                        break;
                    }
                }
            }
        }
        
        if (!gameWindow) return;

        // Gắn Menu vào thẳng Game Window
        MenuViewController *vc = [[MenuViewController alloc] init];
        vc.view.frame = gameWindow.bounds;
        vc.view.backgroundColor = [UIColor clearColor];
        
        [gameWindow addSubview:vc.view];
    });
}
