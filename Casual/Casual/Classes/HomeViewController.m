//
//  HomeViewController.m
//  Casual
//
//  Created by Vikas kumar on 05/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "HomeViewController.h"
#import "PostViewController.h"

@interface HomeViewController ()
@property (strong, nonatomic) IBOutlet UILabel *lblTotalScans;
@property (strong, nonatomic) IBOutlet UILabel *lblMutualScans;
@property (weak, nonatomic) IBOutlet UITextView *tvAddress;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (readonly) CLLocationCoordinate2D currentUserCoordinate;

@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;

@end

@implementation HomeViewController

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
    [self initFAcebook];
    [self initBottombarUI];
    [self startUpdatingCurrentLocation];
}

-(void) initBottombarUI
{
  
  UIImage *selectedImage0 = [UIImage imageNamed:@"BtnHome_Sel.png"];
  UIImage *unselectedImage0 = [UIImage imageNamed:@"BtnHome.png"];
  
  UIImage *selectedImage1 = [UIImage imageNamed:@"BtnScan_Sel.png"];
  UIImage *unselectedImage1 = [UIImage imageNamed:@"BtnScan.png"];
  
  UIImage *selectedImage2 = [UIImage imageNamed:@"BtnHistory_Sel.png"];
  UIImage *unselectedImage2 = [UIImage imageNamed:@"BtnHistory.png"];
  
  UIImage *selectedImage3 = [UIImage imageNamed:@"BtnActivites_Sel.png"];
  UIImage *unselectedImage3 = [UIImage imageNamed:@"BtnActivites.png"];
    
  UIImage *selectedImage4 = [UIImage imageNamed:@"btnInfo_Sel.png"];
  UIImage *unselectedImage4 = [UIImage imageNamed:@"btnInfo.png"];
  
  UITabBar *tabBar = self.tabBarController.tabBar;
  
  UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
  UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
  UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
  UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
  UITabBarItem *item4 = [tabBar.items objectAtIndex:4];
  
  [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
  [item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];
  [item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
  [item3 setFinishedSelectedImage:selectedImage3 withFinishedUnselectedImage:unselectedImage3];
  [item4 setFinishedSelectedImage:selectedImage4 withFinishedUnselectedImage:unselectedImage4];
  
    
    item0.image = unselectedImage0;
    item0.selectedImage = selectedImage0;
    
    item1.image = unselectedImage1;
    item1.selectedImage = selectedImage1;
    
    item2.image = unselectedImage2;
    item2.selectedImage = selectedImage2;
    
    item3.image = unselectedImage3;
    item3.selectedImage = selectedImage3;
    
    item4.image = unselectedImage4;
    item4.selectedImage = selectedImage4;
  
  item0.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  item1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  item2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  item3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  item4.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  
  if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
  {
    // set it just for this instance
    [tabBar setBackgroundImage:[UIImage imageNamed:@"TabBarBG.png"]];
    
    // set for all
    // [[UITabBar appearance] setBackgroundImage: ...
  }
}

-(void)getLoginDetails
{
    NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS];
    
    NSString *totalScans = [currentUser objectForKey:@"scan_count"];
    NSString *mutualScans = [currentUser objectForKey:@"mutualScans"];
    
    int savedScanCount = [[[NSUserDefaults standardUserDefaults] valueForKey:LOCAL_SCANNED_COUNT] integerValue];
    int totalNoOfScans = [totalScans integerValue] + savedScanCount;

    if(totalScans && ![totalScans isEqualToString:@""])
    {
        _lblTotalScans.text = [NSString stringWithFormat:@"%d",totalNoOfScans];
    }
    else
    {
        _lblTotalScans.text = @"0";
    }
    
    if(mutualScans && ![mutualScans isEqualToString:@""])
    {
        _lblMutualScans.text = mutualScans;
    }
    else
    {
        _lblMutualScans.text = @"0";
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] valueForKey:IS_LOGGED_IN] || ![[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS])
    {
        [self logout];
    }
    else
    {
        [self getLoginDetails];
    }
    [self setIntialButtonStates];
}

-(void)setIntialButtonStates
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_FACEBOOK_ON])
    {
        [_btnFacebook setEnabled:YES];
    }
    else
    {
        [_btnFacebook setEnabled:NO];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_TWITTER_ON])
    {
        [_btnTwitter setEnabled:YES];
    }
    else
    {
        [_btnTwitter setEnabled:NO];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutTapped:(id)sender
{
    [self logout];
}

#pragma - INIT Facebook

-(void)fetchUserDetails
{
    [[FBRequest requestForMe]
     startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
     {
         // Did everything come back okay with no errors?
         if (!error && result) {
             [[NSUserDefaults standardUserDefaults] setObject:result forKey:FACEBOOK_DETAILS];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         else {
             
         }
     }];
    
}

-(void) initFAcebook
{
    if([[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded)
    {
        [[FBSession activeSession] openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            
            if(status == FBSessionStateOpen)
            {
                if(![[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_DETAILS])
                    [self fetchUserDetails];
            }
        }];
    }
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
    
    [self performCoordinateGeocode];
//    [self stopUpdatingCurrentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    // stop updating
//    [self stopUpdatingCurrentLocation];
    
    // since we got an error, set selected location to invalid location
    _currentUserCoordinate = kCLLocationCoordinate2DInvalid;
    
    // show the error alert
//    UIAlertView *alert = [[UIAlertView alloc] init];
//    alert.title = @"Error updating location";
//    alert.message = [error localizedDescription];
//    [alert addButtonWithTitle:@"OK"];
//    [alert show];
}

- (void)performCoordinateGeocode
{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocationCoordinate2D coord = _currentUserCoordinate;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
//            [self displayError:error];
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
        [self displayPlacemarks:placemarks];
    }];
}

-(void)displayPlacemarks:(NSArray*)placemarks
{
    CLPlacemark *placeMarkToShow = placemarks[0];
    
  /*  NSString *address1 = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@",
                         placeMarkToShow.name,
                         placeMarkToShow.thoroughfare,
                         placeMarkToShow.subThoroughfare,
                         placeMarkToShow.locality,
                         placeMarkToShow.subLocality,
                         placeMarkToShow.administrativeArea,
                         placeMarkToShow.subAdministrativeArea,
                         placeMarkToShow.postalCode,
                         placeMarkToShow.country ];
   */
    
    NSMutableString *address = [[NSMutableString alloc] init];
    
    if(placeMarkToShow.name.length > 0)
    {
        [address appendString:placeMarkToShow.name];
    }
    if(placeMarkToShow.thoroughfare.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.thoroughfare];
    }
    if(placeMarkToShow.subThoroughfare.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.subThoroughfare];
    }
    if(placeMarkToShow.locality.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.locality];
    }
    if(placeMarkToShow.subLocality.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.subLocality];
    }
    if(placeMarkToShow.administrativeArea.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.administrativeArea];
    }
    if(placeMarkToShow.subAdministrativeArea.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.subAdministrativeArea];
    }
    if(placeMarkToShow.postalCode.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.postalCode];
    }
    if(placeMarkToShow.ISOcountryCode.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.ISOcountryCode];
    }
    if(placeMarkToShow.country.length > 0)
    {
        [address appendString:@", "];
        [address appendString:placeMarkToShow.country];
    }
    
    _tvAddress.text = address;
}

#pragma -mark IBActions

- (IBAction)btnFacebookTwitterTapped:(id)sender
{
    PostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
    vc.isFromhistory = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
