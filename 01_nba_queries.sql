--Some basic queries and questions 1-7
--some basic queries
SELECT * FROM Draft;
--selects all fields and records for table Draft

SELECT yearDraft year, numberRound round, numberRoundPick pick 
    FROM Draft
    WHERE yearDraft > 2010;
--returns draft year, round, and pick for all records from 2011 on
    
SELECT Count(*)
    FROM Draft
    WHERE yearDraft > 2010; 
--returns count (600) of all records of players drafted since 2011

SELECT nameOrganizationFrom university, numberRound round, Count(*) draft_picks
    FROM Draft
    WHERE yearDraft > 2010 AND University IN ('Duke', 'North Carolina')
    GROUP BY university, round;
--returns total number of players drafted by UNC and Duke in each round since 2011
 
SELECT nameOrganizationFrom organization, yearDraft year
    FROM Draft
    WHERE year > 2000
    ORDER BY year ASC, organization;
--returns university/club and draft year from 2001 on, sorted by year then club; notice that 1191 rows returned
    
SELECT DISTINCT nameOrganizationFrom organization, yearDraft year
    FROM Draft
    WHERE year > 2000
    ORDER BY year ASC, organization;
--now the total records dropped to 929 (because unique universities/clubs selected)

SELECT DISTINCT nameOrganizationFrom organization, yearDraft year
    FROM Draft
    WHERE year > 2000
    ORDER BY year ASC, organization
    LIMIT 50; 
--reduces results to 50 records

SELECT DISTINCT nameOrganizationFrom organization, yearDraft year
    FROM Draft
    WHERE year > 2000
    ORDER BY year ASC, organization
    LIMIT 50 OFFSET 50; 
--also 50 records, but starting at row 51

SELECT nameOrganizationFrom university, yearDraft year, Count(*) draft_picks
    FROM Draft
    WHERE University IN 
        ('Georgetown', 'Syracuse', 'St. Johns', 'Villanova', 'Providence', 'Connecticut')
        AND yearDraft > 2000
    GROUP BY year, university
    ORDER BY year ASC; 
 --returns number of players drafted from original Big East schools each year (draft)
 --since 2000 and organzied by year and university

SELECT nameOrganizationFrom university, Count(*) players_drafted
    FROM Draft
    WHERE University IN 
        ('Georgetown', 'Syracuse', 'St. Johns', 'Villanova', 'Providence', 'Connecticut')
        AND yearDraft > 2000
    GROUP BY university
    HAVING players_drafted >= 12;
--now this query limits the count following the grouping to at least 12 players drafted



CREATE VIEW newer_games AS
SELECT GAME_ID, SEASON_ID, GAME_DATE, ATTENDANCE, GAME_TIME, 
    TEAM_ID_HOME, TEAM_ABBREVIATION_HOME, TEAM_NAME_HOME, TEAM_CITY_HOME, WL_HOME, PTS_HOME, 
    MIN_HOME, FGM_HOME, FG_PCT_HOME, FG3M_HOME, FG3A_HOME, FG3_PCT_HOME, FTM_HOME, FTA_HOME, 
    FT_PCT_HOME, OREB_HOME, DREB_HOME, REB_HOME, AST_HOME, STL_HOME, BLK_HOME, TOV_HOME, 
    PF_HOME, PLUS_MINUS_HOME, PTS_PAINT_HOME, PTS_2ND_CHANCE_HOME, PTS_FB_HOME, 
    LARGEST_LEAD_HOME, PTS_OFF_TO_HOME, TEAM_WINS_LOSSES_HOME,
    TEAM_ID_AWAY, TEAM_ABBREVIATION_AWAY, TEAM_NAME_AWAY, TEAM_CITY_AWAY, WL_AWAY, PTS_AWAY, 
    MIN_AWAY, FGM_AWAY, FG_PCT_AWAY, FG3M_AWAY, FG3A_AWAY, FG3_PCT_AWAY, FTM_AWAY, FTA_AWAY, 
    FT_PCT_AWAY, OREB_AWAY, DREB_AWAY, REB_AWAY, AST_AWAY, STL_AWAY, BLK_AWAY, TOV_AWAY, 
    PF_AWAY, PLUS_MINUS_AWAY, PTS_PAINT_AWAY, PTS_2ND_CHANCE_AWAY, PTS_FB_AWAY,
    LARGEST_LEAD_AWAY, PTS_OFF_TO_AWAY, TEAM_WINS_LOSSES_AWAY
    FROM Game
    WHERE GAME_DATE > '2015-10-1'; 
