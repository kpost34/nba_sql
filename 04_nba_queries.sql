--Question 29
--What was the average height, weight, wingspan, and standing reach for the
--top 3 draft picks from 2005-2010?

--return all the players
SELECT d.yearDraft year, d.numberPickOverall pick, d.namePlayer player,
    c.heightWOShoesInches height, c.weightLBS weight, c.wingspanInches wingspan,
    c.reachStandingInches standing_reach
    FROM Draft d
    JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE year BETWEEN 2005 AND 2010 AND pick IN (1, 2, 3)
    ORDER BY year;

--return the averages
SELECT d.yearDraft year, 
    ROUND(AVG(c.heightWOShoesInches),2) avg_height, ROUND(AVG(c.weightLBS),2) avg_weight, 
    ROUND(AVG(c.wingspanInches),2) avg_wingspan, ROUND(AVG(c.reachStandingInches),2) avg_standing_reach
    FROM Draft d
    JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE year BETWEEN 2005 AND 2010 AND numberPickOverall IN (1, 2, 3)
    GROUP BY year
    ORDER BY year;
    

--Question 30
--How did the speed, strength, jumping ability, and body fat of picks 1-5 compare to picks 6-10 and 11-15 for
--the 2007 through 2013 NBA drafts?

--see all the players' information
SELECT d.yearDraft year, d.numberPickOverall pick, d.namePlayer player,
       c.timeThreeQuarterCourtSprint sprint_time, c.repsBenchPress135 bench_reps,
       c.verticalLeapMaxInches vertical, c.pctBodyFat pct_fat
    FROM Draft d
    LEFT JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE year BETWEEN 2007 AND 2013 AND pick < 16
    ORDER BY year;

--includes 'pick_group' (whether the player was selected in picks 1-5, 6-10, or 11-15)
SELECT d.yearDraft year, d.numberPickOverall pick, d.namePlayer player,
       c.timeThreeQuarterCourtSprint sprint_time, c.repsBenchPress135 bench_reps,
       c.verticalLeapMaxInches vertical, c.pctBodyFat pct_fat,
       CASE 
           WHEN d.numberPickOverall < 6 THEN 'first five' 
           WHEN d.numberPickOverall BETWEEN 6 AND 10 THEN 'second five'
           ELSE 'third five' END pick_group
    FROM Draft d
    LEFT JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE year BETWEEN 2007 AND 2013 AND pick < 16
    ORDER BY year;

