//
//  CRViewController.m
//  USC Trams
//
//  Created by Lolcat on 31/01/2013.
//  Copyright (c) 2013 Createch. All rights reserved.
//

#import "CRViewController.h"
#import "MapVCViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "InfoViewController.h"
#import "Stop.h"
#import "RNFrostedSidebar.h"
#import "Prediction.h"
#import "IonIcons.h"
#import "MyNavController.h"
#import "CCTableViewController.h"
#import "TTTAttributedLabel.h"
#import "UIScrollView+EmptyDataSet.h"
@interface CRViewController ()<RNFrostedSidebarDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property BOOL waiting,filtered;
@end

@implementation CRViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbUpdated:) name:@"stopsUpdated" object:nil];
    self.title=@"USC Trams";
    self.waiting = NO;
    [self initViews];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status>0) {
            if (self.refreshControl==nil) {
                [self initViews];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your network connection or that you are not in airplane mode" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                NSLog(@"Unreachable");
                self.refreshControl=nil;
            }
        }
    }];
    [self fetchNearbyStops];
}

-(void)setTableViewAsEmtpy{
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"USC Trams are not available at this location";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)fetchNearbyStops
{
    if([self.navigationController.visibleViewController isKindOfClass:[self class]])
        [self performSelector:@selector(fetchNearbyStops) withObject:nil afterDelay:30];
    [self.refreshControl beginRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading Data..."];
    [Stop fetchNearByStops];
}


-(void)dbUpdated:(NSNotification*)notification{
    NSLog(@"DB updated");
    [self.refreshControl endRefreshing];
    self.stops = (NSDictionary*)notification.object[1];
    self.stopNames = (NSArray*)notification.object[0];
    if (self.stops.count==0) {
        [self setTableViewAsEmtpy];
    }    [self.tableView reloadData];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)initViews
{
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(fetchNearbyStops) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    self.navigationItem.leftBarButtonItem=[((MyNavController*)self.navigationController) getNavButton];
    UIImage *caricon = [IonIcons imageWithIcon:ion_android_car size:30.0f color:self.navigationController.navigationBar.tintColor];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:caricon style:UIBarButtonItemStylePlain target:self action:@selector(pushCruiser)];
}

-(void)pushCruiser{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    CCTableViewController *newVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"Clist"];
    if (newVC) {
        self.navigationController.viewControllers = @[newVC];
    }
}

- (void)viewDidUnload {
    [self setLocationsTableView:nil];
    [self setNavBar:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.stopNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)self.stops[self.stopNames[section]]).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (CGFloat) 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect sectionViewRect = [[UIScreen mainScreen] bounds];
    sectionViewRect.size.height = 40;
    CGRect labelRect = CGRectMake(12, 0, sectionViewRect.size.width, 40);
    CGRect distRect = CGRectMake(sectionViewRect.size.width-60, 0, 60, 40);
    
    UIView *sectionView = [[UIView alloc] initWithFrame:sectionViewRect];
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    UILabel *dist = [[UILabel alloc] initWithFrame:distRect];
    
    label.textColor = [UIColor colorWithRed:1 green:.62 blue:.031 alpha:1];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    label.layer.shadowOffset = CGSizeMake(0.0, -1);
    label.text = self.stopNames[section];
    
    dist.text = [NSString stringWithFormat:@"%@ mi",((Stop*)self.stops[self.stopNames[section]][0]).distance];
    dist.textColor = [UIColor colorWithRed:1 green:.62 blue:.031 alpha:1];
    dist.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    dist.layer.shadowOffset = CGSizeMake(0.0, -1);
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, sectionView.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed:0.000 green:0.498 blue:0.345 alpha:1].CGColor;
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, sectionViewRect.size.height - 1.0f, sectionViewRect.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:0.000 green:0.314 blue:0.212 alpha:1].CGColor;
    
    [sectionView.layer addSublayer:topBorder];
    [sectionView.layer addSublayer:bottomBorder];
    
    UIColor *bg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_lozenge.png"]];
    [sectionView setBackgroundColor:bg];
    
    sectionView.nuiClass = @"sectionTitleView";
    label.nuiClass = @"sectionTitleLabel";
    dist.nuiClass= @"sectionTitleLabel";
    
    [sectionView addSubview:label];
    [sectionView addSubview:dist];
    
    return sectionView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"busLocationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    Stop *stop = self.stops[self.stopNames[indexPath.section]][indexPath.row];
    cell.textLabel.text = stop.routeName;
    [self clearLabelForView:cell];
    UILabel *label = (UILabel *)[cell viewWithTag:10];
    
    label.nuiClass = @"routeName";
    label.text = stop.stopName;
    int numLabels = 1;
    TTTAttributedLabel *tLabel;
    for (Prediction *prediction in stop.predictions)
    {
        tLabel = (TTTAttributedLabel *)[cell viewWithTag:numLabels];
        if ( numLabels <= 3)
        {   tLabel.hidden=NO;
            tLabel.textColor = [UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:1];
            tLabel.backgroundColor = [UIColor colorWithRed:1 green:0.61 blue:0.03 alpha:1];
            tLabel.layer.cornerRadius = 8;
            tLabel.textInsets = UIEdgeInsetsMake(8,8,8,8);
            tLabel.text = [NSString stringWithFormat:@"%@m", prediction.minutes];
            numLabels++;
        }
    }
    return  cell;
    
}

-(void)clearLabelForView:(UITableViewCell*)cell{
    for (int i=1;i<4;i++) {
        UILabel *label = (UILabel *)[cell viewWithTag:i];
        label.textColor =[UIColor clearColor];
        label.backgroundColor=[UIColor clearColor];
        label.text=@"";
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"toMap"]) {
        MapVCViewController *mapVC=[segue destinationViewController];
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        mapVC.stop = self.stops[self.stopNames[indexPath.section]][indexPath.row];
        [self.locationsTableView deselectRowAtIndexPath:[self.locationsTableView indexPathForSelectedRow] animated:NO];
        mapVC.currentLocation=self.locationManager.location;
    }
}

@end
