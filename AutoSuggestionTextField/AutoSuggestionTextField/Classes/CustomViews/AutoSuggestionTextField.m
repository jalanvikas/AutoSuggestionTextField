//
//  AutoSuggestionTextField.m
//  AutoSuggestionTextField
//
//  Created by Vikas Jalan on 14/12/14.
//  Copyright 2014 http://www.vikasjalan.com All rights reserved.
//  Conacts on jalanvikas@gmail.com or contact@vikasjalan.com
//
//  Get the latest version from here:
//  https://github.com/jalanvikas/AutoSuggestionTextField
//
//  * Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  * The name of Vikas Jalan may not be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY VIKAS JALAN "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AutoSuggestionTextField.h"

#define SUGGESTION_TABLE_HOLDER_VIEW_TAG 5002

#define MIN_CHARACTER_COUNT_FOR_SUGGESTION 2

#define AUTO_SUGGESTION_TABLE_HEIGHT 200


@interface AutoSuggestionTextField () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *suggestionTableView;
@property (nonatomic, strong) NSArray *suggestionItems;
@property (nonatomic, strong) NSArray *filteredSuggestionItems;

@property (nonatomic, assign) CGFloat maxViewHeight;
@property (nonatomic, assign) NSInteger noOfCharacterRequiredForSuggestion;

@property (nonatomic, strong) UIColor *autoSuggestTableBackgroundColor;
@property (nonatomic, strong) UIColor *autoSuggestTableCellColor;

#pragma mark - Private Methods

- (void)setupSuggestionView;

- (void)updateSuggestionForString:(NSString *)string;

- (void)shouldShowSuggestionView:(BOOL)show;

@end


@implementation AutoSuggestionTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupSuggestionView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSuggestionView];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setupSuggestionView
{
    self.autoSuggestTableBackgroundColor = [UIColor clearColor];
    self.autoSuggestTableCellColor = [UIColor whiteColor];
    self.maxViewHeight = AUTO_SUGGESTION_TABLE_HEIGHT;
    self.noOfCharacterRequiredForSuggestion = MIN_CHARACTER_COUNT_FOR_SUGGESTION;
    self.delegate = self;
    
    if (nil == self.suggestionTableView)
    {
        self.suggestionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, 0.0) style:UITableViewStylePlain];
        [self.suggestionTableView setDelegate:self];
        [self.suggestionTableView setDataSource:self];
        [self addSubview:self.suggestionTableView];
    }
    
    [self.suggestionTableView setHidden:YES];
    self.suggestionTableView.backgroundColor = self.autoSuggestTableBackgroundColor;
    self.suggestionTableView.layer.cornerRadius = 5.0;
    
    self.clipsToBounds = NO;
}

- (void)updateSuggestionForString:(NSString *)string
{
    if ([string length] >= self.noOfCharacterRequiredForSuggestion)
    {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", string];
        self.filteredSuggestionItems = [self.suggestionItems filteredArrayUsingPredicate:searchPredicate];
        
        if (0 < [self.filteredSuggestionItems count])
        {
            [self shouldShowSuggestionView:YES];
        }
        else
        {
            [self shouldShowSuggestionView:NO];
        }
    }
    else
    {
        [self shouldShowSuggestionView:NO];
    }
}

- (void)shouldShowSuggestionView:(BOOL)show
{
    if (!show && [self.suggestionTableView isHidden])
    {
        return;
    }
    
    CGFloat suggestionTableHeight = ((show)?(MIN(self.maxViewHeight, ([self.filteredSuggestionItems count] * self.bounds.size.height))):0.0f);
    CGRect suggestionTableFrame = CGRectMake(self.frame.origin.x, 0.0, self.bounds.size.width, suggestionTableHeight);
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (nil != keyWindow)
    {
        UIView *suggestionTableHolderView = [keyWindow viewWithTag:SUGGESTION_TABLE_HOLDER_VIEW_TAG];
        if (nil != suggestionTableHolderView)
        {
            CGRect frame = self.suggestionTableView.frame;
            frame.size.height = suggestionTableHeight;
            
            CGRect frm = [[self superview] convertRect:self.frame toView:keyWindow];
            frm.origin.y += self.bounds.size.height;
            
            if ((frm.origin.y + suggestionTableHeight) > keyWindow.bounds.size.height)
            {
                frame.origin.y = (frm.origin.y - self.bounds.size.height - suggestionTableHeight);
            }
            else
            {
                frame.origin.y = frm.origin.y;
            }
            
            self.suggestionTableView.frame = frame;
            [self.suggestionTableView reloadData];
        }
    }
    
    CGRect viewFrame = self.frame;
    viewFrame.size.height = ((0 < suggestionTableHeight)?suggestionTableHeight:self.bounds.size.height);
    if (suggestionTableHeight > 0)
    {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (nil != keyWindow)
        {
            CGRect frm = [[self superview] convertRect:self.frame toView:keyWindow];
            
            UIView *suggestionTableHolderView = [keyWindow viewWithTag:SUGGESTION_TABLE_HOLDER_VIEW_TAG];
            if (nil == suggestionTableHolderView)
            {
                suggestionTableHolderView = [[UIView alloc] initWithFrame:keyWindow.bounds];
            }
            else
            {
                [suggestionTableHolderView setFrame:keyWindow.bounds];
            }
            [suggestionTableHolderView setTag:SUGGESTION_TABLE_HOLDER_VIEW_TAG];
            [suggestionTableHolderView setBackgroundColor:[UIColor clearColor]];
            [suggestionTableHolderView addSubview:self.suggestionTableView];
            [keyWindow addSubview:suggestionTableHolderView];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            [tapGesture setDelegate:self];
            [suggestionTableHolderView addGestureRecognizer:tapGesture];
            
            suggestionTableFrame.origin = frm.origin;
            suggestionTableFrame.origin.y += self.bounds.size.height;
            [self.suggestionTableView setFrame:CGRectMake(frm.origin.x, suggestionTableFrame.origin.y, frm.size.width, self.suggestionTableView.bounds.size.height)];
            
            if ((suggestionTableFrame.origin.y + suggestionTableFrame.size.height) > keyWindow.bounds.size.height)
            {
                suggestionTableFrame.origin.y = (frm.origin.y - suggestionTableFrame.size.height);
            }
        }
    }
    
    if (show)
    {
        [self.suggestionTableView reloadData];
    }
    
    [self.suggestionTableView setHidden:((0 < suggestionTableHeight)?NO:[self.suggestionTableView isHidden])];
    if (![self.suggestionTableView isHidden])
        [[self superview] bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.suggestionTableView setFrame:suggestionTableFrame];
                     }completion:^(BOOL finished){
                         [self.suggestionTableView setHidden:((0 < suggestionTableHeight)?NO:YES)];
                         if ([self.suggestionTableView isHidden])
                         {
                             UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
                             if (nil != keyWindow)
                             {
                                 UIView *suggestionTableHolderView = [keyWindow viewWithTag:SUGGESTION_TABLE_HOLDER_VIEW_TAG];
                                 if (nil != suggestionTableHolderView)
                                 {
                                     [suggestionTableHolderView removeFromSuperview];
                                 }
                             }
                         }
                     }];
}

