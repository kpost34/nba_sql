--Questions 8-16

--Questions 8 and 9: 
--Place Denver's pts for and against during 2015-6 season in two columns
--Compute quartiles for each stat

--create view
--contains all of Denver's games from the 2015-16 season and separates out their points and the opposition's points (as well as
--game id, team ids, attendance, game_time, date, and home and away teams abbrv and cities
CREATE VIEW den_2015 AS
SELECT
    g1.GAME_ID, g1.TEAM_ID_HOME, g1.TEAM_ID_AWAY, g1.attendance, g1.game_time, g1.date,
    g1.home_team, g1.home_city, g1.home_pts,
    g1.away_team, g1.away_city, g1.away_pts,
    g1.team, g1.den_pts, 
    g1.opp_team, g1.opp_pts
    FROM (
        SELECT 
            g2.GAME_ID, g2.GAME_DATE date, g2.ATTENDANCE attendance, g2.GAME_TIME game_time, g2.TEAM_ID_HOME, g2.TEAM_ID_AWAY,
            g2.TEAM_ABBREVIATION_HOME home_team, g2.TEAM_ABBREVIATION_AWAY away_team, g2.TEAM_CITY_HOME home_city,
            g2.TEAM_CITY_AWAY away_city, g2.PTS_HOME home_pts, g2.PTS_AWAY away_pts,
            'DEN' AS team,
            TRIM(CASE WHEN g2.TEAM_ABBREVIATION_HOME != 'DEN' THEN g2.TEAM_ABBREVIATION_HOME ELSE g2.TEAM_ABBREVIATION_HOME = '' END ||
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY != 'DEN' THEN g2.TEAM_ABBREVIATION_AWAY ELSE g2.TEAM_ABBREVIATION_AWAY = ''  END, 0) opp_team,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.PTS_HOME ELSE g2.PTS_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.PTS_AWAY ELSE g2.PTS_AWAY = 0 END den_pts,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.PTS_AWAY ELSE g2.PTS_AWAY = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.PTS_HOME ELSE g2.PTS_HOME = 0 END opp_pts
            FROM Game g2
            WHERE g2.SEASON_ID = 22015 
                AND (g2.TEAM_CITY_HOME = 'Denver' OR  g2.TEAM_CITY_AWAY = 'Denver')
            ) g1;

--compute quartiles for each stat
SELECT date, team, den_pts, 
    NTILE(4) OVER(ORDER BY den_pts) AS quartile,
    opp_team, opp_pts
    FROM den_2015
    ORDER BY date;
--placing denver's pts into quartiles (1=0-25%, 2=25-50%, etc.) but keeping the game date order

SELECT date, team, den_pts, 
    NTILE(4) OVER(ORDER BY den_pts) AS den_quartile,
    opp_team, opp_pts,
    NTILE(4) OVER(ORDER BY opp_pts) AS opp_quartile
    FROM den_2015
    ORDER BY date;
--similar to above, except now I added the quartile for the opposition's points scored


--Question 10: Determine the ranks of the point differential between the Nuggets and their opponents 
--(from largest win to largest loss) during the 2015-2016 season and display 1) in rank order and 
--2) in chronological order. 
--in rank order
SELECT d1.date, d1.team, d1.den_pts, d1.opp_team, d1.opp_pts, d1.margin,
        RANK() OVER(ORDER BY margin DESC) AS den_margin_rank
    FROM(
        SELECT d2.date, d2.team, d2.den_pts, d2.opp_team, d2.opp_pts, d2.den_pts - d2.opp_pts AS margin
        FROM den_2015 d2
        ) d1;

--in chronological order
SELECT d1.date, d1.team, d1.den_pts, d1.opp_team, d1.opp_pts, d1.margin,
        RANK() OVER(ORDER BY margin DESC) AS den_margin_rank
    FROM(
        SELECT d2.date, d2.team, d2.den_pts, d2.opp_team, d2.opp_pts, d2.den_pts - d2.opp_pts AS margin
        FROM den_2015 d2
        ) d1
    ORDER BY date;