--creates View of games (called newer_games) from 2015-16 on and isolating select variables


--returns view
SELECT * FROM newer_games; --7069 rows


--Question 1
--How many points did the nuggets score in home and away games (in total) during the 2018-2019 season?
SELECT GAME_DATE, TEAM_ABBREVIATION_HOME home_team, TEAM_ABBREVIATION_AWAY away_team, PTS_HOME, PTS_AWAY
    FROM newer_games
    WHERE SEASON_ID = 22018 AND 
        (TEAM_ABBREVIATION_HOME = 'DEN' OR TEAM_ABBREVIATION_AWAY = 'DEN');
--returns points for home and away teams in each of denver's games during 18-19 season

SELECT SUM(PTS_HOME) total_home_points , SUM(PTS_AWAY) total_away_points
    FROM newer_games
    WHERE SEASON_ID = 22018 AND 
        (TEAM_ABBREVIATION_HOME = 'DEN' OR TEAM_ABBREVIATION_AWAY = 'DEN');
--problem: sums all home points and away points (including for opposing teams)

SELECT TEAM_ABBREVIATION_HOME home_team, TEAM_ABBREVIATION_AWAY away_team, PTS_HOME, PTS_AWAY,
    CASE WHEN TEAM_ABBREVIATION_HOME = 'DEN' THEN PTS_HOME ELSE PTS_HOME = NULL END den_home_pts,
    CASE WHEN TEAM_ABBREVIATION_AWAY = 'DEN' THEN PTS_AWAY ELSE PTS_AWAY = NULL END den_away_pts
    FROM newer_games
    WHERE SEASON_ID = 22018 AND (TEAM_CITY_HOME = 'Denver' OR TEAM_CITY_AWAY = 'Denver');
--isolates denver's points in each of its 82 games during the 2018-19 season

SELECT 
    SUM(CASE WHEN TEAM_ABBREVIATION_HOME = 'DEN' THEN PTS_HOME ELSE PTS_HOME = NULL END) den_total_home_pts,
    SUM(CASE WHEN TEAM_ABBREVIATION_AWAY = 'DEN' THEN PTS_AWAY ELSE PTS_AWAY = NULL END) den_total_away_pts
    FROM 
        newer_games
    WHERE SEASON_ID = 22018 AND (TEAM_CITY_HOME = 'Denver' OR TEAM_CITY_AWAY = 'Denver');
--returns answer looking for: Denver's total home and away points during 2018-19 season


--Question 2:
--How many total points and points per game did the nuggets score in the 2018-2019 season?    
SELECT 
    SUM(CASE WHEN TEAM_ABBREVIATION_HOME = 'DEN' THEN PTS_HOME ELSE PTS_HOME = NULL END) +
        SUM(CASE WHEN TEAM_ABBREVIATION_AWAY = 'DEN' THEN PTS_AWAY ELSE PTS_AWAY = NULL END) AS den_total_pts,
    (SUM(CASE WHEN TEAM_ABBREVIATION_HOME = 'DEN' THEN PTS_HOME ELSE PTS_HOME = NULL END) +
        SUM(CASE WHEN TEAM_ABBREVIATION_AWAY = 'DEN' THEN PTS_AWAY ELSE PTS_AWAY = NULL END))/82 den_ppg
    FROM newer_games
    WHERE SEASON_ID = 22018 AND (TEAM_CITY_HOME = 'Denver' OR TEAM_CITY_AWAY = 'Denver');
    --returns nuggets' total points and ppg for that season
    

--alternative (cleaner) approach
--subselect in FROM clause which shows pts in each game
SELECT ng1.home_team, ng1.away_team, ng1.den_home_pts, ng1.den_away_pts
    FROM
    (
        SELECT ng2.TEAM_ABBREVIATION_HOME home_team, ng2.TEAM_ABBREVIATION_AWAY away_team,
            (CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'DEN' THEN ng2.PTS_HOME ELSE ng2.PTS_HOME = NULL END) den_home_pts,
            (CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN ng2.PTS_AWAY ELSE ng2.PTS_AWAY = NULL END) den_away_pts
        FROM newer_games ng2
        WHERE ng2.SEASON_ID = 22018 AND (ng2.TEAM_CITY_HOME = 'Denver' OR ng2.TEAM_CITY_AWAY = 'Denver')
    ) ng1;

