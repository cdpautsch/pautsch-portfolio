/* MY DATABASE NAME & PASSWORD: pautsch1 */
/* You should use this script to create a copy of the tables in your own database, for testing queries, inserts, deletes, etc. The SQL commands you put into PHP should already be tested for accuracy this way. Verify all your SQL before using it in PHP, to keep SQL errors and PHP errors separate, and to maintain the integrity of the 'main' database (mine). */

/* ONLY USE THIS PART IF YOU WANT A HARD RESET OF ALL THE TABLES */
/* If you want to only delete information, you need to use a DELETE clause */
DROP TABLE IF EXISTS attendances;
DROP TABLE IF EXISTS meetings;
DROP TABLE IF EXISTS grouped_users;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS saved_searches;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS friended_users;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS comments;


/*
	user_photo is path to photo in /images/profile_images/
*/
CREATE TABLE users (
	user_id INTEGER(9) AUTO_INCREMENT NOT NULL,
	user_acct_name VARCHAR(25) NOT NULL UNIQUE,
	user_fname VARCHAR(25) NOT NULL,
	user_lname VARCHAR(50) NOT NULL,
	user_password VARCHAR(20) NOT NULL,
	user_email VARCHAR(50) NOT NULL,
	user_second_email VARCHAR(50),
	user_major VARCHAR(50),
	user_privacy BOOLEAN NOT NULL DEFAULT FALSE,
	user_biography TEXT NOT NULL,
	PRIMARY KEY (user_id)
);

/*
	user_id_one is initiating friend but the order shouldn't affect function
*/
CREATE TABLE friended_users (
	friended_id INTEGER(12) AUTO_INCREMENT NOT NULL,
	user_id_one INTEGER(9) NOT NULL,
	user_id_two INTEGER(9) NOT NULL,
	PRIMARY KEY (friended_id),
	FOREIGN KEY (user_id_one) REFERENCES users(user_id),
	FOREIGN KEY (user_id_two) REFERENCES users(user_id),
	UNIQUE (user_id_one, user_id_two)
);

/*
	subject_prefix is 'IS','ENGL',etc. Must be all caps.
*/
CREATE TABLE subjects (
	subject_id INTEGER(6) AUTO_INCREMENT NOT NULL,
	subject_name VARCHAR(50) NOT NULL,
	subject_prefix CHAR(4) NOT NULL,
	PRIMARY KEY (subject_id)
);

