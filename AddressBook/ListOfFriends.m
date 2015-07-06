#import "ListOfFriends.h"
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ListOfFriends ()
{
    UIButton *addFriendButton;
    UIButton *sendInviteButton;
}
@property (weak, nonatomic) IBOutlet UILabel *refresh;
@property (weak, nonatomic) IBOutlet UIButton *syncContacts;
@property (strong, nonatomic) IBOutlet UIButton *addFriend;

@property (nonatomic, strong) NSMutableArray *arrContactsData;
@property (nonatomic, strong) NSMutableArray *insideFriends;
@property (nonatomic, strong) NSMutableArray *outsideFriends;
@property (nonatomic, strong) NSMutableArray *allFriends;
@property (nonatomic, strong) NSArray *arrayOfNumbers;
@property (nonatomic, strong) NSMutableArray *indexfortable;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@end

@implementation ListOfFriends

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;


//PFUser *currentUser = [PFUser currentUser];
    if ([PFUser currentUser]) {
        //NSLog(@"Current user: %@", currentUser.username);
    }
    else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    _refresh.hidden = YES;


 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GET CONTACTS FROM PARSE

- (void)updateNumbers
{
    

        _insideFriends = [[NSMutableArray alloc] init];


        _outsideFriends = [[NSMutableArray alloc] init];
    
    NSUInteger index = 0;
        
for (id data in _arrContactsData)
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:[self formatNumber:[data objectForKey:@"mobileNumber"]]];
    PFObject *user = [query getFirstObject];
    if ([user objectForKey:@"username"] != nil) {
        [_insideFriends addObject: data];
        
    }
    else{
        [_outsideFriends addObject: data];
        
    }
         index++;
}// end for loop
    NSLog(@"updatenumbers" );
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self.refreshControl endRefreshing];
    // open up refresh control
    if(self.refreshControl == nil)
    {
    _refresh.hidden = NO;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor grayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(syncContacts:)
                  forControlEvents:UIControlEventValueChanged];
    }

}
- (void)Parse
{
    NSLog(@"parse");
    for(id data in _arrContactsData)
    {
        

               
        NSMutableDictionary *friend = [[NSMutableDictionary alloc]
                                                initWithObjects:@[@"", @"", @""]
                                                forKeys:@[@"FirstName", @"LastName", @"Number"]];

                friend[@"FirstName"] = [data objectForKey:@"firstName"];
                friend[@"LastName"] = [data objectForKey:@"lastName"];
                friend[@"Number"] = [self formatNumber:[data objectForKey:@"mobileNumber"]];
       
                [[PFUser currentUser] addUniqueObject:friend forKey: @"Contacts"];
                [[PFUser currentUser] saveInBackground];

    }//end for loop
    [self updateNumbers];
}
-(void)findRelation
{
    PFQuery *gameQuery = [PFQuery queryWithClassName:@"Game"];
    [gameQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
}
#pragma mark - Hash number
-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
    
    
 
    
    NSInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        
    }
    
    
    return mobileNumber;
}

#pragma mark - Table View
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1. The view for the header
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    
    // 2. Set a custom background color and a border
    headerView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
    headerView.layer.borderWidth = 1.0;
     UILabel* headerLabel = [[UILabel alloc] init];
if(section == 0)
{
                headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
                headerLabel.backgroundColor = [UIColor clearColor];
                headerLabel.textColor = [UIColor whiteColor];
                headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
                headerLabel.text = @"Friends Inside";
                headerLabel.textAlignment = NSTextAlignmentCenter;
}
else{
   
    headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
    headerLabel.text = @"Friends Outside";
    headerLabel.textAlignment = NSTextAlignmentCenter;
    }
    // 3. Add a label

    
    // 4. Add the label to the header view
    [headerView addSubview:headerLabel];
    
    // 5. Finally return
    return headerView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        {
            return [_insideFriends count];
        }
    else
        {
            return [_outsideFriends count];
        }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSUInteger section = [indexPath section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(section == 0)
    {
        NSDictionary *contactInfoDict = [_insideFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [contactInfoDict objectForKey:@"firstName"], [contactInfoDict objectForKey:@"lastName"]];
        // add friend button
        addFriendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addFriendButton.frame = CGRectMake(213.0f, 5.0f, 100.0f, 30.0f);
        [addFriendButton setTitle:@"Add" forState:UIControlStateNormal];
        [cell addSubview:addFriendButton];
        [addFriendButton addTarget:self
                            action:@selector(addFriend:)
                  forControlEvents:UIControlEventTouchUpInside];
      
        return cell;
    }
    else
    {
        NSDictionary *contactInfoDict = [_outsideFriends objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [contactInfoDict objectForKey:@"firstName"], [contactInfoDict objectForKey:@"lastName"]];
        sendInviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendInviteButton.frame = CGRectMake(200, 5.0f, 100.0f, 30.0f);
        [sendInviteButton setTitle:@"Send Invite" forState:UIControlStateNormal];
        
        [cell addSubview:sendInviteButton];
        [sendInviteButton addTarget:self
                            action:@selector(sendInvite:)
                  forControlEvents:UIControlEventTouchUpInside];

        return cell;
    }
        
}

