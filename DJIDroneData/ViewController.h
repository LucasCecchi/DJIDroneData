//
//  ViewController.h
//  DJIDroneData
//
//  Created by Lucas Cecchi on 7/29/15.
//  Copyright (c) 2015 Lucas Cecchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface ViewController : UIViewController<DJIDroneDelegate, DJIMainControllerDelegate,DJIGimbalDelegate>
{
    DJIDrone *_drone;
    DJICamera *_camera;
    NSObject<GroundStationDelegate> *_groundStation;
}
@property (weak, nonatomic) IBOutlet UIView *fpvPreviewView;

@end

