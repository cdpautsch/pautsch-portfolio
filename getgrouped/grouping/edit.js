"use strict";
/* GETGROUPED - GROUPING - EDIT */

/*
	g_name
	g_desc
	g_subject
	g_class
	g_instructor
	g_location
	g_max_size
	g_num_meets
*/

var nameEle;
var descriptionEle;
var subjectEle;
var classEle;
var instructorEle;
var locationEle;
var maxSizeEle;
var numMeetsEle;

var subjectExpandEle;
var classExpandEle;

var submitEle;

var tooltipID;

/* setup DOM variables */
function setupVariables() {
	nameEle = document.getElementById("g_name");
	descriptionEle = document.getElementById("g_desc");
	subjectEle = document.getElementById("g_subject");
	classEle = document.getElementById("g_class");
	instructorEle = document.getElementById("g_instructor");
	locationEle = document.getElementById("g_location");
	maxSizeEle = document.getElementById("g_max_size");
	numMeetsEle = document.getElementById("g_num_meets");
	
	subjectExpandEle = document.getElementById("subject-expand");
	classExpandEle = document.getElementById("class-expand");
	
	submitEle = document.getElementById("create_submit");
}


/* setup event listeners */
function setupListeners() {
	/* --- Error checking --- */
	submitEle.addEventListener("click",checkInputs);
	
	nameEle.addEventListener("blur", function(evt) { checkSingleInputEmpty(evt, nameEle, "g_name_error"); } );
	
	descriptionEle.addEventListener("blur", function(evt) { checkSingleInputEmpty(evt, descriptionEle, "g_desc_error", "tall"); } );
	
	subjectEle.addEventListener("change", function(evt) { checkSingleInputEmpty(evt, subjectEle, "g_subject_error", "tall"); } );
	
	// this means that classes are evaluated when subject is updated
	//subjectEle.addEventListener("change", function(evt) { checkSingleInputEmpty(evt, classEle, "g_class_error"); } );
	
	classEle.addEventListener("change", function(evt) { checkSingleInputEmpty(evt, classEle, "g_class_error"); } );
	
	maxSizeEle.addEventListener("change", function(evt) { checkSingleInputEmpty(evt, maxSizeEle, "g_max_size_error"); } );
	
	instructorEle.addEventListener("blur", function(evt) { checkSingleInputPattern(evt, instructorEle, "g_instructor_error", instructorPattern, "Last name only."); } );
	
	
	/* --- Tooltips --- */
	tooltipID = "hover_tooltip";
	
	nameEle.addEventListener("mouseover", function() { createTooltipTag(nameEle, tooltipID, "This is the name of your group, and is how your group is publically identified."); });
	nameEle.addEventListener("mouseout",removeTooltip);
	
	descriptionEle.addEventListener("mouseover", function() { createTooltipTag(descriptionEle, tooltipID, "This a description of your group, it's purpose, and key information that might not be detailed elsewhere."); });
	descriptionEle.addEventListener("mouseout",removeTooltip);
	
	subjectEle.addEventListener("mouseover", function() { createTooltipTag(subjectEle, tooltipID, "If you want to change the subject, pick a new one here. The list of classes will also update."); });
	subjectEle.addEventListener("mouseout",removeTooltip);
	
	classEle.addEventListener("mouseover", function() { createTooltipTag(classEle, tooltipID, "If you want to change the class, select a new one here."); });
	classEle.addEventListener("mouseout",removeTooltip);
	
	instructorEle.addEventListener("mouseover", function() { createTooltipTag(instructorEle, tooltipID, "This is the last name of your class instructor. This field is optional."); });
	instructorEle.addEventListener("mouseout",removeTooltip);
	
	locationEle.addEventListener("mouseover", function() { createTooltipTag(locationEle, tooltipID, "These are your preferred places to meet. Remote means you will meet via internet applications, such as Skype."); });
	locationEle.addEventListener("mouseout",removeTooltip);
	
	maxSizeEle.addEventListener("mouseover", function() { createTooltipTag(maxSizeEle, tooltipID, "This is a limit on the number of people who can join your study group. 'N/A' means there is no limit."); });
	maxSizeEle.addEventListener("mouseout",removeTooltip);
	
	numMeetsEle.addEventListener("mouseover", function() { createTooltipTag(numMeetsEle, tooltipID, "This is how many meetings you expect to have, on average. There is no hard cap."); });
	numMeetsEle.addEventListener("mouseout",removeTooltip);
	
	
	/* --- Expanding Buttons --- */
	subjectExpandEle.addEventListener("click", function() { toggleExpandInput(subjectExpandEle, subjectEle, 5) });
	classExpandEle.addEventListener("click", function() { toggleExpandInput(classExpandEle, classEle, 1) });
	
	/* --- Checks name for uniqueness --- */
	nameEle.addEventListener("blur",checkUniqueName);
	
	
	/* --- Ajax --- */
	// dynamic update of class list
	subjectEle.addEventListener("change", function(evt) { getClassList(evt.target.value); });
	
}

/* start page */
window.onload = function() {
	console.log("Starting...");
	
	setupVariables();
	setupListeners();
};