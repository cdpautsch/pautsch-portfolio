"use strict";
/* GETGROUPED - GROUPING - GENERAL LIBRARY */

/* removes a tooltip */
function removeTooltip() {
	removeElementById(tooltipID);
}

/* creates a tooltip tag */
function createTooltipTag(domEle, idString, tipString) {
	createTag(domEle, idString, tipString, "tooltip", "&#9872");
}

/* creates an absolute tag (for tooltips or errors) */
function createTag(domEle, idString, msgString, specialClass, specialSymbol) {
	// creates the element, then adds the specified class, ID, symbol, and text
	var tagSpan = document.createElement("span");
	tagSpan.className = specialClass;
	tagSpan.id = idString;
	
	// innerHTML must be used so that the symbol text is properly intrepeted into a Unicode character
	tagSpan.innerHTML = specialSymbol + " &nbsp " + msgString;
	
	domEle.previousElementSibling.appendChild(tagSpan);
}

/* removes a particular element having a particular id */
function removeElementById(idToRemove) {
	// locates the elemenet
	var elementToRemove = document.getElementById(idToRemove);
	
	// if the ID is invalid, the function does nothing
	if (elementToRemove != null) {
		elementToRemove.parentNode.removeChild(elementToRemove);
	}
}

/* controls the expansion of a particular element and associated expand/shrink button */
function toggleExpandInput(buttonEle, inputEle, baseSize) {
	// increase base size by 4
	var newSize = parseInt(baseSize) + 4;
	
	// finds the label which holds the button
	var labelEle = buttonEle.parentElement;
	
	// checks the current content of the button
	if (buttonEle.innerHTML == 'Expand') {
		// expand is clicked
		var newSize = parseInt(baseSize) + 4;
		
		buttonEle.innerHTML = 'Shrink';
		inputEle.size = newSize;
		// CSS rules ensure proper placement of elements
		labelEle.className = "expanded";
		inputEle.className = "expanded";
	}
	else
	{
		// shrink is clicked
		buttonEle.innerHTML = 'Expand';
		inputEle.size = baseSize;
		labelEle.className = "";
		inputEle.className = "";
	}
}