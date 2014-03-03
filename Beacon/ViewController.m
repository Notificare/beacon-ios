//
//  ViewController.m
//  Beacon
//
//  Created by Joel Oliveira on 18/01/14.
//  Copyright (c) 2014 Joel Oliveira. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CBPeripheralManagerDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) CBPeripheralManager * peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic * transferCharacteristic;
@property (nonatomic, strong) NSMutableArray * logs;
@property (nonatomic, strong) NSString * uniqueIdentifier;
@property (nonatomic, strong) IBOutlet UITextView * uuidView;
@property (nonatomic, strong) IBOutlet UITextField * uuidField;
@property (nonatomic, strong) IBOutlet UITextField * majorField;
@property (nonatomic, strong) IBOutlet UITextField * minorField;
@property (nonatomic, strong) IBOutlet UITextField * idField;
@property (nonatomic, strong) IBOutlet UIButton * startButton;
@property (nonatomic, strong) IBOutlet UIButton * stopButton;
@property (nonatomic, strong) IBOutlet UITextView * logsLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setPeripheralManager:[[CBPeripheralManager alloc] initWithDelegate:self queue:nil]];
    [[self startButton] setHidden:NO];
    [[self stopButton] setHidden:YES];
    [[self uuidView] setEditable:NO];
    [[self logsLabel] setEditable:NO];
}

-(IBAction)startAdvertising:(id)sender{
    
    [self setUniqueIdentifier:[self getUUID]];
    [[self uuidView] setText:[NSString stringWithFormat:@"Advertising with UUID: %@", [self uniqueIdentifier]]];
    
    CLBeaconRegion * region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:[self uniqueIdentifier]] major:[[[self majorField] text] intValue] minor:[[[self minorField] text] intValue] identifier:[[self idField] text]];
    
    NSDictionary * peripheralData = [region peripheralDataWithMeasuredPower:nil];
    [[self peripheralManager] startAdvertising:peripheralData];
    
    [[self startButton] setHidden:YES];
    [[self stopButton] setHidden:NO];
    [[self idField] resignFirstResponder];
    [[self majorField] resignFirstResponder];
    [[self minorField] resignFirstResponder];
}

-(IBAction)stopAdvertising:(id)sender{
    
    [[self peripheralManager] stopAdvertising];
    
    [[self startButton] setHidden:NO];
    [[self stopButton] setHidden:YES];
    
    [[self logsLabel] setText:@""];
    [[self uuidView] setText:@""];
    [[self majorField] setText:@""];
    [[self minorField] setText:@""];
    [[self idField] setText:@""];
    [[self idField] resignFirstResponder];
    [[self majorField] resignFirstResponder];
    [[self minorField] resignFirstResponder];
}

-(NSString *)getUUID{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}


#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
}


-(void)addToLog:(NSString *)log{
    [[self logsLabel] setText:[NSString stringWithFormat:@"%@\n%@", [[self logsLabel] text], log]];
}


#pragma mark CBPeripheralManagerDelegates methods
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    [[self logs] addObject:peripheral];
    [self addToLog:@"peripheralManagerDidUpdateState"];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    [[self logs] addObject:central];
    [self addToLog:@"didSubscribeToCharacteristic"];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    [[self logs] addObject:error];
    [self addToLog:@"peripheralManagerDidStartAdvertising"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
