<?php
	session_start();

	if (!($_SESSION["logged_in"])) {
		header("Location:account/login.html");
		exit;
	}
?>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>getGrouped: Dashboard</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="User dashboard when logged in." />

	<!-- if you are in a subdirectory of 'getgrouped', you must refer to the css file with href="../css/getgrouped.css" -->
	<link rel="stylesheet" type="text/css" href="css/getgrouped.css" title="style" />
</head>
<body class="home dashboard">
<?php
// error handling to override default error messages
function error_handler($code, $message, $file, $line) {
	throw new Exception($message);
}
set_error_handler('error_handler');

$page_loaded = FALSE;

try {
	// Checks that SESSION user is set
	if (!isset($_SESSION['user']) || empty($_SESSION['user'])) {
		session_unset();
		session_destroy();
		header("Location:../index.php?error=41");
		exit;
	}

	// retrieves username from session
	$u_acct_name = $_SESSION["user"];

	// checks for HTML injection
	$u_acct_name = htmlspecialchars($u_acct_name);

	// database setup
	$db_link = "studentdb-maria.gl.umbc.edu";
	$db_authenticate = "pautsch1";
	$db_name = "pautsch1";

	// connect to DB
	$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);

	if (mysqli_connect_errno()) {
		throw new Exception("Database error");
	}

	// checks for SQL injection
	$u_acct_name = mysqli_real_escape_string($db,$u_acct_name);

	// retrieves user id
	$user_id_query = "SELECT user_id FROM users WHERE user_acct_name = '$u_acct_name'";
	$user_id_result = mysqli_query($db,$user_id_query);

	// if user id search fails, throws exception and asks that user login again
	if ((!$user_id_result) || (mysqli_num_rows($user_id_result) != 1)) {
		session_unset();
		session_destroy();
		header("Location:../index.php?error=41");
		exit;
	}

	// if we reach this point, then the page could at least verify the user and connect to the database
	$page_loaded = TRUE;
?>
	<!-- Basic generic divs to delineate content areas are included by default -->

<div class="header">
	<!-- HEADER CONTENT -->
	<h1>getGrouped</h1>
	<div class="navbar">
		<p>
			<a href="dashboard.php">Dashboard</a>
			<span class="spacer">|</span>
			<a href="#friends">Friends</a>
			<span class="spacer">|</span>
			<a href="account/preferences.php">Preferences</a>
			<span class="spacer">|</span>
			<a href="account/logout.php">Logout</a>
		</p>
	</div>
</div>

<div class="spacer"></div>