/*
	class number is numeric portion only. e.g. '448' and NOT 'IS 448'. The 'IS' part is retrieved based on its subject_id relation.
*/
CREATE TABLE classes (
	class_id INTEGER(9) AUTO_INCREMENT NOT NULL,
	subject_id INTEGER(6) NOT NULL,
	class_number INTEGER(5) NOT NULL,
	PRIMARY KEY (class_id),
	FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

/*
	saved_search_location: C (campus), O (off-campus), R (remote) (any combo of the three)
*/
CREATE TABLE saved_searches (
	saved_search_id INTEGER(12) AUTO_INCREMENT NOT NULL,
	user_id INTEGER(9) NOT NULL UNIQUE,
	class_id INTEGER(9) NOT NULL,
	saved_search_instructor VARCHAR(50),
	saved_search_section INTEGER(2),
	saved_search_size INTEGER(2),
	saved_search_meetings INTEGER(2),
	saved_search_location VARCHAR(3),
	PRIMARY KEY (saved_search_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id),
	FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

/*
	group_location: C (campus), O (off-campus), R (remote) (any combo of the three)
*/
CREATE TABLE groups (
	group_id INTEGER(9) AUTO_INCREMENT NOT NULL,
	class_id INTEGER(9) NOT NULL,
	group_name VARCHAR(50) NOT NULL UNIQUE,
	group_description TEXT NOT NULL,
	group_instructor VARCHAR(50),
	group_location VARCHAR(3) NOT NULL,
	group_max_size INTEGER(2) NOT NULL,
	group_target_meets INTEGER(2),
	PRIMARY KEY (group_id),
	FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

/*
	Role = 'owner' or 'member' only
*/
CREATE TABLE grouped_users (
	grouped_user_id INTEGER(12) AUTO_INCREMENT NOT NULL,
	user_id INTEGER(9) NOT NULL,
	group_id INTEGER(9) NOT NULL,
	role VARCHAR(8) NOT NULL,
	PRIMARY KEY (grouped_user_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id),
	FOREIGN KEY (group_id) REFERENCES groups(group_id),
	UNIQUE (user_id, group_id)
);

/*
	meeting_location: C (campus), O (off-campus), R (remote) (any combo of the three)
*/
CREATE TABLE meetings (
	meeting_id INTEGER(12) AUTO_INCREMENT NOT NULL,
	group_id INTEGER(9) NOT NULL,
	meeting_name VARCHAR(25) NOT NULL,
	meeting_date DATE NOT NULL,
	meeting_location VARCHAR(3) NOT NULL,
	meeting_location_detail VARCHAR(50) NOT NULL,
	meeting_description TEXT NOT NULL,
	meeting_materials VARCHAR(200),
	meeting_time TIME NOT NULL,
	meeting_duration INTEGER(3) NOT NULL,
	PRIMARY KEY (meeting_id),
	FOREIGN KEY (group_id) REFERENCES groups(group_id)
);

/*
	attendance_status: I (invited), A (attending), N (not attending), M (maybe) (can ONLY be ONE of these for each member)
*/
CREATE TABLE attendances (
	attendance_id INTEGER(12) AUTO_INCREMENT NOT NULL,
	user_id INTEGER(9) NOT NULL,
	meeting_id INTEGER(12) NOT NULL,
	attendance_status CHAR(1) NOT NULL,
	PRIMARY KEY (attendance_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id),
	FOREIGN KEY (meeting_id) REFERENCES meetings(meeting_id),
	UNIQUE (user_id, meeting_id)
);

CREATE TABLE comments (
	comment_id INTEGER(9) AUTO_INCREMENT NOT NULL,
	comment_name VARCHAR(25) NOT NULL,
	comment_email VARCHAR(25) NOT NULL,
	comment_text TEXT NOT NULL,
	comment_respond BOOLEAN NOT NULL DEFAULT FALSE,
	comment_date DATE NOT NULL,
	PRIMARY KEY (comment_id)
);

INSERT INTO comments (comment_name, comment_email, comment_text, comment_respond, comment_date) VALUES ('James T. Kirk', 'jamestkirk@gmail', 'This site is pretty great!', FALSE, SYSDATE());

INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('admin', 'admin', 'admin', 'admin', 'N/A@gmail.com', NULL, 'N/A', TRUE, 'admin');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('jkirk', 'James T.', 'Kirk', '000D0', 'jamestkirk@gmail.com', NULL, 'Starships', FALSE, 'All I ask is a tall ship and a star to sail her by...');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('thedoctor', 'Leonard', 'McCoy', 'abc123', 'entdoctor@gmail.com', NULL, 'Medicine', FALSE, 'I''m not writing any damn bio!');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('miracleWorker', 'Montgomery', 'Scott', 'A1A2B', 'iloveships@gmail.com', NULL, 'Engineering', FALSE, 'Call me Scotty!');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('logic4ever', 'Commander', 'Spock', 'idic', 'fascinating@gmail.com', NULL, 'Science', FALSE, 'Writing a biography would be illogical.');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('2fast2sulu', 'Hikaru', 'Sulu', 'fastfast', 'fastship@gmail.com', NULL, 'Fast Ships', FALSE, 'I like fast ships and I cannot lie.');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('nuclearWessels', 'Pavel', 'Chekov', 'anton', 'russiainventedthat@gmail.com', 'iforgotmyfirstemail@gmail.com', 'Weapons', FALSE, 'Have you heard of the Russian epic "Cindarella"? Where are my nuclear wessels!?!');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('commsgal21', 'Nyota', 'Uhura', 'comms', 'commsgal@gmail.com', NULL, 'Communications', TRUE, 'I''m a private person!');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('thediplomat', 'Jean Luc', 'Picard', '4lights', 'thefabulousfrenchman@gmail.com', NULL, 'Command', FALSE, 'Ah merde! I''m not writing this.');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('theEmissary', 'Benjamin', 'Sisko', 'farBeyond5tars', 'benlafayette@gmail.com', 'siskossons@gmail.com', 'Command', FALSE, 'I''m not Picard.');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('theVoyager', 'Kathryn', 'Janeway', 'donewithdelta', 'capkathryn@gmail.com', NULL, 'Archeology', TRUE, 'I am so done with being lost in the Delta Quadrant.');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('CaptainProton', 'Tom', 'Paris', 'oldschool', 'tparis@gmail.com', 'thecaptainproton@gmail.com', 'History', FALSE, 'I love all things 20th and 21st century!');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('TheKim', 'Harry', 'Kim', 'kimgeek', 'hkim@gmail.com', NULL, 'Science', FALSE, 'I just want a promotion, darnit!');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('firstcap', 'Jonathan', 'Archer', 'letsgo', 'thearcher@gmail.com', NULL, 'Exploration', FALSE, 'It''s been a long road, getting from there to here. It''s been a long time, but my time is finally near. And I will see my dream come alive at last. I will touch the sky. And they''re not gonna hold me down no more, no they''re not gonna change my mind... CAUSE I''VE GOT FAAAAAITH OF THE HEEEEAART!');
INSERT INTO users (user_acct_name, user_fname, user_lname, user_password, user_email, user_second_email, user_major, user_privacy, user_biography) VALUES ('reallylorca', 'Gabriel', 'Lorca', 'iamevil', 'not_evil@gmail.com', NULL, 'Warfare', FALSE, 'No I really am the real Gabriel Lorca. Nope. Definitely not from the mirror universe. Nope.');

INSERT INTO friended_users (user_id_one, user_id_two) VALUES (2, 3);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (2, 4);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (2, 5);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (2, 6);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (2, 7);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (2, 8);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (2, 9);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (2, 10);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (9, 4);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (9, 5);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (9, 10);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (3, 5);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (4, 7);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (5, 8);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (6, 7);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (6, 8);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (7, 8);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (11, 12);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (11, 13);
INSERT INTO friended_users (user_id_one, user_id_two) VALUES (12, 13);



INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Admin Sciences Accounting','ECAC');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Africana Studies','AFST');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('American Studies','AMST');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Ancient Studies','ANCS');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Anthropology','ANTH');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Applied Molecular Biology','AMB');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Arabic','ARBC');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Archaeology','ARCH');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Art','ART');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Asian Studies','ASIA');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Baltimore Student Exchange Program','BSEP');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Biology', 'BIOL');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Biotechnology','BTEC');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Chemistry','CHEM');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Computer Science','CMSC');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('English','ENGL');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Engineering','ENGR');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Information Systems','IS');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Mathematics','MATH');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Philosophy','PHIL');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Physics','PHYS');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Sociology','SCGL');
INSERT INTO subjects (subject_name, subject_prefix) VALUES ('Theatre','THTR');