#pragma mark - Custom Methods

- (void)updateWithAvailableSuggestions:(NSArray *)suggestionItems
{
    self.suggestionItems = suggestionItems;
}

- (void)minimumCharacterRequiredForSuggestion:(NSInteger)characterCount
{
    self.noOfCharacterRequiredForSuggestion = characterCount;
}

- (void)setMaxHeightForAutoSuggestionView:(CGFloat)maxHeight
{
    self.maxViewHeight = maxHeight;
}

- (void)setAutoSuggestionTableColor:(UIColor *)tableColor
{
    self.autoSuggestTableBackgroundColor = tableColor;
    [self.suggestionTableView setBackgroundColor:self.autoSuggestTableBackgroundColor];
}

- (void)setAutoSuggestionTableCellColor:(UIColor *)tableCellColor
{
    self.autoSuggestTableCellColor = tableCellColor;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.bounds.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setText:[self.filteredSuggestionItems objectAtIndex:indexPath.row]];
    [self shouldShowSuggestionView:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.autoSuggestionDelegate respondsToSelector:@selector(selectedSuggestedString:)])
        [self.autoSuggestionDelegate selectedSuggestedString:[self.filteredSuggestionItems objectAtIndex:indexPath.row]];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredSuggestionItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AutoSuggestionItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [[cell textLabel] setTextColor:[self textColor]];
        [[cell textLabel] setFont:[self font]];
    }
    
    NSString *cellTitle = [self.filteredSuggestionItems objectAtIndex:indexPath.row];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [[cell textLabel] setText:cellTitle];
    
    [cell setBackgroundColor:self.autoSuggestTableCellColor];
    
    return cell;
}

#pragma mark - UIGestureRecognizer Methods

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    if (UIGestureRecognizerStateEnded == gesture.state)
    {
        [self shouldShowSuggestionView:NO];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (CGRectContainsPoint(self.suggestionTableView.frame, [touch locationInView:[self.suggestionTableView superview]]))
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.autoSuggestionDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
    {
        return [self.autoSuggestionDelegate textFieldShouldBeginEditing:textField];
    }
    else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.autoSuggestionDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
    {
        [self.autoSuggestionDelegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.autoSuggestionDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
    {
        return [self.autoSuggestionDelegate textFieldShouldEndEditing:textField];
    }
    else
        return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self shouldShowSuggestionView:NO];
    if ([self.autoSuggestionDelegate respondsToSelector:@selector(textFieldDidEndEditing:)])
    {
        [self.autoSuggestionDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChangeCharacter = YES;
    if ([self.autoSuggestionDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        shouldChangeCharacter = [self.autoSuggestionDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    if (shouldChangeCharacter)
    {
        [self updateSuggestionForString:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    }
    else
    {
        [self updateSuggestionForString:textField.text];
    }
    
    return shouldChangeCharacter;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    BOOL shouldClear = YES;
    if ([self.autoSuggestionDelegate respondsToSelector:@selector(textFieldShouldClear:)])
    {
        shouldClear = [self.autoSuggestionDelegate textFieldShouldClear:textField];
    }
    
    if (shouldClear)
    {
        [self updateSuggestionForString:@""];
    }
    
    return shouldClear;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self shouldShowSuggestionView:NO];
    if ([self.autoSuggestionDelegate respondsToSelector:@selector(textFieldShouldReturn:)])
    {
        return [self.autoSuggestionDelegate textFieldShouldReturn:textField];
    }
    else
        return YES;
}

@end
