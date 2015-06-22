//
//  ViewController.m
//  NewVagabond
//
//  Created by Sridatt Bhamidipati on 4/4/15.
//  Copyright (c) 2015 SRI. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Firebase/Firebase.h>
//#import <FBSDKShareKit/FBRequestConnection.h>


@interface ViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UITextField *destination;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UITextField *hobbies;
@property (weak, nonatomic) IBOutlet UIView *ProfileView;
@property (weak, nonatomic) IBOutlet UILabel *facebookName;
@property (weak, nonatomic) IBOutlet UIImageView *profPic;

@property (strong, nonatomic) NSString *facebookNameText;
@property (strong, nonatomic) NSString *facebookIDText;
@property (strong, nonatomic) NSString *profPicURL;

@end

@implementation ViewController

- (IBAction)updateInfo:(id)sender {
    
    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://vagabondapp.firebaseio.com/"];
    
    NSDictionary *user = @{
                                    @"full_name" : _facebookNameText,
                                    @"destination": _destination.text,
                                    @"hobbies": _hobbies.text,
                                    @"profpic": _profPicURL
    };
    

    Firebase *usersRef = [myRootRef childByAppendingPath: _facebookIDText];
    
    [usersRef setValue: user];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.center = self.view.center;
    loginButton.delegate = self;
    [self.view addSubview:loginButton];
    
    loginButton.readPermissions = @[@"email", @"user_friends"];
    
//    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
//        // TODO: publish content.
//    } else {
//        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//        [loginManager logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//            NSLog(@"There is an error");
//        }];
//    } //TRYNA GET USER INFO
    
    

    
    _ProfileView.alpha = 0;

    
    _updateButton.layer.cornerRadius = 4.0;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self addGradientToButton];
}

-(void) addGradientToButton{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = _updateButton.layer.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithWhite:1.0f alpha:0.1f].CGColor,
                            (id)[UIColor colorWithWhite:0.4f alpha:0.5f].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    gradientLayer.cornerRadius = _updateButton.layer.cornerRadius;
    [_updateButton.layer addSublayer:gradientLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginButton:	(FBSDKLoginButton *)loginButton
didCompleteWithResult:	(FBSDKLoginManagerLoginResult *)result
               error:	(NSError *)error{
    //NSLog(@"logineed");
    
    _ProfileView.alpha = 1;

    loginButton.alpha = 0;
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                //NSLog(@"fetched user:%@", result);
                 NSDictionary *json = result;
                 
                 NSString *firstName = json[@"first_name"];
                 _facebookNameText = [firstName stringByAppendingString: @" "];
                 _facebookNameText = [_facebookNameText stringByAppendingString: json[@"last_name"]];
                 _facebookName.text = _facebookNameText;

                 _facebookIDText = json[@"id"];

                 _profPic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:
                        [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",json[@"id"] ]]]];
                 
                 _profPicURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",json[@"id"]];

             }
         }];
    }

}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    NSLog(@"logouted");
    _ProfileView.alpha = 0;
}
@end
