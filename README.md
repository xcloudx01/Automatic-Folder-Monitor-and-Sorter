# Automatic Folder Monitor & File Sorter
## Overview:

This tool takes the hassle out of manually sorting your downloads folder, or any other folder you tend to just throw files into.
It will move files that fall under a category to a specified subfolder. It will also auto-unzip any zipped files for you.
So you can assign a bulk set of image extensions, and any time the script sees one in your monitored folder, it will move it to your "Images" folder.
Eg: photo.jpg > Photos folder\photo.jpg. ZipFile.7z > ZipFile\ZipFileContents*.*

Fully customizable to suit your needs!


## Initial Setup
1. Download and install 7zip or easy-7Zip (http://www.e7z.org/free-download.htm)
2. Download and install AutoHotKey (https://www.autohotkey.com/download/)
3. Open the .ahk file in a text editor.
4. Change the "MonitoredFolder" value near the top of the script to point to the folder that you want to be monitored for changes.
5. Change "UnzipTo" value to point to where you want zip files to be unzipped to.
5. Change "HowOftenToScanInSeconds" To how often it should check if anything within the folder has changed.
6. Change the "7ZipLocation" to point to where your 7zip's 7z.exe is.
7. Under the "Destination folders" section, you can change where files that match a specific file type will be placed. Eg MoveImagesTo = %MonitoredFolder%\Images

## Adding more file types to a category
1. Starting on Line 27, add in the file extension to the list of file extensions on the PushFiletypeToArray command. Eg. "jpeg" and use a comma to seperate the entries.

## Adding custom categories
1. Copy and paste this onto a new line just after the last one on line 32, and adjust the file types within the [ ] brackets, and label what folder they go into at the end to what you'd like to use.

PushFiletypeToArray(FiletypeObjectArray,["exe","msi","cmd"], "FolderNameGoesHere")

## Known issues.
1. Program may crash if attempting to unzip a file that is being stitched together currently by a download manager. This only tends to effect very large zip files.
