//
//  PDFDocumentOutlineViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/20.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentOutlineViewController.h"

#import "PDFDocumentOutline.h"
#import "PDFDocumentOutlineItem.h"
#import "PDFDocumentOutlineItemCell.h"
#import "PDFDocumentViewController.h"

NSString * const PDFDocumentOutlineSegueExit = @"PDFDocumentOutlineSegueExit";

@interface PDFDocumentOutlineViewController ()
@property (nonatomic, strong) NSArray *outlineItems;
@end

@implementation PDFDocumentOutlineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flatten Outline Items

- (NSArray *)flattenOutlineItems
{
    __block __weak NSArray * (^weak_subtrees)(PDFDocumentOutlineItem *, NSUInteger);
    NSArray * (^subtrees)(PDFDocumentOutlineItem *, NSUInteger) =
            ^(PDFDocumentOutlineItem *item, NSUInteger level) {
        NSMutableArray *array = [NSMutableArray arrayWithObject:@{
            @"item": item, @"level": @(level)
        }];
        for (PDFDocumentOutlineItem *c in item.children) {
            [array addObjectsFromArray:weak_subtrees(c, level + 1)];
        }
        return array;
    };
    weak_subtrees = subtrees;

    NSMutableArray *items = [NSMutableArray array];
    for (PDFDocumentOutlineItem *item in self.outline.items) {
        [items addObjectsFromArray:subtrees(item, 0)];
    }
    return items;
}

#pragma mark - Set Outline

- (void)setOutline:(PDFDocumentOutline *)outline
{
    _outline = outline;
    self.outlineItems = [self flattenOutlineItems];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.outlineItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OutlineItemCell";
    PDFDocumentOutlineItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *dic = self.outlineItems[indexPath.row];
    PDFDocumentOutlineItem *item = dic[@"item"];
    NSNumber *level = dic[@"level"];
    [cell configureWithItem:item level:[level unsignedIntegerValue]];
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.outlineItems[indexPath.row];
    PDFDocumentOutlineItem *item = dic[@"item"];
    NSNumber *level = dic[@"level"];
    return [PDFDocumentOutlineItemCell cellHeightForItem:item
                                                   level:[level unsignedIntegerValue]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:PDFDocumentOutlineSegueExit
                              sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PDFDocumentOutlineSegueExit]) {
        if (sender == self) {
            NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
            NSDictionary *dic = self.outlineItems[indexPath.row];
            PDFDocumentOutlineItem *item = dic[@"item"];

            PDFDocumentViewController *vc = segue.destinationViewController;
            [vc goAtIndex:item.pageNumber animated:YES];
        }
    }
}

#pragma mark -

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.outlineItems[indexPath.row];
    PDFDocumentOutlineItem *item = dic[@"item"];
    NSNumber *level = dic[@"level"];
    cell.textLabel.text = item.title;
    cell.textLabel.numberOfLines = 0;
    if (level.unsignedIntegerValue == 0) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:UIFont.systemFontSize];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:UIFont.systemFontSize];
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)item.pageNumber];
    cell.separatorInset = UIEdgeInsetsMake(0, 15 * ([level unsignedIntegerValue] + 1),
                                           0, 0);
}

@end
