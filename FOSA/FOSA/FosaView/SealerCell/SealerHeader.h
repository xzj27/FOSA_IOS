//
//  SealerHeader.h
//  FOSA
//
//  Created by hs on 2019/11/20.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SealerModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol SealerSectionViewDelegate <NSObject>
- (void)SealerHeaderInSection:(NSInteger)SectionHeader;
@end

@interface SealerHeader : UITableViewHeaderFooterView

@property(nonatomic, assign) NSInteger section;/** selected section */
@property(nonatomic, weak) id<SealerSectionViewDelegate> delegate;/** delegate */
- (void)setSectionViewWithModel:(SealerModel *)model section:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
