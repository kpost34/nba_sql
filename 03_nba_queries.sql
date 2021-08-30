--Question 17:
--Provide the running made, attempted, and % of ft, fg, and 3 pt for Denver during the 2018-19 season

--create new view den_2018 with necessary data
CREATE VIEW den_2018 AS
SELECT
    g1.GAME_ID, g1.home_team_id, g1.away_team_id, g1.attendance, g1.game_time, g1.date,
    g1.home_team, g1.home_city, g1.home_pts,
    g1.away_team, g1.away_city, g1.away_pts,
    g1.team, g1.den_pts, den_fg, den_fga, den_fg_pct, den_3pt, den_3pta, den_3pt_pct, den_ft, den_fta, den_ft_pct,
    g1.opp_team, g1.opp_pts
    FROM (
        SELECT 
            g2.GAME_ID, g2.GAME_DATE date, g2.ATTENDANCE attendance, g2.GAME_TIME game_time, g2.TEAM_ID_HOME home_team_id, g2.TEAM_ID_AWAY away_team_id,
            g2.TEAM_ABBREVIATION_HOME home_team, g2.TEAM_ABBREVIATION_AWAY away_team, g2.TEAM_CITY_HOME home_city,
            g2.TEAM_CITY_AWAY away_city, g2.PTS_HOME home_pts, g2.PTS_AWAY away_pts,
            'DEN' AS team,
            TRIM(CASE WHEN g2.TEAM_ABBREVIATION_HOME != 'DEN' THEN g2.TEAM_ABBREVIATION_HOME ELSE g2.TEAM_ABBREVIATION_HOME = '' END ||
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY != 'DEN' THEN g2.TEAM_ABBREVIATION_AWAY ELSE g2.TEAM_ABBREVIATION_AWAY = ''  END, 0) opp_team,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.PTS_HOME ELSE g2.PTS_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.PTS_AWAY ELSE g2.PTS_AWAY = 0 END den_pts,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.PTS_AWAY ELSE g2.PTS_AWAY = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.PTS_HOME ELSE g2.PTS_HOME = 0 END opp_pts,
            
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FGM_HOME ELSE g2.FGM_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FGM_AWAY ELSE g2.FGA_AWAY = 0 END den_fg,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FGA_HOME ELSE g2.FGA_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FGA_AWAY ELSE g2.FGA_AWAY = 0 END den_fga,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FG_PCT_HOME ELSE g2.FG_PCT_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FG_PCT_AWAY ELSE g2.FG_PCT_AWAY = 0 END den_fg_pct,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FG3M_HOME ELSE g2.FG3M_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FG3M_AWAY ELSE g2.FG3M_AWAY = 0 END den_3pt,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FG3A_HOME ELSE g2.FG3A_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FG3A_AWAY ELSE g2.FG3A_AWAY = 0 END den_3pta,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FG3_PCT_HOME ELSE g2.FG3_PCT_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FG3_PCT_AWAY ELSE g2.FG3_PCT_AWAY = 0 END den_3pt_pct,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FTM_HOME ELSE g2.FTM_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FTM_AWAY ELSE g2.FTM_AWAY = 0 END den_ft,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FTA_HOME ELSE g2.FTA_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FTA_AWAY ELSE g2.FTA_AWAY = 0 END den_fta,
            CASE WHEN g2.TEAM_ABBREVIATION_HOME = 'DEN' THEN g2.FT_PCT_HOME ELSE g2.FT_PCT_HOME = 0 END +
            CASE WHEN g2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN g2.FT_PCT_AWAY ELSE g2.FT_PCT_AWAY = 0 END den_ft_pct
            FROM Game g2
            WHERE g2.SEASON_ID = 22018 
                AND (g2.TEAM_CITY_HOME = 'Denver' OR  g2.TEAM_CITY_AWAY = 'Denver')
            ) g1;

--answer question
SELECT d1.*, 
    ROUND(den_total_fg/den_total_fga, 3) den_fg_pct, 
    ROUND(CAST (den_total_3pt AS REAL)/CAST(den_total_3pta AS REAL), 3) den_3pt_pct,
    ROUND(den_total_ft/den_total_fta, 3) den_ft_pct
    FROM(
        SELECT date, team, den_pts, opp_team, opp_pts,
            SUM(d2.den_fg) OVER(ROWS UNBOUNDED PRECEDING) den_total_fg,
            SUM(d2.den_fga) OVER(ROWS UNBOUNDED PRECEDING) den_total_fga,
            SUM(d2.den_3pt) OVER(ROWS UNBOUNDED PRECEDING) den_total_3pt,
            SUM(d2.den_3pta) OVER(ROWS UNBOUNDED PRECEDING) den_total_3pta,
            SUM(d2.den_ft) OVER(ROWS UNBOUNDED PRECEDING) den_total_ft,
            SUM(d2.den_fta) OVER(ROWS UNBOUNDED PRECEDING) den_total_fta
        FROM den_2018 d2
        ) d1;


--Question 18:
--Provide fgm, fga, 3ptm, 3pta, ftm, and fta in each game along with the running pcts
SELECT * FROM den_2018;

