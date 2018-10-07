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
	<title>getGrouped: Group Page</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Page for an single group. Includes upcoming meetings, members, subjects, and (if applicable) admin controls." />
	
	<!-- if you are in a subdirectory of 'getgrouped', you must refer to the css file with href="../css/getgrouped.css" -->
	<link rel="stylesheet" type="text/css" href="../css/getgrouped.css" title="style" />
</head>
<body class="grouping view">
	<!-- Basic generic divs to delineate content areas are included by default -->
	
<?php
// sets up custom error handling
function error_handler($code, $message, $file, $line) {
	throw new Exception($message);
}
set_error_handler('error_handler');

/*
	g_name
	g_desc
	g_subject
	g_class
	g_instructor
	g_location
	g_max_size
	g_num_meets
*/

$page_loaded = FALSE;

try {
	// Checks that SESSION user is set
	if (!isset($_SESSION['user']) || empty($_SESSION['user'])) {
		session_unset();
		session_destroy();
		header("Location:../index.php?error=41");
		exit;
	}
	
	// checks that GET is set
	if ((!isset($_GET['gid']) || (empty($_GET['gid'])))) {
		// if no group ID, no need to stay here, redirects back to the dashboard
		header("Location:../dashboard.php?error=10");
		exit;
	}
	
	// retrieves id of group requested
	$g_id = $_GET['gid'];
	
	// protects against HTML injection
	$g_id = htmlspecialchars($g_id);
	
	// DB setup
	$db_link = "studentdb-maria.gl.umbc.edu";
	$db_authenticate = "pautsch1";
	$db_name = "pautsch1";
	
	// connects to the database
	$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);
	
	// checks for connection error
	if (mysqli_connect_errno()) {
		throw new Exception("Unable to connect to the database.");
	}
	
	
	/* ------------- GET GROUP INFORMATION ------------- */
	
	// checks for sql injection
	$g_id = mysqli_real_escape_string($db, $g_id);
	
	// constructs query
	// query retrieves all regular group info, ID of group owner, and count of current members (using subquery)
	$group_query = "SELECT
					g.group_name AS g_name,
					CONCAT(s.subject_prefix,' ',c.class_number) AS g_class,
					g.group_instructor AS g_instructor,
					g.group_location AS g_location,
					g.group_max_size AS g_max_size,
					g.group_target_meets AS g_meets,
					g.group_description AS g_desc,
					u.user_acct_name AS o_acct_name,
					(SELECT COUNT(*)
						FROM grouped_users
						WHERE group_id = $g_id) AS g_current_size
				FROM groups g, grouped_users gu, users u, classes c, subjects s
				WHERE g.group_id = gu.group_id
				AND gu.user_id = u.user_id
				AND g.class_id = c.class_id
				AND c.subject_id = s.subject_id
				AND g.group_id = $g_id
				AND gu.role = 'Owner';";
				
	// queries DB
	$group_result = mysqli_query($db,$group_query);
	
	// checks for good result
	if (!$group_result || (mysqli_num_rows($group_result) == 0)) {
		mysqli_close($db);
		throw new Exception("Unable to locate group information.");
	}
	
	// marks page progress
	$page_loaded = TRUE;
	
	// fetches row for group info
	$g_row = mysqli_fetch_array($group_result);
	
	// Constructs location string
	if ($g_row['g_location'] != NULL) {
		$location_array = str_split($g_row['g_location']);
		$location_string = "";
		
		foreach ($location_array as $loc_key => $location_item) {
			// revises each array cell with semantically meaningful values
			switch ($location_item) {
				case 'C': $location_array[$loc_key] = 'On-Campus';
							break;
				case 'O': $location_array[$loc_key] = 'Off-Campus';
							break;
				case 'R': $location_array[$loc_key] = 'Remote ';
							break;
				default: continue;
			}
		}
		
		// reassembles new string from array
		$location_string = implode(", ", $location_array);
	}
	else
	{
		$location_string = "Not specified";
	}
	
	// checks instructor
	$g_instructor = $g_row['g_instructor'];
	if ($g_instructor == NULL) {
		$g_instructor = "Not specified";
	}
	
	// checks target meets
	$g_meets = $g_row['g_meets'];
	if ($g_meets == NULL) {
		$g_meets = "Not specified";
	}
	else
	{
		$g_meets = $g_meets . " per week";
	}
	
	// checks group max size
	if ($g_row['g_max_size'] == 11) {
		$g_max_size = "Unlimited";
	}
	else
	{
		$g_max_size = $g_row['g_max_size'];
	}
	
	// saves owner username for later comparison
	$o_acct_name = $g_row['o_acct_name'];
	