INSERT INTO classes (subject_id, class_number) VALUES (18,'410');
INSERT INTO classes (subject_id, class_number) VALUES (18,'420');
INSERT INTO classes (subject_id, class_number) VALUES (18,'436');
INSERT INTO classes (subject_id, class_number) VALUES (18,'448');
INSERT INTO classes (subject_id, class_number) VALUES (18,'450');
INSERT INTO classes (subject_id, class_number) VALUES (18,'451');

INSERT INTO classes (subject_id, class_number) VALUES (1,'101');
INSERT INTO classes (subject_id, class_number) VALUES (2,'101');
INSERT INTO classes (subject_id, class_number) VALUES (3,'101');
INSERT INTO classes (subject_id, class_number) VALUES (4,'101');
INSERT INTO classes (subject_id, class_number) VALUES (5,'101');
INSERT INTO classes (subject_id, class_number) VALUES (6,'101');
INSERT INTO classes (subject_id, class_number) VALUES (7,'101');
INSERT INTO classes (subject_id, class_number) VALUES (8,'101');
INSERT INTO classes (subject_id, class_number) VALUES (9,'101');
INSERT INTO classes (subject_id, class_number) VALUES (10,'101');
INSERT INTO classes (subject_id, class_number) VALUES (11,'101');
INSERT INTO classes (subject_id, class_number) VALUES (12,'101');
INSERT INTO classes (subject_id, class_number) VALUES (13,'101');
INSERT INTO classes (subject_id, class_number) VALUES (14,'101');
INSERT INTO classes (subject_id, class_number) VALUES (15,'101');
INSERT INTO classes (subject_id, class_number) VALUES (16,'101');
INSERT INTO classes (subject_id, class_number) VALUES (17,'101');
INSERT INTO classes (subject_id, class_number) VALUES (18,'101');
INSERT INTO classes (subject_id, class_number) VALUES (19,'101');
INSERT INTO classes (subject_id, class_number) VALUES (20,'101');
INSERT INTO classes (subject_id, class_number) VALUES (21,'101');
INSERT INTO classes (subject_id, class_number) VALUES (22,'101');
INSERT INTO classes (subject_id, class_number) VALUES (23,'101');

