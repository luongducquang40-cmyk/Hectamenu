#import <UIKit/UIKit.h>

static UIWindow *splashWindow = nil;

// --- HÀM TÍNH SỐ NGÀY CÒN LẠI ---
NSString* formatExpiryDate(NSString *expiryStr) {
    if (!expiryStr || expiryStr.length == 0) return @"Vĩnh viễn";
    
    NSDate *expiryDate = nil;
    
    // Nếu KeyAuth trả về timestamp (số)
    if ([expiryStr doubleValue] > 0) {
        NSTimeInterval timestamp = [expiryStr doubleValue];
        expiryDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    } 
    // Nếu KeyAuth trả về chuỗi ISO (2026-11-22T...)
    else {
        NSISO8601DateFormatter *isoFormatter = [[NSISO8601DateFormatter alloc] init];
        expiryDate = [isoFormatter dateFromString:expiryStr];
    }
    
    // Tính số ngày còn lại
    if (expiryDate) {
        NSTimeInterval timeInterval = [expiryDate timeIntervalSinceNow];
        int daysLeft = (int)(timeInterval / (60 * 60 * 24));
        
        if (daysLeft <= 0) {
            return @"Đã hết hạn";
        } else {
            return [NSString stringWithFormat:@"Còn %d ngày", daysLeft];
        }
    }
    
    return @"Không xác định"; 
}

// --- GIAO DIỆN NHẬP KEY ---
@interface LoginView : UIView
@property (nonatomic, strong) UITextField *keyField;
@property (nonatomic, strong) UILabel *statusLabel;
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
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [confirmBtn setTitle:@"XÁC NHẬN" forState:UIControlStateNormal];
        confirmBtn.backgroundColor = [UIColor cyanColor];
        [confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        confirmBtn.layer.cornerRadius = 8;
        confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [confirmBtn addTarget:self action:@selector(checkKey) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmBtn];
        
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
            [confirmBtn.topAnchor constraintEqualToAnchor:self.keyField.bottomAnchor constant:20],
            [confirmBtn.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [confirmBtn.widthAnchor constraintEqualToConstant:200],
            [confirmBtn.heightAnchor constraintEqualToConstant:40],
            [self.statusLabel.topAnchor constraintEqualToAnchor:confirmBtn.bottomAnchor constant:15],
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
                    
                    [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"GrockSavedKey"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    // Lấy ngày hết hạn
                    NSString *expiryRaw = @"Vĩnh viễn";
                    NSArray *subs = json[@"info"][@"subscriptions"];
                    if (subs && subs.count > 0) {
                        expiryRaw = subs[0][@"expiry"];
                    } else if (json[@"info"][@"expires"]) {
                        expiryRaw = json[@"info"][@"expires"];
                    }
                    
                    // Format lại thành số ngày
                    NSString *formattedExpiry = formatExpiryDate(expiryRaw);
                    
                    [self showSuccessViewWithExpiry:formattedExpiry];
                    
                } else {
                    self.statusLabel.text = @"Key không hợp lệ!";
                }
            });
        }];
        [checkTask resume];
    }];
    [initTask resume];
}

- (void)showSuccessViewWithExpiry:(NSString *)expiry {
    [self removeFromSuperview];
    
    UIViewController *rootVC = splashWindow.rootViewController;
    
    UIView *successView = [[UIView alloc] init];
    successView.backgroundColor = [UIColor colorWithRed:0.1 green:0.3 blue:0.1 alpha:0.95];
    successView.layer.cornerRadius = 15;
    successView.layer.borderWidth = 2;
    successView.layer.borderColor = [UIColor greenColor].CGColor;
    successView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.text = [NSString stringWithFormat:@"THÀNH CÔNG!\nThời hạn: %@", expiry];
    lbl.textColor = [UIColor whiteColor];
    lbl.numberOfLines = 2;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    [successView addSubview:lbl];
    
    [NSLayoutConstraint activateConstraints:@[
        [lbl.centerXAnchor constraintEqualToAnchor:successView.centerXAnchor],
        [lbl.centerYAnchor constraintEqualToAnchor:successView.centerYAnchor],
        [lbl.leadingAnchor constraintEqualToAnchor:successView.leadingAnchor constant:20],
        [lbl.trailingAnchor constraintEqualToAnchor:successView.trailingAnchor constant:-20]
    ]];
    
    [rootVC.view addSubview:successView];
    [NSLayoutConstraint activateConstraints:@[
        [successView.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor],
        [successView.centerYAnchor constraintEqualToAnchor:rootVC.view.centerYAnchor],
        [successView.widthAnchor constraintEqualToConstant:350],
        [successView.heightAnchor constraintEqualToConstant:100]
    ]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        splashWindow.hidden = YES;
        splashWindow = nil;
    });
}
@end

