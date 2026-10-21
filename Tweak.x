#import <UIKit/UIKit.h>
#pragma clang diagnostic ignored "-Wunused-variable"

static BOOL isAimbotEnabled = NO;
static BOOL isEspEnabled = NO;
static float currentFOV = 90.0;
static UIImageView *globalLogoBtn = nil;
static UIView *globalPanelView = nil;
static UILabel *statusLabel = nil;

@interface MenuViewController : UIViewController
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // TẠO LOGO
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
    
    // TẠO BẢNG MENU
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
    title.text = @"GROCK PANEL";
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
    
    UISwitch *aimbotSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(530, 80, 50, 30)];
    [aimbotSwitch addTarget:self action:@selector(toggleAimbot:) forControlEvents:UIControlEventValueChanged];
    [globalPanelView addSubview:aimbotSwitch];
    [globalPanelView addSubview:[self createLabel:@"Aimbot" y:80]];
    
    UISwitch *espSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(530, 130, 50, 30)];
    [globalPanelView addSubview:espSwitch];
    [globalPanelView addSubview:[self createLabel:@"ESP" y:130]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self fetchConfigFromWeb];
    });
}

- (UILabel *)createLabel:(NSString *)text y:(int)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 300, 30)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16];
    return label;
}

- (void)toggleAimbot:(UISwitch *)sender { isAimbotEnabled = sender.isOn; }

- (void)fetchConfigFromWeb {
    NSURL *url = [NSURL URLWithString:@"https://menu-wcuk.onrender.com/api/get_config?secret=OP_SECRET_KEY_123"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && data) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (json) {
                    statusLabel.text = @"Trạng thái Web: Đã kết nối (Live)";
                    statusLabel.textColor = [UIColor greenColor];
                }
            }
        });
    }];
    [task resume];
}

- (void)togglePanel { globalPanelView.hidden = !globalPanelView.hidden; }
- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.view];
}
@end

// --- HÀM KHỞI TẠO (ĐÃ SỬA LỖI KEYWINDOW) ---
__attribute__((constructor))
static void setupMenu() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        // LẤY WINDOW CHUẨN CHO iOS 17+
        UIWindow *window = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
        }
        
        if (!window) return;

        MenuViewController *vc = [[MenuViewController alloc] init];
        vc.view.frame = window.bounds;
        vc.view.userInteractionEnabled = YES; 
        
        [window addSubview:vc.view];
    });
}
