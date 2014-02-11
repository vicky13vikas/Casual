//
//  CheckInViewController.m
//  Casual
//
//  Created by Vikas Kumar on 07/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "CheckInViewController.h"
#import <MapKit/MapKit.h>
#import "PlacesLoader.h"
#import "Place.h"
#import "PlaceAnnotation.h"

NSString * const kNameKey = @"name";
NSString * const kReferenceKey = @"reference";
NSString * const kAddressKey = @"vicinity";
NSString * const kLatiudeKeypath = @"geometry.location.lat";
NSString * const kLongitudeKeypath = @"geometry.location.lng";

@interface CheckInViewController ()<CLLocationManagerDelegate, MKAnnotation, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) Place *currentPlace;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (readonly) CLLocationCoordinate2D currentUserCoordinate;
@property (nonatomic, strong) NSArray *locations;

@end

@implementation CheckInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self startUpdatingCurrentLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)startUpdatingCurrentLocation
{
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted )
    {
        return;
    }
    
    // if locationManager does not currently exist, create it
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        _locationManager.distanceFilter = 10.0f; // we don't need to be any more accurate than 10m
        _locationManager.purpose = @"This may be used to obtain your reverse geocoded address";
    }
    
    [_locationManager startUpdatingLocation];
    
    //    [self showCurrentLocationSpinner:YES];
}

- (void)stopUpdatingCurrentLocation
{
    [_locationManager stopUpdatingLocation];
    
    //    [self showCurrentLocationSpinner:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
    {
        return;
    }
    
    _currentUserCoordinate = [newLocation coordinate];
    //    _selectedRow = 1;
    
    // update the current location cells detail label with these coords
    //    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    //    cell.detailTextLabel.text = [NSString stringWithFormat:@"φ:%.4F, λ:%.4F", _currentUserCoordinate.latitude, _currentUserCoordinate.longitude];
    
    // after recieving a location, stop updating
    
    NSLog(@"%@", [NSString stringWithFormat:@"φ:%.4F, λ:%.4F", _currentUserCoordinate.latitude, _currentUserCoordinate.longitude]);
    
    [self performCoordinateGeocode];
    //    [self stopUpdatingCurrentLocation];
    [self loadNearByPlaces];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    // stop updating
    [self stopUpdatingCurrentLocation];
    
    // since we got an error, set selected location to invalid location
    _currentUserCoordinate = kCLLocationCoordinate2DInvalid;
    
    // show the error alert
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error updating location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}


- (void)performCoordinateGeocode
{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocationCoordinate2D coord = _currentUserCoordinate;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
//    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord altitude:1000 horizontalAccuracy:kCLLocationAccuracyThreeKilometers verticalAccuracy:kCLLocationAccuracyThreeKilometers timestamp:[NSDate date]];
    
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            //            [self displayError:error];
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
        [self displayPlacemarksInMap:placemarks];
    }];
}

-(void)displayPlacemarksInMap:(NSArray*)placemarks
{
     CLPlacemark *placemarkToShow = placemarks[0];

    MKCoordinateRegion region =  MKCoordinateRegionMakeWithDistance(placemarkToShow.location.coordinate, 2000, 2000);
    [_mapView setRegion:region];
    
    _mapView.layer.masksToBounds = YES;
    _mapView.mapType = MKMapTypeStandard;
    [_mapView setScrollEnabled:YES];
    
    CLLocationCoordinate2D coord = _currentUserCoordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
    _currentPlace = [[Place alloc] initWithLocation:location reference:nil name:placemarkToShow.name address:placemarkToShow.thoroughfare];

    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:_currentPlace];
    [_mapView addAnnotation:annotation];
}

