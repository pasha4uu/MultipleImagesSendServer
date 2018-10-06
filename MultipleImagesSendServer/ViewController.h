//
//  ViewController.h
//  MultipleImagesSendServer
//
//  Created by PASHA on 06/10/18.
//  Copyright © 2018 Pasha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ELCImagePickerHeader.h"
#import "ELCImagePickerDemoAppDelegate.h"

@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ELCImagePickerControllerDelegate,NSURLSessionDataDelegate,NSURLSessionDelegate>

- (IBAction)pickImagesTap:(id)sender;
@property NSOperationQueue * httpQueue;
@property (nonatomic, strong) NSMutableArray *chosenImages;
- (IBAction)sendServerTap:(id)sender;

@end

