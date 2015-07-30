
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>
#import "enterNumberViewController.h"
@interface ListOfFriends : UITableViewController <ABPeoplePickerNavigationControllerDelegate,UITableViewDelegate, UISearchDisplayDelegate>

- (IBAction)syncContacts:(id)sender;
- (IBAction)logout:(id)sender;



@property (nonatomic, strong) PFObject *friend;
@end
