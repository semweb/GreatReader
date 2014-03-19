//
//  PDFDocumentSettingViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/17/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSettingViewController.h"

#import "PDFDocument.h"
#import "PDFDocumentViewController.h"

NSString * const PDFDocumentSettingSegueExit = @"PDFDocumentSettingSegueExit";
NSString * const PDFDocumentSettingSegueCropOdd = @"PDFDocumentSettingSegueCropOdd";
NSString * const PDFDocumentSettingSegueCropEven = @"PDFDocumentSettingSegueCropEven";


@interface PDFDocumentSettingViewController () <UITableViewDataSource,
                                                UITableViewDelegate>
// Common
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UINavigationBar *naviBar;
@property (nonatomic, strong) UITableViewCell *sliderCell;
@property (nonatomic, strong) UITableViewCell *cropOddCell;
@property (nonatomic, strong) UITableViewCell *cropEvenCell;
@property (nonatomic, strong) UITableViewCell *cropSameCell;
@property (nonatomic, strong) UITableViewCell *cropEnabledCell;
@property (nonatomic, strong) NSArray *cropCells;
// iPhone
@property (nonatomic, strong) IBOutlet UIView *dimView;
@property (nonatomic, strong) IBOutlet UIView *sheetView;
@end

@implementation PDFDocumentSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Title"];
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(done:)];
        [self.naviBar setItems:@[item] animated:NO];    
    }

    self.tableView.scrollEnabled = NO;

    [self prepareCells];
}

- (void)prepareCells
{
    self.sliderCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:nil]; {
        self.sliderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISlider *slider = [[UISlider alloc] initWithFrame:({
            CGRect f = self.sliderCell.contentView.bounds;
            f.origin.x = 20;
            f.size.width -= (CGRectGetMinX(f) * 2);
            f;
        })];
        slider.value = self.document.brightness;
        [slider addTarget:self
                   action:@selector(sliderChanged:)
         forControlEvents:UIControlEventValueChanged];
        slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.sliderCell.contentView addSubview:slider];
    }

    self.cropOddCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:nil]; {
        self.cropOddCell.textLabel.text = @"Edit";
        self.cropOddCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    self.cropEnabledCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:nil]; {
        self.cropEnabledCell.textLabel.text = @"Crop";
        self.cropEnabledCell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectZero];
        [s addTarget:self
              action:@selector(cropEnabledSwitchChanged:)
    forControlEvents:UIControlEventValueChanged];
        s.on = YES;
        self.cropEnabledCell.accessoryView = s;
    }

    self.cropSameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:nil]; {
        self.cropSameCell.textLabel.text = @"Same Crop";
        UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectZero];
        [s addTarget:self
              action:@selector(cropSameSwitchChanged:)
    forControlEvents:UIControlEventValueChanged];
        s.on = YES;
        self.cropSameCell.accessoryView = s;           
    }
    
    self.cropCells = self.currentCropCells;
}

- (NSArray *)currentCropCells
{
    return @[
        self.cropEnabledCell, self.cropSameCell, self.cropOddCell
    ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self performSegueWithIdentifier:PDFDocumentSettingSegueExit
                              sender:sender];
}

- (void)sliderChanged:(UISlider *)slider
{
    self.document.brightness = slider.value;
}

- (void)cropEnabledSwitchChanged:(UISwitch *)sw
{
    [self.tableView reloadData];
}

- (void)cropSameSwitchChanged:(UISwitch *)sw
{
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UITableViewCell *cell = self.cropCells[indexPath.row];
        if (cell == self.cropOddCell || cell == self.cropEvenCell) {
            return 68;
        }
    }

    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.cropOddCell) {
        [self performSegueWithIdentifier:PDFDocumentSettingSegueCropOdd
                                  sender:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.cropCells.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.sliderCell;
    } else {
        return self.cropCells[indexPath.row];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Brightness";
    } else if (section == 1) {
        return @"Crop";
    }
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSString *identifier = segue.identifier;
        if ([identifier isEqualToString:PDFDocumentSettingSegueCropOdd]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{            
                PDFDocumentSettingViewController *dest = segue.destinationViewController;
                [dest performSegueWithIdentifier:PDFDocumentViewControllerSegueCropOdd
                                          sender:dest];
            });
        }
    }
}


@end


@implementation PDFDocumentSettingSegue

- (void)perform
{
    UIViewController *source = self.sourceViewController;
    
    PDFDocumentSettingViewController *dest = self.destinationViewController;
    [source presentViewController:dest
                         animated:NO
                       completion:NULL];
    dest.dimView.alpha = 0.0;
    CGRect endFrame = dest.sheetView.frame;
    dest.sheetView.frame = ({
        CGRect f = endFrame;
        f.origin.y = -CGRectGetHeight(f);
        f;
    });

    endFrame.origin.y = 300;
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        dest.dimView.alpha = 0.1;
        dest.sheetView.frame = endFrame;
    } completion:^(BOOL finished) {
        source.navigationController.modalPresentationStyle = 0;
    }];
}

@end


@implementation PDFDocumentExitSettingSegue : UIStoryboardSegue

- (void)perform
{
    [self perform:NULL];
}

- (void)perform:(void (^)(void))completion
{
    PDFDocumentSettingViewController *source = self.sourceViewController;
    PDFDocumentViewController *dest = self.destinationViewController;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
            source.dimView.alpha = 0.0;
            source.sheetView.frame = ({
                CGRect f = source.sheetView.frame;
                f.origin.y = -CGRectGetHeight(f);
                f;
            });
        } completion:^(BOOL finished) {
            [dest dismissViewControllerAnimated:NO
                                     completion:completion];
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

@end

@implementation PDFDocumentCropOddSegue

- (void)perform
{
    PDFDocumentViewController *dest = self.destinationViewController;    
    [self perform:^{
        [dest performSegueWithIdentifier:PDFDocumentViewControllerSegueCropOdd
                                  sender:dest];
    }];
}

@end

@implementation PDFDocumentCropEvenSegue

- (void)perform
{
    PDFDocumentViewController *dest = self.destinationViewController;    
    [self perform:^{
        [dest performSegueWithIdentifier:PDFDocumentViewControllerSegueCropEven
                                  sender:dest];
    }];
}

@end
