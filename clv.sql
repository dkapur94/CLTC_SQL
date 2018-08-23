SELECT quart1,
       line_of_buss,
       trans,
       (gpm*trans) AS gp from
  (SELECT *, CASE
                 WHEN line_of_buss = 'DF' THEN 420
                 WHEN line_of_buss = 'DH' THEN 1048
                 WHEN line_of_buss = 'IF' THEN 900
                 WHEN line_of_buss = 'IH' THEN 2599
                 ELSE NULL
             END AS gpm
   FROM
     (SELECT quart1, line_of_buss, sum(trnx) AS trans
      FROM
        (SELECT * from(
                         (SELECT email, ceil((visit_month+1)/3) AS quart1
                          FROM
                            (SELECT email, acq_dt, (datediff(acq_dt,'2017-01-01') DIV 31) AS visit_month
                             FROM marketanalytics.cust_profiless_apr18_ind
                             WHERE acq_dt >= '2017-01-01'
                             GROUP BY email,acq_dt)
                          ORDER BY ceil((visit_month+1)/3))q1
                       INNER JOIN
                         (SELECT email,ceil((visit_month+1)/3) AS quart2,line_of_buss,trnx
                          FROM
                            (SELECT email, line_of_buss,count(DISTINCT booking_id) AS trnx, (datediff(booking_dt,'2017-01-01') DIV 31) AS visit_month
                             FROM
                               (SELECT *, CASE
                                              WHEN lob ='DF' THEN 'DF'
                                              WHEN lob = 'IF' THEN 'IF'
                                              WHEN lob IN ('HOTEL_DOM','Hotel_Dom') THEN 'DH'
                                              WHEN lob IN ('HOTEL_INT','Hotel_Int') THEN 'IH'
                                              ELSE NULL
                                          END AS line_of_buss
                                FROM marketanalytics.cust_profilesss_apr18_ind dfg
                                WHERE dfg.email IN
                                    (SELECT DISTINCT email
                                     FROM marketanalytics.cust_profilesss_apr18_ind
                                     WHERE acq_dt >='2017-01-01'
                                       AND device_omni='Desktop' )
                                  AND lob IN ('DF','IF','HOTEL_DOM','HOTEL_INT','Hotel_Int','Hotel_Dom') )a
                             WHERE line_of_buss IS NOT NULL
                             GROUP BY email,line_of_buss,booking_dt)b
                          GROUP BY email,line_of_buss,trnx,visit_month
                          ORDER BY email)q2 ON (q1.email = q2.email
                                                AND q1.quart1 = q2.quart2))u1
         UNION SELECT *
         FROM (
                 (SELECT email, ceil((visit_month+1)/3) AS quart1
                  FROM
                    (SELECT email, acq_dt, (datediff(acq_dt,'2017-01-01') DIV 31) AS visit_month
                     FROM marketanalytics.cust_profiless_apr18_ind
                     WHERE acq_dt >= '2017-01-01'
                     GROUP BY email,acq_dt)
                  ORDER BY ceil((visit_month+1)/3))t1
               INNER JOIN
                 (SELECT email,ceil((visit_month+1)/3) AS quart2,line_of_buss,trnx
                  FROM
                    (SELECT email, line_of_buss,count(DISTINCT booking_id) AS trnx, (datediff(booking_dt,'2017-01-01') DIV 31) AS visit_month
                     FROM
                       (SELECT *, CASE
                                      WHEN lob ='DF' THEN 'DF'
                                      WHEN lob = 'IF' THEN 'IF'
                                      WHEN lob IN ('HOTEL_DOM','Hotel_Dom') THEN 'DH'
                                      WHEN lob IN ('HOTEL_INT','Hotel_Int') THEN 'IH'
                                      ELSE NULL
                                  END AS line_of_buss
                        FROM marketanalytics.cust_profilesss_apr18_ind dfg
                        WHERE dfg.email IN
                            (SELECT DISTINCT email
                             FROM marketanalytics.cust_profilesss_apr18_ind
                             WHERE acq_dt >='2017-01-01'
                               AND device_omni='Desktop' )
                          AND lob IN ('DF','IF','HOTEL_DOM','HOTEL_INT','Hotel_Int','Hotel_Dom') )a
                     WHERE line_of_buss IS NOT NULL
                     GROUP BY email,line_of_buss,booking_dt)b
                  GROUP BY email,line_of_buss,trnx,visit_month
                  ORDER BY email)t2 ON (t1.email = t2.email
                                        AND (t2.quart2-t1.quart1) = 1))u2) x4
      GROUP BY quart1, line_of_buss
      ORDER BY quart1,line_of_buss ))
GROUP BY quart1,
         line_of_buss,
         trans,
         gpm
ORDER BY quart1,
         line_of_buss