SELECT date, team, den_pts, opp_team, opp_pts, 
    den_fg, den_fga, den_fg_pct,
    ROUND(den_total_fg/den_total_fga, 3) run_den_fg_pct, 
    den_3pt, den_3pta, den_3pt_pct,
    ROUND(CAST (den_total_3pt AS REAL)/CAST(den_total_3pta AS REAL), 3) run_den_3pt_pct,
    den_ft, den_fta, den_ft_pct,
    ROUND(den_total_ft/den_total_fta, 3) run_den_ft_pct
    FROM(
        SELECT date, team, den_pts, opp_team, opp_pts, 
            den_fg, den_fga, den_fg_pct, den_3pt, den_3pta, den_3pt_pct, den_ft, den_fta, den_ft_pct,
            SUM(d2.den_fg) OVER(ROWS UNBOUNDED PRECEDING) den_total_fg,
            SUM(d2.den_fga) OVER(ROWS UNBOUNDED PRECEDING) den_total_fga,
            SUM(d2.den_3pt) OVER(ROWS UNBOUNDED PRECEDING) den_total_3pt,
            SUM(d2.den_3pta) OVER(ROWS UNBOUNDED PRECEDING) den_total_3pta,
            SUM(d2.den_ft) OVER(ROWS UNBOUNDED PRECEDING) den_total_ft,
            SUM(d2.den_fta) OVER(ROWS UNBOUNDED PRECEDING) den_total_fta
        FROM den_2018 d2
        ) d1;


--Question 19:
--In the games of the 2018-2019 Nuggets season in which the Nuggets lost by more than 20 points, what percentage
--of their opponents' points came from turnovers? Return the percentages in descending order.
SELECT * FROM den_2018;
SELECT * FROM Game;

--first part of question: games in which the Nuggets lost by at least 20 points
SELECT d.date, d.den_pts, d.opp_team, d.opp_pts, d.den_pts - opp_pts margin
    FROM den_2018 d
    WHERE margin <= -20
    ORDER BY margin;

--answer question
SELECT d.date, d.den_pts, d.opp_team, d.opp_pts, d.den_pts - opp_pts margin,
    g.TEAM_CITY_HOME home, g.TEAM_CITY_AWAY away, g.PTS_OFF_TO_HOME, g.PTS_OFF_TO_AWAY,
    ROUND(((CASE WHEN g.TEAM_CITY_HOME = 'Denver' THEN CAST(g.PTS_OFF_TO_AWAY AS REAL) ELSE 0 END +
    CASE WHEN g.TEAM_CITY_AWAY = 'Denver' THEN CAST(g.PTS_OFF_TO_HOME AS REAL) ELSE 0 END)/opp_pts * 100), 2) opp_pct_pts_to
    FROM den_2018 d
    JOIN Game g ON d.Game_ID = g.game_ID
    WHERE margin <= -20
    ORDER BY opp_pct_pts_to DESC;
--returns only games in which Denver lost by more than 20, extracts the po turnovers for Den's opponents,
--and calculates the percentage of points from the Nuggets turnovers


--Question 20: 
--In the largest three defeats by the Nuggest in the 2018-19 season, what was the length of the games and who officiated those games?
SELECT d.team, d.den_pts, d.opp_team, d.opp_pts, d.den_pts-d.opp_pts margin, g.GAME_TIME length, go.FIRST_NAME || ' ' || go.LAST_NAME official
    FROM den_2018 d
    JOIN Game g
    ON d.GAME_ID = g.GAME_ID
    JOIN Game_Officials go
    ON d.GAME_ID = go.GAME_ID
    ORDER BY margin DESC
    LIMIT 9;
--returns team (Denver), Denver's points, opposition, opponent's points, margin of victory, game length, and the three officials per game
--with their first and last names concatenated together with a space between


--Question 21:
--Return denver's points in the first game against each opponent during the 2018-19 season and sort alphabetically by opponent city.
SELECT date, team,
    FIRST_VALUE(den_pts) OVER (PARTITION BY opp_team ORDER BY date) den_pts,
    opp_team, opp_pts
    FROM den_2018
    GROUP BY opp_team
    ORDER BY opp_team;
--returns 29 rows (as expected; 1 for each team) and Denver's points in first game against each opponent
--plus the game date, opponent team name, and their points (in that game)


--Question 21:
--Rank Denver's points in games against each opponent in descending order and sort alphabetically by opposition team city.
SELECT date, team, den_pts,
    ROW_NUMBER() OVER (PARTITION BY opp_team ORDER BY den_pts DESC) rank,
    opp_team, opp_pts
    FROM den_2018
    ORDER BY opp_team;

SELECT date, team, den_pts,
    RANK() OVER (PARTITION BY opp_team ORDER BY den_pts DESC) rank,
    opp_team, opp_pts
    FROM den_2018
    ORDER BY opp_team;
--ROW_NUMBER() and RANK() return the same results in this instance


--Question 22:
--In the 2018-2019 season, how many points did the Nuggets score in their previous match-up against each opponent?
SELECT date, team, 
    LAG(den_pts) OVER (PARTITION BY opp_team ORDER BY date) prev_den_pts,
    den_pts, opp_team, opp_pts
    FROM den_2018
    ORDER BY opp_team;
--returns Denver's previous point total for each opponent; note the NULL value for the first match-up