<?php
	session_start();
?>
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>getGrouped: Leave a Comment</title>
	<meta name="author" content="Christian Pautsch" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Leave a comment for getGrouped administration." />
	
	<!-- if you are in a subdirectory of 'getgrouped', you must refer to the css file with href="../css/getgrouped.css" -->
	<link rel="stylesheet" type="text/css" href="css/getgrouped.css" title="style" />
</head>
<body class="home comment">
	<!-- Basic generic divs to delineate content areas are included by default -->
	
<div class="header">
	<!-- HEADER CONTENT -->
	<h1>Leave a Comment for getGrouped</h1>
	<div class="navbar">
	<?php
		if (isset($_SESSION["logged_in"]) && ($_SESSION["logged_in"])) {
			?>
		<p>
			<a href="dashboard.php">Dashboard</a>
			<span class="spacer">|</span>
			<a href="dashboard.php#friends">Friends</a>
			<span class="spacer">|</span>
			<a href="account/preferences.php">Preferences</a>
			<span class="spacer">|</span>
			<a href="account/logout.php">Logout</a>
		</p>
			<?php
		}
		else
		{
			?>
			<?php
		}
	?>
	</div>
</div>

<div class="spacer"></div>

<?php
	if (isset($_SESSION['user']) && !empty($_SESSION['user'])) {
		// gets username
		$u_acct = $_SESSION['user'];
		$u_acct = htmlspecialchars($u_acct);
		
		// DB setup
		$db_link = "studentdb-maria.gl.umbc.edu";
		$db_authenticate = "pautsch1";
		$db_name = "pautsch1";
		
		// connects to the database
		$db = mysqli_connect($db_link, $db_authenticate, $db_authenticate, $db_name);
		
		// checks connection
		if (mysqli_connect_errno()) {
			exit;
		}
		
		// checks for sql injection
		$u_acct = mysqli_real_escape_string($db,$u_acct);
		
		// prepares query
		$user_query = "SELECT CONCAT(user_fname,' ',user_lname)AS u_name, user_email AS u_email
						FROM users
						WHERE user_acct_name = '$u_acct';";
						
		// queries the DB
		$user_result = mysqli_query($db,$user_query);
		
		// exits if query fails
		if (!$user_result || (mysqli_num_rows($user_result) == 0)) {
			mysqli_close($db);
			exit;
		}
		
		// fetches row
		$user_row = mysqli_fetch_array($user_result);
		
		// fetches variables
		$u_name = $user_row['u_name'];
		$u_email = $user_row['u_email'];
	}
?>
	
<div class="main-content">

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
			
			61 = error leaving comment
		*/
		if (isset($_GET['error']) && !empty($_GET['error'])) {
			$error_code = $_GET['error'];
			$error_code = htmlspecialchars($error_code);
			
			// checks error code
			switch ($error_code) {
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
	<!-- MAIN CONTENT -->
	<div class="section col-1">
		<form class="aligned" method="POST" action="confirm_comment.php">
			<p class="center">
				Write a comment for getGrouped administration! Make sure to leave your email if you are not logged on, and we will get back to you if requested!
			</p>
			
			<p><br/>
				<label>Your Name <span class="warning">*</span></label>
				<input type="text" id="c_name" name="c_name" value="<?php if (isset($u_name)) { echo $u_name; } ?>"/>
				<br/>
				<br/>
				<label>Email <span class="warning">*</span></label>
				<input type="text" id="c_email" name="c_email" value="<?php if (isset($u_email)) { echo $u_email; } ?>"/>
			</p><br/>

			<p class="vertical">
				<label>Your Comment <span class="warning">*</span></label>
				<textarea id="c_comment" name="c_comment" rows="5"></textarea><br/><br/>
			</p><br/>
			<p>
				<label>Do you want us to contact you? <span class="warning">*</span></label>
				<input name="c_respond" type="radio" value="1">Yes</input>
				<input name="c_respond" type="radio" value="0" checked>No</input>
				<br/><br/>
				<input class="small-button" id="comment_submit" type="submit" value="Leave Comment" />
			</p>
		</form>
	</div>
</div>

<div class="spacer"></div>

<div class="footer">
	<!-- FOOTER CONTENT -->
	<?php
		if (isset($_SESSION["logged_in"]) && ($_SESSION["logged_in"])) {
			?>
	<div class="navbar">
		<p>
			<a href="about.php">About</a>
			<span class="spacer">|</span>
			<a href="faq.php">FAQ</a>
			<span class="spacer">|</span>
			<a href="email_getgrouped.php" target="_blank">Contact Us</a>
		</p>
	</div>
			<?php
		}
	?>
	<p class="copyright">&copy; 2018 getGrouped</p>
</div>

<!-- Code was reused from the grouping use case for the dashboard -->
<script type="text/javascript" src="comment.js"></script>
<script type="text/javascript" src="grouping/validation.js"></script>
<script type="text/javascript" src="grouping/grouping.js"></script>

</body>
</html>