--answering the question (for each pick group and year
SELECT d.yearDraft year,
    CASE 
       WHEN d.numberPickOverall < 6 THEN 'first five' 
       WHEN d.numberPickOverall BETWEEN 6 AND 10 THEN 'second five'
       ELSE 'third five' END pick_group,
       ROUND(AVG(c.timeThreeQuarterCourtSprint),2) avg_sprint_time, 
       ROUND(AVG(c.repsBenchPress135),2) avg_bench_reps,
       ROUND(AVG(c.verticalLeapMaxInches),2) avg_vertical, 
       ROUND(AVG(c.pctBodyFat),2) avg_pct_fat
    FROM Draft d
    LEFT JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE year BETWEEN 2007 AND 2013 AND d.numberPickOverall < 16
    GROUP BY year, pick_group
    ORDER BY year;
    
--considered across years
SELECT 
    CASE 
       WHEN d.numberPickOverall < 6 THEN 'first five' 
       WHEN d.numberPickOverall BETWEEN 6 AND 10 THEN 'second five'
       ELSE 'third five' END pick_group,
       ROUND(AVG(c.timeThreeQuarterCourtSprint),2) avg_sprint_time, 
       ROUND(AVG(c.repsBenchPress135),2) avg_bench_reps,
       ROUND(AVG(c.verticalLeapMaxInches),2) avg_vertical, 
       ROUND(AVG(c.pctBodyFat),2) avg_pct_fat
    FROM Draft d
    LEFT JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE d.yearDraft BETWEEN 2007 AND 2013 AND d.numberPickOverall < 16
    GROUP BY pick_group
    ORDER BY d.yearDraft;
    

--Question 31
--For the player that had the lowest total rankings in those four categories, how many pts,
--rebs, and asts do (did) they average in the NBA?

--return all the players and the four metrics (that did not have a NULL value) in them and their rankings
--for each metric
SELECT m.player, m.id, m.year, m.sprint_time, m.bench_reps, m.vertical, m.pct_fat,
    RANK() OVER(ORDER BY m.sprint_time) sprint_rank,  
    RANK() OVER(ORDER BY bench_reps DESC) bench_rank,
    RANK() OVER(ORDER BY vertical DESC) vertical_rank,
    RANK() OVER(ORDER BY pct_fat) body_fat_rank
    FROM(
    SELECT d.yearDraft year, d.numberPickOverall pick, d.namePlayer player, d.idPlayer id,
           c.timeThreeQuarterCourtSprint sprint_time, c.repsBenchPress135 bench_reps,
           c.verticalLeapMaxInches vertical, c.pctBodyFat pct_fat
        FROM Draft d
        LEFT JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
        WHERE year BETWEEN 2007 AND 2013 AND
            pick < 16 AND 
            sprint_time IS NOT NULL AND
            bench_reps IS NOT NULL AND
            vertical IS NOT NULL AND
            pct_fat IS NOT NULL
        ORDER BY year) m;

--next step: sum the rankings and find the minimum total ranking and associated player
--for each year
SELECT r.year, r.total_rank,
    MIN(r.total_rank) lowest_total_rank, 
    CASE WHEN r.total_rank = MIN(r.total_rank) THEN r.player END player_min_rank,
    r.id
    FROM(
        SELECT m.player, m.id, m.year, m.sprint_time, m.bench_reps, m.vertical, m.pct_fat,
            RANK() OVER(ORDER BY m.sprint_time) sprint_rank,  
            RANK() OVER(ORDER BY bench_reps DESC) bench_rank,
            RANK() OVER(ORDER BY vertical DESC) vertical_rank,
            RANK() OVER(ORDER BY pct_fat) body_fat_rank,
            RANK() OVER(ORDER BY m.sprint_time) +
                RANK() OVER(ORDER BY bench_reps DESC) +
                RANK() OVER(ORDER BY vertical DESC) +
                RANK() OVER(ORDER BY pct_fat) total_rank
            FROM(
            SELECT d.yearDraft year, d.numberPickOverall pick, d.namePlayer player, d.idPlayer id,
                   c.timeThreeQuarterCourtSprint sprint_time, c.repsBenchPress135 bench_reps,
                   c.verticalLeapMaxInches vertical, c.pctBodyFat pct_fat
                FROM Draft d
                LEFT JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
                WHERE year BETWEEN 2007 AND 2013 AND
                    pick < 16 AND 
                    sprint_time IS NOT NULL AND
                    bench_reps IS NOT NULL AND
                    vertical IS NOT NULL AND
                    pct_fat IS NOT NULL
            ORDER BY year) m) r
    GROUP BY r.year;

--join with the Player_Attributes data for the stats requested
SELECT r.year, 
    CASE WHEN r.total_rank = MIN(r.total_rank) THEN r.player END player_min_rank,
    MIN(r.total_rank) total_rank,
    p.PTS ppg, p.AST apg, p.REB rpg
    FROM(
        SELECT m.player, m.id, m.year, m.sprint_time, m.bench_reps, m.vertical, m.pct_fat,
            RANK() OVER(ORDER BY m.sprint_time) sprint_rank,  
            RANK() OVER(ORDER BY bench_reps DESC) bench_rank,
            RANK() OVER(ORDER BY vertical DESC) vertical_rank,
            RANK() OVER(ORDER BY pct_fat) body_fat_rank,
            RANK() OVER(ORDER BY m.sprint_time) +
                RANK() OVER(ORDER BY bench_reps DESC) +
                RANK() OVER(ORDER BY vertical DESC) +
                RANK() OVER(ORDER BY pct_fat) total_rank
            FROM(
            SELECT d.yearDraft year, d.numberPickOverall pick, d.namePlayer player, d.idPlayer id,
                   c.timeThreeQuarterCourtSprint sprint_time, c.repsBenchPress135 bench_reps,
                   c.verticalLeapMaxInches vertical, c.pctBodyFat pct_fat
                FROM Draft d
                LEFT JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
                WHERE year BETWEEN 2007 AND 2013 AND
                    pick < 16 AND 
                    sprint_time IS NOT NULL AND
                    bench_reps IS NOT NULL AND
                    vertical IS NOT NULL AND
                    pct_fat IS NOT NULL
            ORDER BY year) m) r
    JOIN Player_Attributes p ON r.id=p.ID
    GROUP BY r.year;


--Question 32
--Are players drafted into the NBA becoming leaner? Compare across years, by round,
--and overall. 

--NOTE: database error where the two Reggie Williams, who entered the NBA in 1987 and
--2009, are given the same unique identifier; also note that % body fat was taken from 2001 on
SELECT yearCombine, namePlayer, idPlayer FROM Draft_Combine WHERE namePlayer = 'Reggie Williams';
SELECT yearDraft, namePlayer, idPlayer FROM Draft WHERE namePlayer = 'Reggie Williams';

--compare across years
--by avg
SELECT d.yearDraft year, ROUND(AVG(c.pctBodyFat),2) avg_body_fat
    FROM Draft d
    JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE year > 2000
    GROUP BY year
    ORDER BY avg_body_fat;

    
--by min
SELECT d.yearDraft year, d.namePlayer player, MIN(c.pctBodyFat) lowest_body_fat
    FROM Draft d
    JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE year > 2000
    GROUP BY year
    ORDER BY lowest_body_fat;
    
--by lowest 3
SELECT *
    FROM(
        SELECT d.yearDraft year, d.namePlayer player, c.pctBodyFat body_fat,
            RANK() OVER(PARTITION BY d.yearDraft ORDER BY c.pctBodyFat) rank_body_fat
            FROM Draft d
            JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
            WHERE year > 2000 AND body_fat IS NOT NULL) dc
    WHERE dc.rank_body_fat BETWEEN 1 AND 3;


--compare lowest 3 by round (first two rounds only & across all years)
SELECT *
    FROM(
        SELECT d.yearDraft year, d.numberRound round, d.namePlayer player, c.pctBodyFat body_fat,
            RANK() OVER(PARTITION BY d.numberRound ORDER BY c.pctBodyFat) rank_body_fat
            FROM Draft d
            JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
            WHERE year > 2000 AND body_fat IS NOT NULL
            ORDER BY round, rank_body_fat) dc
    WHERE dc.rank_body_fat BETWEEN 1 AND 3 AND dc.round < 3;


--compare lowest by round and year (including only first two rounds)
--by pct body fat
SELECT d.yearDraft year, d.numberRound round, d.namePlayer player, MIN(c.pctBodyFat) body_fat
    FROM Draft d
    JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE c.pctBodyFat IS NOT NULL AND 
        round BETWEEN 1 AND 2 AND
        year > 2000
    GROUP BY year, round
    ORDER BY body_fat;

--by year and round
SELECT d.yearDraft year, d.numberRound round, d.namePlayer player, MIN(c.pctBodyFat) body_fat
    FROM Draft d
    JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE c.pctBodyFat IS NOT NULL AND 
        round BETWEEN 1 AND 2 AND
        year > 2000
    GROUP BY year, round
    ORDER BY year, round;


--compare overall (top 10)
SELECT d.yearDraft year, d.namePlayer player, c.pctBodyFat body_fat
    FROM Draft d
    JOIN Draft_Combine c ON d.idPlayer = c.idPlayer
    WHERE body_fat IS NOT NULL
    ORDER BY body_fat
    LIMIT 10;
    

--Question 33
--Where did the fastest, strongest, and best jumping players get drafted?
--Look at each metric individually and combined and for each year and overall.

--overall and individual metrics
--speed
SELECT c.namePlayer player, c.timeThreeQuarterCourtSprint sprint, 
    d.yearDraft draft, d.numberPickOverall pick 
    FROM Draft_Combine c
    JOIN Draft d ON c.idPlayer = d.idPlayer
    WHERE sprint IS NOT NULL
    ORDER BY sprint
    LIMIT 10;

--strength
SELECT c.namePlayer player, c.repsBenchPress135 bench_reps, 
    d.yearDraft draft, d.numberPickOverall pick 
    FROM Draft_Combine c
    JOIN Draft d ON c.idPlayer = d.idPlayer
    WHERE bench_reps IS NOT NULL
    ORDER BY bench_reps DESC
    LIMIT 10;

--vertical
SELECT c.namePlayer player, c.verticalLeapMaxInches vertical, 
    d.yearDraft draft, d.numberPickOverall pick 
    FROM Draft_Combine c
    JOIN Draft d ON c.idPlayer = d.idPlayer
    WHERE vertical IS NOT NULL
    ORDER BY vertical DESC
    LIMIT 10;
    
--overall and combined
--with subquery
SELECT dc.*,
    RANK() OVER(ORDER BY sprint) sprint_rank,
    RANK() OVER(ORDER BY bench_reps DESC) bench_rank,
    RANK() OVER(ORDER BY vertical DESC) vertical_rank,
    RANK() OVER(ORDER BY sprint) +
    RANK() OVER(ORDER BY bench_reps DESC) +
    RANK() OVER(ORDER BY vertical DESC) total_rank
    FROM(
        SELECT c.namePlayer player,  d.yearDraft draft, d.numberPickOverall pick,
            c.timeThreeQuarterCourtSprint sprint, c.repsBenchPress135 bench_reps,
            c.verticalLeapMaxInches vertical
            FROM Draft_Combine c
            JOIN Draft d ON c.idPlayer = d.idPlayer
            WHERE sprint IS NOT NULL AND
                bench_reps IS NOT NULL AND
                vertical IS NOT NULL) dc
    ORDER BY total_rank
    LIMIT 10;

--without subquery  
SELECT c.namePlayer player,  d.yearDraft draft, d.numberPickOverall pick,
        c.timeThreeQuarterCourtSprint sprint, c.repsBenchPress135 bench_reps,
        c.verticalLeapMaxInches vertical,
        RANK() OVER(ORDER BY c.timeThreeQuarterCourtSprint) sprint_rank,
        RANK() OVER(ORDER BY c.repsBenchPress135 DESC) bench_rank,
        RANK() OVER(ORDER BY c.verticalLeapMaxInches DESC) vertical_rank,
        RANK() OVER(ORDER BY c.timeThreeQuarterCourtSprint) +
        RANK() OVER(ORDER BY c.repsBenchPress135 DESC) +
        RANK() OVER(ORDER BY c.verticalLeapMaxInches DESC) total_rank
    FROM Draft_Combine c
    JOIN Draft d ON c.idPlayer = d.idPlayer
    WHERE sprint IS NOT NULL AND
            bench_reps IS NOT NULL AND
            vertical IS NOT NULL
    ORDER BY total_rank
    LIMIT 10;
            
--by year and metric
--speed
SELECT player, draft, pick, sprint
    FROM(
        SELECT c.namePlayer player, d.yearDraft draft, d.numberPickOverall pick,
            c.timeThreeQuarterCourtSprint sprint,
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.timeThreeQuarterCourtSprint) sprint_rank
            FROM Draft_Combine c
            JOIN Draft d ON c.idPlayer = d.idPlayer
            WHERE sprint IS NOT NULL) dc
    WHERE sprint_rank = 1;
    
