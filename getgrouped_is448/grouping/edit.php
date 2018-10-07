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
	<title>getGrouped: Edit Group</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Page for editing your group settings." />
	
	<!-- if you are in a subdirectory of 'getgrouped', you must refer to the css file with href="../css/getgrouped.css" -->
	<link rel="stylesheet" type="text/css" href="../css/getgrouped.css" title="style" />

	<!-- Prototype -->
	<script type="text/javascript" src=" https://ajax.googleapis.com/ajax/libs/prototype/1.7.3.0/prototype.js"></script>
</head>
<body class="grouping edit">
	<!-- Basic generic divs to delineate content areas are included by default -->
	
<?php
// begin try block
$page_loaded = FALSE;

try {
	// check if group GET
	// ABORT IF FAIL
	if (!isset($_GET['gid']) || empty($_GET['gid'])) {
		header("Location:../dashboard.php?error=10");
		exit;
	}
	
	// check if username SESSION
	// ABORT IF FAIL
	if (!isset($_SESSION['user']) || empty($_SESSION['user'])) {
		session_unset();
		session_destroy();
		header("Location:../index.php?error=41");
		exit;
	}
	
	// gets username and group idate
	$u_acct = $_SESSION['user'];
	$u_acct = htmlspecialchars($u_acct);
	$g_id = $_GET['gid'];
	$g_id = htmlspecialchars($g_id);
	
	// connect to DB
	// ABORT IF FAIL
	
	// DB setup
	$db_link = "studentdb-maria.gl.umbc.edu";
	$db_authenticate = "pautsch1";
	$db_name = "pautsch1";
	
	// connects to the database
	$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);
	
	// checks connection
	if (mysqli_connect_errno()) {
		throw new Exception("Unable to connect to the database");
	}
	
	// query for group
	// ABORT IF FAIL
	
	// checks for sql injection
	$u_acct = mysqli_real_escape_string($db,$u_acct);
	$g_id = mysqli_real_escape_string($db,$g_id);
	
	// prepares query
	$group_query = "SELECT
						g.group_name AS g_name,
						g.group_description AS g_desc,
						CONCAT(s.subject_prefix,' ',c.class_number) AS g_class,
						s.subject_id AS g_s_id,
						c.class_id AS g_c_id,
						g.group_instructor AS g_instructor,
						g.group_location AS g_location,
						g.group_max_size AS g_size,
						g.group_target_meets AS g_meets,
						gu.role AS u_role
					FROM groups g, grouped_users gu, users u, classes c, subjects s
					WHERE g.group_id = gu.group_id
					AND gu.user_id = u.user_id
					AND g.class_id = c.class_id
					AND c.subject_id = s.subject_id
					AND g.group_id = $g_id
					AND u.user_acct_name = '$u_acct'
					ORDER BY g_class, g_name;";
					
	// queries the DB
	$group_result = mysqli_query($db,$group_query);
	
	// exits if query fails
	if (!$group_result || (mysqli_num_rows($group_result) == 0)) {
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=5");
		exit;
	}
	
	// fetches row
	$group_row = mysqli_fetch_array($group_result);
	
	// exits if user not owner
	if ($group_row['u_role'] != 'Owner') {
		mysqli_close($db);
		header("Location:view.php?gid=$g_id&error=9");
		exit;
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
	
	// Creates class query
	/* NOTE!!! This may change radically with the introduction of JavaScript to handle dynamic updating of the class list based on subject update. */
	$class_query = "SELECT
						class_id AS c_id,
						class_number AS c_number
					FROM classes
					WHERE subject_id = $group_row[g_s_id]
					ORDER BY class_number;";		
	$class_result = mysqli_query($db,$class_query);
	if (!$class_result || (mysqli_num_rows($class_result) == 0)) {
		mysqli_close($db);
		throw new Exception("There was a problem retrieving the list of classes.");
	}
	
	// page loaded enough to display some information
	$page_loaded = TRUE;
	
	// read group query results into header
?>

<div class="header">
	<!-- HEADER CONTENT -->
	<h1>Edit Group: <?php echo $group_row['g_name']; ?></h1>
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
	
<div class="main-content">

<?php
	// check if error GET
	if (isset($_GET['error']) && !empty($_GET['error'])) {
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
	
	// check if success GET
	if (isset($_GET['success']) && !empty($_GET['success'])) {
		?>
			<div class="col-1 section success">
				<p class="center">
					Your edit was saved successfully!
				</p>
			</div>
		<?php
	}
	
	// read group query results into body
?>
	<!-- MAIN CONTENT -->
	<div class="flex-container">
		<div class="section col-12">
		<form class="aligned" method="POST" action="edit_confirm.php?gid=<?php echo $g_id; ?>">
			<br/>
			<p>
				<label>Group Name<span class="warning">*</span></label>
				<input type="text" name="g_name" id="g_name" maxlength="50" value="<?php echo $group_row['g_name']; ?>"/>
				<br/><br/>
			</p>
			
			<p class="vertical">
				<label>Group Description<span class="warning">*</span></label>
				<textarea name="g_desc" id="g_desc" rows="3"maxlength="25000" ><?php echo $group_row['g_desc']; ?></textarea>
				<br/><br/>
				
				<label>Current Class</label> <strong><?php echo $group_row['g_class']; ?></strong>
				<br/><br/>
				
				<label>New Subject<span id="subject-expand" class="expand-button">Expand</span></label>
				<select name = "g_subject" id="g_subject" size="5">
				<br/>
			<?php
				// populates Subjects
				while ($s_row = mysqli_fetch_array($subject_result)) {
					if ($s_row['s_id'] == $group_row['g_s_id']) {
						echo ("<option value='$s_row[s_id]' selected> $s_row[s_name] </option>");
					}
					else {
						echo ("<option value='$s_row[s_id]'> $s_row[s_name] </option>");
					}
				}
			?>
				</select>
				<br/><br/>
				
				<label>New Course Number<span id="class-expand" class="expand-button">Expand</span></label>
				<select name="g_class" id="g_class">
			<!-- This section will be dynamically updated with JavaScript -->
			<!-- more PHP may be added at a later time -->
			<?php
				// populates classes
				while ($c_row = mysqli_fetch_array($class_result)) {
					if ($c_row['c_id'] == $group_row['g_c_id']) {
						echo ("<option value='$c_row[c_id]' selected> $c_row[c_number] </option>");
					}
					else {
						echo ("<option value='$c_row[c_id]'> $c_row[c_number] </option>");
					}
				}

					/* <option value="none" selected>New Class</option>
					<option value="1">101</option>
					<option value="1">201</option>
					<option value="1">301</option>
					<option value="1">IS 420</option>
					<option value="2">IS 436</option>
					<option value="3">IS 448</option>
					<option value="4">IS 450</option> */
			?>
				</select>
				<br/><br/>
			</p>
			
			<p>
				
				<label>Instructor (last name)</label>
				<input type="text" name="g_instructor" id="g_instructor" maxlength="50" value="<?php if (!empty($group_row['g_instructor'])){echo $group_row['g_instructor'];} ?>" />
				<br/><br/>
				
				<label>Meeting Location</label>
<?php
	// determines location
	$g_loc_str = $group_row['g_location'];

	$on_campus = preg_match("/C/",$g_loc_str);
	$off_campus = preg_match("/O/",$g_loc_str);
	$remote = preg_match("/R/",$g_loc_str);
?>
				<span id="g_location">
				<input type="checkbox" name="g_location[]" id="g_check_campus" value="C" <?php if ($on_campus){echo "checked";} ?>><label class="checks">On-Campus</label>
				
				<input type="checkbox" name="g_location[]" id="g_check_off" value="O" <?php if ($off_campus){echo "checked";} ?>><label class="checks">Off-Campus</label>
				
				<input type="checkbox" name="g_location[]" id="g_check_remote" value="R" <?php if ($remote){echo "checked";} ?>><label class="checks">Remotely (virtual)</label>
				</span>
				<br/><br/>
				
				<label>Max Group Size<span class="warning">*</span></label>
				<select name="g_max_size" id="g_max_size">
<?php
	// determines class size
	$g_size = $group_row['g_size'];
?>
					<option value="2" <?php if ($g_size==2){echo "selected";} ?>>2 people</option>
					<option value="3" <?php if ($g_size==3){echo "selected";} ?>>3 people</option>
					<option value="4" <?php if ($g_size==4){echo "selected";} ?>>4 people</option>
					<option value="5" <?php if ($g_size==5){echo "selected";} ?>>5 people</option>
					<option value="6" <?php if ($g_size==6){echo "selected";} ?>>6 people</option>
					<option value="7" <?php if ($g_size==7){echo "selected";} ?>>7 people</option>
					<option value="8" <?php if ($g_size==8){echo "selected";} ?>>8 people</option>
					<option value="9" <?php if ($g_size==9){echo "selected";} ?>>9 people</option>
					<option value="10" <?php if ($g_size==10){echo "selected";} ?>>10 people</option>
					<option value="11" <?php if ($g_size==11){echo "selected";} ?>>No Limit</option>
				</select>
				<br/><br/>
				
				<label>Meetings per week</label>
				<select name="g_num_meets" id="g_num_meets">
<?php
	// determines target meetings per week
	if (empty($group_row['g_meets']) || ($group_row['g_meets'] == NULL)) {
		$g_meets = 0;
	}
	else
	{
		$g_meets = $group_row['g_meets'];
	}
?>
					<option value="NULL" <?php if ($g_meets==0){echo "selected";} ?>>--</option>
					<option value="1" <?php if ($g_meets==1){echo "selected";} ?>>1 per week</option>
					<option value="2" <?php if ($g_meets==2){echo "selected";} ?>>2 per week</option>
					<option value="3" <?php if ($g_meets==3){echo "selected";} ?>>3 per week</option>
					<option value="4" <?php if ($g_meets==4){echo "selected";} ?>>4 per week</option>
					<option value="5" <?php if ($g_meets==5){echo "selected";} ?>>5 per week</option>
					<option value="6" <?php if ($g_meets==6){echo "selected";} ?>>6 per week</option>
					<option value="7" <?php if ($g_meets==7){echo "selected";} ?>>7+ per week</option>
				</select>

				<br/>
				<br/>
				
				<input id="create_submit" class="small-button" type="submit" value="Update Group" />
				<br/>
			</p>
		</form>
		</div>
		<div class="section members col-3">
			<h4>Group Members</h4>
			<div class="spacer"></div>
			<ul class="fancy">
<?php	
	// query for members
	
	// prepares query
	$member_query = "SELECT
						u.user_id AS u_id,
						CONCAT(u.user_fname,' ',u.user_lname) AS u_name
					FROM users u, grouped_users gu
					WHERE u.user_id = gu.user_id
					AND gu.group_id = $g_id
					AND gu.role = 'Member'
					ORDER BY u.user_fname, u.user_lname, u.user_acct_name;";
					
	// executes query
	$member_result = mysqli_query($db,$member_query);
	
	// checks for errors
	if (!$member_result) {
		echo ("<li class='error'>Unable to load members.</li>");
	}
	else if (mysqli_num_rows($member_result) == 0) {
		echo ("<li class='error'>No members found</li>");
	}
	else {
		// read members into members section
		while ($member_row = mysqli_fetch_array($member_result)) {
			// line read
			echo ("<li><a href='../friending/user.php?uid=$member_row[u_id]'>$member_row[u_name]</a><a class='remove' href='remove.php?gid=$g_id&uid=$member_row[u_id]' title='Remove Member'>x</a></li>");
		}
	}
?>
			</ul>
		</div>
	</div>
	
	<div class="short-spacer"></div>
	
	<div class="section col-1 thin">
		<p class="center">
			<a class="med-button special wide" href="view.php?gid=<?php echo $g_id; ?>">Return to the Group</a>
		</p>
	</div>
<?php
	// end try block
	mysqli_close($db);
}
catch (Exception $e) {
	// handle exception
	if (!$page_loaded) {
		// major failure
		?>
		<div class="header">
			<!-- FAILURE HEADER CONTENT -->
			<h1>Edit Group Error</h1>
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

		<div class="spacer"></div>
			
		<div class="main-content">
			<div class="section col-1">
				<p class="center">
					<?php echo "There was a fatal error: " .$e->getMessage(); ?>
				</p>
				<div class="short-spacer"></div>
				<p class="center">
					<a class="med-button" href="../dashboard.php">Return to the Dashboard</a>
					<a class="med-button" href="../leave_comment.php">Contact Us</a>
				</p>
			</div>
		<?php
	}
	else {
		// minor failure
		echo "There was an error: " .$e->getMessage();
		mysqli_close($db);
	}
}
?>
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
<script type="text/javascript" src="edit.js"></script>

</body>
</html>