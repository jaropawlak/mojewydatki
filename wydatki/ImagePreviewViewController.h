//
//  ImagePreviewViewController.h
//  wydatki
//
//  Created by jarek on 12.10.2013.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImagePreviewViewController : UIViewController< UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong) UIImage* previewImage;
@property (strong) NSString* fileName;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
- (IBAction)doneClicked:(UIBarButtonItem *)sender;
- (IBAction)editClicked:(UIBarButtonItem *)sender;

-(void)setupImage:(UIImage*)image named:(NSString*)name;

@end
