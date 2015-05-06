//
//  MyNavController.m
//  USCTrams
//
//  Created by Hemanth on 11/04/15.
//  Copyright (c) 2015 Hemanth. All rights reserved.
//

#import "MyNavController.h"
#import "RNFrostedSidebar.h"
#import "IonIcons.h"
#import "InfoViewController.h"
#import "CCTableViewController.h"
#import "CRViewController.h"
#import "GPUberViewController.h"
@interface MyNavController ()<RNFrostedSidebarDelegate>

@end

@implementation MyNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIBarButtonItem*)getNavButton{
    UIImage *navImage = [IonIcons imageWithIcon:ion_arrow_right_b
                                      iconColor:self.navigationBar.tintColor
                                       iconSize:30.0f
                                      imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:navImage
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(openInfoPage:)];
    button.tintColor = [UIColor blueColor];
    return button;
}

-(IBAction)openInfoPage:(id)sender{
    CGSize buttonsize = CGSizeMake(100.0f, 100.0f);
    UIImage *busicon = [IonIcons imageWithIcon:ion_android_bus
                                     iconColor:[UIColor whiteColor]
                                      iconSize:100.0f
                                     imageSize:buttonsize];
    UIImage *caricon = [IonIcons imageWithIcon:ion_android_car
                                     iconColor:[UIColor whiteColor]
                                      iconSize:100.0f
                                     imageSize:buttonsize];
    UIImage *helpicon = [IonIcons imageWithIcon:ion_ios_help
                                      iconColor:[UIColor whiteColor]
                                       iconSize:100.0f
                                      imageSize:buttonsize];
    UIImage *shareicon = [IonIcons imageWithIcon:ion_android_share_alt
                                       iconColor:[UIColor whiteColor]
                                        iconSize:100.0f
                                       imageSize:buttonsize];
    UIImage *ubericon = [UIImage imageNamed:@"uber-128"];
    NSArray *images = @[
                        busicon,
                        caricon,
                        ubericon,
                        helpicon,
                        shareicon
                        ];
    
    RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
    callout.width = 100;
    callout.delegate = self;
    [callout show];
    
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    [sidebar dismissAnimated:YES completion:^(BOOL finished) {
        if (finished) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UIViewController *newVC,*oldVC;
            oldVC = [self visibleViewController];
            if (index == 0) {
                if ([oldVC isKindOfClass:[CRViewController class]]) {
                    return;
                }
                newVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TramsTable"];
            }
            if (index == 1) {
                if ([oldVC isKindOfClass:[CCTableViewController class]]) {
                    return;
                }
                newVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"Clist"];
            }
            if (index == 2) {
                GPUberViewController *uber = [[GPUberViewController alloc] initWithServerToken:@"OJCNEU1pGoCFbUvx9UWKhvZ_MPHCBmWDK5-kc1te"];
                uber.clientId = @"ec7dBt3Te3Yh84kIr7So7pBUTawp83_m";
                [uber showInViewController:self.visibleViewController];
                return;
            }
            if (index == 3) {
                newVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"infoView"];
                [self presentViewController:newVC animated:YES completion:nil];
                return;
            }
            if (index == 4) {
                newVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"shareViewNav"];
                [self presentViewController:newVC animated:YES completion:nil];
                return;
            }
            if (newVC) {
                self.viewControllers = @[newVC];
            }
        }
    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
