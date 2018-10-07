<?php
	// set XML header
	header('Content-Type: application/xml'); 
	
	if ((!isset($_GET['sid'])) || empty($_GET['sid'])) {
		// TODO evaluate if this is the right way to handle this
		echo "<error>10</error>";
		exit;
	}
	
	// gets subject id`
	$s_id = $_GET['sid'];
	
	// Checks for HTML injection
	$s_id = htmlspecialchars($s_id);
	
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
	$s_id = mysqli_real_escape_string($db, $s_id);
	
	// prepares query
	$class_query = "SELECT c.class_id AS c_id, c.class_number AS c_number
					FROM classes c
					WHERE c.subject_id = $s_id
					ORDER BY c_number;";
					
	// executes query
	$class_result = mysqli_query($db, $class_query);
	
	// checks query result
	if (!$class_result || (mysqli_num_rows($class_result) == 0)) {
		// TODO evaluate if this is the right way to handle this
		mysqli_close($db);
		echo "<error>10</error>";
		exit;
	}
	
	// prints everything in the list of classes.
	$class_xml = "<classes>";
	
	while ($class_row = mysqli_fetch_array($class_result)) {
		// extract one class record
		$class_xml = $class_xml . "<class>
			<id>$class_row[c_id]</id>
			<number>$class_row[c_number]</number>
			</class>";
	}
	
	$class_xml = $class_xml . "</classes>";
	
	mysqli_close($db);
	
	echo $class_xml;

?>