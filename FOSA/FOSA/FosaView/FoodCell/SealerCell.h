//
//  SealerCell.h
//  FOSA
//
//  Created by hs on 2019/11/28.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SealerCell : UITableViewCell

@property (nonatomic,strong) UILabel *expireLabel,*remindLabel,*storageLabel,*foodNameLabel;
@property (nonatomic,strong) UIImageView *foodImgView;
@property (nonatomic,strong) UIButton *checkBtn;
@end

NS_ASSUME_NONNULL_END
