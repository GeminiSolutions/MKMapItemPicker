//
//  MKMapItemPickerViewController.m
//  MKPlacePicker
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

#import "MKMapItemPickerViewController.h"
#import "MKMapItemListViewController.h"

@interface MKMapItemPickerViewController () <UISearchBarDelegate, MKMapViewDelegate, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate, MKMapItemListViewControllerDelegate>
{
    CLLocationManager* locationManager;
    MKLocalSearch* localSearch;
    MKLocalSearchCompleter* localSearchCompleter;
    MKMapView* _mapView;
    UIPanGestureRecognizer*  panGesture;
    NSLayoutConstraint* tableTopConstraint;
    UISearchBar* _searchBar;
    UIView* dimmingView;
    UIVisualEffectView* contentView;
    MKMapItemListViewController* itemList;
    NSMutableArray<MKMapItem*>* mapItems;
}
@end

@implementation MKMapItemPickerViewController
@synthesize delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [localSearch cancel];
}

- (void)setup {
    locationManager = [[CLLocationManager alloc] init];
    localSearchCompleter = [[MKLocalSearchCompleter alloc] init];
    _mapView = [[MKMapView alloc] init];
    panGesture = [[UIPanGestureRecognizer alloc] init];
    tableTopConstraint = [[NSLayoutConstraint alloc] init];
    _searchBar = [[UISearchBar alloc] init];
    dimmingView = [[UIView alloc] init];
    contentView = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight]];
    itemList = [[MKMapItemListViewController alloc] initWithStyle: UITableViewStyleGrouped];
    mapItems = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Search
    localSearchCompleter.delegate = self;

    // Location
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = 50;
    [locationManager requestLocation];

    // UI
    dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.5];

    itemList.delegate = self;
    itemList.tableView.backgroundColor = [UIColor clearColor];
    [self addChildViewController:itemList];

    [panGesture addTarget:self action:@selector(panGestureAction)];

    [contentView addGestureRecognizer:panGesture];
    contentView.layer.cornerRadius = 20;
    contentView.clipsToBounds = YES;

    UIView* knob = [[UIView alloc] initWithFrame: CGRectZero];
    knob.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.15];
    knob.layer.cornerRadius = 2;
    [contentView addSubview: knob];

    [_searchBar setBackgroundImage: [[UIImage alloc] init] forBarPosition: UIBarPositionAny barMetrics: UIBarMetricsDefault];
    _searchBar.placeholder = NSLocalizedString(@"Search for a place or address", comment: @"Search for a place or address");
    _searchBar.delegate = self;

    [self.view addSubview: _mapView];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self.view insertSubview:dimmingView belowSubview:_mapView];
    dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:dimmingView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:dimmingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:dimmingView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:dimmingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];

    [self.view addSubview:contentView];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    tableTopConstraint = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.view addConstraint: tableTopConstraint];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:contentView.layer.cornerRadius]];
    //tableView.translatesAutoresizingMaskIntoConstraints = false
    
    knob.translatesAutoresizingMaskIntoConstraints = NO;
    [knob addConstraint:[NSLayoutConstraint constraintWithItem:knob attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    [knob addConstraint:[NSLayoutConstraint constraintWithItem:knob attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:4]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:knob attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:4]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:knob attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [contentView addSubview: _searchBar];
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchBar sizeToFit];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_searchBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:knob attribute:NSLayoutAttributeBottom multiplier:1 constant:4]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:_searchBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [contentView addSubview: itemList.tableView];
    itemList.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:itemList.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:itemList.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_searchBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:itemList.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:itemList.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self setEditing:NO animated: NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    editing ? [_searchBar becomeFirstResponder] : [_searchBar resignFirstResponder];
    itemList.tableView.scrollEnabled = editing;
    _searchBar.showsCancelButton = editing;
    [UIView setAnimationsEnabled: animated];
    tableTopConstraint.constant = (editing ? 30 : self.view.bounds.size.height * 2 / 3);
    [self.view setNeedsUpdateConstraints];
    panGesture.enabled = !editing;
    [UIView animateWithDuration:0.15 animations:^{
        editing ? [self.view insertSubview: dimmingView aboveSubview: _mapView] : [self.view sendSubviewToBack: dimmingView];
        [self.view layoutIfNeeded];
    }];
}

- (void)reloadWith:(NSArray<MKMapItem*>*)items {
    NSMutableArray* annotations = [NSMutableArray array];
    for (MKMapItem* item in items) {
        [annotations addObject: item.placemark];
    }
    
    [itemList reloadWith: items];
    [_mapView removeAnnotations: _mapView.annotations];
    [_mapView addAnnotations: annotations];
    itemList.headerMessage = nil;
}

