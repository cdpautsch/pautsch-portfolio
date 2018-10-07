"use strict";
/* GETGROUPED - GROUPING - VALIDATION LIBRARY */

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

var instructorPattern = /^[a-z-]*$/i;

var emptyString = "Cannot be empty.";


/* checks a single, specific input instead of all inputs */
function checkSingleInputEmpty(evt, domEle, idString, specialClass) {
	removeElementById(idString);
	
	// if no special class was provided, defaults to blank to avoid errors
	if (specialClass == null) {
		specialClass = "";
	}
	
	// checks if this input is empty
	if (checkEmpty(evt, domEle, idString, emptyString, specialClass)) {

		console.log(domEle.name,"input good.");
			
		// checks if this was the last error on the page to be corrected
		if (document.querySelectorAll(".error-count").length == 0) {
			removeElementById("top_error");
		}
		
		return true;
	}
	else
	{
		console.log(domEle.name,"input bad.");
		//evt.stopPropagation();
		
		return false;
	}
}

/* checks a single, specific input instead of all inputs */
function checkSingleInputPattern(evt, domEle, idString, pattern, alertString) {
	removeElementById(idString);
	
	// checks if this input value matches a pattern
	if (checkPattern(evt, domEle, idString, pattern, alertString)) {

		console.log(domEle.name,"input good.");
		
		// checks if this was the last error on the page to be corrected
		if (document.querySelectorAll(".error-count").length == 0) {
			removeElementById("top_error");
		}
		
		return true;
	}
	else
	{
		console.log(domEle.name,"input bad.");
		//evt.stopPropagation();
		
		return false;
	}
}

/* checks all inputs for creating or editing a group */
function checkInputs(evt) {
	resetErrors();
	
	// sets event if browser is IE
	if (!evt) {
		evt = window.event;
	}
	
	// tracks if ANY input has a problem
	var isInputGood = true;
	
	/* checks inputs in reverse order, so that the last input checked is at the top, and is the one selected */
	if (!checkEmpty(evt, maxSizeEle, "g_max_size_error", emptyString)) {
		isInputGood = false;
	}
	
	if (!checkPattern(evt, instructorEle, "g_instructor_error", instructorPattern, "Last name only.")) {
		isInputGood = false;
	}
	
	if (!checkEmpty(evt, classEle, "g_class_error", "You must choose a class.")) {
		isInputGood = false;
	}
	
	if (!checkEmpty(evt, subjectEle, "g_subject_error", "You must choose a subject.","tall")) {
		isInputGood = false;
	}
	
	if (!checkEmpty(evt, descriptionEle, "g_desc_error", emptyString,"tall")) {
		isInputGood = false;
	}
	
	if (!checkEmpty(evt, nameEle, "g_name_error", emptyString)) {
		isInputGood = false;
	}
	
	// if all inputs are good, then event proceeds
	if (isInputGood) {
		console.log("Inputs good.");
		return true;
	}
	else
	{
		// if ANY input is bad, event is aborted
		console.log("One or more inputs bad.");
		evt.preventDefault();
		evt.stopPropagation();
		
		createTopError("Please correct the error(s) below, then try again.");
		return false;
	}
}

/* creates warning at the top of the screen. The createTag() function cannot be used because the appending logic is slightly different, because of the top error's special positioning. */
function createTopError(errorString) {
	// creates the element with appropriate class and id
	var topErrorSpan = document.createElement("span");
	topErrorSpan.className = "error-tag top";
	topErrorSpan.id = "top_error";
	
	topErrorSpan.innerHTML = errorString;
	
	// inserts element at the very top of the page
	document.body.insertBefore(topErrorSpan, document.body.firstChild);
}

