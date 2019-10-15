//
//  AppDelegate.m
//  ControlMe
//
//  Created by 曹伟东 on 2019/1/26.
//  Copyright © 2019年 曹伟东. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    int displayH;
    NSTimer *mouseXYtimer;
    
    NSLock *_lock;
    NSString *_logString;
    
    NSString *OwnerName;
    NSString *appName;
}
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    _lock=[[NSLock alloc] init];
    displayH = getDisplayHeight();
    _logString=@"";
    
}


-(IBAction)scanAppBtnAction:(id)sender{
    NSArray *WinOwnerNameList=scanOpenWin();
    for (NSString *name in WinOwnerNameList) {
        [self logUpdate:name];
    }
}
-(IBAction)launchAppBtnAction:(id)sender{
    appName=[_appNameTF stringValue];
    if ([appName length] == 0) {
        [self printAlarmWindow:@"AppName ERROR!"];
    }
    //launch App
    bool result=[[NSWorkspace sharedWorkspace] launchApplication:appName];
    NSLog(@"launchApp:%@ result:%d",appName,result);
    [self logUpdate:[NSString stringWithFormat:@"launchApp:%@ result:%d",appName,result]];
}
-(IBAction)terminateAppAction:(id)sender{
    OwnerName=[_winOwnerNameTF stringValue];
    if ([OwnerName length] == 0) {
        [self printAlarmWindow:@"OwnerName ERROR!"];
    }
    //terminal test App
    [NSThread detachNewThreadSelector:@selector(terminateAppThread) toTarget:self withObject:nil];
}
-(void)terminateAppThread{
    [self logUpdate:[NSString stringWithFormat:@"terminate:%@",OwnerName]];
    bool result=terminateApp(OwnerName);
    [self logUpdate:[NSString stringWithFormat:@"terminate:%@ result:%d",OwnerName,result]];
}
-(IBAction)monitorXYBtnAction:(id)sender{
    if([[_monitorXYBtn title] isEqualToString:@"Start"]){
        mouseXYtimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(printMouseXY) userInfo:nil repeats:YES];
        [_monitorXYBtn setTitle:@"Stop"];
        [_mouseXlabel setBackgroundColor:[NSColor greenColor]];
        [_mouseYlabel setBackgroundColor:[NSColor greenColor]];
    }else{
        [mouseXYtimer invalidate];
        mouseXYtimer = nil;
        [_monitorXYBtn setTitle:@"Start"];
        [_mouseXlabel setBackgroundColor:[NSColor whiteColor]];
        [_mouseYlabel setBackgroundColor:[NSColor whiteColor]];
    }
}
-(void)printMouseXY{
    NSPoint p=[NSEvent mouseLocation];
    [_mouseXlabel setStringValue:[NSString stringWithFormat:@"X:%.f",p.x]];
    [_mouseYlabel setStringValue:[NSString stringWithFormat:@"Y:%.f",(displayH-p.y)]];
}
-(IBAction)testBtnAction:(id)sender{
    _logString=@"";
    NSString *cmd=[_cmdTF stringValue];
    if([cmd length] == 0){
        [self printAlarmWindow:@"CMD ERROR!"];
        return;
    }
    //window owner name
    OwnerName=[_winOwnerNameTF stringValue];
    if ([OwnerName length] == 0) {
        [self printAlarmWindow:@"OwnerName ERROR!"];
        return;
    }
    // get app name
    appName=[_appNameTF stringValue];
    if ([appName length] == 0) {
        [self printAlarmWindow:@"AppName ERROR!"];
        return;
    }
    
    [NSThread detachNewThreadSelector:@selector(testAsyncThread:) toTarget:self withObject:cmd];
}
-(void)testAsyncThread:(NSString *)cmd{
    bool launchAppAndMoveOK = true;
    
    CGPoint point = CGPointMake(0, 0);
    //移动窗体至(0,0),并置前显示
    if(!moveWin2Position(OwnerName, &point)){
        //[self printAlarmWindow:@"Move win fail,please check setting!"];
        [self logUpdate:[NSString stringWithFormat:@"first move win:%@ fail",OwnerName]];
        //launch App
        bool result=[[NSWorkspace sharedWorkspace] launchApplication:appName];
        NSLog(@"launchApp:%@ result:%d",appName,result);
        [self logUpdate:[NSString stringWithFormat:@"launchApp:%@ result:%d",appName,result]];
        [NSThread sleepForTimeInterval:0.5f];
        
        //move to (0,0) and active window
        result=moveWin2Position(OwnerName, &point);
        [self logUpdate:[NSString stringWithFormat:@"move win:%@ result:%d",OwnerName,result]];
        launchAppAndMoveOK=result;
    }else{
        [self logUpdate:[NSString stringWithFormat:@"Move win:%@ successful",OwnerName]];
    }
    
    if(!launchAppAndMoveOK){
        [self logUpdate:@"Launch app and move operation FAIL!"];
        return;
    }
    
    //cmd:M:120,125@D:0.1@T:Hello world!@M:125,35
    NSArray *cmdArray=[cmd componentsSeparatedByString:@"@"];
    for (int i=0; i<[cmdArray count]; i++) {
        NSString *thisCommand=[cmdArray objectAtIndex:i];
        [self logUpdate:[NSString stringWithFormat:@"command:%@",thisCommand]];
        
        if([thisCommand isEqualToString:@""]) continue;
        //move to (x,y) click
        if ([thisCommand hasPrefix:@"M:"] && [thisCommand containsString:@","] ) {
            NSString *tempXY=[thisCommand substringFromIndex:2];
            NSArray *arryXY=[tempXY componentsSeparatedByString:@","];
            int intX=[arryXY[0] intValue];
            int intY=[arryXY[1] intValue];
            point=CGPointMake(intX, intY);
            //鼠标到达位置,click start button
            mouseButtonLeftClick(&point);
            [self logUpdate:[NSString stringWithFormat:@"Move to X1:%d Y1:%d Click ",intX,intY]];
        }
        //input string
        else if([thisCommand hasPrefix:@"T:"]){
            NSString *inputStr=[thisCommand substringFromIndex:2];
            //鼠标到达位置，删除输入框内容
            //mouseButtonLeftClick(&pt);
            clickCommandAndChar(kVK_ANSI_A);
            clickSingleChar(kVK_Delete);
            //向输入框写入command
            writeStringHelper(inputStr, 0);
            [self logUpdate:[NSString stringWithFormat:@"input:%@",inputStr]];
        }
        //delay seconds
        else if([thisCommand hasPrefix:@"D:"]){
            NSString *subStr=[thisCommand substringFromIndex:2];
            float delayT=[subStr floatValue];
            [NSThread sleepForTimeInterval:delayT];
            [self logUpdate:[NSString stringWithFormat:@"delay:%f s Done",delayT]];
        }
        [NSThread sleepForTimeInterval:0.2f];
    }
    [self logUpdate:@"Action all commands!"];
}



