//
//  SJAssetGroupsTableViewController.m
//  SJAssetPicker
//
//  Created by shejun.zhou on 15/7/4.
//  Copyright (c) 2015年 shejun.zhou. All rights reserved.
//

#import "SJAssetGroupsTableViewController.h"
#import "SJAssetPickerViewController.h"
#import "SJAssetPickerModel.h"

@interface SJAssetGroupsTableViewController ()

@property (nonatomic, strong) NSMutableArray *groupsArray;
@property (nonatomic, strong) SJAssetPickerModel *model;

@end

@implementation SJAssetGroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] init];
    _groupsArray = [[NSMutableArray alloc] init];
    _model = [SJAssetPickerModel shareManager];
    _model.selectedAssetsArrayTemp = [_model.selectedAssetsArray mutableCopy];
    [self loadGroupsNameAndIcon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_groupsArray count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJAssetGroupsTableViewCellReuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:_groupsArray[indexPath.row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"name"]];
    cell.imageView.image = [dic objectForKey:@"image"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:_groupsArray[indexPath.row]];
    NSString *groupName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"name"]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SJAssetPicker" bundle:nil];
    SJAssetPickerViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"SJAssetPickerViewController"];
    //    VC.groupName = groupName;
    VC.title = groupName;
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)loadGroupsNameAndIcon{
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        
        if(group != nil) {
            NSString *strName = [NSString stringWithFormat:@"%@", [group valueForProperty:@"ALAssetsGroupPropertyName"]];
            UIImage *img = [UIImage imageWithCGImage:[group posterImage]];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:strName  forKey:@"name"];
            [dic setObject:img      forKey:@"image"];
            [_groupsArray addObject:dic];
            [self.tableView reloadData];
            if ([strName isEqualToString:@"Camera Roll"]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SJAssetPicker" bundle:nil];
                SJAssetPickerViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"SJAssetPickerViewController"];
                VC.title = strName;
                [self.navigationController pushViewController:VC animated:NO];
            }
        }
    };
    
    [_model.library enumerateGroupsWithTypes:ALAssetsGroupAll
                            usingBlock:assetGroupEnumerator
                          failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
    
}


- (IBAction)tappedCancelItemAction:(id)sender {
    [_model.selectedAssetsArrayTemp removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