--strength
SELECT player, draft, pick, bench_reps
    FROM(
        SELECT c.namePlayer player, d.yearDraft draft, d.numberPickOverall pick,
            c.repsBenchPress135 bench_reps,
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.repsBenchPress135 DESC) bench_rank
            FROM Draft_Combine c
            JOIN Draft d ON c.idPlayer = d.idPlayer
            WHERE bench_reps IS NOT NULL) dc
    WHERE bench_rank = 1;

--vertical
SELECT player, draft, pick, vertical, vertical_rank
    FROM(
        SELECT c.namePlayer player, d.yearDraft draft, d.numberPickOverall pick,
            c.verticalLeapMaxInches vertical,
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.verticalLeapMaxInches DESC) vertical_rank
            FROM Draft_Combine c
            JOIN Draft d ON c.idPlayer = d.idPlayer) dc
    WHERE vertical_rank = 1;
    
--by year and combined   
SELECT player, draft, pick, MIN(total_rank) total_rank, sprint, bench_reps, vertical
    FROM(
        SELECT c.namePlayer player, d.yearDraft draft, d.numberPickOverall pick,
            c.timeThreeQuarterCourtSprint sprint,
            c.repsBenchPress135 bench_reps,
            c.verticalLeapMaxInches vertical,
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.timeThreeQuarterCourtSprint) sprint_rank,
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.repsBenchPress135) bench_rank,
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.verticalLeapMaxInches) vertical_rank,
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.timeThreeQuarterCourtSprint) +
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.repsBenchPress135) +
            RANK()OVER(PARTITION BY d.yearDraft ORDER BY c.verticalLeapMaxInches) total_rank
            FROM Draft_Combine c
            JOIN Draft d ON c.idPlayer = d.idPlayer
            WHERE sprint IS NOT NULL AND
                    bench_reps IS NOT NULL AND
                    vertical IS NOT NULL) dc
    WHERE draft>1987
    GROUP BY draft;
            
