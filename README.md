# Automatic Folder Monitor & File Sorter
## Overview:

This tool takes the hassle out of manually sorting your downloads folder, or any other folder you tend to just throw files into.
It will move files that fall under a category to a specified subfolder. It will also auto-unzip any zipped files for you.
So you can assign a bulk set of image extensions, and any time the script sees one in your monitored folder, it will move it to your "Images" folder.
Eg: photo.jpg > Photos folder\photo.jpg. ZipFile.7z > ZipFile\*.*

Fully customizable to suit your needs!


## Initial Setup
1. Download and install 7zip or easy-7Zip
2. Open the .ahk file in a text editor.
3. Change the "MonitoredFolder" value near the top of the script to point to the folder that you want to be monitored for changes.
4. Change "HowOftenToScanInSeconds" To how often it should check if anything within the folder has changed.
5. Change the "7ZipLocation" to point to where your 7zip's 7z.exe is.
6. Under the "Destination folders" section, you can change where files that match a specific file type will be placed. Eg MoveImagesTo = %MonitoredFolder%\Images

## Adding more file types to a category
1. Under the "File types" heading, add any extensions that you particularly want to be assigned to a that category. Eg:	ZipExt := ["zip","7z","rar","r00","001"] could become 		ZipExt := ["zip","7z","rar","r00","001","NEWEXT1","NEWEXT2","NEWEXT3"]

## Adding custom categories
1. If you want more categories, add them under the "File types" section. Define the name of the category, followed by a comma seperated list in brackets of extensions that that category should contain. Eg: ZipExt := ["zip","7z","rar","r00","001"]
2. And then under the "Media files" section, add	ScanForChangedFiles(CATEGORY_NAME,TARGET_FOLDER,OverWrite) onto a new line.
3. Change CATEGORY_Name to what you just named your custom category.
4. Change TARGET_FOLDER to where you'd like them to go. Eg: "C:\Downloads\" (without quotes) or you can use "%MonitoredFolder%\MyCustomCategory" (without quotes) To make them go to a folder called "MyCustomCategory" that's within your monitored folder.
