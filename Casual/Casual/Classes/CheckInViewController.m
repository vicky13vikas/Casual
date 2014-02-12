//
//  CheckInViewController.m
//  Casual
//
//  Created by Vikas Kumar on 07/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "CheckInViewController.h"

#define REGION_RADIUS 1000

NSString * const kNameKey = @"name";
NSString * const kReferenceKey = @"reference";
NSString * const kAddressKey = @"vicinity";
NSString * const kLatiudeKeypath = @"geometry.location.lat";
NSString * const kLongitudeKeypath = @"geometry.location.lng";

@interface CheckInViewController ()<CLLocationManagerDelegate, MKAnnotation, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) id <FBGraphPlace> currentPlace;
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
    
    [self loadNearByPlacesFromFacebook];
    
    [self displayPlacemarksInMap];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    // stop updating
//    [self stopUpdatingCurrentLocation];
    
    // since we got an error, set selected location to invalid location
    _currentUserCoordinate = kCLLocationCoordinate2DInvalid;
    
    // show the error alert
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = nil;
    alert.message = @"Error updating location";
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

-(void)displayPlacemarksInMap
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[[_currentPlace location] latitude] doubleValue], [[[_currentPlace location] longitude] doubleValue]);

    MKCoordinateRegion region =  MKCoordinateRegionMakeWithDistance(coordinate, REGION_RADIUS, REGION_RADIUS);
    [_mapView setRegion:region];
    
    _mapView.layer.masksToBounds = YES;
    _mapView.mapType = MKMapTypeStandard;
    [_mapView setScrollEnabled:NO];

    [_mapView addAnnotation:self];
}

#pragma -mark UITableView Delegates and datasource.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlacesListTableViewCell" forIndexPath:indexPath];
    
    id <FBGraphPlace>place = (id<FBGraphPlace>)_locations[indexPath.row] ;
    
    cell.textLabel.text = [place name];
    cell.detailTextLabel.text = [[place location] street];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_mapView removeAnnotations:_mapView.annotations];
    _currentPlace = _locations[indexPath.row];
    
    _currentPlace = (id<FBGraphPlace>)_locations[indexPath.row] ;

    [_mapView addAnnotation:self];
}

#pragma -mark Facebook Posting

- (IBAction)postLocationToFacebook:(id)sender
{
    [self showLoadingScreenWithMessage:@"Posting..."];
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
        [self hideLoadingScreen];
    }
}

- (void) post
{
    [[FBRequest requestForPostStatusUpdate:@"" place:_currentPlace tags:[NSArray arrayWithObjects:nil]]
     startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
     {
         [self hideLoadingScreen];
         // Did everything come back okay with no errors?
         if (!error && result) {
             [self showAlertWithMessage:@"Posted Successfully" andTitle:nil];
         }
         else {
             [self showAlertWithMessage:@"Error Posting to Facebook" andTitle:@"Error"];
         }
     }];
    
}


-(void)loadNearByPlacesFromFacebook
{
    if([[FBSession activeSession] isOpen])
    {
        if (([[[FBSession activeSession]permissions]indexOfObject:@"publish_actions"] == NSNotFound))
        {
            [self RequestWritePermissions];
        }
        else
            [self loadNearPlaces];
    }
    else if([[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded)
    {
        [[FBSession activeSession] openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (([[[FBSession activeSession]permissions]indexOfObject:@"publish_actions"] == NSNotFound))
            {
                [self RequestWritePermissions];
            }
            else
                [self loadNearPlaces];
        }];
    }
    else
    {
        [self showAlertWithMessage:@"Please allow Facebook in settings page" andTitle:@"Facebook not signed In"];
    }

}

-(void)parseResultsfromFacebookPlaces:(id)result
{
    NSArray *data = [result objectForKey:@"data"];

    NSMutableArray *temp = [NSMutableArray array];
    for (FBGraphObject<FBGraphPlace> * place in data)
    {
        [temp addObject:place];
    }
    _locations = [temp copy];
    _currentPlace = _locations[0];
    [self displayPlacemarksInMap];
    [_tableView reloadData];
}

-(void)loadNearPlaces
{
    [[FBRequest requestForPlacesSearchAtCoordinate:_currentUserCoordinate radiusInMeters:REGION_RADIUS resultsLimit:30 searchText:nil] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if(!error)
        {
            [self parseResultsfromFacebookPlaces:result];
        }
        else
        {
            [self showAlertWithMessage:@"Error Loading Places from Facebook" andTitle:@"Error"];
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
             [self hideLoadingScreen];
         }
     }];
}

#pragma mark - MKAnnotation Protocol (for map pin)

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[[_currentPlace location] latitude] doubleValue], [[[_currentPlace location] longitude] doubleValue]);
    return coordinate;
}

- (NSString *)title
{
    return [_currentPlace name];
}

@end
