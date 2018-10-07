<?php
	session_start();

	if (!($_SESSION["logged_in"])) {
		header("Location:../account/login.html");
		exit;
	}
?>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>getGrouped: Create a Group</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Page for group creation." />

	<!-- if you are in a subdirectory of 'getgrouped', you must refer to the css file with href="../css/getgrouped.css" -->
	<link rel="stylesheet" type="text/css" href="../css/getgrouped.css" title="style" />

	<!-- Prototype -->
	<script type="text/javascript" src=" https://ajax.googleapis.com/ajax/libs/prototype/1.7.3.0/prototype.js"></script>

</head>
<body class="grouping create">
	<!-- Basic generic divs to delineate content areas are included by default -->
	


<div class="header">
	<!-- HEADER CONTENT -->
	<h1>Create a Group</h1>
	<div class="navbar">
		<p>
			<a href="../dashboard.php">Dashboard</a>
			<span class="spacer">|</span>
			<a href="../dashboard.php#friends">Friends</a>
			<span class="spacer">|</span>
			<a href="../account/preferences.php">Preferences</a>
			<span class="spacer">|</span>
			<a href="../account/logout.php">Logout</a>
		</p>
	</div>
</div>

<div class="spacer" id="first-spacer"></div>

<?php
// error handling to override default error messages
function error_handler($code, $message, $file, $line) {
	throw new Exception($message);
}
set_error_handler('error_handler');

try {
	// Checks that user is set
	if (!isset($_SESSION['user']) || empty($_SESSION['user'])) {
		session_unset();
		session_destroy();
		header("Location:../index.php?error=41");
		exit;
	}
	
	// DB setup
	$db_link = "studentdb-maria.gl.umbc.edu";
	$db_authenticate = "pautsch1";
	$db_name = "pautsch1";
	
	// Connect to DB
	$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);
	
	// checks for DB error
	if (mysqli_connect_errno()) {
		throw new Exception("There was a problem connecting to the database.");
	}
	
	// Creates subject query
	$subject_query = "SELECT
						subject_id AS s_id,
						CONCAT(subject_name,' (',subject_prefix,')') AS s_name
					FROM subjects
					ORDER BY subject_name;";		
	$subject_result = mysqli_query($db,$subject_query);
	if (!$subject_result || (mysqli_num_rows($subject_result) == 0)) {
		mysqli_close($db);
		throw new Exception("There was a problem retrieving the list of subjects.");
	}

?>

<div class="main-content">

<?php
	// Checks for previous failure in the creation of the group
	if (isset($_GET['error']) AND !empty($_GET['error'])) {
		// report errors if error GET
		$error_code = $_GET['error'];
		$error_code = htmlspecialchars($error_code);
		
		/*
			1 = leave group error
			2 = join group error
			3 = group create error
			4 = group delete error
			5 = group edit error
			9 = user not group owner
			10 = group doesn't exist
		*/
		
		// checks error code
		switch ($error_code) {
			case 1: $error_message = "There was an error joining the group. Please try again.";
					break;
			case 2: $error_message = "There was an error leaving the group. Please try again.";
					break;
			case 3: $error_message = "There was an error creating the group. Please try again.";
					break;
			case 4: $error_message = "There was an error deleting the group. Please try again.";
					break;
			case 5: $error_message = "There was an error editing the group. Please try again.";
					break;
			case 6: $error_message = "You cannot take that action against the owner of the group.";
					break;
			case 7: $error_message = "That user is not a member of the group.";
					break;
			case 8: $error_message = "There was an error removing the member from the group.";
					break;
			case 9: $error_message = "You are not the owner of the group and cannot take that action.";
					break;
			case 10: $error_message = "That group does not exist, or the wrong ID was provided.";
					break;
			case 62: $error_message = "There was an error connecting to the database. Please try again or contact us to resolve the problem.";
					break;
			default: $error_message = "There was an unknown error during your last action.";
		}
		?>
		<div class="col-1 section warning">
			<p class="center">
				<?php echo $error_message; ?>
			</p>
		</div>
		<?php
	}
