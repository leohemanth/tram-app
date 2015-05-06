//
//  CCTableViewController.m
//  USC Trams
//
//  Created by Hemanth on 20/10/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CCTableViewController.h"
#import "AFNetworking.h"
#import <HTMLReader/HTMLReader.h>
#import "MapVCViewController.h"
#import "XMLDictionary.h"
#import "MyNavController.h"
#import "ShareTableViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "IonIcons.h"
#import "ViewController.h"
#import "TTTAttributedLabel.h"
@interface CCTableViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic,retain) NSMutableArray *cruisers;
@end

@implementation CCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cruisers = [NSMutableArray array];
    [self initViews];
    [self updateTable];
}

- (void)initViews
{
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(updateTable) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    self.navigationItem.leftBarButtonItem=[((MyNavController*)self.navigationController) getNavButton];
    self.navigationItem.rightBarButtonItem=[self getCallButton];
}

-(void)setTableAsEmpty{
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
}

-(UIBarButtonItem*)getCallButton{
    
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
        return nil;
    
    UIImage *navImage = [IonIcons imageWithIcon:ion_ios_telephone
                                      iconColor:self.navigationController.navigationBar.tintColor
                                       iconSize:30.0f
                                      imageSize:CGSizeMake(30.0f, 30.0f)];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:navImage
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(callCruiser)];
    button.tintColor = [UIColor blueColor];
    return button;
}

-(void)callCruiser{
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:@"213.740.4911"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}


- (void)dealloc
{
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = nil;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"Campus Cruiser is currently closed";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"If you are in need of a ride after hours, a USC friendly alternative is Yellowcab. Yellowcab now accepts USCard!. Please call (800) USC-TAXI or click here for more information.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:@"(800)USC-TAXI"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]};
    
    return [[NSAttributedString alloc] initWithString:@"Call Yellow Cabs" attributes:attributes];
}

-(void)updateTable{
    if (self.isViewLoaded && self.view.window) {
        [self performSelector:@selector(updateTable) withObject:nil afterDelay:20];
    }
    
    NSString *urlString = @"http://cruiser.usc.edu:90/";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSASCIIStringEncoding];
        HTMLDocument *document = [HTMLDocument documentWithString:response];
        
        NSArray *calls = [document nodesMatchingSelector:@"option"];
        for (HTMLElement*element in calls) {
            NSMutableDictionary *cruiser = [NSMutableDictionary dictionary];
            cruiser[@"callid"] = element.attributes;
            cruiser[@"url"] = [NSString stringWithFormat:@"http://cruiser.usc.edu:90/xml_call_status.asp?callid=%@&hash=%lf",element.attributes[@"value"], ((double)arc4random() / 10000000000)];
            cruiser[@"text"] = [self getTransformedStatusText:element.textContent];
            [self.cruisers addObject:cruiser];
        }
        if (self.cruisers.count==0) {
            [self setTableAsEmpty];
        }
        [self sortCruisers];
        [self.tableView reloadData];
        for (int i=0; i<self.cruisers.count; i++) {
            [self getCallStatusFor:self.cruisers[i]];
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
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

-(void)getCallStatusFor:(NSMutableDictionary*)cruiser{
    NSString *urlString = cruiser[@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response = [NSDictionary dictionaryWithXMLData:responseObject][@"message"][@"_text"];
        if (response) {
            cruiser[@"response"] = response;
        }
        NSString *red = [self getRedSpanfromtext:cruiser[@"response"]];
        if (red) {
            cruiser[@"red"] = red;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
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

-(NSString*)getTransformedStatusText:(NSString*)text{
    NSArray *from = @[@"Call "];
    NSArray *to = @[@""];
    NSString *is = text;
    for (int i = 0; i<from.count; i++) {
        is = [is stringByReplacingOccurrencesOfString:from[i]
                                           withString:to[i]];
    }
    return is;
}

-(NSString *)getRedSpanfromtext:(NSString*)text{
    NSString *start = @"<span style='color:red'>";
    NSString *end = @"</span>";
    NSRange startLoc = [text rangeOfString:start];
    if (startLoc.location == NSNotFound) {
        return nil;
    }
    NSRange endLoc = [[text substringFromIndex:startLoc.location+startLoc.length] rangeOfString:end];
    NSString *hashtagWord =[self stringByStrippingHTML:[text substringWithRange:NSMakeRange(startLoc.location+start.length, endLoc.location)]];
    
    return hashtagWord;
}

-(NSString *) stringByStrippingHTML:(NSString*)s {
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

-(void)sortCruisers{
    NSArray *sortedArray;
    sortedArray = [self.cruisers sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        int aCall = [self getCallFromString:a[@"text"]];
        int bCall = [self getCallFromString:b[@"text"]];
        return aCall>bCall;
    }];
    self.cruisers = [sortedArray mutableCopy];
}

-(int)getCallFromString:(NSString*)text{
    NSRange hashtag = [text rangeOfString:@"#"];
    NSRange word = [[text substringFromIndex:hashtag.location] rangeOfString:@" "];
    NSString *hashtagWord = [text substringWithRange:NSMakeRange(hashtag.location+1, word.location)];
    return [hashtagWord intValue];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cruisers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"carLocationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    NSDictionary *cruiser = self.cruisers[indexPath.row];
    //  cell.textLabel.text = cruiser[@"text"];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:3];
    textLabel.text = cruiser[@"text"];
    TTTAttributedLabel *label = (TTTAttributedLabel*)[cell viewWithTag:1];
    label.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    if (cruiser[@"red"]) {
        label.hidden = NO;
        [label setText:[self getlableStringFrom:cruiser[@"red"]]];
        label.layer.cornerRadius = 8;
    }else{
        label.hidden = YES;
    }
    return cell;
}
-(NSString *)getlableStringFrom:(NSString*)s{
    NSArray *from = @[@"minutes",@"van",@"bike rack",@" bike"];
    NSArray *to = @[@"m",@"v",@"b",@"b"];
    NSString *is = s;
    for (int i =0; i<from.count; i++) {
        is = [is stringByReplacingOccurrencesOfString:from[i]
                                           withString:to[i]];
    }
    // is = [NSString stringWithFormat:@" %@   ",is];
    return is;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    MapVCViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"MapView"];
    //    [self.navigationController pushViewController:mapVC animated:YES];
}
#pragma mark - Navigation

//  In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *vc=segue.destinationViewController;
    vc.cruiser = self.cruisers[self.tableView.indexPathForSelectedRow.row];
}


@end
