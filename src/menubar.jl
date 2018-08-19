menubarHeaders = ["File", "Edit", "Map", "Room", "Help", "Debug"]
menubarItems = [
    [
        ("New", createNewMap),
        ("Open", showFileOpenDialog),
        ("Save", menuFileSave),
        ("Save as", showFileSaveDialog),
        ("Exit", ExitWindow.exitAhorn),
    ],
    [
        ("Undo", History.undo!),
        ("Redo", History.redo!) 
    ],
    [
        ("Stylegrounds", StylegroundWindow.editStylegrounds),
        ("Metadata", MetadataWindow.configureMetadata),
        ("Save Map Image", MapImageDumper.dumpMapImageDialog)
    ],
    [
        ("Add", RoomWindow.createRoom),
        ("Configure", RoomWindow.configureRoom),
    ],
    [
        ("Check for Updates", UpdateWindow.updateAhorn),
        ("About", AboutWindow.showAboutWindow),
    ],
    [
        ("Reload Tools", (w) -> debug.reloadTools!()),
        ("Reload Entities", (w) -> debug.reloadEntities!()),
        ("Reload Triggers", (w) -> debug.reloadTriggers!()),
        ("Reload External Sprites", (w) -> loadExternalSprites!()),
        ("Clear Map Render Cache", (w) -> debug.clearMapDrawingCache!()),
        ("Force Draw All Rooms", (w) -> debug.forceDrawWholeMap!()),
    ]
]

menubar = Menubar.generateMenubar(menubarHeaders, menubarItems)