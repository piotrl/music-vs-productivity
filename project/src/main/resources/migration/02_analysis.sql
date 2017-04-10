-- Look for correlation between amount activities within one hour and music played
SELECT
  date_trunc('hour', ma.activityStarted)           AS hour,
  count(DISTINCT ma.activityName)                  AS activities,
  sum(DISTINCT COALESCE(track.duration, 0)) / 60.0 AS musicMinutes,
  sum(DISTINCT ma.activityTime) / 60.0             AS activityMinutes
FROM music_activity ma
  LEFT JOIN lastfm_track track ON track.id = ma.trackId
WHERE ma.accountId = :accountId
--   AND date_trunc('day', ma.activityStarted) = '2017-02-23' -- mock
GROUP BY hour
ORDER BY hour ASC;

/**
 *  Most popular artists played in hours (all time)
 */
SELECT
  artist.name,
  sum(track.duration) / 3600.0    AS hours,
  count(DISTINCT ma.scrobbleId) AS scrobbles
FROM music_activity ma
  JOIN lastfm_track track ON track.id = ma.trackId
  JOIN lastfm_artist artist ON track.artist_id = artist.id
WHERE ma.activityStarted >= :from AND ma.activityStarted <= :to
      AND ma.accountid = :accountId
GROUP BY artist.name
ORDER BY scrobbles DESC;

/**
 * summary of listened activities, music and salience per day for current month
 */
WITH aggregation_summary AS (SELECT
                               day,
                               sum(music) / 3600.0                   AS music,
                               sum(activity) / 3600.0                AS activity,
                               (sum(activity) - sum(music)) / 3600.0 AS salience
                             FROM (SELECT
                                     played_when :: DATE AS day,
                                     track.duration      AS music,
                                     0                   AS activity
                                   FROM lastfm_scrobble scrobble
                                     JOIN lastfm_track track ON scrobble.track_id = track.id
                                   UNION
                                   SELECT
                                     start_time :: DATE AS day,
                                     0                  AS music,
                                     spent_time         AS activity
                                   FROM rescuetime_activity
                                  ) m
                             GROUP BY day
                             ORDER BY day)
SELECT
  summary.*
FROM generate_series(
         DATE_TRUNC('month', NOW() :: DATE),
         DATE_TRUNC('month', NOW()) + '1 MONTH' :: INTERVAL - '1 DAY' :: INTERVAL,
         '1 day' :: INTERVAL
     ) date
  JOIN aggregation_summary summary ON summary.day = date