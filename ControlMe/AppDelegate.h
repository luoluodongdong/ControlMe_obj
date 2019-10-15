//
//  AppDelegate.h
//  ControlMe
//
//  Created by 曹伟东 on 2019/1/26.
//  Copyright © 2019年 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "inputHelper.h"
#import "ScanWindowsTitle.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSTextField *_appNameTF;
    IBOutlet NSTextField *_winOwnerNameTF;
    IBOutlet NSButton *_scanAppBtn;
    IBOutlet NSButton *_launchAppBtn;
    IBOutlet NSButton *_terminateAppBtn;
    
    IBOutlet NSTextField *_mouseXlabel;
    IBOutlet NSTextField *_mouseYlabel;
    IBOutlet NSButton *_monitorXYBtn;
    
    IBOutlet NSTextField *_cmdTF;
    IBOutlet NSButton *_testBtn;
    
    IBOutlet NSTextView *_logTV;
}

-(IBAction)scanAppBtnAction:(id)sender;
-(IBAction)launchAppBtnAction:(id)sender;
-(IBAction)terminateAppAction:(id)sender;
-(IBAction)monitorXYBtnAction:(id)sender;
-(IBAction)testBtnAction:(id)sender;
@end

