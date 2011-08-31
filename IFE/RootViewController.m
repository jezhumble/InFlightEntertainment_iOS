//
//  RootViewController.m
//  IFE
//
//  Created by Jez Humble on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "Movie.h"

@implementation RootViewController

@synthesize IFEList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.IFEList = [NSMutableArray array];

    self.tableView.rowHeight = 48.0;
    self.title = @"Movies";
    [self addObserver:self forKeyPath:@"IFEList" options:0 context:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [IFEList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSUInteger const kNameLabelTag = 2;
    static NSUInteger const kInfoLabelTag = 3;
    static NSUInteger const kRatingLabelTag = 4;
    
    UILabel *nameLabel = nil;
    UILabel *infoLabel = nil;
    UILabel *ratingLabel = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, 250, 20)] autorelease];
        nameLabel.tag = kNameLabelTag;
        nameLabel.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:nameLabel];
        
        infoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 28, 250, 14)] autorelease];
        infoLabel.tag = kInfoLabelTag;
        infoLabel.font = [UIFont systemFontOfSize:10];
        [cell.contentView addSubview:infoLabel];

        ratingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(270, 3, 48, 42)] autorelease];
        ratingLabel.tag = kRatingLabelTag;
        ratingLabel.font = [UIFont boldSystemFontOfSize:30];
        [cell.contentView addSubview:ratingLabel];

    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:kNameLabelTag];
        infoLabel = (UILabel *)[cell.contentView viewWithTag:kInfoLabelTag];
        ratingLabel = (UILabel *)[cell.contentView viewWithTag:kRatingLabelTag];
    }
    
    // Configure the cell.
    Movie *movie = [IFEList objectAtIndex:indexPath.row];
    nameLabel.text = movie.name;
    infoLabel.text = [NSString stringWithFormat:@"%u (%um) %@", movie.year, movie.runtime, movie.genre];
    ratingLabel.text = [NSString stringWithFormat:@"%.1f", movie.rating];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Movie *movie = [IFEList objectAtIndex:indexPath.row];
    NSURL *link = [movie imdbWebLink];
    [[UIApplication sharedApplication] openURL:link];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.IFEList = nil;
    [self removeObserver:self forKeyPath:@"IFEList"];
}


- (void)dealloc
{
    [IFEList release];

    [super dealloc];
}

#pragma mark -
#pragma mark KVO support

- (void)insertMovies:(NSArray *)movies
{
    // this will allow us as an observer to notified (see observeValueForKeyPath)
    // so we can update our UITableView
    //
    [self willChangeValueForKey:@"IFEList"];
    [self.IFEList addObjectsFromArray:movies];
    [self didChangeValueForKey:@"IFEList"];
}

// listen for changes to the IFE list coming from our app delegate.
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self.tableView reloadData];
}

@end
