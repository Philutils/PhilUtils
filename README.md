Who software developers have taken code here and there for their creation know we can win a lot of time by sharing. Sometimes also we lose time by copying half made stuff with no correct Error handling, there we lose time.

So here, Made with attention and Tested on Win97 Win XP Win 10 Word 13. Still todo is adapt API call #IF VBA for modern VBA.

KNOWNFOLDER s is discussed in Software has to do with Folders like Desktop, Music etc. See URL: https://learn.microsoft.com/en-us/windows/win32/shell/knownfolderid

It looks good and Microsoft did big progress since I know them BUT: I want my code to work on new AND old systems. Goal: From Win97 to  Win11 :) ... so if you look again at the Url above about KnownFolders, and you look on old systems, ... we also had a way to read registry and find the "Special" folders like Desktop MyDocuments. Now with Knownfolders as discribed in Ms documentation, we have access to more than 100 constants and GUID's that will referr to known folders.

With my way of programming I want my soft to continue working on old systems, so I integrate new with old and I get this Class KnownFolders with access on them on each system from Win97 to Win 11


So in KNOWNFOLDERS.cls, first it will be resolved the modern way using SHGetKnownFolderPath from kernel32. If this fails (on old computers), the passed KNOWNFOLDERID will be translated into the old naming we had in REgistry Current User ShellFolders and read there.

KnownFolders.cls uses X64X32.bas and Registry.cls (when no success with SHGetKnownFolderPath) and Registry uses WinApiError.bas for its messages.

Please enjoy the reading.