INSERT INTO classes (subject_id, class_number) VALUES (1,'201');
INSERT INTO classes (subject_id, class_number) VALUES (2,'201');
INSERT INTO classes (subject_id, class_number) VALUES (3,'201');
INSERT INTO classes (subject_id, class_number) VALUES (4,'201');
INSERT INTO classes (subject_id, class_number) VALUES (5,'201');
INSERT INTO classes (subject_id, class_number) VALUES (6,'201');
INSERT INTO classes (subject_id, class_number) VALUES (7,'201');
INSERT INTO classes (subject_id, class_number) VALUES (8,'201');
INSERT INTO classes (subject_id, class_number) VALUES (9,'201');
INSERT INTO classes (subject_id, class_number) VALUES (10,'201');
INSERT INTO classes (subject_id, class_number) VALUES (11,'201');
INSERT INTO classes (subject_id, class_number) VALUES (12,'201');
INSERT INTO classes (subject_id, class_number) VALUES (13,'201');
INSERT INTO classes (subject_id, class_number) VALUES (14,'201');
INSERT INTO classes (subject_id, class_number) VALUES (15,'201');
INSERT INTO classes (subject_id, class_number) VALUES (16,'201');
INSERT INTO classes (subject_id, class_number) VALUES (17,'201');
INSERT INTO classes (subject_id, class_number) VALUES (18,'201');
INSERT INTO classes (subject_id, class_number) VALUES (19,'201');
INSERT INTO classes (subject_id, class_number) VALUES (20,'201');
INSERT INTO classes (subject_id, class_number) VALUES (21,'201');
INSERT INTO classes (subject_id, class_number) VALUES (22,'201');
INSERT INTO classes (subject_id, class_number) VALUES (23,'201');

INSERT INTO classes (subject_id, class_number) VALUES (1,'301');
INSERT INTO classes (subject_id, class_number) VALUES (2,'301');
INSERT INTO classes (subject_id, class_number) VALUES (3,'301');
INSERT INTO classes (subject_id, class_number) VALUES (4,'301');
INSERT INTO classes (subject_id, class_number) VALUES (5,'301');
INSERT INTO classes (subject_id, class_number) VALUES (6,'301');
INSERT INTO classes (subject_id, class_number) VALUES (7,'301');
INSERT INTO classes (subject_id, class_number) VALUES (8,'301');
INSERT INTO classes (subject_id, class_number) VALUES (9,'301');
INSERT INTO classes (subject_id, class_number) VALUES (10,'301');
INSERT INTO classes (subject_id, class_number) VALUES (11,'301');
INSERT INTO classes (subject_id, class_number) VALUES (12,'301');
INSERT INTO classes (subject_id, class_number) VALUES (13,'301');
INSERT INTO classes (subject_id, class_number) VALUES (14,'301');
INSERT INTO classes (subject_id, class_number) VALUES (15,'301');
INSERT INTO classes (subject_id, class_number) VALUES (16,'301');
INSERT INTO classes (subject_id, class_number) VALUES (17,'301');
INSERT INTO classes (subject_id, class_number) VALUES (18,'301');
INSERT INTO classes (subject_id, class_number) VALUES (19,'301');
INSERT INTO classes (subject_id, class_number) VALUES (20,'301');
INSERT INTO classes (subject_id, class_number) VALUES (21,'301');
INSERT INTO classes (subject_id, class_number) VALUES (22,'301');
INSERT INTO classes (subject_id, class_number) VALUES (23,'301');

