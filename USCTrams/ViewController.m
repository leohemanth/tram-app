//
//  ViewController.m
//  USCTrams
//
//  Created by Hemanth on 28/06/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import "ViewController.h"
#import "Stop.h"
#import "AFNetworking.h"
#import <HTMLReader/HTMLReader.h>
#import "XMLDictionary.h"

@interface ViewController ()

@property (nonatomic,weak) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self getCallStatusFor];
}

-(void)initViews{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getCallStatusFor)];
    self.title = self.cruiser[@"text"];
}

-(void)getCallStatusFor{
    if (self.isViewLoaded && self.view.window) {
        [self performSelector:@selector(getCallStatusFor) withObject:nil afterDelay:20];
    }

    NSString *urlString = self.cruiser[@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [NSDictionary dictionaryWithXMLData:responseObject][@"message"][@"_text"];
        [self.webView loadHTMLString:response baseURL:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Cruisers"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
}




@end