- (void)loadNearByPlaces
{
    CLLocationCoordinate2D coord = _currentUserCoordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];

    [[PlacesLoader sharedInstance] loadPOIsForLocation:location radius:1000 successHanlder:^(NSDictionary *response) {
//        NSLog(@"Response: %@", response);
        if([[response objectForKey:@"status"] isEqualToString:@"OK"])
        {
            id places = [response objectForKey:@"results"];
            NSMutableArray *temp = [NSMutableArray array];
            
            if([places isKindOfClass:[NSArray class]])
            {
                for(NSDictionary *resultsDict in places)
                {
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[resultsDict valueForKeyPath:kLatiudeKeypath] floatValue] longitude:[[resultsDict valueForKeyPath:kLongitudeKeypath] floatValue]];
                    Place *currentPlace = [[Place alloc] initWithLocation:location reference:[resultsDict objectForKey:kReferenceKey] name:[resultsDict objectForKey:kNameKey] address:[resultsDict objectForKey:kAddressKey]];
                    [temp addObject:currentPlace];
                    
//                    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
//                    [_mapView addAnnotation:annotation];
                }
            }
            
            _locations = [temp copy];
            
//            NSLog(@"Locations: %@", _locations);
            [_tableView reloadData];
        }
    } errorHandler:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



#pragma -mark UITableView Delegates and datasource.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlacesListTableViewCell" forIndexPath:indexPath];

    Place *place = _locations[indexPath.row];
    
    cell.textLabel.text = place.placeName;
    cell.detailTextLabel.text = place.address;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_mapView removeAnnotations:_mapView.annotations];
    _currentPlace = _locations[indexPath.row];

    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:_currentPlace];
    [_mapView addAnnotation:annotation];

    
}

#pragma -mark Facebook Posting

- (IBAction)postLocationToFacebook:(id)sender
{
    if([[FBSession activeSession] isOpen])
    {
        if (([[[FBSession activeSession]permissions]indexOfObject:@"publish_actions"] == NSNotFound))
        {
            [self RequestWritePermissions];
        }
        else
            [self post];
    }
    else if([[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded)
    {
        [[FBSession activeSession] openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (([[[FBSession activeSession]permissions]indexOfObject:@"publish_actions"] == NSNotFound))
            {
                [self RequestWritePermissions];
            }
            else
                [self post];
        }];
    }
    else
    {
        [self showAlertWithMessage:@"Please allow Facebook in settings page" andTitle:@"Facebook not signed In"];
    }
}

- (void) post
{
    id <FBGraphPlace>place = (id<FBGraphPlace>)[FBGraphObject graphObject] ;
    id <FBGraphLocation> location = (id<FBGraphLocation>)[FBGraphObject graphObject];
    
    [location setLatitude:[NSNumber numberWithDouble:_currentPlace.location.coordinate.latitude]];
    [location setLongitude:[NSNumber numberWithDouble:_currentPlace.location.coordinate.longitude]];
    [location setStreet:_currentPlace.address];
    
    [place setLocation:location];
//    [place setName:_currentPlace.placeName];
//    [place setCategory:@"River"];
    
    [[FBRequest requestForPostStatusUpdate:@"1231223" place:place tags:[NSArray arrayWithObjects:@"vicky13vikas", nil]]
     startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
     {
         [self hideLoadingScreen];
         // Did everything come back okay with no errors?
         if (!error && result) {
             [self showAlertWithMessage:@"Posted Successfully" andTitle:nil];
             [self.navigationController popViewControllerAnimated:YES];
         }
         else {
             [self showAlertWithMessage:@"Error Posting to Facebook" andTitle:@"Error"];
         }
     }];
}

-(void)faceBookErrorMessage
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"Error Connecting To Facebook" delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    [errorAlert show];
    
}

-(void)RequestWritePermissions
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"publish_actions", nil];
    
    [[FBSession activeSession] requestNewPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error)
     {
         if (!error) {
             [self post];
         }
         else
         {
             [self showAlertWithMessage:@"Error Posting to Facebook" andTitle:@"Error"];
         }
     }];
}


@end