- (void)search:(MKLocalSearchCompletion*)completion {
    MKLocalSearchRequest* searchRequest = [[MKLocalSearchRequest alloc] initWithCompletion:completion];
    searchRequest.region = _mapView.region;
    MKLocalSearch* search = [[MKLocalSearch alloc] initWithRequest: searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil && response != nil) {
            [mapItems addObjectsFromArray: response.mapItems];
            [self reloadWith: mapItems];
        }
    }];
    localSearch = search;
}

- (BOOL)regionDidChangeFromUserInteraction:(MKMapView*)mapView {
    if (mapView.subviews.count == 0)
        return NO;
    
    for (UIGestureRecognizer* gr in mapView.subviews.firstObject.gestureRecognizers) {
        if (gr.state == UIGestureRecognizerStateBegan || gr.state == UIGestureRecognizerStateEnded)
            return YES;
    }
    
    return NO;
}

#pragma marg - Pan gesture

- (void)panGestureAction {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        contentView.tag = tableTopConstraint.constant;
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        tableTopConstraint.constant = (CGFloat)contentView.tag + [panGesture translationInView: panGesture.view].y;
    }
    else {
        if (tableTopConstraint.constant >= (self.view.bounds.size.height - 2 * _searchBar.bounds.size.height)) {
            tableTopConstraint.constant = (self.view.bounds.size.height - 1.5 * _searchBar.bounds.size.height);
        }
        else if (tableTopConstraint.constant <= (self.view.bounds.size.height / 3)) {
            [self setEditing:YES animated: YES];
        }
        else {
            [self setEditing: NO animated: YES];
        }
    }
}

#pragma mark - Search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self setEditing: YES animated: YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setEditing: NO animated: YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self setEditing: NO animated: YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.text = nil;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    localSearchCompleter.queryFragment = searchBar.text;
    itemList.headerMessage = [NSLocalizedString(@"Loading", comment: @"Loading") stringByAppendingString: @"..."];
    return YES;
}

#pragma mark - Map view delegate

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    MKAnnotationView* pin = [mapView dequeueReusableAnnotationViewWithIdentifier: @""];
    if (pin) {
        pin.annotation = annotation;
    }
    else {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @""];
        pin.canShowCallout = true;
    }

    return pin;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    if ([self regionDidChangeFromUserInteraction: mapView]) {
        itemList.tableView.delegate = nil;
        [UIView animateWithDuration:0.2 animations:^{}];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if ([self regionDidChangeFromUserInteraction: mapView]) {
        localSearchCompleter.region = mapView.region;
        _mapView.delegate = nil;
        [UIView animateWithDuration:0.2 animations:^{}];
    }
}

#pragma mark - Local search completer delegate

- (void)completerDidUpdateResults:(MKLocalSearchCompleter *)completer {
    if (localSearchCompleter.results.count == 0) {
        [itemList reloadWith: [NSArray array]];
        return;
    }

    [mapItems removeAllObjects];
    [itemList reloadWith:mapItems];
    for (MKLocalSearchCompletion* completion in localSearchCompleter.results)
        [self search: completion];
}

- (void)completer:(MKLocalSearchCompleter *)completer didFailWithError:(NSError *)error {
    //
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0)
        [_mapView setCamera:[MKMapCamera cameraLookingAtCenterCoordinate: locations[0].coordinate fromDistance: 1000 pitch: 0 heading: 0]];
    _mapView.showsCompass = YES;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    _mapView.showsCompass = YES;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
}

#pragma mark - Item list view controller delegate

- (void)controller:(MKMapItemListViewController*)controller didSelect:(MKMapItem*)item {
    [self setEditing:NO animated:YES];
    _mapView.camera.altitude = 1000;
    _mapView.camera.centerCoordinate = item.placemark.coordinate;
    if (self.delegate)
        [self.delegate controller:self didSelect:item];
}

- (void)controller:(MKMapItemListViewController *)controller didSelectAccessoryButtonFor:(MKMapItem *)item {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Open in Maps", comment: @"Open in Maps") message: nil preferredStyle: UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle: NSLocalizedString(@"Open", comment: @"Open") style: UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
        [item openInMapsWithLaunchOptions:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", comment: @"Cancel") style: UIAlertActionStyleCancel handler: nil]];
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)controller:(MKMapItemListViewController *)controller didChangeContentOffset:(CGPoint)offset {
    tableTopConstraint.constant -= offset.y;
}

- (void)controller:(MKMapItemListViewController *)controller didEndDragging:(BOOL)willDecelerate {
    [self panGestureAction];
}

@end