/* checks if a particular element has an empty or null value */
function checkEmpty(evt, domEle, idString, alertString, specialClass) {
	console.log("checkEmpty:", domEle.name, "...");
	
	// if no special class was provided, defaults to blank to avoid errors
	if (specialClass == null) {
		specialClass = "";
	}
	
	// checks dom emptiness two ways (null or empty value)
	if ((domEle.value == null) || (domEle.value == "")) {
		
		console.log(" ",domEle.name,"is empty.");
		
		// empty value
		createInputErrorTag(domEle, idString, alertString, specialClass);
		
		domEle.focus();
		
		return false;
	}
	else
	{
		console.log(" ",domEle.name," is not empty.");
		return true;
	}
}

/* checks if the value of a particular element matches a particular pattern */
function checkPattern(evt, domEle, idString, pattern, alertString) {
	console.log("checkPattern:", domEle.name, "...");
	
	// tests the pattern
	if (!pattern.test(domEle.value)) {
		
		console.log(" ",domEle.name,"fails pattern.");
		
		// no match
		createInputErrorTag(domEle, idString, alertString);
		
		domEle.focus();
		domEle.select();
		
		return false;
	}
	else
	{
		// matches pattern
		console.log(" ",domEle.name," matches pattern.");
		return true;
	}
}

/* retrieves the current ID of the group, if there is one. The edit page will have a GID, but create will not. */
function getCurrentGroupID() {
	// retrieves URL
    var url = window.location.href;
	
	// finds query string (actually an array or matching results)
	var queryString = url.match(/\?gid=\d+/);
	
	if (queryString) {
		// extracts group value from the query string
		var groupID = queryString[0].substring(5);
	
		return groupID;
	}
	else
	{
		// returns empty if not found
		return "";
	}
}

/* checks group name for uniqueness (self-matches are permitted) */
function checkUniqueName() {
	console.log("Checking class name for uniqueness");
	
	// only actually makes the ajax request if the value is non-empty
	if (nameEle.value.length != 0) {
		
		// gets the parameters (group name and current group ID)
		var gname_value = nameEle.value;
		
		var groupID = getCurrentGroupID();

		console.log("gname_value: " , gname_value);

		// sends the request
		new Ajax.Request("check_unique_name.php",
		{
			method: "get",
			parameters: {gname: gname_value, gid: groupID},
			onSuccess: displayUniqueNameCheck,
			onFailure: displayAjaxFailure
		}
		);
	}
	else
	{
		// if the element is empty, the unique tag needs to be removed so that the empty error tag can be displayed (handled by a different function
		removeElementById("g_name_unique");
	}
}

/* displays the results of the unique name check */
function displayUniqueNameCheck(data) {
	// checks for errors
	if (data.responseXML.getElementsByTagName("error")[0]) {
		// records error in log
		console.log("There was a PHP error: ", data.responseXML.getElementsByTagName("error")[0].textContent);
		
		// at present, no error message is displayed for the user, because this is a lower-priority check that will not often fire
	}
	
	// removes any pre-existing unique name tag
	removeElementById("g_name_unique");
	
	// begins parsing the XML
	var xml = data.responseXML.getElementsByTagName("name")[0];
	
	console.log("Name XML: ",xml);
	
	// extracts message and response class name
	var msgString = xml.getElementsByTagName("msg")[0].textContent;
	var classString = "error-tag error-count " + xml.getElementsByTagName("response")[0].textContent;
	
	// creates the tag
	createTag(nameEle, "g_name_unique", msgString, classString, "&#9650");
}

/* creates an error tag for an input error */
function createInputErrorTag(domEle, idString, alertString, specialClass) {
	// redundant check for null special classes to avoid errors
	if (specialClass == null) {
		specialClass = "";
	}
	
	createTag(domEle, idString, alertString, "error-tag error-count " + specialClass, "&#9650");
}

/* removes all error warnings on the page */
function resetErrors() {
	console.log("Resetting errors...");
	
	removeElementById("g_name_error");
	removeElementById("g_desc_error");
	removeElementById("g_subject_error");
	removeElementById("g_class_error");
	removeElementById("g_instructor_error");
	removeElementById("g_max_size_error");
	removeElementById("top_error");
}

























