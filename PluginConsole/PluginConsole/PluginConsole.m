//
//  PluginConsole.m
//  PluginConsole
//
//  Created by Александр Северьянов on 15.05.13.
//  Copyright (c) 2013 Александр Северьянов. All rights reserved.
//

#import "PluginConsole.h"
#import "IDEKit.h"
#import "LogClient.h"

typedef NS_ENUM(NSInteger, ConsoleMode) {
    ConsoleModeDefault = 0,
    ConsoleModePlugins,
};

@implementation PluginConsole


+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
}

- (id)init
{
    if (self = [super init]) {
        _windowsSet = [[NSMutableSet alloc] init];
        _buttons = [[NSMutableSet alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeWindowNotification:) name:NSWindowWillCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeNotification:) name:NSWindowDidUpdateNotification object:nil];
    }
    return self;
}

- (void)closeWindowNotification:(NSNotification *)note {
    NSWindow *window = note.object;
    if (window) {
        NSButton *button = nil;
        for (NSButton *btn in _buttons) {
            if (btn.window == window) {
                button = btn;
                break;
            }
        }
        if (button) {
            [_buttons removeObject:button];
        }
        [_windowsSet removeObject:window];
    }
}

- (void)activeNotification:(NSNotification *)notif
{
    for (NSWindow *window in [NSApp windows]) {
        if ([_windowsSet containsObject:window]) continue;
        NSView *contentView = window.contentView;
        IDEConsoleTextView *console = [self consoleViewInMainView:contentView];
        DVTScopeBarView *scopeBar = nil;
        NSView *parent = console.superview;
        while (!scopeBar) {
            if (!parent) break;
            scopeBar = [self scopeBarViewInView:parent];
            parent = parent.superview;
        }
        if (scopeBar) {
//            if (scopeBar.subviews.count > 3) continue;
            NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(10.0f, 10.0f, 100.f, 20.f)];
#if  !__has_feature(objc_arc)
            [button autorelease];
#endif
            [button setButtonType:NSOnOffButton];
            [button setBezelStyle:NSSmallSquareBezelStyle];
            [button setFont:[NSFont fontWithName:@"Helvetica" size:9.f]];
            [button setTitle:@"Show Log of Plugins"];
            button.target = self;
            button.action = @selector(buttonAction:);
            [scopeBar addViewOnRight:button];
            [_windowsSet addObject:window];
            [_buttons addObject:button];
        }
    }
}

- (void)buttonAction:(NSButton *)sender
{
    for (NSWindow *window in [NSApp windows]) {
        for (NSButton *btn in _buttons) {
            [btn setState:sender.state];
        }
    }
    if (sender.state == NSOnState) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLog:) name:PluginLoggerShouldLogNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PluginLoggerShouldLogNotification object:nil];
    }
}

- (void)addLog:(NSNotification *)notification
{
    for (NSWindow *window in [NSApp windows]) {
        NSView *contentView = window.contentView;
        IDEConsoleTextView *console = [self consoleViewInMainView:contentView];
        console.logMode = 1;
        [console insertText:notification.object];
        [console insertNewline:@""];
//        console.logMode = 0;
    }
}

- (IDEConsoleTextView *)consoleViewInMainView:(NSView *)mainView
{
    for (NSView *childView in mainView.subviews) {
        if ([childView isKindOfClass:NSClassFromString(@"IDEConsoleTextView")]) {
            return (IDEConsoleTextView *)childView;
        } else {
            NSView *v = [self consoleViewInMainView:childView];
            if ([v isKindOfClass:NSClassFromString(@"IDEConsoleTextView")]) {
                return (IDEConsoleTextView *)v;
            }
        }
    }
    return nil;
}

- (DVTScopeBarView *)scopeBarViewInView:(NSView *)view {
    for (NSView *childView in view.subviews) {
        if ([childView isKindOfClass:NSClassFromString(@"DVTScopeBarView")]) {
            return (DVTScopeBarView *)childView;
        } else {
            NSView *v = [self scopeBarViewInView:childView];
            if ([v isKindOfClass:NSClassFromString(@"DVTScopeBarView")]) {
                return (DVTScopeBarView *)v;
            }
        }
    }
    return nil;
}

- (void)dealloc
{
#if  !__has_feature(objc_arc)
    [_buttons release];
    [_windowsSet release];
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