?>

<div class="header">
	<!-- HEADER CONTENT -->
	<h1><?php echo $g_row['g_name']; ?></h1>
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
	<?php
		// Checks for errors from another request
		// Users can be redirected back to the group view page if there was an error leaving or joining the group
		if (isset($_GET['error']) && !empty($_GET['error'])) {
			$error_code = $_GET['error'];
			$error_code = htmlspecialchars($error_code);
			
			/*
				1 = leave group error
				2 = join group error
				3 = group create error
				4 = group delete error
				5 = group edit error
				7 = user not a member
				8 = remove member error
				9 = not owner error
				10 = group not found error
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
	<div class="section information col-1">
		<table class="group-info">
			<tr class="header">
				<th>Class</th>
				<th>Instructor</th>
				<th>Locations</th>
			</tr>
			<tr>
				<td><?php echo $g_row['g_class']; ?></td>
				<td><?php echo $g_instructor; ?></td>
				<td><?php echo $location_string; ?></td>
			</tr>
		</table>
		
		<table class="group-info">
			<tr class="header">
				<th>Max Group Size</th>
				<th>Current Group Size</th>
				<th>Target Meetings</th>
			</tr>
			<tr>
				<td><?php echo $g_max_size; ?></td>
				<td><?php echo $g_row['g_current_size']; ?></td>
				<td><?php echo $g_meets; ?></td>
			</tr>
		</table>
		
		<p class="center"><?php echo $g_row['g_desc']; ?></p>
	</div>
	
	<div class="short-spacer"></div>
	
	<div class="flex-container">
		<div class="section col-2 meetings">
			<h4>
				Upcoming Meetings
			</h4>
			<ul class="fancy">
<?php
	/* ------------- GROUP MEETINGS ------------- */
	// constructs query
	$meeting_query = "SELECT
			m.meeting_id AS m_id,
			m.meeting_name AS m_name,
			DATE_FORMAT(m.meeting_date,'%a, %c/%e') AS m_date,
			TIME_FORMAT(m.meeting_time,'%h:%i %p') AS m_time
		FROM meetings m, groups g
		WHERE m.group_id = g.group_id
		AND g.group_id = $g_id
		AND m.meeting_date >= SYSDATE() - interval 1 day
		ORDER BY m_date, m_time, m_name;";
		
	// queries the DB
	$meeting_result = mysqli_query($db,$meeting_query);
	
	// checks response
	if (!$meeting_result || mysqli_num_rows($meeting_result) == 0) {
		// no meetings
		?>
			<li class="error">There are no meetings to display.</li>
		<?php
	}
	else
	{
		// meetings to display
		while ($meeting_row_var = mysqli_fetch_array($meeting_result)) {
			echo ("<li><a href='../scheduling/view.php?mid=$meeting_row_var[m_id]'>$meeting_row_var[m_name]: $meeting_row_var[m_date] at $meeting_row_var[m_time]</a></li>");
		}
	}
?>
			</ul>
		</div>
		
		<div class="section col-2 members">
			<h4>Group Members</h4>
			<ul class="fancy">
<?php
	/* ------------- GROUP MEMEBRS ------------- */
	$member_query = "SELECT
			u.user_id AS u_id,
			u.user_acct_name AS u_acct,
			CONCAT(u.user_fname,' ',u.user_lname,' (',u.user_acct_name,')') AS u_name,
			u.user_email AS u_email
		FROM users u, grouped_users gu
		WHERE u.user_id = gu.user_id
		AND gu.group_id = $g_id
		ORDER BY u.user_fname, u.user_lname, u.user_acct_name;";
	
	$member_result = mysqli_query($db,$member_query);
	
	if ((!$member_result) || (mysqli_num_rows($member_result) <= 0)){
		?>
		<li class='error'>Unable to load members</li>
		<?php
	}
	else
	{
		// display members
		
		// extracts the first member separate from the loop
		// this is done because we need an initial target for the email, and the others are in the CC's
		$first_member_row = mysqli_fetch_array($member_result);
		echo ("<li><a href='../friending/user.php?uid=$first_member_row[u_id]'>$first_member_row[u_name]</a></li>");
			
		// gets the first email
		$member_first_email = $first_member_row['u_email'];
		
		// begins tracking if current user is member of group
		$is_member = FALSE;
		
		// checks first member if they are current user
		if ($first_member_row['u_acct'] == $_SESSION['user']) {
			$is_member = TRUE;
		}
		
		// processes the rest of the members
		while ($member_row_var = mysqli_fetch_array($member_result)) {
			echo ("<li><a href='../friending/user.php?uid=$member_row_var[u_id]'>$member_row_var[u_name]</a></li>");
			
			// assembles an array of emails
			$member_email_array[] = $member_row_var['u_email'];
			
			// checks if each member is the current user
			if ($member_row_var['u_acct'] == $_SESSION['user']) {
				$is_member = TRUE;
			}
		}
	}
?>
			</ul>
		</div>
	</div>
	
	<div class="short-spacer"></div>
	
	<?php
		/* ------------- DETERMINING BUTTONS ------------- */
		// Checks user role
		if ($is_member) {

			// gets current user
			$u_name = $_SESSION['user'];
		
			// Checks if owner or member
			if ($u_name == $o_acct_name) {
				// is owner
				$is_owner = TRUE;
				?>
					<div class="section col-1 options owner">
				<?php
			}
			else
			{
				// is member
				$is_owner = FALSE;
				?>
					<div class="section col-1 options member">
				<?php
			}
			
			// starts to actually add the buttons now that div is in place
			echo "<p>";
			
			/*
				CREATE MEETING BUTTON
			*/
			?>
				<a class="med-button" href="../scheduling/create.php?gid=<?php echo $g_id; ?>">Create a Meeting</a>
			<?php
			
			/*
				EMAIL GROUP BUTTON
			*/
			if (isset($member_email_array) && !empty($member_email_array)) {
				
				$member_email_string = implode(", ",$member_email_array);
				
				echo ("<a class='med-button' href='mailto:$member_first_email?subject=$g_row[g_name] (via getGrouped)&cc=$member_email_string' target='_BLANK'>Email Group</a>");
			}
			else
			{
				// produces disabled button if member emails not available
				?>
					<a class="med-button disabled" href='' title='Unable to load user emails'>Email Group</a> 
				<?php
			}
			
			// adds two buttons if owner
			// adds only one button if not
			
			if ($is_owner) {
				// owner-only buttons
				/*
					EDIT GROUP BUTTON
				*/
				/*
					DELETE GROUP BUTTON
				*/
				?>
					<a class="med-button special" href="edit.php?gid=<?php echo $g_id; ?>">Edit Group Settings</a>
					
					<a class="med-button warning" href="delete.php?gid=<?php echo $g_id; ?>">Delete Group</a>
				<?php
			}
			else {
				// member-only button
				/*
					LEAVE GROUP BUTTON
				*/
				?>
					<a class="med-button special" href="leave.php?gid=<?php echo $g_id; ?>">Leave Group</a>
				<?php
			}
			
		}
		else
		{
			// is non-member
			/*
				JOIN GROUP BUTTON
			*/
			?>
				<div class="section col-1 options">
					<p>
						<a class="med-button special" href="join.php?gid=<?php echo $g_id; ?>">Join Group</a>
			<?php
		}	
	?>
		</p>
	</div>
<?php
	mysqli_close($db);
} // end try block
catch (Exception $e) {
	// handles exceptions
	if ($page_loaded) {
		echo ("There was an error: " . $e->getMessage());
		mysqli_close($db);
	}
	else
	{
	?>
		<div class="header">
			<!-- HEADER CONTENT -->
			<h1>Sorry!</h1>
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
				Oops! We weren't able to display a group.
				<br/>
				<br/>
				<?php echo $e->getMessage(); ?>
			</p>
			<div class="short-spacer"></div>
			<p class="center">
				<a class="med-button" href="../dashboard.php">Return to the Dashboard</a>
				<a class="med-button" href="../leave_comment.php">Contact Us</a>
			</p>
		</div>
	<?php
	} // end exception handling
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

</body>
</html>