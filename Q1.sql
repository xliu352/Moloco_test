-- Imported data into MySQL Workbench running locally. I also used R to check results runned by MySQL.
-- Original data is saved under schema called "sampledata", and the file name is "sampledata", so sampledata.sampledata is used to locate the data table. 

-- Consider only the rows with country_id = "BDV" (there are 844 such rows). 
-- For each site_id, we can compute the number of unique user_id's found in these 844 rows. 
-- Which site_id has the largest number of unique users? And what's the number?

SELECT 
    x.site_id, x.user_count
FROM
    (SELECT DISTINCT
        site_id, COUNT(DISTINCT (user_id)) AS user_count
    FROM
        sampledata.sampledata
    WHERE
        country_id = 'BDV'
    GROUP BY site_id) x
ORDER BY x.user_count DESC
LIMIT 1;


-- Between 2019-02-03 00:00:00 and 2019-02-04 23:59:59, there are four users who visited a certain site more than 10 times. 
-- Find these four users & which sites they (each) visited more than 10 times.


SELECT user_id, site_id, COUNT(site_id) AS visit_count
FROM sampledata.sampledata
WHERE ts > '2019-02-03 00:00:00' AND ts < '2019-02-04 23:59:59' 
GROUP BY site_id, user_id
HAVING visit_count > 10;

-- For each site, compute the unique number of users whose last visit (found in the original data set) was to that site. 
-- For instance, user "LC3561"'s last visit is to "N0OTG" based on timestamp data. 
-- Based on this measure, what are top three sites? (hint: site "3POLC" is ranked at 5th with 28 users whose last visit in the data set was to 3POLC)


SELECT a.site_id, COUNT(a.user_id) AS number_user
FROM sampledata.sampledata a
INNER JOIN
(SELECT user_id, max(ts) AS last_time
FROM sampledata.sampledata
GROUP BY user_id) b
ON a.user_id = b.user_id AND a.ts = b.last_time
GROUP BY a.site_id
ORDER BY number_user DESC
LIMIT 3;


-- For each user, determine the first site he/she visited and the last site he/she visited based on the timestamp data. 
-- Compute the number of users whose first/last visits are to the same website. What is the number?

SELECT COUNT(*) AS count_num
FROM (
SELECT a.user_id, a.ts, a.site_id
FROM sampledata.sampledata a
INNER JOIN 
(SELECT t.user_id, min(t.ts) AS first_time
FROM sampledata.sampledata t
GROUP BY t.user_id) b
ON a.user_id = b.user_id AND a.ts = b.first_time) first
INNER JOIN 
(SELECT a.user_id, a.ts, a.site_id
FROM sampledata.sampledata a
INNER JOIN
(SELECT t.user_id, max(t.ts) AS last_time
FROM sampledata.sampledata t
GROUP BY t.user_id) d
ON a.user_id = d.user_id AND a.ts = d.last_time) last
ON first.user_id = last.user_id AND first.site_id = last.site_id;