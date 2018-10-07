<?php
  session_start();

  if (isset($_SESSION["logged_in"]) AND ($_SESSION["logged_in"])) {
  	header("Location:dashboard.php");
  	exit;
  }
  else
  {
?>

<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns = "http://www.w3.org/1999/xhtml">
<head>
	<title>getGrouped: Welcome</title>
	<meta name="author" content="Jake Ruth" />
	<meta name="keywords" content="is448, bellero, getgrouped" />
	<meta name="description" content="Homepage when user NOT logged in." />
	
	<!-- if you are in a subdirectory of 'getgrouped', you must refer to the css file with href="../css/getgrouped.css" -->
	<link rel="stylesheet" type="text/css" href="css/getgrouped.css" title="style" />
</head>
<body class="home homepage">
	<!-- Basic generic divs to delineate content areas are included by default -->
	
<div class="header">
	<!-- HEADER CONTENT -->
	<h1>getGrouped</h1>
	<div class="navbar">
		<p>
			<a href="about.php">About</a>
			<span class="spacer">|</span> 
			<a href="faq.php">FAQ</a>
			<span class="spacer">|</span> 
			<a href="email_getgrouped.php" target="_blank">Contact Us</a>
			<span class="spacer">|</span> 
			<a href="account/login.html">Login</a>
		</p>
	</div>
</div>

<div class="spacer"></div>
	
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
			51-60 general
			
			41 = Error caused logout
			
			61 = error leaving comment
			62 = database failure
		*/
		if (isset($_GET['error']) && !empty($_GET['error'])) {
			$error_code = $_GET['error'];
			$error_code = htmlspecialchars($error_code);
			
			// checks error code
			switch ($error_code) {
				case 41: $error_message = "There was a fatal error that caused you to be logged out. Please login again.";
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
			
			// checks success code
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
	<!-- MAIN CONTENT -->
	<div class="section col-1">
		<a class="big-button" href = "account/signup.html">Get Started - Create an Account!</a>
		<a class="big-button" href = "account/login.html">Sign into your Account</a>
		<h2>The study group website for college students!</h2>
		<p>
		This site is for college students who want to meet up and study with other students who are taking the same classes at the same university! With getGrouped, it has never been easier to create a study group, meet up, and study with students with the same goals as you!
		</p>
	</div>
	<a class="image" href="https://s3.amazonaws.com/StartupStockPhotos/uploads/17.jpg">
		<img src="images/home.png" alt="Get Ready to Study" />
	</a>
</div>

<div class="spacer"></div>

<div class="footer">
	<!-- FOOTER CONTENT -->
	<p class="copyright">&copy; 2018 getGrouped</p>
</div>

</body>
<?php } ?>
</html>