//
//  inputHelper.h
//  AutoClickTest
//
//  Created by Weidong2 on 2018/6/13.
//  Copyright © 2018年 LUXShare-ICT. All rights reserved.
//
#import <Carbon/Carbon.h>
//在某点点击鼠标左键
void mouseButtonLeftClick(CGPoint *pt);
//模拟键盘输入字符串 flags=0
void writeStringHelper(NSString *valueToset, int flags);
//快捷键command + i kVK_ANSI_I
void clickCommandAndChar(int keycode);
//模拟输入某个按键 kVK_ANSI_I
void clickSingleChar(int keycode);

void PostMouseEvent(CGMouseButton button, CGEventType type, CGPoint *point)
{
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, *point, button);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}
void mouseButtonLeftClick(CGPoint *pt)
{
    PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseDown, pt);
    PostMouseEvent(kCGMouseButtonLeft, kCGEventLeftMouseUp, pt);
    [NSThread sleepForTimeInterval:0.2f];
}

void writeStringHelper(NSString *valueToSet, int flags)
{
    UniChar buffer;
    CGEventRef keyEventDown = CGEventCreateKeyboardEvent(NULL, 1, true);
    CGEventRef keyEventUp = CGEventCreateKeyboardEvent(NULL, 1, false);
    CGEventSetFlags(keyEventDown,0);
    CGEventSetFlags(keyEventUp,0);
    for (int i = 0; i < [valueToSet length]; i++) {
        [valueToSet getCharacters:&buffer range:NSMakeRange(i, 1)];
        CGEventKeyboardSetUnicodeString(keyEventDown, 1, &buffer);
        CGEventSetFlags(keyEventDown,flags);
        CGEventPost(kCGSessionEventTap, keyEventDown);
        CGEventKeyboardSetUnicodeString(keyEventUp, 1, &buffer);
        CGEventSetFlags(keyEventUp,flags);
        CGEventPost(kCGSessionEventTap, keyEventUp);
        
    }
    CFRelease(keyEventUp);
    CFRelease(keyEventDown);
    [NSThread sleepForTimeInterval:0.2f];
}
void clickCommandAndChar(int keycode)
{
    //command＋i kVK_ANSI_I
    
    CGEventRef push = CGEventCreateKeyboardEvent(NULL, keycode, true);
    
    CGEventSetFlags(push, kCGEventFlagMaskCommand);
    
    CGEventPost(kCGHIDEventTap, push);
    CFRelease(push);
    [NSThread sleepForTimeInterval:0.2f];
}
void clickSingleChar(int keycode)
{
    CGEventRef push = CGEventCreateKeyboardEvent(NULL, keycode, true);
    
    CGEventPost(kCGHIDEventTap, push);
    
    CFRelease(push);
    [NSThread sleepForTimeInterval:0.2f];
}