// --- HÀM KIỂM TRA KEY TỰ ĐỘNG ---
static void autoCheckSavedKey(UIViewController *rootVC) {
    NSString *savedKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"GrockSavedKey"];
    if (!savedKey || savedKey.length == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            LoginView *loginView = [[LoginView alloc] initWithFrame:CGRectZero];
            loginView.translatesAutoresizingMaskIntoConstraints = NO;
            [rootVC.view addSubview:loginView];
            [NSLayoutConstraint activateConstraints:@[
                [loginView.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor],
                [loginView.centerYAnchor constraintEqualToAnchor:rootVC.view.centerYAnchor],
                [loginView.widthAnchor constraintEqualToConstant:450],
                [loginView.heightAnchor constraintEqualToConstant:230]
            ]];
            [loginView.keyField becomeFirstResponder];
        });
        return;
    }
    
    NSString *ownerId = @"RqTkTCmBWe";
    NSString *appName = @"Grocklq";
    NSString *appVersion = @"1.0";
    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *initUrl = [NSString stringWithFormat:@"https://keyauth.win/api/1.3/?type=init&name=%@&ownerid=%@&ver=%@", appName, ownerId, appVersion];
    
    NSURLSessionDataTask *initTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:initUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) return;
        NSDictionary *initJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!initJson || ![initJson[@"success"] boolValue]) return;
        
        NSString *sessionId = initJson[@"sessionid"];
        NSString *checkUrl = [NSString stringWithFormat:@"https://keyauth.win/api/1.3/?type=license&key=%@&hwid=%@&sessionid=%@&name=%@&ownerid=%@&ver=%@", savedKey, hwid, sessionId, appName, ownerId, appVersion];
        
        NSURLSessionDataTask *checkTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:checkUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error && data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if (json && [json[@"success"] boolValue]) {
                        splashWindow.hidden = YES;
                        splashWindow = nil;
                        return;
                    }
                }
                LoginView *loginView = [[LoginView alloc] initWithFrame:CGRectZero];
                loginView.translatesAutoresizingMaskIntoConstraints = NO;
                [rootVC.view addSubview:loginView];
                [NSLayoutConstraint activateConstraints:@[
                    [loginView.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor],
                    [loginView.centerYAnchor constraintEqualToAnchor:rootVC.view.centerYAnchor],
                    [loginView.widthAnchor constraintEqualToConstant:450],
                    [loginView.heightAnchor constraintEqualToConstant:230]
                ]];
                [loginView.keyField becomeFirstResponder];
            });
        }];
        [checkTask resume];
    }];
    [initTask resume];
}

// --- HÀM KHỞI TẠO ---
__attribute__((constructor))
static void showGrockSplash() {
    dispatch_async(dispatch_get_main_queue(), ^{
        splashWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        splashWindow.windowLevel = UIWindowLevelAlert + 1; 
        splashWindow.backgroundColor = [UIColor blackColor];
        
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor blackColor];
        rootVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        splashWindow.rootViewController = rootVC;
        splashWindow.hidden = NO;
        
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [rootVC.view addSubview:imageView];
        
        [NSLayoutConstraint activateConstraints:@[
            [imageView.topAnchor constraintEqualToAnchor:rootVC.view.topAnchor],
            [imageView.bottomAnchor constraintEqualToAnchor:rootVC.view.bottomAnchor],
            [imageView.leadingAnchor constraintEqualToAnchor:rootVC.view.leadingAnchor],
            [imageView.trailingAnchor constraintEqualToAnchor:rootVC.view.trailingAnchor]
        ]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageURL = @"https://i.ibb.co/Xx443mVt/image.png"; 
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            if (imageData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = [UIImage imageWithData:imageData];
                });
            }
        });
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:rootVC action:@selector(dismissKeyboard)];
        [rootVC.view addGestureRecognizer:tap];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            autoCheckSavedKey(rootVC);
        });
    });
}

@interface UIViewController (Dismiss)
- (void)dismissKeyboard;
@end

@implementation UIViewController (Dismiss)
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}
@end