--again, subselect in FROM clause, but this time computing statistics requested (total pts and ppg)
SELECT den_total_pts, den_total_pts/82 den_ppg
    FROM
    (
        SELECT 
            SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'DEN' THEN ng2.PTS_HOME ELSE ng2.PTS_HOME = NULL END) + 
            SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN ng2.PTS_AWAY ELSE ng2.PTS_AWAY = NULL END) den_total_pts
        FROM newer_games ng2
        WHERE ng2.SEASON_ID = 22018 AND (ng2.TEAM_CITY_HOME = 'Denver' OR ng2.TEAM_CITY_AWAY = 'Denver')
    ) ng1;


--Question 3:
--How many points total and per game did the nuggets score in the 2018-2019 season broken down by month?
SELECT 
    STRFTIME('%Y-%m',ng1.GAME_DATE) month,
    COUNT(den_home_pts) + COUNT(den_away_pts) games,
    SUM(ng1.den_home_pts) + SUM(ng1.den_away_pts) den_tot_pts,
    (SUM(ng1.den_home_pts) + SUM(ng1.den_away_pts))/(COUNT(den_home_pts) + COUNT(den_away_pts)) den_ppg
    FROM
    (
        SELECT ng2.GAME_DATE, ng2.TEAM_ABBREVIATION_HOME home_team, ng2.TEAM_ABBREVIATION_AWAY away_team,
            (CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'DEN' THEN ng2.PTS_HOME ELSE ng2.PTS_HOME = NULL END) den_home_pts,
            (CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN ng2.PTS_AWAY ELSE ng2.PTS_AWAY = NULL END) den_away_pts
        FROM newer_games ng2
        WHERE ng2.SEASON_ID = 22018 AND (ng2.TEAM_CITY_HOME = 'Denver' OR ng2.TEAM_CITY_AWAY = 'Denver')
    ) ng1
    GROUP BY month;



--Question 4:
--How many total points and points per game did the nuggets score in each season since 2015-2016?
--('15-16, '16-17, '17-18, '18-19, '19-20, '20-21)
SELECT ng1.SEASON_ID, den_total_pts, den_total_pts/82 den_ppg
    FROM
    (
        SELECT 
            ng2.SEASON_ID,
            SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'DEN' THEN ng2.PTS_HOME ELSE ng2.PTS_HOME = NULL END) + 
            SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN ng2.PTS_AWAY ELSE ng2.PTS_AWAY = NULL END) den_total_pts
        FROM newer_games ng2
        WHERE ng2.TEAM_CITY_HOME = 'Denver' OR ng2.TEAM_CITY_AWAY = 'Denver'
        GROUP BY ng2.SEASON_ID
    ) ng1;


--Question 5:
--Who officiated the 3 longest games in 2016-17?
SELECT 
    n.GAME_DATE date, 
    n.TEAM_ABBREVIATION_HOME home, 
    n.TEAM_ABBREVIATION_AWAY road, 
    n.GAME_TIME game_time, 
    g.FIRST_NAME || ' ' || g.LAST_NAME official --concatenates first & last names of officials
    FROM newer_games n
    JOIN Game_Officials g ON n.GAME_ID = g.GAME_ID --join on game ids
    WHERE SEASON_ID='22019'
    ORDER BY GAME_TIME DESC --order from longest to shortest
    LIMIT 9; --return top 9 results as there are 3 refs per game
--returns the date of the game, matchup, game time (in descending order), and officials' full names


--Question 6:
--How many all-star appearances did the top 5 draft picks of the 1980s average per draft class?
SELECT d.yearDraft year, d.numberPickOverall draft_pos, d.namePlayer name, p.ALL_STAR_APPEARANCES asg_appear
    FROM Draft d
    JOIN Player_Attributes p ON d.idPlayer = p.ID
    WHERE 
        numberPickOverall BETWEEN 1 AND 5 AND 
        yearDraft BETWEEN 1980 AND 1989
    ORDER BY yearDraft ASC, numberPickOverall ASC;
--returns the draft year, pick #, player name, and all-star appearances
--note that there are 49, not 50, results becausee Len Bias died before his rookie year

--now to compute the average all-star game appearances
SELECT d.yearDraft year, AVG(p.ALL_STAR_APPEARANCES) avg_asg_appear
    FROM Draft d
    JOIN Player_Attributes p ON d.idPlayer = p.ID
    WHERE 
        d.numberPickOverall BETWEEN 1 AND 5 AND 
        year BETWEEN 1980 AND 1989
    GROUP BY year
    ORDER BY avg_asg_appear DESC;
