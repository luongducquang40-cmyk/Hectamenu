#import <UIKit/UIKit.h>

// --- HÀM HIỂN THỊ ẢNH CHÀO VÀ BẢNG NHẬP KEY ---
__attribute__((constructor))
static void showGrockSplash() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *mainWindow = [[UIApplication sharedApplication] windows].firstObject;
        if (!mainWindow) return;
        
        // 1. Tạo cửa sổ đè lên trên cùng
        UIWindow *splashWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        splashWindow.windowLevel = UIWindowLevelAlert + 1; 
        splashWindow.backgroundColor = [UIColor blackColor];
        
        // Tạo một ViewController gốc cho cửa sổ này
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor blackColor];
        splashWindow.rootViewController = rootVC;
        splashWindow.hidden = NO;
        
        // 2. Hiển thị ảnh của Op
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:splashWindow.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        NSString *imageURL = @"https://i.ibb.co/Xx443mVt/image.png"; 
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        if (imageData) {
            imageView.image = [UIImage imageWithData:imageData];
        }
        [rootVC.view addSubview:imageView];
        
        // 3. Sau 3 giây, hiện bảng nhập Key (Gắn trực tiếp vào splashWindow)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"GROCK PANEL" message:@"Vui lòng nhập Key để sử dụng:" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
                tf.placeholder = @"Nhập Key...";
            }];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Xác nhận" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *key = alert.textFields.firstObject.text;
                
                // GỬI KEY LÊN WEB CỦA OP ĐỂ CHECK
                NSString *urlStr = [NSString stringWithFormat:@"https://menu-wcuk.onrender.com/api/check_key?key=%@", key];
                
                NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error || !data) {
                            exit(0); // Văng game nếu không có mạng
                        }
                        
                        NSError *jsonError;
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                        
                        if (json && !jsonError) {
                            if ([json[@"status"] boolValue]) {
                                // KEY ĐÚNG -> Ẩn cửa sổ chứa ảnh và bảng Key đi
                                splashWindow.hidden = YES;
                            } else {
                                // KEY SAI -> Văng game
                                exit(0); 
                            }
                        } else {
                            exit(0);
                        }
                    });
                }];
                [task resume];
            }]];
            
            // Hiển thị bảng nhập Key trên cửa sổ splashWindow
            [rootVC presentViewController:alert animated:YES completion:nil];
        });
    });
}
