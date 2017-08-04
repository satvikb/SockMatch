//
//  SettingView.h
//  sock match
//
//  Created by Satvik Borra on 8/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "Functions.h"
@interface SettingView : UIView

typedef void (^SettingTouch)(void);

-(id)initWithFrame:(CGRect)frame settingType:(SettingTypes)type;
-(void)updateSetting:(SettingTypes)type;

@property (nonatomic, copy) SettingTouch touchBeganBlock;

@end