<div class="main-content">
	<!-- MAIN CONTENT -->
	<?php
		/* ------------ FORWARDED ERROR CHECKING ------------- */
		// Users can be redirected back to the group view page if there was an error leaving or joining the group
		/*
			ERROR CODES
			1-10 Grouping
			11-20 Matching
			21-30 Scheduling
			31-40 Friending
			41-50 Account
			51-60 general

			GROUPING
			1 = leave group error
			2 = join group error
			3 = group create error
			4 = group delete error
			5 = group edit error
			7 = user not a member
			8 = remove member error
			9 = not owner error
			10 = group not found error
			
			MATCHING
			11 = Missing fields
			12 = no class found

			ACCOUNT
			41 = Error caused logout

			GENERAL
			61 = error leaving comment
			62 = database failure
		*/
		if (isset($_GET['error']) && !empty($_GET['error'])) {
			$error_code = $_GET['error'];
			$error_code = htmlspecialchars($error_code);

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
				case 7: $error_message = "That user is not a member of the group.";
						break;
				case 8: $error_message = "There was an error removing the member from the group.";
						break;
				case 9: $error_message = "You are not the owner of the group and cannot take that action.";
						break;
				case 10: $error_message = "That group does not exist, or the wrong ID was provided.";
						break;
				//Matching errors
				case 11: $error_message = "Please fill in the required fields.";
						break;
				case 12: $error_message = "No classes found with that subject name and course number.";
						break;
				case 61: $error_message = "There was an error leaving the comment. Please try again.";
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

	<?php
		/* ------------ FORWARDED SUCCESS CHECKING ------------- */
		// Users can be redirected to the group view page if an action was successful
		/*
			SUCCESS CODES
			1-10 Grouping
			11-20 Matching
			21-30 Scheduling
			31-40 Friending
			41-50 Account
			61-70 General

			61 = Leave Comment Successful
		*/
		if (isset($_GET['success']) && !empty($_GET['success'])) {
			$success_code = $_GET['success'];
			$success_code = htmlspecialchars($success_code);

			// checks error code
			switch ($success_code) {
				case 61: $success_message = "Your comment was left successfully!";
						break;
				default: $success_message = "Your action was successful!";
			}

			?>
				<div class="col-1 section success">
					<p class="center">
						<?php echo $success_message; ?>
					</p>
				</div>
			<?php
		}
	?>

	<div class="flex-container">
		<div class="calendar section dashboard-group col-2">
			<h4>Your Meetings</h4>
			<div class="spacer"></div>
			<ul class="fancy">
<?php
	// sets user ID
	$user_row_var = mysqli_fetch_array($user_id_result);
	$u_id = $user_row_var['user_id'];

	/* MEETINGS */
	// constructs query
	$meeting_query = "SELECT
						m.meeting_id AS m_id,
						m.meeting_name AS name,
						DATE_FORMAT(m.meeting_date,'%a, %c/%e') AS date,
						TIME_FORMAT(m.meeting_time,'%h:%i %p') AS time,
						a.attendance_status AS status,
						CONCAT(s.subject_prefix,' ',c.class_number) AS class
					FROM users u, attendances a, meetings m, groups g, classes c, subjects s
					WHERE u.user_id = a.user_id
					AND a.meeting_id = m.meeting_id
					AND m.group_id = g.group_id
					AND g.class_id = c.class_id
					AND c.subject_id = s.subject_id
					AND u.user_id = $u_id
					AND a.attendance_status != 'N'
					AND m.meeting_date >= SYSDATE() - interval 1 day
					ORDER BY m.meeting_date, m.meeting_time;";

	// calls query on db
	$meeting_result = mysqli_query($db,$meeting_query);

	// checks for bad meeting result
	if ((!$meeting_result) || (mysqli_num_rows($meeting_result) <= 0)) {
		// meeting result bad
		echo ("<li class='error'>You have no meetings</li>");
	}
	else
	{
		// meetings to display
		while ($meeting_row_var = mysqli_fetch_array($meeting_result)) {
			// constructs meeting string
			switch ($meeting_row_var['status']) {
				case 'A':
					$meeting_status = 'Attending';
					break;
				case 'N':
					$meeting_status = 'Not Attending';
					break;
				case 'M':
					$meeting_status = 'Maybe';
					break;
				default:
					$meeting_status = 'Invited';
			}

			$meeting_row_str = "<li><a href='scheduling/view.php?mid=$meeting_row_var[m_id]'>
				$meeting_row_var[name]:
				$meeting_row_var[date] at
				$meeting_row_var[time]
				($meeting_status)
				(<em>$meeting_row_var[class]</em>)
			</a></li>";

			// creates meeting row
			echo $meeting_row_str;
		}
	}
?>
			</ul>
		</div>

		<div class="groups section dashboard-group col-2">
			<h4>Your Groups</h4>
			<div class="spacer"></div>
			<ul class="fancy">
<?php
	/* GROUPS */
	// constructs query
	$group_query = "SELECT
						g.group_id AS g_id,
						g.group_name AS g_name,
						CONCAT(s.subject_prefix,' ',c.class_number) AS class
					FROM users u, grouped_users gu, groups g, classes c, subjects s
					WHERE u.user_id = gu.user_id
					AND gu.group_id = g.group_id
					AND u.user_id = $u_id
					AND g.class_id = c.class_id
					AND c.subject_id = s.subject_id
					ORDER BY class, g_name;";

	// calls query on db
	$group_result = mysqli_query($db,$group_query);

	// checks for bad group result
	if ((!$group_result) || (mysqli_num_rows($group_result) <= 0)) {
		// group result bad
		echo ("<li class='error'>You are in no groups</li>");
	}
	else
	{
		// groups to display
		while ($group_row_var = mysqli_fetch_array($group_result)) {
			// constructs group string
			$group_row_str = "<li><a href='grouping/view.php?gid=$group_row_var[g_id]'>
				$group_row_var[g_name]
				(<em>$group_row_var[class]</em>)
			</a></li>";

			// creates group row
			echo $group_row_str;

		}
	}
?>
			</ul>
		</div>
	</div>

	<div class="spacer"></div>

	<div class="flex-container">
		<div id="friends" class="friending section dashboard-group col-2">
			<h4>Your Friends</h4>
			<div class="spacer"></div>
			<ul class="fancy">
<?php
	/* FRIENDS */
	// constructs query
	$friend_query = "SELECT
						user_id AS u_id,
						user_acct_name AS acct_name,
						user_fname AS fname,
						user_lname AS lname
					FROM users
					WHERE user_id IN
					(SELECT user_id_one AS user_id
					FROM friended_users
					WHERE user_id_two = $u_id
					UNION
					SELECT user_id_two AS user_id
					FROM friended_users
					WHERE user_id_one = $u_id)
					ORDER BY lname, fname, acct_name;";

	// calls query on db
	$friend_result = mysqli_query($db,$friend_query);

	// checks for bad friend result
	if ((!$friend_result) || (mysqli_num_rows($friend_result) <= 0)) {
		// friend result bad
		echo ("<li class='error'>You haven't friended any users</li>");
	}
	else
	{
		// friends to display
		while ($friend_row_var = mysqli_fetch_array($friend_result)) {
			// constructs friend string
			$friend_row_str = "<li><a href='friending/user.php?uid=$friend_row_var[u_id]'>
				$friend_row_var[fname]
				$friend_row_var[lname]
				(<em>$friend_row_var[acct_name]</em>)
			</a></li>";

			// creates friend row
			echo $friend_row_str;

		}
	}
?>
			</ul>
		</div>

		<div class="navigation section dashboard-group col-2">
			<p>
				<a class="med-button" href="scheduling/create.php">Create a Meeting</a>
				<br/>
				<a class="med-button" href="grouping/create.php">Create a Group</a>
				<br/>
				<a class="med-button" href="matching/search.php">Find a Group</a>
				<br/>
				<a class="med-button" href="account/preferences.php">User Preferences</a>
			</p>
			<form action="friending/results.php" method="POST">
				<p class="button-group">
				<label>Find a Friend: </label><input id="friend_search" type="text" name="search_user_name"/>
				<input id="search_submit" class="small-button" type="submit" value="Search"/>
				<br/>
				<br/>
				</p>
			</form>
		</div>
	</div>
</div>



<?php
	// closes db
	mysqli_close($db);

	// end try block
}
catch (Exception $e) {
	// EXCEPTION HANDLING
	// if there was a username or db connection error, a new header needs to be produced
	if (!($page_loaded)) {
?>
	<div class="header">
		<h1>We're Sorry</h1>
		<div class="navbar">
			<p>
				<a href="dashboard.php">Dashboard</a>
				<span class="spacer">|</span>
				<a href="dashboard.php#friends">Friends</a>
				<span class="spacer">|</span>
				<a href="account/preferences.php">Preferences</a>
				<span class="spacer">|</span>
				<a href="account/logout.php">Logout</a>
			</p>
		</div>
	</div>

	<div class="spacer"></div>
<?php
	}
	else
	{
		// The main content below is printed if there is a serious DB error and no content can be displayed
?>
	<div class="main-content">
		<div class="section col-1">
			<p>
				<?php echo "There was a fatal error: " .$e->getMessage(); ?>
			</p>
			<div class="short-spacer"></div>
			<p class="center">
				<a class="med-button" href="dashboard.php">Try Again</a>
				<a class="med-button" href="account/logout.php">Logout</a>
				<a class="med-button" href="leave_comment.php">Contact Us</a>
			</p>
		</div>
	</div>
<?php
	}
}	// end of exception handling
?>

<div class="spacer"></div>

<div class="footer">
	<!-- FOOTER CONTENT -->
		<div class="navbar">
			<p>
				<a href="about.php">About</a>
				<span class="spacer">|</span>
				<a href="faq.php" target="_blank">FAQ</a>
				<span class="spacer">|</span>
				<a href="leave_comment.php">Contact Us</a>
			</p>
		</div>
	<p class="copyright">&copy; 2018 getGrouped</p>
</div>

<!-- Code was reused from the grouping use case for the dashboard -->
<script type="text/javascript" src="dashboard.js"></script>
<script type="text/javascript" src="grouping/validation.js"></script>
<script type="text/javascript" src="grouping/grouping.js"></script>


</body>
</html>
