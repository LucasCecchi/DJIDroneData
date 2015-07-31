//
//  ViewController.m
//  DJIDroneData
//
//  Created by Lucas Cecchi on 7/29/15.
//  Copyright (c) 2015 Lucas Cecchi. All rights reserved.
//


//Get Gimbal--> Pitch for angle
//Get Drone ---> Yaw for compass direction
//counter-clockwise is ++????


#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//90 degrees facing forward = 0
double gimbalAngle = 45;
//true north = 0
double droneCompassDirection = 0;
float droneAltitude = 10;
bool isFlying;
const float M_TO_DEGREES = 0.00000904366;
const float X_FOVANGLE = 94;
const float Y_FOVANGLE = 52.875;
CLLocationCoordinate2D droneLocation;
CLLocationCoordinate2D destinationPoint;
CGPoint fixedCenter;

-(void)droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom3Professional];
    [_drone connectToDrone];
    _drone.delegate = self;
    _drone.gimbal.delegate = self;
    _drone.mainController.mcDelegate = self;
    [_drone.mainController startUpdateMCSystemState];
    [_drone.gimbal startGimbalAttitudeUpdates];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    fixedCenter = [self.fpvPreviewView.superview convertPoint:self.fpvPreviewView.center toView:nil];
}

-(void) gimbalController:(DJIGimbal *)controller didUpdateGimbalState:(DJIGimbalState *)gimbalState{
    DJIGimbalAttitude gimbalOrientation = gimbalState.attitude;
    gimbalAngle = gimbalOrientation.pitch;
}

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state{
    droneAltitude = state.altitude;
    droneLocation = state.droneLocation;
    isFlying = state.isFlying;
    DJIAttitude droneOrientation = state.attitude;
    droneCompassDirection = droneOrientation.yaw;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    NSLog(@"Touch x : %f y : %f", touchPoint.x, touchPoint.y);
    float xAngleOfTouch = ((touchPoint.x - fixedCenter.x)/(self.fpvPreviewView.bounds.size.width/2))*(X_FOVANGLE/2);
    float yAngleOfTouch = ((fixedCenter.y - touchPoint.y)/(self.fpvPreviewView.bounds.size.height/2))*(Y_FOVANGLE/2);
    NSLog(@"Angle x: %f y : %f",xAngleOfTouch, yAngleOfTouch);
    //assumes 0 yaw means gimbal points straight forward change later when its known for sure
    float directMetersToDestination = tan((yAngleOfTouch + (90 - gimbalAngle))/ 180 * M_PI)*droneAltitude;
    float xMetersToDestination = cos((xAngleOfTouch + droneCompassDirection)/ 180 * M_PI)*directMetersToDestination;
    float yMetersToDestination = sin((xAngleOfTouch + droneCompassDirection)/ 180 * M_PI)*directMetersToDestination;
    NSLog(@"distance to destination : %f", directMetersToDestination);
    
    destinationPoint.latitude = (droneLocation.latitude + (yMetersToDestination*M_TO_DEGREES));
    destinationPoint.longitude = (droneLocation.longitude + (xMetersToDestination*M_TO_DEGREES));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated{
    [_drone.gimbal stopGimbalAttitudeUpdates];
    [_drone.mainController stopUpdateMCSystemState];
    [_drone disconnectToDrone];
    [_drone destroy];
}



@end
