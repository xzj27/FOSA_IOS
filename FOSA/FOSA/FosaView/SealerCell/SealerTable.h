//
//  SealerTable.h
//  FOSA
//
//  Created by hs on 2019/11/20.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SealerTable : UITableView
@property(nonatomic, strong) NSMutableArray *dataArr;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style dataSource:(NSMutableArray *)dataArr;
@end

NS_ASSUME_NONNULL_END