--Question 11:
--Provide the average points that denver and its opponents scored against each other during the 2015-6 season
--averages as aggregates
SELECT team, 
    ROUND(AVG(den_pts),2) avg_den_pts, opp_team, ROUND(AVG(opp_pts),2) avg_opp_pts
    FROM den_2015
    GROUP BY opp_team;

--averages as window functions
SELECT date, team, den_pts,
        CAST(AVG(den_pts) OVER (PARTITION BY opp_team) AS DECIMAL(5,2)) avg_den_pts,
        opp_team, opp_pts,
        CAST(AVG(opp_pts) OVER (PARTITION BY opp_team) AS DECIMAL(5,2)) avg_opp_pts
        FROM den_2015
        ORDER BY date;


--Question 12:
--Provide the running average and cumulative points for and against the Nuggets during the 2015-6 season
SELECT date, team, den_pts,
        SUM(den_pts) OVER (ROWS UNBOUNDED PRECEDING) cumulative_den_pts,
        AVG(den_pts) OVER (ROWS UNBOUNDED PRECEDING) running_avg_den_pts,
        opp_team, opp_pts,
        SUM(opp_pts) OVER (ROWS UNBOUNDED PRECEDING) cumulative_opp_pts,
        AVG(opp_pts) OVER (ROWS UNBOUNDED PRECEDING) running_avg_opp_pts
        FROM den_2015
        ORDER BY date;
--works, but decimals are way too long; let's try doing this as a subquery (to be able to use ROUND()
--in the outer SELECT)
SELECT d1.date, d1.team, 
        d1.den_pts, d1.cumulative_den_pts, ROUND(d1.run_avg_den_pts, 2) run_avg_den_pts,
        d1.opp_team, d1.opp_pts, d1.cumulative_opp_pts, ROUND(d1.run_avg_opp_pts, 2) run_avg_opp_pts
    FROM (
        SELECT d2.date, d2.team, d2.den_pts,
            SUM(d2.den_pts) OVER (ROWS UNBOUNDED PRECEDING) cumulative_den_pts,
            AVG(d2.den_pts) OVER (ROWS UNBOUNDED PRECEDING) run_avg_den_pts,
            d2.opp_team, d2.opp_pts,
            SUM(d2.opp_pts) OVER (ROWS UNBOUNDED PRECEDING) cumulative_opp_pts,
            AVG(d2.opp_pts) OVER (ROWS UNBOUNDED PRECEDING) run_avg_opp_pts
            FROM den_2015 d2
            ORDER BY d2.date
        ) d1;


--Question 13:
--Question 12, except no running total and break avg down by opponent
SELECT date, team, den_pts,
        AVG(den_pts) OVER (PARTITION BY opp_team ROWS UNBOUNDED PRECEDING) run_avg_den_pts,
        opp_team, opp_pts,
        AVG(opp_pts) OVER (PARTITION BY opp_team ROWS UNBOUNDED PRECEDING) run_avg_opp_pts
        FROM den_2015
        ORDER BY date;
--ordered by date

SELECT date, team, den_pts,
        AVG(den_pts) OVER (PARTITION BY opp_team ROWS UNBOUNDED PRECEDING) run_avg_den_pts,
        opp_team, opp_pts,
        AVG(opp_pts) OVER (PARTITION BY opp_team ROWS UNBOUNDED PRECEDING) run_avg_opp_pts
        FROM den_2015
        ORDER BY opp_team;
--ordered by opposing team
        

--Question 14:
--Return Denver's and its opponents' ppg for each month of the 2015-16 season as window function.
SELECT d1.month, d1.date, 
    d1.team, d1.den_pts, ROUND(d1.avg_den_pts, 2) avg_den_pts_month, 
    d1.opp_team, d1.opp_pts, ROUND(d1.avg_opp_pts, 2) avg_den_pts_month
    FROM (
        SELECT STRFTIME('%Y-%m',d2.date) month, d2.date, d2.team, 
            d2.den_pts,
            AVG(d2.den_pts) OVER (PARTITION BY STRFTIME('%Y-%m',d2.date)) avg_den_pts,
            d2.opp_team, d2.opp_pts,
            AVG(d2.opp_pts) OVER (PARTITION BY STRFTIME('%Y-%m',d2.date)) avg_opp_pts
            FROM den_2015 d2
            ) d1
    ORDER BY month;
