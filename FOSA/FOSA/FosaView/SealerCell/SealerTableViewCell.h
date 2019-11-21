//
//  SealerTableViewCell.h
//  FOSA
//
//  Created by hs on 2019/11/19.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SealerTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *foodName,*expireDate,*storageDate;

- (void)InitCellData:(NSString *)data;
@end

NS_ASSUME_NONNULL_END
