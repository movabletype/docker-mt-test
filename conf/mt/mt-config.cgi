## Movable Type Configuration File
##
## This file defines system-wide
## settings for Movable Type. In 
## total, there are over a hundred 
## options, but only those 
## critical for everyone are listed 
## below.
##
## Information on all others can be 
## found at:
##  https://www.movabletype.org/documentation/config

#======== REQUIRED SETTINGS ==========

CGIPath        /cgi-bin/
StaticWebPath  /mt-static/
StaticFilePath /var/www/html/mt-static

#======== DATABASE SETTINGS ==========

ObjectDriver DBI::mysql
Database mt
DBUser mt
DBPassword test
DBHost mysql
DBPort 3306

#======== MAIL =======================
EmailAddressMain admin@localhost.localdomain

ImageDriver ImageMagick

DebugMode 5
