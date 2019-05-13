;prompt to overrite

;User variables. 1 = yes. 0 = no.
	;Behaviour
		MonitoredFolder = D:\Downloads
		HowOftenToScanInSeconds = 60 ;How long we wait before re-scanning the folder for any changes.
		ToolTips = 1 ;Show helper popups showing what the program is doing.
		OverWrite = 1 ;Overwrite duplicate files?

	;Zip files
		7ZipLocation = C:\Program Files\Easy 7-Zip\7z.exe ;Needed to provide unzipping functionality.
		OpenExtractedZip = True ;Open the folder up after extraction has finished?
		DeleteZipFileAfterExtract = 1 ;Recycle the zip file after a successful extract.
		UnzipSuccessSound = 1 ;Play a jingle when unzipped something.

	;File types (In quotation marks, seperated by comma)
		ZipExt := ["zip","7z","rar","r00","001"]
		ImageExt := ["jpg","bmp","gif","gifv","webm","png","jpeg","swf","tga","tiff","exr","psd"]
		DocumentExt := ["txt","nfo","rtf","pdf","docx","doc"]
		AudioExt := ["mp3","flac","wav"]
		VideoExt := ["avi","mpg","mpeg","mov","mp4","mkv","wmv"]
		ProgramsExt := ["exe","msi","jar","cmd","bat","ahk"]
		DiscImageExt := ["iso","mdf","bin","cue"]

		;Destination folders
			UnzipTo = %MonitoredFolder%\Compressed ; Note: Will also make a sub-dir in the name of the zipfile. eg: pies.rar will become a folder called pies, with the rar contents inside.
			MoveVideosTo = %MonitoredFolder%\Videos
			MoveImagesTo = %MonitoredFolder%\Images
			MoveDiscImagesTo = %MonitoredFolder%\ISO
			MoveProgramsTo = %MonitoredFolder%\Programs
			MoveAudioTo = %MonitoredFolder%\Audio
			MoveDocumentsTo = %MonitoredFolder%\Documents

;End user variables




















;Init stuff
	#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
	; #Warn  ; Enable warnings to assist with detecting common errors.
	SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
	SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	#SingleInstance Force


;Start the folder monitor
	WaitTimeBetweenScans := HowOftenToScanInSeconds * 1000
	SetTimer, SearchFiles, %WaitTimeBetweenScans%
	GoSub,SearchFiles ; Immediately do a scan
	return

;Main Code
	SearchFiles:
		;Zipped files
		For index, value in ZipExt {
			Loop, Files, %MonitoredFolder%\*.%value%
				UnZip(A_LoopFileName,A_LoopFileDir,A_LoopFileFullPath)
			;Extra folders to scan
				;Loop, Files, %MonitoredFolder%\Compressed\*.%value%
					;UnZip(A_LoopFileName,A_LoopFileDir,A_LoopFileFullPath)
				;Loop, Files, %MonitoredFolder%\Torrents\Completed Torrents\*.%value%, F R
					;	UnZip(A_LoopFileName,A_LoopFileDir,A_LoopFileFullPath)

		}

		;Media files
			ScanForChangedFiles(ImageExt,MoveImagesTo,OverWrite) ;You can change overwriting on a per filetype basis if you want. Change OverWrite to 1 for on, 0 for off.
			ScanForChangedFiles(DocumentExt,MoveDocumentsTo,OverWrite)
			ScanForChangedFiles(AudioExt,MoveAudioTo,OverWrite)
			ScanForChangedFiles(VideoExt,MoveVideosTo,OverWrite)
			ScanForChangedFiles(ProgramsExt,MoveProgramsTo,OverWrite)
			ScanForChangedFiles(DiscImageExt,MoveDiscImagesTo,OverWrite)
			ScanForChangedFiles(ImageExt,MoveImagesTo,OverWrite)
		return









;Functions
	UnZip(FileFullName,Dir,FullPath)
	{
		global 7ZipLocation ;Saves having to re-pass this dir each time you use this function.
		global DeleteZipFileAfterExtract
		global OpenExtractedZip
		global Tooltips
		global UnzipTo
		global UnzipSuccessSound
		;Get filename
			StringGetPos,ExtentPos,FileFullName,.,R
			FileName := SubStr(FileFullName,1,ExtentPos)
			if Tooltips
			{
				Tooltip,Unzipping %FileName% > %Dir%\%FileName%
				SetTimer, RemoveToolTip, 3000
			}
			MakeFolderIfNotExist(UnzipTo . "\" . FileName)
			Runwait, "%7ZipLocation%" x "%FullPath%" -o"%UnzipTo%\%FileName%"
		sleep,2000
		IfExist %UnzipTo%\%FileName%
		{
			if DeleteZipFileAfterExtract
				Filerecycle, %FullPath%
			if OpenExtractedZip
				run, %UnzipTo%\%FileName%
			if UnzipSuccessSound
				soundplay, *64
		}
		else
			msgbox,,Oh Noes!,Something went wrong and I couldn't unzip %FileName% to %UnzipTo%\%FileName%
	}

	ScanForChangedFiles(ExtensionToScanArray,DestinationFolder,OverWriteFiles)
	{
		global MonitoredFolder ;Need to grab this global, saves having to pass it everytime to this function.
		global Tooltips
		For index, value in ExtensionToScanArray
		{
			Loop, Files, %MonitoredFolder%\*.%value% ;Loop files which match the current value of array index. Never returns false.
			{
				MakeFolderIfNotExist(DestinationFolder) ;Make the folder if it doesn't exist.
				FileMove,%A_LoopFileFullPath%,%DestinationFolder%\*.*,%OverWriteFiles% ; *.* is needed else it could be renamed to no extension! (If dest folder failed)
				if Tooltips
				{
					Tooltip,Moving %A_LoopFileName% > %DestinationFolder%
					SetTimer, RemoveToolTip, 3000
				}
				sleep,500 ;Sleep between moves.
			}
		}
	}

	MakeFolderIfNotExist(TheFolderDir)
	{
		ifnotexist,%TheFolderDir%
			FileCreateDir,%TheFolderDir%
	}

	RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
	return

^Esc::ExitApp
