#import <UIKit/UIKit.h>

// Hàm này tự động chạy khi Dylib được nạp vào game
__attribute__((constructor))
static void setupMenu() {
    // Đợi 3 giây để game load xong hoàn toàn trước khi hiện menu
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        // Tạo một cửa sổ riêng để hiển thị nút
        UIWindow *window = [[UIApplication sharedApplication] windows].firstObject;
        if (!window) return;

        // Tạo nút bấm
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 100, 80, 40);
        btn.backgroundColor = [UIColor redColor];
        btn.layer.cornerRadius = 8.0;
        btn.layer.borderWidth = 2.0;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        [btn setTitle:@"MENU ON" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        [window addSubview:btn];
        
        // Ghi log để kiểm tra (nếu game không văng)
        NSLog(@"[MyMenu] Menu đã load thành công!");
    });
}
