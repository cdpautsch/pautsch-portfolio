<?php
	session_start();
	
	/*
		name
		email
		comment
		respond
	*/
	
	// Checks that POST request is set
	if (
		(!isset($_POST['c_name']) || empty($_POST['c_name'])) ||
		(!isset($_POST['c_email']) || empty($_POST['c_email'])) ||
		(!isset($_POST['c_comment']) || empty($_POST['c_comment'])) ||
		(!isset($_POST['c_respond']) || (($_POST['c_respond'] != 0) && ($_POST['c_respond'] != 1)))
		) {
		header("Location:leave_comment.php?error=61");
		exit;
	}
			
	// Values from POST
	$name = $_POST['c_name'];
	$email = $_POST['c_email'];
	$comment = $_POST['c_comment'];
	$respond = $_POST['c_respond'];
	
	// Checks for HTML injection
	$name = htmlspecialchars($name);
	$email = htmlspecialchars($email);
	$comment = htmlspecialchars($comment);
	$respond = htmlspecialchars($respond);
	
	// database setup
	$db_link = "studentdb-maria.gl.umbc.edu";
	$db_authenticate = "pautsch1";
	$db_name = "pautsch1";
	
	// Connect to DB
	$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);
	
	// checks DB connection
	if (mysqli_connect_errno()) {
		header("Location:leave_comment.php?error=62");
		exit;
	}
	
	// Checks for SQL injection
	$name = mysqli_real_escape_string($db,$name);
	$email = mysqli_real_escape_string($db,$email);
	$comment = mysqli_real_escape_string($db,$comment);
	$respond = mysqli_real_escape_string($db,$respond);
	
	// Create query
	$comment_insert = "INSERT INTO comments (comment_name, comment_email, comment_text, comment_respond, comment_date)
						VALUES ('$name', '$email', '$comment', $respond, SYSDATE());";
	
	// executes query
	$comment_result = mysqli_query($db,$comment_insert);
	
	// checks if group created
	if (!$comment_result || (mysqli_affected_rows($db) == 0)) {
		mysqli_close($db);
		
		// returns to edit page and exits
		header("Location:leave_comment.php?error=61");
		exit;
	}
	
	// if no errors, continues
	
	// closes db
	mysqli_close($db);

	// directs to page based on if the user is logged in or not
	if (isset($_SESSION["logged_in"]) && ($_SESSION["logged_in"])) {
		header("Location:dashboard.php?success=61");
	}
	else
	{
		header("Location:index.php?success=61");
	}
?>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>Submitting the comment...</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Processes a request to submit a comment..." />

	<link rel="stylesheet" type="text/css" href="../css/getgrouped.css" title="style" />
</head>
<body>
</body>
</html>