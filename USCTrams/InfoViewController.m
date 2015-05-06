//
//  InfoViewController.m
//  USCTram
//
//  Created by Hemanth on 24/03/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()
@property  (nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.scalesPageToFit=YES;
    [self.view addSubview:    self.webView];
    [    self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://transnet.usc.edu/index.php/bus-map-schedules/"]]];
    [self.webView setDelegate:self];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.spinner.frame = CGRectMake(round((self.webView.frame.size.width - 35) / 2), round((self.webView.frame.size.height - 35) / 2), 35, 35);

    [self.view addSubview:self.spinner];
    
    
    [self.spinner startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.spinner removeFromSuperview];
}
@end
