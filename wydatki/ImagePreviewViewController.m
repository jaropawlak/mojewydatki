//
//  ImagePreviewViewController.m
//  wydatki
//
//  Created by jarek on 12.10.2013.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import "ImagePreviewViewController.h"

@interface ImagePreviewViewController ()

@end

@implementation ImagePreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)setupImage:(UIImage*)image named:(NSString*)name
{
    _previewImage = image;
    _fileName = name;
    imageWasChanged = NO;
    _imagePreview.image = image;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _imagePreview.image = _previewImage;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneClicked:(UIBarButtonItem *)sender {
    if (imageWasChanged) {
        [self saveImage];
    }
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark image picker

- (IBAction)editClicked:(UIBarButtonItem *)sender {
    BOOL isPhotoAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ];
    BOOL isLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (isPhotoAvailable && isLibraryAvailable)
    {
        NSString* photo = Localize(@"Photo");
        NSString* library = Localize(@"Library");
        UIActionSheet *chooseSource = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"chooseInput", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:library,photo,nil];
        [chooseSource showFromRect:self.view.frame inView:self.view animated:YES];
        
    }
    else if (isLibraryAvailable)
    {
        [self usePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }

}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1 )
    {
        [self usePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }
    else if (buttonIndex == 0)
    {
        [self usePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}
-(void)usePickerWithType:(UIImagePickerControllerSourceType) sourceType
{
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
    
}
UIImage* image;
BOOL imageWasChanged = NO;
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = (UIImage*)[info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
    {
        image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    }
    self.imagePreview.image = _previewImage = image;
    imageWasChanged = YES;
    [picker dismissModalViewControllerAnimated:YES];
}
-(void)saveImage
{
    if (image!= nil)
    {
        //scale image
        CGSize size =CGSizeMake(image.size.width/2, image.size.height/2);
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0,0,size.width,size.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        NSData* data = UIImageJPEGRepresentation(newImage, 0.9f);
        //generate name
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:_fileName error:&error];
        if (error != nil)
            NSLog (@"%@", error.description);
        [data writeToFile:_fileName atomically:NO];
    }
}

@end