-(void)logUpdate:(NSString *)log{
    [_lock lock];
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setDateFormat:@"[yyyy-MM-dd HH:mm:ss.SSS]"];
    
    NSString *dateText=[NSString string];
    dateText=[dateFormat stringFromDate:[NSDate date]];
    //dateText=[dateText stringByAppendingString:@"\n"];
    //_logString = [_logString stringByAppendingString:@"\r\n==============================\r\n"];
    _logString = [_logString stringByAppendingString:dateText];
    _logString = [_logString stringByAppendingString:log];
    _logString = [_logString stringByAppendingString:@"\r\n"];
    
    [self performSelectorOnMainThread:@selector(addLogOnMainThread) withObject:nil waitUntilDone:YES];
    //if([self._logString length] >10000) self._logString=@"";
    NSLog(@"%@",log);
    [_lock unlock];
}
-(void)addLogOnMainThread{
    [_logTV setString:_logString];
    [_logTV scrollRangeToVisible:NSMakeRange([[_logTV textStorage] length],0)];
    [_logTV setNeedsDisplay: YES];
}
-(long)printAlarmWindow:(NSString *)info{
    NSLog(@"start run window");
    NSAlert *theAlert=[[NSAlert alloc] init];
    [theAlert addButtonWithTitle:@"OK"]; //1000
    //[theAlert addButtonWithTitle:@"No"]; //1001
    
    [theAlert setMessageText:@"Alarm!"];
    [theAlert setInformativeText:info];
    [theAlert setAlertStyle:0];
    //[theAlert setIcon:[NSImage imageNamed:@"alarm1.png"]];
    
    NSLog(@"End run window");
    // [theAlert beginSheetModalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    //int choice = [theAlert runModal];
    
    return [theAlert runModal];
    
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(void)windowShouldClose:(id)sender{
    NSLog(@"ControlMe window close...");
    [NSApp terminate:self];
}

@end
