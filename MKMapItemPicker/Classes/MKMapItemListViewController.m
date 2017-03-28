//
//  MKMapItemListViewController.m
//  MKPlacePicker
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

#import "MKMapItemListViewController.h"
#import "MKMapItemListViewCell.h"

@interface MKMapItemListViewController ()
{
    UILabel* headerLabel;
    NSArray<MKMapItem*>* mapItems;
}
@end

@implementation MKMapItemListViewController
@synthesize delegate;

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle: style];
    if (self) {
        headerLabel = [[UILabel alloc] init];
        mapItems = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass: MKMapItemListViewCell.class forCellReuseIdentifier: MKMapItemListViewCell.reuseIdentifier];
    self.tableView.rowHeight = 60;
    headerLabel.textColor = UIColor.darkGrayColor;
    headerLabel.font = [UIFont boldSystemFontOfSize:10];
    headerLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)reloadWith:(NSArray<MKMapItem*>*)items {
    mapItems = items;
    [self.tableView reloadData];
}

- (NSString*)headerMessage {
    return headerLabel.text;
}

- (void)setHeaderMessage:(NSString*)message {
    headerLabel.text = message;
    [headerLabel sizeToFit];
    self.tableView.tableHeaderView = (message == nil ? nil : headerLabel);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mapItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMapItemListViewCell* cell = (MKMapItemListViewCell*)[self.tableView dequeueReusableCellWithIdentifier: MKMapItemListViewCell.reuseIdentifier forIndexPath: indexPath];
    
    MKMapItem* item = mapItems[indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.phoneNumber;
    if (item.isCurrentLocation) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize: cell.textLabel.font.pointSize];
        cell.textLabel.textColor = UIColor.blueColor;
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize: cell.textLabel.font.pointSize];
        cell.textLabel.textColor = UIColor.blackColor;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath: indexPath animated:YES];
    if (self.delegate)
        [self.delegate controller: self didSelect: mapItems[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate)
        [self.delegate controller: self didSelectAccessoryButtonFor: mapItems[indexPath.row]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0 && scrollView.isDragging && scrollView.isTracking) {
        if (self.delegate)
            [self.delegate controller: self didChangeContentOffset: scrollView.contentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.isTracking) {
        if (self.delegate)
            [self.delegate controller: self didEndDragging: decelerate];
    }
}

@end
