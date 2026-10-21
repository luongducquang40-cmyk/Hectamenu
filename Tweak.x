#import <UIKit/UIKit.h>

// --- 1. HIỂN THỊ ẢNH CHÀO CỦA OP (ĐÈ LÊN ẢNH CỦA DEV) ---
__attribute__((constructor))
static void showGrockSplash() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIApplication sharedApplication] windows].firstObject;
        if (!window) return;
        
        // Tạo cửa sổ đè lên trên cùng
        UIWindow *splashWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        splashWindow.windowLevel = UIWindowLevelAlert + 1; 
        splashWindow.backgroundColor = [UIColor blackColor];
        
        // Ảnh của Op
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:splashWindow.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        // Link ảnh Đức Quang của Op
        NSString *imageURL = @"https://i.ibb.co/Xx443mVt/image.png"; 
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        if (imageData) {
            imageView.image = [UIImage imageWithData:imageData];
        }
        
        [splashWindow addSubview:imageView];
        splashWindow.hidden = NO;
        splashWindow.rootViewController = [[UIViewController alloc] init];
        
        // Sau 3 giây, đóng ảnh chào và hiện bảng nhập Key
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            splashWindow.hidden = YES;
            
            // Hiện bảng nhập Key
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
                        // Bắt lỗi nếu Web chết
                        if (error || !data) {
                            exit(0); // Văng game
                        }
                        
                        NSError *jsonError;
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                        
                        if (json && !jsonError) {
                            if ([json[@"status"] boolValue]) {
                                // Key ĐÚNG -> Cho phép chơi
                            } else {
                                // Key SAI -> Văng game
                                exit(0); 
                            }
                        } else {
                            exit(0);
                        }
                    });
                }];
                [task resume];
            }]];
            
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        });
    });
}
