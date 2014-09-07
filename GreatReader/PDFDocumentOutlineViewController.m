//
//  PDFDocumentOutlineViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/20.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentOutlineViewController.h"

#import "Device.h"
#import "PDFDocumentOutline.h"
#import "PDFDocumentOutlineItem.h"
#import "PDFDocumentOutlineItemCell.h"
#import "PDFDocumentViewController.h"

static NSString * const PDFDocumentOutlineSegueExit = @"PDFDocumentOutlineSegueExit";
static NSString * const PDFDocumentOutlineItemCellIdentifier = @"PDFDocumentOutlineItemCellIdentifier";

@interface PDFDocumentOutlineViewController ()
@property (nonatomic, strong) NSArray *outlineItems;
@property (nonatomic, assign) NSInteger activeIndex;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation PDFDocumentOutlineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *nibName = @"PDFDocumentOutlineItemCell";
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:PDFDocumentOutlineItemCellIdentifier];

    if (IsPhone() &&
        [[[UIDevice currentDevice] systemVersion] compare:@"8"] == NSOrderedAscending) {

        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }

    self.activeIndex = -1;
    [self.outlineItems enumerateObjectsUsingBlock:^(NSDictionary *item,
                                                    NSUInteger idx,
                                                    BOOL *stop) {
        NSUInteger from = [item[@"item"] pageNumber];
        NSDictionary *next = item[@"next"];
        NSUInteger to = next ? [next[@"item"] pageNumber]
                             : NSNotFound;
        if (from <= self.currentPage && self.currentPage < to) {
            self.activeIndex = idx;
        }
        else if (from > self.currentPage) {
            *stop = YES;
        }
    }];    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToCurrentPage];
}

#pragma mark - Scroll to currentPage

- (void)scrollToCurrentPage
{
    if (self.activeIndex > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.activeIndex
                                                    inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
    }
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
    [[items copy] enumerateObjectsUsingBlock:^(NSDictionary *dic,
                                        NSUInteger idx,
                                        BOOL *stop) {
        NSMutableDictionary *mdic = [dic mutableCopy];
        if (idx < items.count - 1) {
            [mdic setObject:items[idx + 1] forKey:@"next"];
            [items removeObjectAtIndex:idx];
            [items insertObject:mdic atIndex:idx];
        }
    }];
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
    PDFDocumentOutlineItemCell *cell = [tableView dequeueReusableCellWithIdentifier:PDFDocumentOutlineItemCellIdentifier forIndexPath:indexPath];
    NSDictionary *dic = self.outlineItems[indexPath.row];
    PDFDocumentOutlineItem *item = dic[@"item"];
    NSNumber *level = dic[@"level"];
    [cell configureWithItem:item
                      level:[level unsignedIntegerValue]
                    current:(indexPath.row == self.activeIndex)];
    return cell;
}

#pragma mark - UITableView Delegate

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
