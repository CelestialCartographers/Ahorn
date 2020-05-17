const hotkeys = Hotkey[
    Hotkey(
        "ctrl + alt + shift + s",
        SettingsWindow.showSettings
    ),
    Hotkey(
        "ctrl + shift + s",
        showFileSaveDialog
    ),
    Hotkey(
        "ctrl + s",
        menuFileSave
    ),
    Hotkey(
        "ctrl + o",
        showFileOpenDialog
    ),
    Hotkey(
        "ctrl + n",
        createNewMap
    ),
    Hotkey(
        "ctrl + m",
        MetadataWindow.configureMetadata
    ),
    Hotkey(
        "ctrl + shift + t",
        RoomWindow.configureRoom
    ),
    Hotkey(
        "ctrl + t",
        RoomWindow.createRoom
    ),
    Hotkey(
        "ctrl + shift + z",
        History.redo!
    ),
    Hotkey(
        "ctrl + z",
        History.undo!
    ),
    Hotkey(
        "ctrl + f",
        focusFilterEntry!
    )
]