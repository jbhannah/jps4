# cruser.pl
# This file contains Coranto settings which, for one reason
# or another, couldn't be included in the web-based interface.
# (EXCEPTION: The Server Problems settings, which is 
# in coranto.cgi.)
#
# It is also the place to put any custom subroutines you have.

# ** RAW PERL IN NEWS STYLES **
# When editing news styles, it's possible to use raw Perl code
# enclosed inside <PerlCode>print 'code here';</PerlCode> tags.
# This is a useful and powerful feature if you know Perl, but can
# also be slightly dangerous: it allows anyone who can gain access
# to an Administrator-level account to run arbitrary commands on 
# your server. Set to 1 to enable this feature, 0 to disable.

$EnableRawPerl = 1;

# ** FILE LOCKING **
# File locking is a feature, provided by the operating system, which
# prevents possible serious problems when Coranto is being used by
# multiple users. Almost every operating system supports this, except
# for Windows 9x/ME. Possible settings:
# 2  Enable file locking. If you know your server supports it, set
#	UseFlock to this.
# 0  Disable file locking. This may result in file corruption.

$UseFlock = 2;

# ** NSETTINGS.CGI LOCATION **
# It is important that your nsettings.cgi is not visible over the Web.
# One way of accomplishing it is to move it to a different directory,
# and give it another name. You can set the following option to the new
# path of nsettings.cgi. Use an absolute path (no trailing slash).
# Example:
# $nsettingspath = '/usr/home/me/securefiles/coranto-settings-5432.cgi';

$nsettingspath = '';

# If you set $nsettingspath, you must also set $nsbkpath to the new
# path of nsbk.cgi, which is a backup of nsettings.cgi.

$nsbkpath = '';

# ** CRCFG.DAT LOCATION **
# While there's no danger in crcfg.dat being viewable over the web,
# you may need to move it to another directory. If so, specify a path
# below. As above, use an absolute path (no trailing slash).

$cfgpath = '';

# ** ADVANCED TIMING FEATURES **
# Don't change these settings unless you know exactly what you're doing.

# Lifespan of cookies, in seconds.
# 7776000 seconds is equal to 90 days.
$cookieExpLength = 7776000;
# Lifespan of sessions, in seconds.
# 7200 seconds = 2 hours
$SessionLength = 7200;

# ** INSERT CUSTOM SUBROUTINES HERE **
# Below is the place to put in any custom subroutines you have. (If you don't
# know what this means, just ignore this section.)










# ** END CUSTOM SUBROUTINE AREA **


1;
