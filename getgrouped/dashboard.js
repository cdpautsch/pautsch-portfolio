"use strict";
/* GETGROUPED - DASHBOARD */

/* This code is intended to function with help from some of the Grouping Use Case javascript */

var searchEle;

var submitEle;

// setup DOM variables
function setupVariables() {
	searchEle = document.getElementById("friend_search");
	
	submitEle = document.getElementById("search_submit");
}


// setup event listeners
function setupListeners() {
	/* --- Error checking --- */
	submitEle.addEventListener("click",checkDashboardInputs);
	
	searchEle.addEventListener("blur", function(evt) { checkSingleInputEmpty(evt, searchEle, "friend_search_error"); } );
	
}

// checks Dashboard inputs (in this case, there is only one, for the friend search
function checkDashboardInputs(evt) {
	// resets lone error
	removeElementById("friend_search_error");
	
	// sets event if browser is IE
	if (!evt) {
		evt = window.event;
	}
	
	// old code for checking multiple inputs is retained, in case more inputs are ever added
	var isInputGood = true;
	
	if (!checkEmpty(evt, searchEle, "friend_search_error", emptyString)) {
		isInputGood = false;
	}
	
	if (isInputGood) {
		console.log("Inputs good.");
		return true;
	}
	else
	{
		console.log("One or more inputs bad.");
		evt.preventDefault();
		evt.stopPropagation();
		
		return false;
	}
}

// start page
window.onload = function() {
	console.log("Starting...");
	
	setupVariables();
	setupListeners();
};