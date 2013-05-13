# crlang.pl
# This file contains English-language messages for Coranto.
# Do not translate this file; see the Coranto website for more information on
# how to translate Coranto's messages into a foreign language.

$crlangVersion = 1;

%Messages = (
'ContentType' => q~<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">~, # If your language needs a different character set, you may have to change this tag.
'LoggedIn' => q~You are logged in as user~, # Used as: You are logged in as user (name).
'Section_MainPage' => q~Main Page~,
'MainPage_YourVersion' => q~Your Version:~,
'MainPage_CurrentVersion' => q~Current Version:~,
'Section_Submit' => q~Submit News~,
'Section_Modify' => q~Modify News~,
'Section_Build' => q~Build News~,
'Section_UserInfo' => q~User Info~,
'Section_LogOut' => q~Log Out~,
'BackTo' => q~Back to~, # Used as: Back to (site name)
'Desc_Submit' => q~Create a new news item and add it to the database.~, # The description on the main page for Submit News
'Desc_Modify' => q~Remove or edit existing news items.~,
'Desc_Modify_High' => q~You may edit any news items, including those submitted by others.~,
'Desc_Modify_Std' => q~You may only edit items that you have previously submitted.~,
'Desc_Build' => q~Generate news HTML files from the database. News must be built before any new or changed items will appear on your site.~,
'Desc_UserInfo' => q~Change information associated with your user account, such as your password.~,
'Desc_LogOut' => q~Log out of Coranto. You will have to enter your username and password to gain access again.~,
'Submit' => q~Submit~,
'Reset' => q~Reset~,
'Date' => q~Date~,
'User' => q~User~,
'Category' => q~Category~,
'Preview' => q~Preview~, # Used as a verb, not a noun. (it's a label on a button)
'Search' => q~Search~, # Also used as a verb.
'Go' => q~Go~, # Again, a button label.
'Edit' => q~Edit~,
'Save' => q~Save Changes~,
'SaveNews_Title' => q~News Saved~,
'SaveNews_Message' => q~The submitted news item has been added to the database.~,
'SaveNews_Message_Auto' => q~<b>Build News has been run automatically</b>, so the item should be visible on your site immediately.~,
'SaveNews_Message_NoAuto' => q~<b>You must build news</b> before this item will be visible on your site.~,
'Build_Title' => q~News Built~,
'Build_Message' => q~News HTML files have been built from the database. This means that your site should now reflect any new or changed items.~,
'DisplayLink' => q~Powered by~,
'Modify_Search' => q~Search for~, # Used as: Search for (text box) in field (select box).
'Modify_SearchIn' => q~in field~,
'Modify_Jump' => q~Jump to:~, # Used as: Jump to: (date select boxes)
'Modify_Del' => q~Del.~, # An abbreviation for Delete, used to label the checkbox column in Modify News.
'Modify_DelButton' => q~Delete Checked Items~,
'Modify_Next' => q~Next Page~,
'Modify_None' => q~No items could be found.~,
'ModifySave_Title' => q~Changes Saved~,
'ModifySave_Message' => q~Your changes to this item have been saved. Now, close this window to return to Modify News.~,
'ModifySave_Message_Auto' => q~<b>Build News has been run automatically</b>, so your changes should be visible on your site immediately.~,
'ModifySave_Message_NoAuto' => q~<b>You must build news</b> before your changes will be visible on your site.~,
'UserInfo_PassChange' => q~Change Password~,
'UserInfo_PassChange_Message' => q~Leave the password fields blank if you don't want to change your password.~,
'UserInfo_Pass_1' => q~Current Password~,
'UserInfo_Pass_2' => q~New Password~,
'UserInfo_Pass_3' => q~Verify New Password~,
'UserInfo_Profile' => q~Edit User Profile~,
'UserInfo_Error_1' => q~The current password that you entered is not correct.~,
'UserInfo_Error_2' => q~The passwords entered do not match. Please type in your new password again, and retype it in the "Verify Password" field.~,
'UserInfo_Error_3' => q~Passwords must be at least 5 characters long.~,
'UserInfoSave_Title' => q~User Info Saved~,
'UserInfoSave_Message' => q~Changes to your user info have been saved. If you changed your password, you will be asked to log in again once you move to another page. If you changed other information, you may need to build news before changes appear on your site.~,
'LogOut_Message' => q~You have been logged out.~
);

1;

