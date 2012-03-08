function getAllChildren(obj)
{
	var children = new Array();
	for (var i = 0; i < obj.pageItems.length; i++)
        children.push(obj.pageItems[i]);
	return children;
}

function ungroup(obj)
{
    var elements = getAllChildren(obj);
    for(var i=0; i < elements.length; i++)
    {
        try
        {
            elements[i].moveBefore(obj);
        }
        catch(e)
        {

        }
    }
    obj.remove();
}

String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

var currentDocRef = app.activeDocument;
var currentSelection = app.activeDocument.selection;

if (currentSelection.length > 0)
{
    var destFile = File.saveDialog('Specify a file to save the extracted objects to:', 'Adobe Illustrator:*.ai,Adobe FXG:*.fxg');
    
    if (destFile != null)
    {
        var selectionGroup = currentSelection[0].parent.groupItems.add();

        for(i = 0; i < currentDocRef.selection.length; i++)
        {
            var currObj = currentDocRef.selection[i];
            currObj.moveToBeginning(selectionGroup);
        }

        var placedDocument = app.documents.add(DocumentColorSpace.CMYK, selectionGroup.controlBounds[2] - selectionGroup.controlBounds[0], selectionGroup.controlBounds[1] - selectionGroup.controlBounds[3]);

        //if ( currentSelection.length > 0 )
        //{
        //    for ( i = 0; i < currentSelection.length; i++ )
        //    {
        //        //currentSelection[i].selected = false;
        //        newItem = currentSelection[i].duplicate( placedDocument, ElementPlacement.PLACEATEND );
        //    }
        //}

        var newItem = selectionGroup.duplicate( placedDocument, ElementPlacement.PLACEATEND );
        newItem.left = 0;
        newItem.top = placedDocument.artboards[0].artboardRect[1];

        ungroup(newItem);

        var saveOptions;
        var canLink = false;
        
        if (destFile.name.endsWith('.fxg'))
        {
            // unfortunately, Illustrator does not support linking to FXG files
            var fxgSaveOptions = new FXGSaveOptions();
            fxgSaveOptions.saveMultipleArtboards = false;
            fxgSaveOptions.filtersPolicy = FiltersPreservePolicy.KEEPFILTERSEDITABLE;
            fxgSaveOptions.version = FXGVersion.VERSION2PT0;
            fxgSaveOptions.blendsPolicy  = BlendsExpandPolicy.AUTOMATICALLYCONVERTBLENDS;
            fxgSaveOptions.includeUnusedSymbols = false;
            fxgSaveOptions.preserveEditingCapabilities = true;
            fxgSaveOptions.textPolicy = TextPreservePolicy.AUTOMATICALLYCONVERTTEXT;
            fxgSaveOptions.downsampleLinkedImages = false;
            fxgSaveOptions.GradientsPolicy = GradientsPreservePolicy.AUTOMATICALLYCONVERTGRADIENTS;
            saveOptions = fxgSaveOptions;
        }
        else
        {
            saveOptions = new IllustratorSaveOptions();
            canLink = true;
        }
        
        placedDocument.saveAs(destFile, saveOptions);

        currentDocRef.activate();

        if (canLink)
        {
            var placedItem = selectionGroup.parent.placedItems.add();
            placedItem.file = destFile;
            placedItem.left = selectionGroup.left;
            placedItem.top = selectionGroup.top;

            selectionGroup.remove();
        }
        else
        {
            ungroup(selectionGroup);
        }
    }
}