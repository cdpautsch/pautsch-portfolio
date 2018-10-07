"use strict";
/* GETGROUPED - LEAVE COMMENT */

/* This code is intended to function with help from some of the Grouping Use Case javascript */

var nameEle;
var emailEle;
var commentEle;

var submitEle;

// setup DOM variables
function setupVariables() {
	nameEle = document.getElementById("c_name");
	emailEle = document.getElementById("c_email");
	commentEle = document.getElementById("c_comment");
	
	submitEle = document.getElementById("comment_submit");
}


// setup event listeners
function setupListeners() {
	/* --- Error checking --- */
	submitEle.addEventListener("click",checkCommentInputs);
	
	nameEle.addEventListener("blur", function(evt) { checkSingleInputEmpty(evt, nameEle, "c_name_error"); } );
	
	emailEle.addEventListener("blur", function(evt) { checkSingleInputEmpty(evt, emailEle, "c_email_error"); } );
	
	commentEle.addEventListener("blur", function(evt) { checkSingleInputEmpty(evt, commentEle, "c_comment_error", "tall"); } );
	
}

// checks inputs for leaving a comment
function checkCommentInputs(evt) {
	resetCommentErrors();
	
	// sets event if browser is IE
	if (!evt) {
		evt = window.event;
	}
	
	var isInputGood = true;
	
	/* checks inputs in reverse order, so that the last input checked is at the top, and is the one selected */
	if (!checkEmpty(evt, commentEle, "g_comment_error", "You must enter text for a comment.","tall")) {
		isInputGood = false;
	}
	
	if (!checkEmpty(evt, emailEle, "c_email_error", emptyString)) {
		isInputGood = false;
	}
	
	if (!checkEmpty(evt, nameEle, "c_name_error", emptyString)) {
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

// removes all error warnings on the page
function resetCommentErrors() {
	console.log("Resetting errors...");
	
	removeElementById("c_name_error");
	removeElementById("c_email_error");
	removeElementById("c_comment_error");
}

// start page
window.onload = function() {
	console.log("Starting...");
	
	setupVariables();
	setupListeners();
};