"use strict";
/* GETGROUPED - GROUPING - GET CLASSES */

/* get the list of classes from PHP */
function getClassList(subjectID) {
	console.log("getting class list (sid=" + subjectID + ")...");
	
	new Ajax.Request("get_classes.php",
	{
		method: "get",
		parameters: {sid: subjectID},
		onSuccess: updateClassList,
		onFailure: displayAjaxFailure
	}
	);
}


/* populate the list of classes */
function updateClassList(data) {
	// data is an XML element
	
	console.log("updating class list (data=" + data + ")...");
	
	// deletes all old options
	while (classEle.firstChild) {
		classEle.removeChild(classEle.firstChild);
	}
	
	// retrieves new classes array
	var classes = data.responseXML.getElementsByTagName("class");
	
	console.log("classes= " + classes + ", length=" + classes.length);
	
	// parses through XML to find class information
	for (var i = 0; i < classes.length; i++) {
		console.log("value=" + classes[i].nodeName);
		
		// gets ID and number of class
		var idNode = classes[i].getElementsByTagName("id")[0];
		var numberNode = classes[i].getElementsByTagName("number")[0];
		
		// creates new option
		var classOption = document.createElement('option');
		classOption.value = idNode.textContent;
		classOption.innerHTML = numberNode.textContent;
		
		console.log("New Option= " + classOption.innerHTML);
		
		// adds option
		$('g_class').appendChild(classOption);
	}
}


/* displays an error */
function displayAjaxFailure(data) {
	// In case of an error, the response text is logged to the console
	console.log("Ajax failure: ", data.responseText);
	
	// borrows a validation javascript function
	createTopError("There was a fatal JavaScript error. Please reload the page.");
}



/* JQUERY */
/* this was the original code and is retained here as a reference */
/* // get the list of classes from PHP
function getClassList(subjectID) {
	console.log("getting class list (sid=" + subjectID + ")...");
	
	$.get(
		"get_classes.php",
		{ sid: subjectID },
		"xml")
	.done( function(data) {
		updateClassList(data);
	});
}


// populate the list of classes
function updateClassList(data) {
	console.log("updating class list (data=" + data + ")...");
	
	// deletes all old options
	$('#g_class').empty();
	
	$('class', data).each(function() {
		var classID = $('id', this).text();
		var classNumber = $('number', this).text();
		
		$('#g_class').append($('<option>', {
			value: classID,
			text: classNumber
		}));
	});
}*/