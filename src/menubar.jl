const menubarChoices = Menubar.AbstractMenuItem[
    Menubar.MenuChoices(
        "File",
        Menubar.AbstractMenuItem[
            Menubar.MenuChoice("New", createNewMap, Image(icon_name="document-new-symbolic", size=:MENU)),
            Menubar.MenuChoice("Open", showFileOpenDialog, Image(icon_name="document-open-symbolic")),
            Menubar.MenuSeparator(),
            Menubar.MenuChoice("Save", menuFileSave, Image(icon_name="document-save-symbolic")),
            Menubar.MenuChoice("Save as", showFileSaveDialog, Image(icon_name="document-save-as-symbolic")),
            Menubar.MenuSeparator(),
            Menubar.MenuChoice("Exit", ExitWindow.exitAhorn, Image(icon_name="application-exit-symbolic")),
        ]
    ),
    Menubar.MenuChoices(
        "Edit",
        Menubar.AbstractMenuItem[
            Menubar.MenuChoice("Undo", History.undo!, Image(icon_name="edit-undo-symbolic")),
            Menubar.MenuChoice("Redo", History.redo!, Image(icon_name="edit-redo-symbolic")),
            Menubar.MenuSeparator(),
            Menubar.MenuChoice("Settings", SettingsWindow.showSettings, Image(icon_name="preferences-system-symbolic")),
        ]
    ),
    Menubar.MenuChoices(
        "View",
        Menubar.AbstractMenuItem[
            Menubar.MenuChoices(
                "RoomList",
                Menubar.AbstractMenuItem[
                    Menubar.MenuRadioGroup(
                        [
                            ("All", showAllRoomListColumns),
                            ("Room Name", showRoomListNameColumn),
                            ("None", hideAllRoomListColumns),
                        ],
                        getRoomListVisibilityRadioIndex
                    )
                ]
            ),
            Menubar.MenuSeparator(),
            Menubar.MenuCheck("Foreground Tiles", (w) -> setGlobalLayerVisiblity("fgTiles", w), true),
            Menubar.MenuCheck("Background Tiles", (w) -> setGlobalLayerVisiblity("bgTiles", w), true),
            Menubar.MenuCheck("Entities", (w) -> setGlobalLayerVisiblity("entities", w), true),
            Menubar.MenuCheck("Triggers", (w) -> setGlobalLayerVisiblity("triggers", w), true),
            Menubar.MenuCheck("Foreground Decals", (w) -> setGlobalLayerVisiblity("fgDecals", w), true),
            Menubar.MenuCheck("Background Decals", (w) -> setGlobalLayerVisiblity("bgDecals", w), true),
        ]
    ),
    Menubar.MenuChoices(
        "Map",
        Menubar.AbstractMenuItem[
            Menubar.MenuChoice("Stylegrounds", StylegroundWindow.createStylegroundWindow, Image(icon_name="document-page-setup-symbolic")),
            Menubar.MenuChoice("Metadata", MetadataWindow.configureMetadata, Image(icon_name="document-properties-symbolic")),
            Menubar.MenuSeparator(),
            Menubar.MenuChoice("Save Map Image", MapImageDumper.dumpMapImageDialog, Image(icon_name="image-x-generic-symbolic"))
        ]
    ),
    Menubar.MenuChoices(
        "Room",
        Menubar.AbstractMenuItem[
            Menubar.MenuChoice("Add", RoomWindow.createRoom, Image(icon_name="star-new-symbolic")),
            Menubar.MenuChoice("Configure", RoomWindow.configureRoom, Image(icon_name="system-run-symbolic")),
            Menubar.MenuSeparator(),
            Menubar.MenuChoice("Delete", deleteRoomCallback, Image(icon_name="edit-delete-symbolic")),
        ]
    ),
]

const menubarDebugChoices = Menubar.AbstractMenuItem[
    Menubar.MenuChoices(
        "Debug",
        Menubar.AbstractMenuItem[
            Menubar.MenuChoices(
                "Reload",
                Menubar.AbstractMenuItem[
                    Menubar.MenuChoice("Tools", (w) -> debug.reloadTools!()),
                    Menubar.MenuChoice("Entities", (w) -> debug.reloadEntities!()),
                    Menubar.MenuChoice("Triggers", (w) -> debug.reloadTriggers!()),
                    Menubar.MenuChoice("Effects", (w) -> debug.reloadEffects!()),
                    Menubar.MenuChoice("External Sprites", (w) -> loadAllExternalSprites!(force=true)),
                    Menubar.MenuChoice("Language Files", (w) -> debug.reloadLangdata()),
                ]
            ),
            Menubar.MenuChoice("Clear Map Render Cache", (w) -> debug.clearMapDrawingCache!()),
            Menubar.MenuChoice("Force Draw All Rooms", (w) -> debug.forceDrawWholeMap!()),
            Menubar.MenuChoice("Check Tooltip Coverage", (w) -> debug.checkTooltipCoverage()),
            Menubar.MenuChoice("Dump Sprites", SpriteDumperWindow.dumpSpritesDialog),
            Menubar.MenuChoice("Test Console", TestEvalWindow.showEvalWindow),
        ]
    )
]

const menubarEndChoices = Menubar.AbstractMenuItem[
    Menubar.MenuChoices(
        "Help",
        Menubar.AbstractMenuItem[
            Menubar.MenuChoice("Check for Updates", UpdateWindow.updateAhorn, Image(icon_name="software-update-available-symbolic")),
            Menubar.MenuChoice("About", AboutWindow.showAboutWindow, Image(icon_name="help-about-symbolic")),
        ]
    ),
]

menubar = Gtk.MenuBar()