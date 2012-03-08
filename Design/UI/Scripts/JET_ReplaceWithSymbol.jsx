/*
JET_ReplaceWithSymbol.jsx
A Javascript for Adobe Illustrator
Purpose: Replaces selected items with Instances of a Symbol from the Symbols Panel.
The desired Symbol can be defined by its index number (its number of occurrance in the Panel).
*/
var docRef=app.activeDocument;
var symbolNum=prompt("Enter the number of the Symbol you want to replace each selected object",1);
for(i=0;i<docRef.selection.length;i++){
    var currObj=docRef.selection[i];
    var selectionGroup = currObj.parent.groupItems.add();
    currObj.moveToBeginning(selectionGroup);
    
    var currLeft=selectionGroup.left;
    var currTop=selectionGroup.top;
    var currWidth=selectionGroup.width;
    var currHeight=selectionGroup.height;
    var currInstance=selectionGroup.parent.symbolItems.add(docRef.symbols[symbolNum-1]);
    currInstance.width*=currHeight/currInstance.height;
    currInstance.height=currHeight;
    currInstance.left=currLeft;
    currInstance.top=currTop;
    currInstance.selected=true;
    selectionGroup.remove();
    redraw();
}