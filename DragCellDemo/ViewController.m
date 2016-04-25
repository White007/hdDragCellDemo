//
//  ViewController.m
//  DragCellDemo
//
//  Created by 朱明科 on 16/4/25.
//  Copyright © 2016年 zhumingke. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic)UICollectionView *showCollection;
@property(nonatomic)NSMutableArray *dataArray;
@end

@implementation ViewController
-(NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initCollectionView];
}
-(void)initData{
    for (NSInteger i = 1; i <= 16; i ++) {
        NSString *str = [NSString stringWithFormat:@"%ld",i];
        UIImage *image = [UIImage imageNamed:str];
        [self.dataArray addObject:image];
    }
}
-(void)initCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    //layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.showCollection = [[UICollectionView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-120)/2, 100, 120, 500) collectionViewLayout:layout];
    _showCollection.backgroundColor = [UIColor grayColor];
    _showCollection.delegate = self;
    _showCollection.dataSource = self;
    [_showCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    [self.view addSubview:_showCollection];
}
#pragma mark - uicollectioview 
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:self.dataArray[indexPath.row]];
    cell.backgroundView = imageView;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:longPress];
    return cell;
}
-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)longPress:(UILongPressGestureRecognizer *)longPress{
    UIGestureRecognizerState state = longPress.state;
    CGPoint location = [longPress locationInView:self.showCollection];
    
    NSIndexPath *indexPath = [self.showCollection indexPathForItemAtPoint:location];
    //NSLog(@"%@",indexPath);
    static UIView *snapshot = nil;//把长按的cell加载到snapshot上
    static NSIndexPath *sourceIndexPath = nil;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            if(indexPath){
                sourceIndexPath = indexPath;
                UICollectionViewCell *cell = [self.showCollection cellForItemAtIndexPath:indexPath];
                snapshot = [self customSnapshothotFromeView:cell];//快照
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.showCollection addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05,1.05);
                    snapshot.alpha = 0.98;
                    cell.hidden = YES;//长按是把当前的cell影藏掉
                }completion:nil];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGPoint center = snapshot.center;
            center.y = location.y;
            center.x = location.x;
            snapshot.center = center;
            if(indexPath && ![indexPath isEqual:sourceIndexPath]){
                [self.dataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row ];
                
                [self.showCollection moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                sourceIndexPath =indexPath;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            
        }
        default:
        {
            UICollectionViewCell *cell =[self.showCollection cellForItemAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
            }completion:^(BOOL finished) {
                [snapshot removeFromSuperview];
                cell.hidden = NO;
                snapshot = nil;
            }];
            [self.showCollection reloadData];
            sourceIndexPath = nil;
        }
            break;
    }

}
- (UIView *)customSnapshothotFromeView:(UIView *)inputView{
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