--using FROM subquery
    
SELECT STRFTIME('%Y-%m',d1.date) month, d1.date, d1.team, 
            d1.den_pts,
            (SELECT ROUND(AVG(d2.den_pts),2) 
                FROM den_2015 d2
                WHERE STRFTIME('%Y-%m',d2.date) = STRFTIME('%Y-%m',d1.date)) avg_den_pts_month,
            d1.opp_team, d1.opp_pts,
            (SELECT ROUND(AVG(d3.opp_pts),2)
                FROM den_2015 d3 
                WHERE STRFTIME('%Y-%m',d3.date) = STRFTIME('%Y-%m',d1.date)) avg_opp_pts_month
            FROM den_2015 d1
    ORDER BY month;
--using SELECT subquery


--Question 15:
--What's the avg margin of victory/defeat for each month of the 2015-16 season?
SELECT STRFTIME('%Y-%m',d1.date) month, d1.date, d1.team, 
            d1.den_pts, d1.opp_team, d1.opp_pts, d1.den_pts-d1.opp_pts margin,
            (SELECT ROUND(AVG(d2.den_pts) - AVG(d2.opp_pts), 2)
                FROM den_2015 d2
                WHERE STRFTIME('%Y-%m',d2.date) = STRFTIME('%Y-%m',d1.date)) avg_margin_month
            FROM den_2015 d1
    ORDER BY month;


--Question 16:
--What were the 3 largest victories and 3 largest defeats (including ties) for the Nuggets in home and away games during
--the 2015-16 season? Place in the following order: away games--largest victories to largest defeats--then home games--same

--calculate margins for home and away games, sort for largest victories/defeats, and union them
SELECT d1.*
    FROM
    (SELECT date, home_team, den_pts, away_team, opp_pts,
        den_pts - opp_pts den_margin
        FROM den_2015 
        ORDER BY den_margin DESC
        LIMIT 3) d1
UNION 
SELECT d2.*
    FROM
    (SELECT date, home_team, den_pts, away_team, opp_pts,
        den_pts - opp_pts den_margin
        FROM den_2015 
        ORDER BY den_margin ASC
        LIMIT 3) d2
    ORDER BY den_margin DESC;
--this is for all games

--set up CASE statement to separate when Denver is home/away and sort by this factor
SELECT d1.*
    FROM
        (SELECT date, home_team, away_team, den_pts, opp_pts, den_pts - opp_pts den_margin,
        CASE WHEN home_team = 'DEN' THEN 1 ELSE 0 END home_away
        FROM den_2015 
        WHERE home_away= 0
        ORDER BY den_margin DESC
        LIMIT 3) d1
UNION
SELECT d2.*
    FROM
        (SELECT date, home_team, away_team, den_pts, opp_pts, den_pts - opp_pts den_margin,
        CASE WHEN home_team = 'DEN' THEN 1 ELSE 0 END home_away
        FROM den_2015 
        WHERE home_away = 0
        ORDER BY den_margin ASC
        LIMIT 3) d2
UNION
SELECT d3.*
    FROM
        (SELECT date, home_team, away_team, den_pts, opp_pts, den_pts - opp_pts den_margin,
        CASE WHEN home_team = 'DEN' THEN 1 ELSE 0 END home_away
        FROM den_2015 
        WHERE home_away = 1
        ORDER BY den_margin DESC
        LIMIT 4) d3
UNION
SELECT d4.*
    FROM
        (SELECT date, home_team, away_team, den_pts, opp_pts, den_pts - opp_pts den_margin,
        CASE WHEN home_team = 'DEN' THEN 1 ELSE 0 END home_away
        FROM den_2015 
        WHERE home_away = 1
        ORDER BY den_margin ASC
        LIMIT 4) d4
    ORDER BY home_away, den_margin DESC;
--returns 3 largest victories and defeats, first on the road then at home, including ties