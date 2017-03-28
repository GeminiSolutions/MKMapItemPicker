//
//  MKMapItemListViewCell.m
//  MKPlacePicker
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

#import "MKMapItemListViewCell.h"

@implementation MKMapItemListViewCell

+ (NSString*)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: MKMapItemListViewCell.reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryType = UITableViewCellAccessoryDetailButton;
        self.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    return self;
}

@end
