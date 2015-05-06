//
//  ShareTableViewController.m
//  USC Tram
//
//  Created by Hemanth on 15/05/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "ShareTableViewController.h"
#import <Social/Social.h>
#import <NUI/UIView+NUI.h>
#import <NUI/UILabel+NUI.h>
#import <QuartzCore/QuartzCore.h>

@interface ShareTableViewController ()
@property NSString *shareString,*urlString,*appName,*fbUrl;

@end

@implementation ShareTableViewController


- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.urlString=@"https://itunes.apple.com/us/app/usc-tram/id879908623";
    self.fbUrl=@"http://facebook.com/usctrams";
    self.appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];

//    self.appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    self.shareString= [NSString stringWithFormat:@"Check out this app to keep track of %@ \n%@\n%@",self.appName,self.urlString,self.fbUrl];
  //  sectionView.nuiClass = @"sectionTitleView";
  //  label.nuiClass = @"sectionTitleLabel";
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.title=@"Share";
}


- (IBAction)facebookbutton:(UITableView*)tableView{
    
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/783916111641507"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com/usctrams"]];
    }
}

- (IBAction)facebookSharebutton:(UITableView*)tableView{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:self.shareString];
        
        [mySLComposerSheet addImage:[UIImage imageNamed:@"AppIcon.png"]];
        
      //  [mySLComposerSheet addURL:[NSURL URLWithString:@"http://facebook.com/usctrams"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
               //     NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
               //     NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
}

-(IBAction)messageshare:(id)sender{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = self.shareString;
        controller.messageComposeDelegate = self;
         [self presentViewController:controller animated:YES completion:nil];
    }
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)mailme:(id)sender{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    if([MFMailComposeViewController canSendMail])
    {
        controller.mailComposeDelegate=self;
        controller.title=@"FeedBack";
        [controller setToRecipients:@[@"usctrams@gmail.com"]];
        [controller setMessageBody:@"" isHTML:NO];
        [controller setSubject:[NSString stringWithFormat:@"FeedBack about %@",self.appName]];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)mailshare:(id)sender{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    if([MFMailComposeViewController canSendMail])
    {
        controller.mailComposeDelegate=self;
        controller.title=@"Share";
        [controller setMessageBody:self.shareString isHTML:NO];
        [controller setSubject:[NSString stringWithFormat:@"iOS app to keep track of %@",self.appName]];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self facebookSharebutton:tableView];
                    break;
                case 1:
                    [self messageshare:tableView];
                    break;
                case 2:
                    [self mailshare:tableView];
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self facebookbutton:tableView];
                    break;
                case 1:
                    [self mailme:tableView];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
}


@end