INSERT INTO classes (subject_id, class_number) VALUES (9,'102');
INSERT INTO classes (subject_id, class_number) VALUES (12,'102');
INSERT INTO classes (subject_id, class_number) VALUES (14,'102');
INSERT INTO classes (subject_id, class_number) VALUES (16,'102');
INSERT INTO classes (subject_id, class_number) VALUES (19,'102');
INSERT INTO classes (subject_id, class_number) VALUES (20,'102');
INSERT INTO classes (subject_id, class_number) VALUES (9,'102');

INSERT INTO classes (subject_id, class_number) VALUES (12,'202');
INSERT INTO classes (subject_id, class_number) VALUES (14,'202');
INSERT INTO classes (subject_id, class_number) VALUES (16,'202');
INSERT INTO classes (subject_id, class_number) VALUES (19,'202');
INSERT INTO classes (subject_id, class_number) VALUES (20,'202');

INSERT INTO classes (subject_id, class_number) VALUES (5,'400');
INSERT INTO classes (subject_id, class_number) VALUES (6,'400');
INSERT INTO classes (subject_id, class_number) VALUES (13,'400');
INSERT INTO classes (subject_id, class_number) VALUES (14,'400');
INSERT INTO classes (subject_id, class_number) VALUES (17,'400');
INSERT INTO classes (subject_id, class_number) VALUES (21,'400');

INSERT INTO classes (subject_id, class_number) VALUES (4,'350');
INSERT INTO classes (subject_id, class_number) VALUES (8,'350');
INSERT INTO classes (subject_id, class_number) VALUES (10,'350');
INSERT INTO classes (subject_id, class_number) VALUES (22,'350');
INSERT INTO classes (subject_id, class_number) VALUES (23,'350');

INSERT INTO classes (subject_id, class_number) VALUES (15,'147');
INSERT INTO classes (subject_id, class_number) VALUES (15,'215');
INSERT INTO classes (subject_id, class_number) VALUES (15,'247');

INSERT INTO classes (subject_id, class_number) VALUES (18,'425');
INSERT INTO classes (subject_id, class_number) VALUES (18,'310');



INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (4, 'We Love IS', 'A group for those who love IS! All IS poses shall not be welcome! Look down upon the liberal arts peasants!', 'Pike', 'CR', 7, 3);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (69, 'Miracle Workers ''R Us', 'For those folks who love all things engineering and starships!!', 'Data', 'R', 10, 3);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (74, 'Logic meets Sociology', 'For those of who embrace logic, to examine human concepts of sociology and compare it with Vulcan research.', 'Sarek', 'OR', 5, 5);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (65, 'Oh God We Can''t Even', 'We don''t know how we ended up in this class or what''s it about. Please help us not fail.', 'Q', 'COR', 7, 7);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (45, 'English Self Tutoring', 'We can write and talk and read just fine but Lord help us if they want a fancy essay.', 'Ratburn', 'C', 11, 3);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (34, 'Anthropology Fans', 'Not our major, but we like it! But we also need help with it. Please only join if you''re truly interested in the subject!', 'Jackson', 'O', 10, 2);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (16, 'I want to be a Saumrai', 'I wanted to be a Samurai but it turns out Asian Studies doesn''t turn you into a Samurai', 'Watanabe', 'CR', 5, NULL);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (1, 'Information System Undergraduates', 'I couldn''t think of a better title.', 'Decker', 'OR', 4, 1);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (6, 'InfoSys Reviewers', 'I had to retake this class because apparently you can''t threaten to conquer the globe if the instructor doesn''t give you an A.', 'April', 'O', 11, 4);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (4, 'Who loves Web Programming? We do!', 'The name says it all!', 'Jellico', 'O', 3, 1);
INSERT INTO groups (class_id, group_name, group_description, group_instructor, group_location, group_max_size, group_target_meets) VALUES (4, 'Insert Clever IS Name Here', 'I''m so tired of studying that I cannot think of anything more clever.', 'Ross', 'C', 11, 5);

