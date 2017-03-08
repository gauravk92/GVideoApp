//
//  GVWebBrowserViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/3/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVWebBrowserViewController.h"

@interface GVWebBrowserViewController () <UIWebViewDelegate>

@end

@implementation GVWebBrowserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gvideoapp.com"]]];
    self.webView.delegate = self;
}


#pragma mark - WebView delegate methods 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {

}
- (void)webViewDidFinishLoad:(UIWebView *)webView {

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Web Page Load Error" message:@"There was an error loading the web page. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    });

}

@end
