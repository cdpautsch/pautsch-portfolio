<?php
	session_start();

	// Redirects if not logged in
	if (!($_SESSION["logged_in"])) {
		header("Location:../account/login.html");
		exit;
	}
	
	// Checks that GET request is set
	if (!isset($_GET['gid']) || empty($_GET['gid'])) {
		header("Location:../dashboard.php?error=10");
		exit;
	}
	
	// Checks that user is set
	if (!isset($_SESSION['user']) || empty($_SESSION['user'])) {
		session_unset();
		session_destroy();
		header("Location:../index.php?error=41");
		exit;
	}
		
	// Values from GET & SESSION
	$g_id = $_GET['gid'];
	$u_acct = $_SESSION['user'];
	
	// Checks for HTML injection
	$g_id = htmlspecialchars($g_id);
	$u_acct = htmlspecialchars($u_acct);
	
	// database setup
	$db_link = "studentdb-maria.gl.umbc.edu";
	$db_authenticate = "pautsch1";
	$db_name = "pautsch1";
	
	// Connect to DB
	$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);
	
	// checks DB connection
	if (mysqli_connect_errno()) {
		header("Location:view.php?gid=$g_id&error=62");
		exit;
	}
	
	// Checks for SQL injection
	$g_id = mysqli_real_escape_string($db,$g_id);
	$u_acct = mysqli_real_escape_string($db,$u_acct);
	
	// Confirms user account is valid
	$user_query = "SELECT user_id FROM users WHERE user_acct_name = '$u_acct';";
	$user_result = mysqli_query($db,$user_query);
	if ((!$user_result) || (mysqli_num_rows($user_result) == 0)) {
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=1");
		exit;
	}
	$user_result_row = mysqli_fetch_array($user_result);
	$u_id = $user_result_row['user_id'];
	
	// Confirms user is NOT in the group
	$group_query = "SELECT group_id FROM grouped_users WHERE user_id = $u_id AND group_id = $g_id;";
	$group_result = mysqli_query($db,$group_query);
	if ((!$user_result) || (mysqli_num_rows($group_result) != 0)) {
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=1");
		exit;
	}
	
	// starts db transaction
	// PHP 5.5.0 syntax
	// mysqli_begin_transaction($db);
	mysqli_query($db, "START TRANSACTION;");
	
	// create new grouped user relationship
	$insert_gu_query = "INSERT INTO grouped_users (group_id, user_id, role) VALUES ($g_id, $u_id, 'Member');";
	$insert_gu_result = mysqli_query($db,$insert_gu_query);
	if (!$insert_gu_result) {
		//mysqli_rollback($db);
		mysqli_query($db, "ROLLBACK;");
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=1");
		exit;
	}
	
	// create new attendance relationships
	$meeting_query = "SELECT meeting_id FROM meetings WHERE group_id = $g_id AND meeting_date >= SYSDATE();";
	$meeting_result = mysqli_query($db,$meeting_query);
	if (!$meeting_result) {
		//mysqli_rollback($db);
		mysqli_query($db, "ROLLBACK;");
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=1");
		exit;
	}
	
	if (mysqli_num_rows($meeting_result) != 0) {
		while ($meeting_row = mysqli_fetch_array($meeting_result)) {
			// adds attendance for every upcoming meeting
			$insert_a_query = "INSERT INTO attendances (attendance_status, user_id, meeting_id) VALUES ('I',$u_id, $meeting_row[meeting_id]);";
			$insert_a_result = mysqli_query($db,$insert_a_query);
			if (!$insert_a_result) {
				//mysqli_rollback($db);
				mysqli_query($db, "ROLLBACK;");
				mysqli_close($db);
				header("Location:view.php?gid=$g_id&error=1");
				exit;
			}
		}
	}
	
	// if queries were successful, then relationship has been created!
	// PHP 5.5.0 syntax
	//mysqli_commit($db);
	mysqli_query($db, "COMMIT;");
	mysqli_close($db);
	
	// redirects to the group
	header("Location:view.php?gid=$g_id");
?>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>Joining the group...</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Processes a request to join the group..." />

	<link rel="stylesheet" type="text/css" href="../css/getgrouped.css" title="style" />
</head>
<body>
</body>
</html>