INSERT INTO grouped_users (group_id, user_id, role) VALUES (1, 2, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (2, 4, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (3, 5, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (4, 7, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (5, 6, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (6, 8, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (7, 7, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (1, 3, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (1, 4, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (2, 6, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (2, 7, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (3, 9, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (5, 4, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (5, 8, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (6, 9, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (7, 6, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (2, 2, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (6, 2, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (6, 11, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (5, 12, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (7, 13, 'Member');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (8, 14, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (9, 15, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (10, 14, 'Owner');
INSERT INTO grouped_users (group_id, user_id, role) VALUES (11, 15, 'Owner');

INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (1,'Regular IS Meetup','2018-06-17','C','At the library','First introductory meeting','none','21:00:00',60);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (1,'Regular IS Meetup','2018-06-24','C','At the library','Regular meeting','books or notes','21:00:00',60);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (1,'Regular IS Meetup','2018-06-01','C','At the library','Regular meeting','books or notes','21:00:00',60);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (1,'Special IS Study Session','2018-06-30','C','At the library, top floor','Getting ready for the first quiz.','Your notes!','21:00:00',60);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (2,'Weekly ENGR Standup','2018-06-23','R','on Skype','Ongoing meeting for the engineers!','Your engineering manuals','09:00:00',30);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (3,'Logic Meet','2018-06-29','O','Panera Bread is a logical place','Let us discuss logic and things.','Your logic','06:30:00',60);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (3,'Logic Discussion','2018-06-30','O','Panera Bread is still a logical place','Let us discuss logic and things.','Your logic','06:30:00',60);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (3,'Logic Roundtable','2018-06-01','O','Panera Bread is yet still a logical place','Let us discuss logic and things.','Your logic','06:30:00',60);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (6,'Weekend Get Together','2018-06-05','O','At Jim''s place','Let''s talk about cool anthropology things and drink Jim''s Romulan Ale I know he has.','BYOB','19:15:00',60);
INSERT INTO meetings (group_id, meeting_name, meeting_date, meeting_location, meeting_location_detail, meeting_description, meeting_materials, meeting_time, meeting_duration) VALUES (7,'Samurai Class','2018-06-07','C','At the gym','Let''s be samurai! (EDIT) Oh god I was wrong this isn''t a Samurai class this is Asian studies you need to bring books!','Katanas. (EDIT) I was wrong! bring books!','15:00:00',45);

INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (1, 2, 'A');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (2, 2, 'A');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (3, 2, 'A');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (4, 2, 'A');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (1, 3, 'M');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (2, 3, 'M');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (3, 3, 'N');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (4, 3, 'M');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (1, 4, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (2, 4, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (3, 4, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (4, 4, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (5, 4, 'A');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (5, 6, 'A');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (5, 7, 'N');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (5, 2, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (6, 5, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (6, 9, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (7, 5, 'M');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (7, 9, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (8, 5, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (8, 9, 'A');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (9, 8, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (9, 9, 'M');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (9, 2, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (10, 6, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (10, 7, 'I');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (9, 11, 'A');
INSERT INTO attendances (meeting_id, user_id, attendance_status) VALUES (10, 13, 'M');

INSERT INTO saved_searches (user_id, class_id, saved_search_instructor, saved_search_section, saved_search_size, saved_search_meetings, saved_search_location) VALUES (1, 1, NULL, NULL, NULL, NULL, NULL);

INSERT INTO saved_searches (user_id, class_id, saved_search_instructor, saved_search_section, saved_search_size, saved_search_meetings, saved_search_location) VALUES (2, 2, 'Pike', 1, 15, 3, NULL);













