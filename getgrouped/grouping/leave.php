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
	
	/*
		Confirms:
			- user acct is valid
			- group id is valid
			- user is NOT owner of group
	*/
	$user_query = "SELECT u.user_id
					FROM users u, grouped_users gu, groups g
					WHERE u.user_id = gu.user_id
					AND gu.group_id = g.group_id
					AND u.user_acct_name = '$u_acct'
					AND NOT gu.role = 'Owner'
					AND g.group_id = $g_id;";
	$user_result = mysqli_query($db,$user_query);
	if ((!$user_result) || (mysqli_num_rows($user_result) == 0)) {
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=2");
		exit;
	}
	$user_result_row = mysqli_fetch_array($user_result);
	$u_id = $user_result_row['user_id'];
	
	// starts db transaction
	// PHP 5.5.0 syntax
	// mysqli_begin_transaction($db);
	mysqli_query($db, "START TRANSACTION;");
	
	// deletes grouped_users relationship
	$delete_gu_query = "DELETE FROM grouped_users WHERE group_id = $g_id AND user_id = $u_id;";
	$delete_gu_result = mysqli_query($db,$delete_gu_query);
	if (!$delete_gu_result) {
		//mysqli_rollback($db);
		mysqli_query($db, "ROLLBACK;");
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=2");
		exit;
	}
	
	// deletes attendances
	$delete_a_query = "DELETE FROM attendances WHERE user_id = $u_id AND meeting_id IN (SELECT meeting_id FROM meetings WHERE group_id = $g_id);";
	$delete_a_result = mysqli_query($db,$delete_a_query);
	if (!$delete_a_query) {
		//mysqli_rollback($db);
		mysqli_query($db, "ROLLBACK;");
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=2");
		exit;
	}
	
	// if both queries were successful, then all relationships have been deleted
	// PHP 5.5.0 syntax
	//mysqli_commit($db);
	mysqli_query($db, "COMMIT;");
	mysqli_close($db);
	
	// redirects to the dashboard
	header("Location:../dashboard.php");
?>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>Leaving the group...</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Processes a request to leave the group..." />

	<link rel="stylesheet" type="text/css" href="../css/getgrouped.css" title="style" />
</head>
<body>
</body>
</html>