?>

	<!-- MAIN CONTENT -->
	<div class="section col-1">
	<form class="aligned" method="POST" action="create_confirm.php">
		<p>
			<br/>
			<label>Group name<span class="warning">*</span>
			</label>
			
			<input type="text" name="g_name" id="g_name" maxlength="50" />
			<br/><br/>
		</p>

		<p class="vertical">
			<label>Group description<span class="warning">*</span>
				
			</label>
			<textarea name="g_desc" id="g_desc" rows="3"></textarea>
			<br/>
			<br/>

			<label>Subject name<span class="warning">*</span>
				<span id="subject-expand" class="expand-button">Expand</span>
			</label>
			<select name = "g_subject" id="g_subject" size="5">
			
			<?php
				// adds subjects
				while ($s_row = mysqli_fetch_array($subject_result)) {
					echo ("<option value='$s_row[s_id]'> $s_row[s_name] </option>");
				}
				
				// closes db
				mysqli_close($db);
			?>
			
			</select>
			<br/><br/>
		
			<label>Course number<span class="warning">*</span><span id="class-expand" class="expand-button">Expand</span></label>
			<select name="g_class" id="g_class">
				<option value="">--</option>
			<!-- This section will be dynamically updated with JavaScript -->
			<!-- more PHP may be added at a later time -->
				<!-- <option value="1">101</option>
				<option value="1">201</option>
				<option value="1">301</option>
				<option value="1">420</option>
				<option value="2">436</option>
				<option value="3">448</option>
				<option value="4">450</option> -->
			</select>
			<br/><br/>
		</p>
		<p>
			<label>Instructor (last name)</label>
			<input type="text" name="g_instructor" id="g_instructor" maxlength="25000" />
			<br/><br/>

			<label>Meeting location</label>
			<span id="g_location">
				<input type="checkbox" name="g_location[]" id="g_check_campus" value="C" checked>On-Campus</input>
				<input type="checkbox" name="g_location[]" id="g_check_off" value="O">Off-Campus</input>
				<input type="checkbox" name="g_location[]" id="g_check_remote" value="R">Remote</input>
			</span>
			<br/><br/>

			<label>Max group size<span class="warning">*</span></label>
			<select name="g_max_size" id="g_max_size">
				<option value="">--</option>
				<option value="2">2</option>
				<option value="3">3</option>
				<option value="4">4</option>
				<option value="5">5</option>
				<option value="6">6</option>
				<option value="7">7</option>
				<option value="8">8</option>
				<option value="9">9</option>
				<option value="10">10</option>
				<option value="11">N/A</option>
			</select>
			<br/><br/>

			<label>Meetings per week</label>
			<select name="g_num_meets" id="g_num_meets">
				<option value="NULL">--</option>
				<option value="1">1</option>
				<option value="2">2</option>
				<option value="3">3</option>
				<option value="4">4</option>
				<option value="5">5</option>
				<option value="6">6</option>
				<option value="7">7+</option>
			</select>
			<br/>
			<br/>

			<input id="create_submit" class="small-button" type="submit" value="Create Group" />
			<br/>
			<input id="create_reset" class="small-button warning" type="reset" value="Reset Fields" />
		</p>
	</form>
	<?php
} // end of try block
catch (Exception $e) {
	// handles catastrophic errors loading the create.php page
	?>
		<p class="center"><?php echo $e->getMessage(); ?></p>
		<div class="short-spacer"></div>
		<p class="center">
			<a class="med-button" href="create.php">Try Again</a>
			<a class="med-button" href="../leave_comment.php">Contact Us</a>
		</p>
	<?php
}
?>
	</div>
</div>

<div class="spacer"></div>

<div class="footer">
	<!-- FOOTER CONTENT -->
	<div class="navbar">
		<p>
			<a href="../about.php">About</a>
			<span class="spacer">|</span>
			<a href="../faq.php">FAQ</a>
			<span class="spacer">|</span>
			<a href="../leave_comment.php">Contact Us</a>
		</p>
	</div>
	<p class="copyright">&copy; 2018 getGrouped</p>
</div>

<script type="text/javascript" src="ajax.js"></script>
<script type="text/javascript" src="grouping.js"></script>
<script type="text/javascript" src="validation.js"></script>
<script type="text/javascript" src="create.js"></script>

</body>
</html>
