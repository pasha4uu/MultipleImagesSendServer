//
//  ViewController.m
//  MultipleImagesSendServer
//
//  Created by PASHA on 06/10/18.
//  Copyright © 2018 Pasha. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NSLog(@"ok ok");
  // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)pickImagesTap:(id)sender {
  ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
  elcPicker.maximumImagesCount =8;
  elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
  elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
  elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
  elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
  elcPicker.imagePickerDelegate = self;
  [self presentViewController:elcPicker animated:YES completion:nil];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
  [self dismissViewControllerAnimated:YES completion:nil];
  NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
  for (NSDictionary *dict in info)
  {
    if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto)
    {
      if ([dict objectForKey:UIImagePickerControllerOriginalImage])
      {
        UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
        [images addObject:image];
      }
    }
  }
  
  if (images.count!=0) {
    self.chosenImages = [[NSMutableArray alloc]init];
    for (int i = 0; i<images.count; i++) {
      
      UIImage * image = [UIImage imageWithCGImage:[[images objectAtIndex:i]CGImage]];
      NSData * dataImage = UIImageJPEGRepresentation(image, 1.0f);
      [self.chosenImages addObject:dataImage];
    }
    NSLog(@"images ---- %@",images);
  //  [self multipleBannersSend];
  }
  
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)multipleBannersSend
{
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  NSString *boundary = @"SportuondoFormBoundary";
  NSMutableData *body = [NSMutableData data];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  [params setValue:@"5b9c90824b335122dc4f6f45"forKey:@"vendor_id"];
  [params setValue:@"5ba8b0f573c1c827b77cce52" forKey:@"business_id"];
  
  for (NSString *param in params) {
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  for (int i = 0;i<self.chosenImages.count;i++)
  {
    NSData * imageDataFile ;
    imageDataFile = [self.chosenImages objectAtIndex:i];
    if (imageDataFile) {
      [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\";filename=\"image.jpg\"\r\n", @"banner_images[]"] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[self.chosenImages objectAtIndex:i]];
      [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
      [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
  }
  [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  sessionConfiguration.HTTPAdditionalHeaders = @{
                                                 //                                                   @"api-key"       : @"55e76dc4bbae25b066cb",
                                                 @"Accept"        : @"application/json",
                                                 @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                 };
  
  NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.reatchall.com/vendor/upload-banner-images"]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPMethod = @"POST";
  request.HTTPBody = body;
  NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"my data is :  %@ ",dic);
    dispatch_async(dispatch_get_main_queue(), ^{
      
      [MBProgressHUD hideHUDForView:self.view animated:YES];
      if ([[dic objectForKey:@"success"] boolValue]) {
        [self showMessage:@"banners Added successfully"];
      }
      else
      {
        [self showMessage:[dic objectForKey:@"msg"]];
      }
    });
    
  }];
  
  [task resume];
}

- (void)showMessage:(NSString*)message
{
  const CGFloat fontSize = 16;
  
  UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(8, self.view.frame.size.height-60, self.view.frame.size.width-16, 40)];
  label.backgroundColor = [UIColor blackColor];
  label.font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
  label.text = message;
  label.textColor =[UIColor whiteColor];
  label.layer.cornerRadius=5;
  label.layer.masksToBounds=YES;
  label.numberOfLines=0;
  label.textAlignment=NSTextAlignmentCenter;
  // [label sizeToFit];
  
  //  label.center = point;
  
  [self.view addSubview:label];
  
  [UIView animateWithDuration:0.5 delay:2 options:0 animations:^{
    label.alpha = 0;
  } completion:^(BOOL finished) {
    label.hidden = YES;
    [label removeFromSuperview];
  }];
}
- (IBAction)sendServerTap:(id)sender {
  [self multipleBannersSend];
}

@end
