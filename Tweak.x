// Hàm tính số ngày còn lại
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
