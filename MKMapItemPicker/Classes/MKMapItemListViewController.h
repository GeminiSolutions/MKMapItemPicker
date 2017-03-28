//
//  MKMapItemListViewController.h
//  MKPlacePicker
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MKMapItemListViewController;


@protocol MKMapItemListViewControllerDelegate <NSObject>

- (void)controller:(MKMapItemListViewController*)controller didSelect:(MKMapItem*)item;
- (void)controller:(MKMapItemListViewController*)controller didSelectAccessoryButtonFor:(MKMapItem*)item;
- (void)controller:(MKMapItemListViewController*)controller didEndDragging:(BOOL)willDecelerate;
- (void)controller:(MKMapItemListViewController*)controller didChangeContentOffset:(CGPoint)offset;

@end


@interface MKMapItemListViewController : UITableViewController

@property (weak) id<MKMapItemListViewControllerDelegate> delegate;
@property (readwrite) NSString* headerMessage;

- (void)reloadWith:(NSArray<MKMapItem*>*)items;

@end
