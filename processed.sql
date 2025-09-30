SELECT 
    COALESCE(A.UserID, B.UserID) AS userid,
    A.UserID,
    A.Name,
    A.Surname,
    A.Email,
    A.Gender,
    A.Race,
    A.Age,
     -- Age bucket
    CASE
        WHEN Age BETWEEN 0 AND 12 THEN 'Child'
        WHEN Age BETWEEN 13 AND 18 THEN 'Teenager'
        WHEN Age BETWEEN 18 AND 25 THEN 'Youth'
        WHEN Age BETWEEN 26 AND 35 THEN 'Elder Youth'
        WHEN Age BETWEEN 36 AND 45 THEN 'Adult'
        ELSE '46+'
    END AS age_bucket,
    A.Province,
        A.`Social Media Handle`,
        B.Channel2,
        B.RecordDate2,
        -- Fixed time bucket using try_to_timestamp
        CASE
            WHEN RecordDate2 IS NULL THEN NULL
            WHEN HOUR(try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 18 AND 22 THEN 'Evening'
            ELSE 'Night'
        END AS time_bucket,
        B.Duration2,
        CASE
            WHEN Duration2 IS NULL THEN NULL
            WHEN CAST(Duration2 AS INT) BETWEEN 0 AND 5 THEN '0-5 mins'
            WHEN CAST(Duration2 AS INT) BETWEEN 6 AND 15 THEN '6-15 mins'
            WHEN CAST(Duration2 AS INT) BETWEEN 16 AND 30 THEN '16-30 mins'
            ELSE '31+ mins'
        END AS engagement_bucket
    FROM bright_tv_user_profiles AS A
    FULL OUTER JOIN bright_tv_viewership AS B
    ON A.UserID = B.UserID

    SELECT
        COUNT(DISTINCT COALESCE(A.UserID, B.UserID)) AS total_users
    FROM bright_tv_user_profiles AS A
    FULL OUTER JOIN bright_tv_viewership AS B
        ON A.UserID = B.UserID;

    SELECT
        ROUND(AVG(CAST(Duration2 AS DOUBLE)), 2)AS avg_viewing_duration
    FROM bright_tv_viewership;

    SELECT 
    time_bucket,
    COUNT(*) AS views
FROM (
    SELECT 
        CASE
            WHEN RecordDate2 IS NULL THEN NULL
            WHEN HOUR(try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN HOUR(try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(try_to_timestamp(RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 18 AND 22 THEN 'Evening'
            ELSE 'Night'
        END AS time_bucket
    FROM bright_tv_viewership
) t
GROUP BY time_bucket
ORDER BY views DESC
LIMIT 1;

SELECT 
    Gender,
    engagement_bucket,
    COUNT(*) AS viewers
FROM (
    SELECT 
        A.Gender,
        CASE
            WHEN Duration2 IS NULL THEN NULL
            WHEN CAST(Duration2 AS INT) BETWEEN 0 AND 5 THEN '0-5 mins'
            WHEN CAST(Duration2 AS INT) BETWEEN 6 AND 15 THEN '6-15 mins'
            WHEN CAST(Duration2 AS INT) BETWEEN 16 AND 30 THEN '16-30 mins'
            ELSE '31+ mins'
        END AS engagement_bucket
    FROM bright_tv_user_profiles AS A
    LEFT JOIN bright_tv_viewership AS B
        ON A.UserID = B.UserID
) t
GROUP BY Gender, engagement_bucket;
