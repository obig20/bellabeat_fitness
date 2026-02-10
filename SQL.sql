-- 1. CLEANUP – drop old tables to avoid conflicts

DROP TABLE IF EXISTS public.merged_activity_sleep;
DROP TABLE IF EXISTS public.sleep_daily;
DROP TABLE IF EXISTS public.daily_activity;
DROP TABLE IF EXISTS public.minute_sleep;

-- 2. CREATE & IMPORT daily_activity
CREATE TABLE public.daily_activity (
    "Id"                BIGINT,
    "ActivityDate"      TEXT,
    "TotalSteps"        INTEGER,
    "TotalDistance"     DOUBLE PRECISION,
    "TrackerDistance"   DOUBLE PRECISION,
    "LoggedActivitiesDistance" DOUBLE PRECISION,
    "VeryActiveDistance" DOUBLE PRECISION,
    "ModeratelyActiveDistance" DOUBLE PRECISION,
    "LightActiveDistance" DOUBLE PRECISION,
    "SedentaryActiveDistance" DOUBLE PRECISION,
    "VeryActiveMinutes" INTEGER,
    "FairlyActiveMinutes" INTEGER,
    "LightlyActiveMinutes" INTEGER,
    "SedentaryMinutes"  INTEGER,
    "Calories"          INTEGER
);


SELECT COUNT(*) AS activity_rows FROM public.daily_activity;

-- Convert date string → DATE type
ALTER TABLE public.daily_activity
ALTER COLUMN "ActivityDate" TYPE DATE
USING TO_DATE("ActivityDate", 'MM/DD/YYYY');

-- Quick check
SELECT * FROM public.daily_activity LIMIT 5;


-- 3. CREATE & IMPORT minute_sleep

CREATE TABLE public.minute_sleep (
    id      TEXT,           
    date    TEXT,
    value   INTEGER,
    logid   BIGINT
);



-- Verify
SELECT COUNT(*) AS minute_rows FROM public.minute_sleep;     
SELECT * FROM public.minute_sleep LIMIT 5;

-- 4. AGGREGATE minute_sleep → daily sleep hours
CREATE TABLE public.sleep_daily AS
SELECT
    id,
    DATE(TO_DATE(date, 'MM/DD/YYYY HH12:MI:SS AM')) AS sleep_date,
    COUNT(*) AS minutes_asleep
FROM public.minute_sleep
WHERE value = 1
GROUP BY id, sleep_date
ORDER BY id, sleep_date;

ALTER TABLE public.sleep_daily
ADD COLUMN hours_asleep NUMERIC(5,2);

UPDATE public.sleep_daily
SET hours_asleep = ROUND(minutes_asleep::NUMERIC / 60.0, 2);

-- Quick verification
SELECT COUNT(*) AS sleep_days FROM public.sleep_daily;
SELECT COUNT(DISTINCT id) AS unique_users FROM public.sleep_daily;
SELECT ROUND(AVG(hours_asleep), 2) AS avg_sleep_h, 
       ROUND(MIN(hours_asleep), 2) AS min_h, 
       ROUND(MAX(hours_asleep), 2) AS max_h 
FROM public.sleep_daily;



-- 5. MERGE activity + sleep
CREATE TABLE public.merged_activity_sleep AS
SELECT
    a."Id":: TEXT          AS id,
    a."ActivityDate",
    a."TotalSteps",
    a."SedentaryMinutes",
    a."Calories",
    s.minutes_asleep,
    s.hours_asleep,
    EXTRACT(DOW FROM a."ActivityDate") AS weekday_num,          -- 0 = Sunday
    TRIM(TO_CHAR(a."ActivityDate", 'Day')) AS weekday_name
FROM public.daily_activity a
LEFT JOIN public.sleep_daily s
    ON a."Id":: TEXT = s.id
    AND a."ActivityDate" = s.sleep_date;

-- Verify merge
SELECT COUNT(*) AS merged_rows FROM public.merged_activity_sleep;
SELECT * FROM public.merged_activity_sleep LIMIT 10;


-- 6. MAIN ANALYSIS QUERIES


-- A. Averages by weekday
SELECT
    weekday_name,
    weekday_num,
    ROUND(AVG("TotalSteps")::numeric, 0)     AS avg_steps,
    ROUND(AVG("SedentaryMinutes")::numeric, 0) AS avg_sedentary_min,
    ROUND(AVG("Calories")::numeric, 0)       AS avg_calories,
    ROUND(AVG(hours_asleep), 2)              AS avg_sleep_hours,
    COUNT(*)                                 AS days_count
FROM public.merged_activity_sleep
GROUP BY weekday_name, weekday_num
ORDER BY weekday_num;

-- B. Sleep category comparison
SELECT
    CASE
        WHEN hours_asleep >= 7                  THEN '7+ hours (good)'
        WHEN hours_asleep IS NOT NULL           THEN '<7 hours (short)'
        ELSE 'No sleep data'
    END AS sleep_group,
    ROUND(AVG("TotalSteps")::numeric, 0)     AS avg_steps,
    ROUND(AVG("SedentaryMinutes")::numeric, 0) AS avg_sedentary,
    ROUND(AVG("Calories")::numeric, 0)       AS avg_calories,
    COUNT(*)                                 AS count_days
FROM public.merged_activity_sleep
GROUP BY sleep_group
ORDER BY sleep_group;

-- C. Overall averages (only days with sleep)
SELECT
    ROUND(AVG("TotalSteps")::numeric, 0)     AS overall_avg_steps,
    ROUND(AVG("SedentaryMinutes")::numeric, 0) AS overall_avg_sedentary_min,
    ROUND(AVG("Calories")::numeric, 0)       AS overall_avg_calories,
    ROUND(AVG(hours_asleep), 2)              AS overall_avg_sleep_hours
FROM public.merged_activity_sleep
WHERE hours_asleep IS NOT NULL;

