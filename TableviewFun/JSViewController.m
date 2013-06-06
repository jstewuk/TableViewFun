//
//  JSViewController.m
//  TableviewFun
//
//  Created by James Stewart on 5/29/13.
//  Copyright (c) 2013 StewartStuff. All rights reserved.
//

#import "JSViewController.h"

@interface JSViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, copy ) NSArray *data;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *fakeHeaderView;

@end


@implementation JSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.fakeHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1028, 75)];
    [self.view addSubview:self.fakeHeaderView];
    
    self.fakeHeaderView.backgroundColor = [UIColor purpleColor];
    self.fakeHeaderView.hidden = YES;
    self.tableview.tableHeaderView = self.headerView;
    [self.tableview addObserver:self
                     forKeyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
}

- (UIView *)headerView  {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1028, 500)];
    headerView.backgroundColor = [UIColor blueColor];
    
    UIView *headerContainerView = [[UIView alloc] init];
    headerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    headerContainerView.backgroundColor = [UIColor yellowColor];
    [headerView addSubview:headerContainerView];
        
    
    return headerView;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    UIView *headerView = self.tableview.tableHeaderView;
    if (headerView.frame.size.width > 0) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            constrainToSuperView([headerView subviews][0], 20, 100);
        });
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.view setNeedsUpdateConstraints];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

void constrainToSuperView(UIView *view, float minimumSize, NSUInteger priority) {
    if (!view || !view.superview) {
        return;
    }
    for (NSString *format in @[
         @"H:|-==5-[view(>=minimumSize@hiPriority)]-==5-|",
         @"V:|-==5-[view(>=minimumSize@hiPriority)]-==5-|"] ) {
        NSArray *constraints =
          [NSLayoutConstraint
           constraintsWithVisualFormat:format
           options:0
           metrics:@{@"priority" : @(priority), @"hiPriority" : @(priority + 10),@"minimumSize" : @(minimumSize)}
           views:@{@"view" : view}
           ];
        [view.superview addConstraints:constraints];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    CGPoint offsetPoint = (CGPoint)[((NSValue *)change[@"new"]) CGPointValue];
    CGFloat vertOffset = offsetPoint.y;
    if (scrollingThroughHeader(self, vertOffset)) {
        //showLockedHeaderView(self);
    }
    if (scrolledPastHeaderDown(self, vertOffset)) {
        //removeLockedHeaderView(self);
    }
    if (scrolledThroughAnimationTripZone(self, vertOffset)) {
        //animateDropDownIn(self);
        showLockedHeaderView(self);
    }
    if (scrolledDownPastAnimationTripZone(self, vertOffset)) {
        removeLockedHeaderView(self);
    }
}

typedef  JSViewController thisClass;

bool scrollingThroughHeader(thisClass *self, CGFloat offset) {
    CGFloat lowerBound = 0;
    CGFloat upperBound = self.tableview.tableHeaderView.frame.size.height;
    return (offset > lowerBound && offset < upperBound);
}

bool scrolledPastHeaderDown(thisClass *self, CGFloat offset) {
    return (offset <= 0);
}

void showLockedHeaderView(thisClass *self) {
    if (self.fakeHeaderView.hidden) {
        self.fakeHeaderView.hidden = NO;
    }
}

void removeLockedHeaderView(thisClass *self) {
    if ( ! self.fakeHeaderView.hidden) {
        self.fakeHeaderView.hidden = YES;
    }
}

bool scrolledThroughAnimationTripZone(thisClass *self, CGFloat offset) {
    CGFloat lowerBound = self.tableview.tableHeaderView.frame.size.height / 2.0;
    CGFloat upperBound = self.tableview.tableHeaderView.frame.size.height;
    return (offset > lowerBound && offset < upperBound);
}

bool scrolledDownPastAnimationTripZone(thisClass *self, CGFloat offset) {
    CGFloat lowerBound = self.tableview.tableHeaderView.frame.size.height / 2.0;
    return (offset <= lowerBound);
}

void animateDropDownIn(thisClass *self) {
    NSLog(@"animate dropdown in");
}

void animateDropDownOut(thisClass *self) {
    NSLog(@"animate dropdown OUT");
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

NSString * const kCellID = @"cellID";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:kCellID];
    }
    
    cell.textLabel.text = self.data[indexPath.row];
    
    return cell;
}

- (NSArray *)data {
    _data = nil;
    if (_data == nil) {
        NSMutableArray *m_data = [NSMutableArray array];
        for (NSInteger index = 0; index <= 100; ++index) {
            m_data[index] = [@(index) stringValue];
        }
        _data = [NSArray arrayWithArray:m_data];
    }
    return _data;
}

#pragma mark - UITableViewDelegate

@end
