//
//  MKMapItemPickerViewController.h
//  MKPlacePicker
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MKMapItemPickerViewController;


@protocol MKMapItemPickerViewControllerDelegate <NSObject>

- (void)controller:(MKMapItemPickerViewController*)controller didSelect:(MKMapItem*)item;

@end


@interface MKMapItemPickerViewController : UIViewController

@property (weak) id<MKMapItemPickerViewControllerDelegate> delegate;

@end