--for the top 20? for each metric, how many were drafted in R1 vs R2?
--one metric (e.g., vertical)
--return list
SELECT c.namePlayer player, c.verticalLeapMaxInches vertical, d.numberRound round
    FROM Draft_Combine c
    JOIN Draft d ON c.idPlayer = d.idPlayer
    WHERE vertical IS NOT NULL
    ORDER BY vertical DESC
    LIMIT 23; --ties for vertical through top 23
    
--one metric (e.g., vertical)
--return counts
SELECT round, COUNT(round) draft_picks
    FROM(
    SELECT c.namePlayer player, c.verticalLeapMaxInches vertical, d.numberRound round
        FROM Draft_Combine c
        JOIN Draft d ON c.idPlayer = d.idPlayer
        WHERE vertical IS NOT NULL
        ORDER BY vertical DESC
        LIMIT 23) dc
    GROUP BY round;


--return round for the players in the top 20 of each metric
SELECT dc.*
    FROM(
        SELECT c.namePlayer player, d.yearDraft draft, d.numberPickOverall pick,d.numberRound round,
            c.timeThreeQuarterCourtSprint sprint,
            c.repsBenchPress135 bench_reps,
            c.verticalLeapMaxInches vertical,
            RANK()OVER(ORDER BY c.timeThreeQuarterCourtSprint) sprint_rank,
            RANK()OVER(ORDER BY c.repsBenchPress135) bench_rank,
            RANK()OVER(ORDER BY c.verticalLeapMaxInches) vertical_rank
            FROM Draft_Combine c
            JOIN Draft d ON c.idPlayer = d.idPlayer
            WHERE sprint IS NOT NULL AND
                    bench_reps IS NOT NULL AND
                    vertical IS NOT NULL) dc
    WHERE draft>1987 AND
            (sprint_rank <= 20 OR bench_rank <= 20 OR vertical_rank <= 20);
            
--whats the breakdown by round for the query above?
SELECT dc.round, COUNT(dc.round) draft_picks
    FROM(
        SELECT c.namePlayer player, d.yearDraft draft, d.numberPickOverall pick,d.numberRound round,
            c.timeThreeQuarterCourtSprint sprint,
            c.repsBenchPress135 bench_reps,
            c.verticalLeapMaxInches vertical,
            RANK()OVER(ORDER BY c.timeThreeQuarterCourtSprint) sprint_rank,
            RANK()OVER(ORDER BY c.repsBenchPress135) bench_rank,
            RANK()OVER(ORDER BY c.verticalLeapMaxInches) vertical_rank
            FROM Draft_Combine c
            JOIN Draft d ON c.idPlayer = d.idPlayer
            WHERE sprint IS NOT NULL AND
                    bench_reps IS NOT NULL AND
                    vertical IS NOT NULL) dc
    WHERE dc.draft>1987 AND
            (dc.sprint_rank <= 20 OR dc.bench_rank <= 20 OR dc.vertical_rank <= 20)
    GROUP BY dc.round;