#pragma mark - get Contacts
- (IBAction)syncContacts:(id)sender {


 
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, error);
 
 
     if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
     ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
         if (granted) {
             CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
             CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBookRef);
             
             for(int i = 0; i < numberOfPeople; i++) {
                 NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                                         initWithObjects:@[@"", @"", @"", @""]
                                                         forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber"]];
                 ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                 
                 CFTypeRef generalCFObject = (ABRecordCopyValue(person, kABPersonFirstNameProperty));
                 CFTypeRef generalCFObject2 = (ABRecordCopyValue(person, kABPersonLastNameProperty));
                 
                 [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
                 CFRelease(generalCFObject);
                 
                 [contactInfoDict setObject:(__bridge NSString *)generalCFObject2 forKey:@"lastName"];
                 CFRelease(generalCFObject2);
                 
                 ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                 
                 for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                     CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                     CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                     
                     if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                         [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                     }
                     
                     else if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                         [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                     }
                     else if (CFStringCompare(currentPhoneLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
                         [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                     }
                     
                     CFRelease(currentPhoneLabel);
                     CFRelease(currentPhoneValue);
                 }
                 CFRelease(phoneNumbers);
                 // Initialize the array if it's not yet initialized.
                 if (_arrContactsData == nil) {
                     _arrContactsData = [[NSMutableArray alloc] init];
                 }
                 // Add the dictionary to the array.
                 _arrContactsData[i]=contactInfoDict;
                 
              

                 
                 
                 
             }
             
      [self Parse];
             

     } else {
         [self performSegueWithIdentifier:@"showLogin" sender:self];
     //SEND BACK TO LOG IN SCREEN
     }
     });
     }
     else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
         CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
         CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBookRef);
         
         for(int i = 0; i < numberOfPeople; i++) {
             NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                                     initWithObjects:@[@"", @"", @"", @""]
                                                     forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber"]];
             ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
             
             CFTypeRef generalCFObject = (ABRecordCopyValue(person, kABPersonFirstNameProperty));
             CFTypeRef generalCFObject2 = (ABRecordCopyValue(person, kABPersonLastNameProperty));
             
             [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
             CFRelease(generalCFObject);
             
             [contactInfoDict setObject:(__bridge NSString *)generalCFObject2 forKey:@"lastName"];
             CFRelease(generalCFObject2);
             
             ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
             
             for (CFIndex j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {
                 CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
                 CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                 
                 if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                     [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                 }
                 
                 else if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                     [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                 }
                 else if (CFStringCompare(currentPhoneLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
                     [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                 }
                 
                 CFRelease(currentPhoneLabel);
                 CFRelease(currentPhoneValue);
             }
             CFRelease(phoneNumbers);
             // Initialize the array if it's not yet initialized.
             if (_arrContactsData == nil) {
                 _arrContactsData = [[NSMutableArray alloc] init];
             }
             // Add the dictionary to the array.
             _arrContactsData[i]=contactInfoDict;
        
           
       
             
             
             
         }
           [self Parse];
     }
     else {
         [self performSegueWithIdentifier:@"showLogin" sender:self];
     }
    
  

    _syncContacts.hidden = YES;



}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    if (![PFUser currentUser]) {
 [self performSegueWithIdentifier: @"showLogin" sender:self];
    }
   
}

- (IBAction)addFriend:(id)sender
{
    [sender setTitle:@"Friend" forState:UIControlStateNormal];
    [sender setEnabled:NO];
  /*
   PFObject *friendofUser= [PFObject objectWithClassName:@"Friends"];
   [friendofUser setObject:[PFUser currentUser] forKey:@"friended"];*/
 
   NSLog(@"friend added");
}

- (IBAction)sendInvite:(id)sender
{
    [sender setTitle:@"Invite Sent" forState:UIControlStateNormal];
    [sender setEnabled:NO];
    /*PFObject *game= [PFObject objectWithClassName:@"Game"];
    [game setObject:[PFUser currentUser] forKey:@"createdBy"];
    [self.tableView reloadData];*/
}
@end
