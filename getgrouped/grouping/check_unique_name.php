<?php
	// set XML header
	header('Content-Type: application/xml'); 
	
	if ((!isset($_GET['gname'])) || empty($_GET['gname'])) {
		// TODO evaluate if this is the right way to handle this
		echo "<error>10</error>";
		exit;
	}
	
	// gets subject id`
	$g_name = $_GET['gname'];
	
	// Checks for HTML injection
	$g_name = htmlspecialchars($g_name);
	
	// database setup
	$db_link = "studentdb-maria.gl.umbc.edu";
	$db_authenticate = "pautsch1";
	$db_name = "pautsch1";
	
	// connect to the DB
	$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);
	
	// checks for DB connection error
	if (mysqli_connect_errno()) {
		// TODO evaluate if this is the right way to handle this
		echo "<error>62</error>";
		exit;
	}
	
	// Checks for SQL injection
	$g_name = mysqli_real_escape_string($db, $g_name);
	
	// prepares query
	$name_query = "SELECT COUNT(*) AS names_found
					FROM groups
					WHERE LOWER(group_name) = LOWER('$g_name')";
	
	// if a group ID was provided, the query will ignore this group ID in possible matches
	if (isset($_GET['gid']) && !empty($_GET['gid'])) {
		$name_query = $name_query . " AND NOT group_id = $_GET[gid];";
	}
	else
	{
		$name_query = $name_query . ";";
	}
					
	// executes query
	$name_result = mysqli_query($db, $name_query);
	
	// checks query result
	if (!$name_result || (mysqli_num_rows($name_result) == 0)) {
		// TODO evaluate if this is the right way to handle this
		mysqli_close($db);
		echo "<error>11</error>";
		exit;
	}
	
	$name_row = mysqli_fetch_array($name_result);
	
	if ($name_row['names_found'] == 0) {
		$name_msg = "Name available!";
		$name_response = "available";
	}
	else
	{
		$name_msg = "Name taken! Please pick another.";
		$name_response = "taken";
	}
	
	// prints everything in the list of classes.
	$name_xml = "<name>";
	
	$name_xml = $name_xml . "<msg>$name_msg</msg>
			<response>$name_response</response>";
	
	$name_xml = $name_xml . "</name>";
	
	mysqli_close($db);
	
	echo $name_xml;

?>