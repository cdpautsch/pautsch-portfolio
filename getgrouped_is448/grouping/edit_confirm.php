<?php
	session_start();

	// Redirects if not logged in
	if (!($_SESSION["logged_in"])) {
		header("Location:../account/login.html");
		exit;
	}
	
	/*
		g_name
		g_desc
		g_subject
		g_class
		g_instructor
		g_location
		g_max_size
		g_num_meets
		g_id
	*/
	
	// Checks that GET request is set
	if (!isset($_GET['gid']) || empty($_GET['gid'])) {
		header("Location:../dashboard.php?error=10");
		exit;
	}
		
	// Values from GET
	$g_id = $_GET['gid'];
	
	// Checks that POST request is set
	if (
		(!isset($_POST['g_name']) || empty($_POST['g_name'])) ||
		(!isset($_POST['g_desc']) || empty($_POST['g_desc'])) ||
		(!isset($_POST['g_class']) || empty($_POST['g_class'])) ||
		(!isset($_POST['g_max_size']) || empty($_POST['g_max_size'])) ||
		(!isset($_POST['g_num_meets']) || empty($_POST['g_num_meets']))
		) {
		header("Location:edit.php?gid=$g_id&error=5");
		exit;
	}
	
	// Checks that user is set
	if (!isset($_SESSION['user']) || empty($_SESSION['user'])) {
		session_unset();
		session_destroy();
		header("Location:../index.php?error=41");
		exit;
	}
			
	// Values from POST
	$g_name = $_POST['g_name'];
	$g_desc = $_POST['g_desc'];
	$g_class = $_POST['g_class'];
	$g_instructor = $_POST['g_instructor'];
	$g_location_array = $_POST['g_location'];
	$g_max_size = $_POST['g_max_size'];
	$g_num_meets = $_POST['g_num_meets'];
	
	// creates location string
	$g_location = implode("",$g_location_array);
	
	// Checks for HTML injection
	$g_name = htmlspecialchars($g_name);
	$g_desc = htmlspecialchars($g_desc);
	$g_class = htmlspecialchars($g_class);
	$g_instructor = htmlspecialchars($g_instructor);
	$g_location = htmlspecialchars($g_location);
	$g_max_size = htmlspecialchars($g_max_size);
	$g_num_meets = htmlspecialchars($g_num_meets);
	$g_id = htmlspecialchars($g_id);
	
	// database setup
	$db_link = "studentdb-maria.gl.umbc.edu";
	$db_authenticate = "pautsch1";
	$db_name = "pautsch1";
	
	// Connect to DB
	$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);
	
	// checks DB connection
	if (mysqli_connect_errno()) {
		header("Location:edit.php?gid=$g_id&error=62");
		exit;
	}
	
	// Checks for SQL injection
	$g_name = mysqli_real_escape_string($db,$g_name);
	$g_desc = mysqli_real_escape_string($db,$g_desc);
	$g_class = mysqli_real_escape_string($db,$g_class);
	$g_instructor = mysqli_real_escape_string($db,$g_instructor);
	$g_location = mysqli_real_escape_string($db,$g_location);
	$g_max_size = mysqli_real_escape_string($db,$g_max_size);
	$g_num_meets = mysqli_real_escape_string($db,$g_num_meets);
	$g_id = mysqli_real_escape_string($db,$g_id);
	
	// Create query
	$group_update = "UPDATE groups
					SET class_id = $g_class,
						group_name = '$g_name',
						group_description = '$g_desc',
						group_instructor = '$g_instructor',
						group_location = '$g_location',
						group_max_size = $g_max_size,
						group_target_meets = $g_num_meets
					WHERE group_id = $g_id;";
	
	// starts db transaction
	// PHP 5.5.0 syntax
	// mysqli_begin_transaction($db);
	mysqli_query($db, "START TRANSACTION;");
	
	// executes query
	$group_result = mysqli_query($db,$group_update);
	
	// checks if group created
	if (!$group_result) {
		// rolls back to avoid bad data
		//mysqli_rollback($db);
		mysqli_query($db, "ROLLBACK;");
		mysqli_close($db);
		
		// returns to edit page and exits
		header("Location:edit.php?gid=$g_id&error=5");
		exit;
	}
	
	// if no errors, commits the changes
	
	// PHP 5.5.0 syntax
	//mysqli_commit($db);
	mysqli_query($db, "COMMIT;");
	
	// closes db
	mysqli_close($db);
	
	header("Location:edit.php?gid=$g_id&success=yes");
?>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>Editing the group...</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Processes a request to edit the group..." />

	<link rel="stylesheet" type="text/css" href="../css/getgrouped.css" title="style" />
</head>
<body>
</body>
</html>