select * from census_data;

select * from chicago_public_schools;

select * from chicago_crime_data;


--Write and execute a SQL query to list the school names, 
--community names and average attendance
--for communities with a hardship index of 98.

SELECT cps.Name_of_school ,cps.community_area_name,  
		cps.average_student_attendance
FROM chicago_public_schools AS cps left outer join  census_data AS ce
ON  cps.COMMUNITY_AREA_NUMBER = ce.COMMUNITY_AREA_NUMBER
WHERE ce.hardship_index =98;


--Write and execute a SQL query to list all crimes that took place at a 
--school. Include case number, crime type and community name.

SELECT cr.case_number, cr.primary_type, cen.community_area_name
FROM chicago_crime_data AS cr left outer join census_data AS cen 
on cr.community_area_number = cen.community_area_number
where cr.location_description = 'COLLEGE/UNIVERSITY GROUNDS';

--Exercise 2: Creating a View
CREATE VIEW Schools_data as (
SELECT  NAME_OF_SCHOOL 		as School_Name ,
		Safety_Icon 		as Safety_Rating,
		Family_Involvement_Icon as Family_Rating,
		Environment_Icon	as Environment_Rating,
		Instruction_Icon	as Instruction_Rating,
		Leaders_Icon 		as	Leaders_Rating,
		Teachers_Icon		as Teachers_Rating
FROM CHICAGO_PUBLIC_SCHOOLS);

---------------------------------------------------------------------------

select * from schools_data;

select school_name, leaders_rating from schools_data;


--Exercise 3: Creating a Stored Procedure

--Write the structure of a query to create or replace a stored procedure called 
--UPDATE_LEADERS_SCORE that takes a in_School_ID parameter as an integer and a in_Leader_Score
-- parameter as an integer. Don't forget to use the #SET TERMINATOR statement to use 
--the @ for the CREATE statement terminator.


--#SET TERMINATOR @  
CREATE OR REPLACE PROCEDURE UPDATE_LEADERS_SCORE 
	(IN in_School_ID INTEGER , IN in_Leader_Score INT)

LANGUAGE SQL
BEGIN

	
END                                                            
@                                                            
--#SET TERMINATOR ;


--Inside your stored procedure, write a SQL statement to update the Leaders_Score field 
--in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID to the value
-- in the in_Leader_Score parameter.


--#SET TERMINATOR @  
CREATE OR REPLACE PROCEDURE UPDATE_LEADERS_SCORE 
	(IN in_School_ID INT , IN in_Leader_Score INT)

LANGUAGE SQL
BEGIN

	UPDATE chicago_public_schools
		SET Leaders_Score = in_Leader_Score
		WHERE School_id = in_School_id;
	
	
END                                                            
@                                                            
--#SET TERMINATOR ;





--Inside your stored procedure, write a SQL IF statement to update the Leaders_Icon
--field in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID using
--the following information.



--#SET TERMINATOR @  
CREATE OR REPLACE PROCEDURE UPDATE_LEADERS_SCORE 
	(IN in_School_ID INT , IN in_Leader_Score INT)

LANGUAGE SQL
BEGIN

	UPDATE chicago_public_schools
		SET Leaders_Score = in_Leader_Score
		WHERE School_id = in_School_id;
		
	IF in_Leader_Score > 0 and in_Leader_Score < 20 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Very Weak'
			WHERE School_id = in_School_id;
			
	ELSEIF in_Leader_Score < 40 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Weak'
			WHERE School_id = in_School_id;
			
	ELSEIF in_Leader_Score < 60 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Average'
			WHERE School_id = in_School_id;
	
	ELSEIF in_Leader_Score < 80 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Strong'
			WHERE School_id = in_School_id;
			
	
	ELSEIF in_Leader_Score < 100 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Very Strong'
			WHERE School_id = in_School_id;
			
	END IF;				
		
END                                                            
@                                                            
--#SET TERMINATOR ;


--Write a query to call the stored procedure, passing a valid school ID 
--and a leader score of 50, to check that the procedure works as 
--expected.
ALTER TABLE chicago_public_schools 
ALTER COLUMN LEADERS_ICON
SET DATA TYPE varchar(20);

CALL UPDATE_LEADERS_SCORE ( 610038 , 50 );

select * from chicago_public_schools;

-------------------------------------------------------------------------------------
--Exercise 4: Using Transactions
--Update your stored procedure definition. Add a generic ELSE clause
-- to the IF statement that rolls back the current work if the score did
-- not fit any of the preceding categories.


--#SET TERMINATOR @  
CREATE OR REPLACE PROCEDURE UPDATE_LEADERS_SCORE 
	(IN in_School_ID INT , IN in_Leader_Score INT)

LANGUAGE SQL
BEGIN

	UPDATE chicago_public_schools
		SET Leaders_Score = in_Leader_Score
		WHERE School_id = in_School_id;
		
	IF in_Leader_Score > 0 and in_Leader_Score < 20 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Very Weak'
			WHERE School_id = in_School_id;
			
	ELSEIF in_Leader_Score < 40 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Weak'
			WHERE School_id = in_School_id;
			
	ELSEIF in_Leader_Score < 60 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Average'
			WHERE School_id = in_School_id;
	
	ELSEIF in_Leader_Score < 80 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Strong'
			WHERE School_id = in_School_id;
			
	
	ELSEIF in_Leader_Score < 100 THEN
		UPDATE chicago_public_schools
			SET Leaders_Icon = 'Very Strong'
			WHERE School_id = in_School_id;
	
	ELSE ROLLBACK WORK;
	
	END IF;				
		
	COMMIT WORK;
END                                                            
@                                                            
--#SET TERMINATOR ;


CALL UPDATE_LEADERS_SCORE(610038,38);

CALL UPDATE_LEADERS_SCORE(610038,101);