--the top 5 picks from 1984 had the most all-star game appearances, on average


--Question 7:
--What are the 3 pt field goal percentages for all teams in the northwest division (jazz, nuggets, 
--blazers, t'wolves, thunder) during the 2019-2020 season, and how many 3pt fg did they make and attempt?
SELECT 
    ng1.den_3pt_made, ng1.den_3pt_attempt, ROUND(ng1.den_3pt_made/ng1.den_3pt_attempt, 3) AS den_3pt_per,
    ng1.uta_3pt_made, ng1.uta_3pt_attempt, ROUND(ng1.uta_3pt_made/ng1.uta_3pt_attempt, 3) AS uta_3pt_per,
    ng1.por_3pt_made, ng1.por_3pt_attempt, ROUND(ng1.por_3pt_made/ng1.por_3pt_attempt, 3) AS por_3pt_per,
    ng1.min_3pt_made, ng1.min_3pt_attempt, ROUND(ng1.min_3pt_made/ng1.min_3pt_attempt, 3) AS min_3pt_per,
    ng1.okc_3pt_made, ng1.okc_3pt_attempt, ROUND(ng1.okc_3pt_made/ng1.okc_3pt_attempt, 3) AS okc_3pt_per
    FROM
    (
        SELECT 
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'DEN' THEN ng2.FG3M_HOME ELSE ng2.FG3M_HOME = NULL END) + 
                SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN ng2.FG3M_AWAY ELSE ng2.FG3M_AWAY = NULL END) AS float) den_3pt_made,
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'DEN' THEN ng2.FG3A_HOME ELSE ng2.FG3A_HOME = NULL END) + 
                SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'DEN' THEN ng2.FG3A_AWAY ELSE ng2.FG3A_AWAY = NULL END) AS float) den_3pt_attempt,
                
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'UTA' THEN ng2.FG3M_HOME ELSE ng2.FG3M_HOME = NULL END) + 
                SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'UTA' THEN ng2.FG3M_AWAY ELSE ng2.FG3M_AWAY = NULL END) AS float) uta_3pt_made,
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'UTA' THEN ng2.FG3A_HOME ELSE ng2.FG3A_HOME = NULL END) + 
                SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'UTA' THEN ng2.FG3A_AWAY ELSE ng2.FG3A_AWAY = NULL END) AS float) uta_3pt_attempt,
            
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'POR' THEN ng2.FG3M_HOME ELSE ng2.FG3M_HOME = NULL END) + 
                SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'POR' THEN ng2.FG3M_AWAY ELSE ng2.FG3M_AWAY = NULL END) AS float) por_3pt_made,
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'POR' THEN ng2.FG3A_HOME ELSE ng2.FG3A_HOME = NULL END) + 
                SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'POR' THEN ng2.FG3A_AWAY ELSE ng2.FG3A_AWAY = NULL END) AS float) por_3pt_attempt,
            
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'MIN' THEN ng2.FG3M_HOME ELSE ng2.FG3M_HOME = NULL END) + 
                 SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'MIN' THEN ng2.FG3M_AWAY ELSE ng2.FG3M_AWAY = NULL END) AS float) min_3pt_made,
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'MIN' THEN ng2.FG3A_HOME ELSE ng2.FG3A_HOME = NULL END) + 
                 SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'MIN' THEN ng2.FG3A_AWAY ELSE ng2.FG3A_AWAY = NULL END) AS float) min_3pt_attempt,
             
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'OKC' THEN ng2.FG3M_HOME ELSE ng2.FG3M_HOME = NULL END) + 
                 SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'OKC' THEN ng2.FG3M_AWAY ELSE ng2.FG3M_AWAY = NULL END) AS float) okc_3pt_made,
            CAST(SUM(CASE WHEN ng2.TEAM_ABBREVIATION_HOME = 'OKC' THEN ng2.FG3A_HOME ELSE ng2.FG3A_HOME = NULL END) + 
                 SUM(CASE WHEN ng2.TEAM_ABBREVIATION_AWAY = 'OKC' THEN ng2.FG3A_AWAY ELSE ng2.FG3A_AWAY = NULL END) AS float) okc_3pt_attempt
                 
        FROM newer_games ng2
        WHERE ng2.SEASON_ID = 22019
    ) ng1;