<?php
	session_start();

	// Redirects if not logged in
	if (!($_SESSION["logged_in"])) {
		header("Location:../account/login.html");
		exit;
	}
	
	// Checks that GET GID request is set
	if (!isset($_GET['gid']) || empty($_GET['gid'])) {
		header("Location:../dashboard.php?error=10");
		exit;
	}
	
	// Checks that GET UID request is set
	if (!isset($_GET['gid']) || empty($_GET['gid'])) {
		header("Location:../dashboard.php?error=8");
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
	$m_id = $_GET['uid'];
	$o_acct = $_SESSION['user'];
	
	// Checks for HTML injection
	$g_id = htmlspecialchars($g_id);
	$m_id = htmlspecialchars($m_id);
	$o_acct = htmlspecialchars($o_acct);
	
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
	$m_id = mysqli_real_escape_string($db,$m_id);
	$o_acct = mysqli_real_escape_string($db,$o_acct);
	
	/*
		Confirms:
			- current user has valid acct name
			- current user is owner
			- group id is valid
	*/
	$owner_query = "SELECT u.user_id AS o_id
					FROM users u, grouped_users gu, groups g
					WHERE u.user_id = gu.user_id
					AND gu.group_id = g.group_id
					AND u.user_acct_name = '$o_acct'
					AND gu.role = 'Owner'
					AND g.group_id = $g_id;";
	$owner_result = mysqli_query($db,$owner_query);
	if (!$owner_query || (mysqli_num_rows($owner_result) == 0)) {
		mysqli_close($db);
		header("Location:view.php?gid=$g_id%error=9");
		exit;
	}
	
	/*
		Confirms:
			- member id is valid
			- member id is in group
			- member is not the owner
	*/
	$member_query = "SELECT role
					FROM grouped_users
					WHERE user_id = $m_id
					AND group_id = $g_id;";
	$member_result = mysqli_query($db,$member_query);
	if ((!$member_result) || (mysqli_num_rows($member_result) == 0)) {
		mysqli_close($db);
		header("Location:edit.php?gid=$g_id&error=7");
		exit;
	}
	$role_row = mysqli_fetch_array($member_result);
	if ($role_row['role'] == 'Owner') {
		mysqli_close($db);
		header("Location:edit.php?gid=$g_id&error=6");
		exit;
	}
	
	// starts db transaction
	// PHP 5.5.0 syntax
	// mysqli_begin_transaction($db);
	mysqli_query($db, "START TRANSACTION;");
	
	// deletes attendances
	$delete_a_query = "DELETE FROM attendances WHERE user_id = $m_id AND meeting_id IN (SELECT meeting_id FROM meetings WHERE group_id = $g_id);";
	$delete_a_result = mysqli_query($db,$delete_a_query);
	if (!$delete_a_query) {
		//mysqli_rollback($db);
		mysqli_query($db, "ROLLBACK;");
		mysqli_close($db);
		header("Location:edit.php?gid=$g_id&error=8");
		exit;
	}
	
	// deletes grouped_users relationship
	$delete_gu_query = "DELETE FROM grouped_users WHERE group_id = $g_id AND user_id = $m_id;";
	$delete_gu_result = mysqli_query($db,$delete_gu_query);
	if (!$delete_gu_result) {
		//mysqli_rollback($db);
		mysqli_query($db, "ROLLBACK;");
		mysqli_close($db);
		header("Location:edit.php?gid=$g_id&error=8");
		exit;
	}
	
	// if both queries were successful, then all relationships have been deleted
	// PHP 5.5.0 syntax
	//mysqli_commit($db);
	mysqli_query($db, "COMMIT;");
	mysqli_close($db);
	
	// redirects to the group edit
	header("Location:edit.php?gid=$g_id&success=yes");
?>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>Removing a user from the group...</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Processes a request to remove a user from the group" />

	<link rel="stylesheet" type="text/css" href="../css/getgrouped.css" title="style" />
</head>
<body>
</body>
</html>