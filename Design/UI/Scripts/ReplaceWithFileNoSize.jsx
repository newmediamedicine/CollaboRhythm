/*
JET_ReplaceWithSymbol.jsx
A Javascript for Adobe Illustrator
Purpose: Replaces selected items with Instances of a Symbol from the Symbols Panel.
The desired Symbol can be defined by its index number (its number of occurrance in the Panel).
*/
var docRef=app.activeDocument;
var placedFile = File.openDialog('Select a file to replace each selected object with:', 'Adobe Illustrator:*.ai,Adobe FXG:*.fxg');

var objectsToReplace = new Array;
for(i=0;i<docRef.selection.length;i++)
{
    objectsToReplace.push(docRef.selection[i]);
}

for (i=0;i<objectsToReplace.length;i++)
{
    var currObj=objectsToReplace[i];
    var currLeft=currObj.left;
    var currTop=currObj.top;
    var currWidth=currObj.width;
    var currHeight=currObj.height;
    var currInstance = currObj.parent.placedItems.add();
    currInstance.file = placedFile;
    currInstance.left=currLeft;
    currInstance.top=currTop;
    currInstance.selected=true;
    currObj.remove();
    redraw();
}