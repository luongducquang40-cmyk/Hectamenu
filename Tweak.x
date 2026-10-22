#import <UIKit/UIKit.h>

static UIWindow *splashWindow = nil;

// --- GIAO DIỆN NHẬP KEY (NẰM NGANG) ---
@interface LoginView : UIView
@property (nonatomic, strong) UITextField *keyField;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation LoginView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.9];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor cyanColor].CGColor;
        
        // Tiêu đề
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 30)];
        title.text = @"GROCK PANEL";
        title.textColor = [UIColor cyanColor];
        title.font = [UIFont boldSystemFontOfSize:24];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        // Ô nhập Key
        self.keyField = [[UITextField alloc] initWithFrame:CGRectMake(30, 70, frame.size.width - 60, 40)];
        self.keyField.backgroundColor = [UIColor whiteColor];
        self.keyField.layer.cornerRadius = 8;
        self.keyField.placeholder = @"Nhập Key...";
        self.keyField.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.keyField];
        
        // Nút Xác nhận
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(30, 130, frame.size.width - 60, 40);
        [btn setTitle:@"XÁC NHẬN" forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor cyanColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 8;
        [btn addTarget:self action:@selector(checkKey) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        // Label trạng thái
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, frame.size.width, 20)];
        self.statusLabel.textColor = [UIColor yellowColor];
        self.statusLabel.font = [UIFont systemFontOfSize:12];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.statusLabel];
    }
    return self;
}

- (void)checkKey {
    NSString *key = self.keyField.text;
    if (key.length == 0) return;
    
    self.statusLabel.text = @"Đang kiểm tra...";
    
    // Thông tin KeyAuth của Op
    NSString *ownerId = @"RqTkTCmBWe";
    NSString *appName = @"Grocklq";
    NSString *appVersion = @"1.0";
    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // 1. Khởi tạo Session
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
        
        // 2. Check Key với Session ID
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
        
        // Ảnh của Op
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:splashWindow.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        NSString *imageURL = @"https://i.ibb.co/Xx443mVt/image.png"; 
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        if (imageData) { imageView.image = [UIImage imageWithData:imageData]; }
        [rootVC.view addSubview:imageView];
        
        // Sau 3 giây, hiện bảng nhập Key
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // Kích thước bảng nhập key (Ngang)
            LoginView *loginView = [[LoginView alloc] initWithFrame:CGRectMake(0, 0, 500, 220)];
            loginView.center = rootVC.view.center;
            [rootVC.view addSubview:loginView];
        });
    });
}
