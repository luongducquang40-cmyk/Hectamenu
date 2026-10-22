#import <UIKit/UIKit.h>

static UIWindow *splashWindow = nil;

// --- GIAO DIỆN NHẬP KEY ---
@interface LoginView : UIView
@property (nonatomic, strong) UITextField *keyField;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *confirmBtn;
@end

@implementation LoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.95];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor cyanColor].CGColor;
        
        UILabel *title = [[UILabel alloc] init];
        title.text = @"GROCK PANEL";
        title.textColor = [UIColor cyanColor];
        title.font = [UIFont boldSystemFontOfSize:24];
        title.textAlignment = NSTextAlignmentCenter;
        title.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:title];
        
        self.keyField = [[UITextField alloc] init];
        self.keyField.backgroundColor = [UIColor whiteColor];
        self.keyField.layer.cornerRadius = 8;
        self.keyField.placeholder = @"Nhập Key...";
        self.keyField.textAlignment = NSTextAlignmentCenter;
        self.keyField.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.keyField];
        
        self.confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.confirmBtn setTitle:@"XÁC NHẬN" forState:UIControlStateNormal];
        self.confirmBtn.backgroundColor = [UIColor cyanColor];
        [self.confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.confirmBtn.layer.cornerRadius = 8;
        self.confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.confirmBtn addTarget:self action:@selector(checkKey) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.confirmBtn];
        
        self.statusLabel = [[UILabel alloc] init];
        self.statusLabel.textColor = [UIColor yellowColor];
        self.statusLabel.font = [UIFont systemFontOfSize:12];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.statusLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [title.topAnchor constraintEqualToAnchor:self.topAnchor constant:20],
            [title.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            
            [self.keyField.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:20],
            [self.keyField.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:30],
            [self.keyField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-30],
            [self.keyField.heightAnchor constraintEqualToConstant:40],
            
            [self.confirmBtn.topAnchor constraintEqualToAnchor:self.keyField.bottomAnchor constant:20],
            [self.confirmBtn.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [self.confirmBtn.widthAnchor constraintEqualToConstant:200],
            [self.confirmBtn.heightAnchor constraintEqualToConstant:40],
            
            [self.statusLabel.topAnchor constraintEqualToAnchor:self.confirmBtn.bottomAnchor constant:15],
            [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]
        ]];
    }
    return self;
}

- (void)checkKey {
    [self.keyField resignFirstResponder];
    NSString *key = self.keyField.text;
    if (key.length == 0) return;
    
    self.statusLabel.text = @"Đang kiểm tra...";
    
    NSString *ownerId = @"RqTkTCmBWe";
    NSString *appName = @"Grocklq";
    NSString *appVersion = @"1.0";
    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *initUrl = [NSString stringWithFormat:@"https://keyauth.win/api/1.3/?type=init&name=%@&ownerid=%@&ver=%@", appName, ownerId, appVersion];
    
    NSURLSessionDataTask *initTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:initUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            dispatch_async(dispatch_get_main_queue(), ^{ self.statusLabel.text = @"Lỗi kết nối!"; });
            return;
        }
        
        NSDictionary *initJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!initJson || ![initJson[@"success"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{ self.statusLabel.text = @"Lỗi khởi tạo session!"; });
            return;
        }
        
        NSString *sessionId = initJson[@"sessionid"];
        NSString *checkUrl = [NSString stringWithFormat:@"https://keyauth.win/api/1.3/?type=license&key=%@&hwid=%@&sessionid=%@&name=%@&ownerid=%@&ver=%@", key, hwid, sessionId, appName, ownerId, appVersion];
        
        NSURLSessionDataTask *checkTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:checkUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error || !data) {
                    self.statusLabel.text = @"Lỗi kết nối!";
                    return;
                }
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (json && [json[@"success"] boolValue]) {
                    splashWindow.hidden = YES;
                    splashWindow = nil;
                } else {
                    self.statusLabel.text = @"Key không hợp lệ!";
                }
            });
        }];
        [checkTask resume];
    }];
    [initTask resume];
}
@end

// --- HÀM KHỞI TẠO ---
__attribute__((constructor))
static void showGrockSplash() {
    dispatch_async(dispatch_get_main_queue(), ^{
        splashWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        splashWindow.windowLevel = UIWindowLevelAlert + 1; 
        splashWindow.backgroundColor = [UIColor blackColor];
        
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor blackColor];
        splashWindow.rootViewController = rootVC;
        splashWindow.hidden = NO;
        
        // Ép xoay ngang
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        
        // 1. ẢNH NỀN (Ghim cố định, không bị đẩy lên khi bàn phím hiện)
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSString *imageURL = @"https://i.ibb.co/Xx443mVt/image.png"; 
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        if (imageData) { imageView.image = [UIImage imageWithData:imageData]; }
        [rootVC.view addSubview:imageView];
        
        // Ghim ảnh nền chết ở 4 góc màn hình
        [NSLayoutConstraint activateConstraints:@[
            [imageView.topAnchor constraintEqualToAnchor:rootVC.view.topAnchor],
            [imageView.bottomAnchor constraintEqualToAnchor:rootVC.view.bottomAnchor],
            [imageView.leadingAnchor constraintEqualToAnchor:rootVC.view.leadingAnchor],
            [imageView.trailingAnchor constraintEqualToAnchor:rootVC.view.trailingAnchor]
        ]];
        
        // Thêm sự kiện chạm vào nền để tắt bàn phím
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:rootVC action:@selector(dismissKeyboard)];
        [rootVC.view addGestureRecognizer:tap];
        
        // 2. BẢNG NHẬP KEY
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            LoginView *loginView = [[LoginView alloc] initWithFrame:CGRectZero];
            loginView.translatesAutoresizingMaskIntoConstraints = NO;
            [rootVC.view addSubview:loginView];
            
            // Căn giữa bảng Key
            [NSLayoutConstraint activateConstraints:@[
                [loginView.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor],
                [loginView.centerYAnchor constraintEqualToAnchor:rootVC.view.centerYAnchor],
                [loginView.widthAnchor constraintEqualToConstant:450],
                [loginView.heightAnchor constraintEqualToConstant:230]
            ]];
            
            // Bật bàn phím
            [loginView.keyField becomeFirstResponder];
        });
    });
}

// Hàm tắt bàn phím
@interface UIViewController (Dismiss)
- (void)dismissKeyboard;
@end

@implementation UIViewController (Dismiss)
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}
@end
