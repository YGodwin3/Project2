USE internet_db;

/*
USE internet_db;

DROP TABLE`internet_freedom`;

CREATE TABLE `internet_freedom` (
  `INTERNET_FREEDOM_ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `COUNTRY_CD` varchar(15) NOT NULL,
  `YEAR_NO` int(4) UNSIGNED NOT NULL,
  `COUNTRY_NM` varchar(60) DEFAULT NULL,
  `INTERNET_USER_RATE` decimal(24,20) DEFAULT NULL,
  `POLITY_SCORE` int(4) SIGNED DEFAULT NULL,
  `REGIME_STATUS` varchar(15) DEFAULT NULL,
  `FREEDOM_IND` int(4) SIGNED DEFAULT NULL,
  `FREEDOM_STATUS` varchar(15) DEFAULT NULL,
  `CORRUPTION_INDEX` int(4) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`INTERNET_FREEDOM_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
*/

TRUNCATE TABLE `internet_freedom`;

INSERT INTO `internet_db`.`internet_freedom`
(
    `COUNTRY_CD`,
    `YEAR_NO`,
    `COUNTRY_NM`,
    `INTERNET_USER_RATE`,
    `POLITY_SCORE`,
    `REGIME_STATUS`,
    `FREEDOM_IND`,
    `FREEDOM_STATUS`,
	`CORRUPTION_INDEX`
)
SELECT 
	 natural_key.COUNTRY_CD
    ,natural_key.YEAR_NO
    ,natural_key.COUNTRY_NM
    ,internet.INTERNET_USER_RATE
    ,regime.POLITY_SCORE
    ,regime.REGIME_STATUS
    ,freedom.FREEDOM_IND
    ,freedom.FREEDOM_STATUS
    ,corruption.CORRUPTION_INDEX
FROM (
        SELECT
            a.COUNTRY_CD,
			a.COUNTRY_NM,
			a.`WB_COUNTRY_CD`,
			a.`TI_COUNTRY_CD`,
			a.`FRD_COUNTRY_CD`,
			a.`REG_COUNTRY_CD`,
            a.`JSON_COUNTRY_CD`,
            b.YEAR_NO
        FROM (
				SELECT 
					`ISO_3166_ALPHA3_CD` AS COUNTRY_CD, 
					`COUNTRY_NM`,
					`WB_COUNTRY_CD`,
					`TI_COUNTRY_CD`,
					`FRD_COUNTRY_CD`,
					`REG_COUNTRY_CD`,
					`JSON_COUNTRY_CD`
				FROM `internet_db`.`ld_csv_country_iso_cd`
				WHERE `INCLUDE_FLG` = 1
				  AND `JSON_COUNTRY_CD` != ''
                ORDER BY 1
             ) a
        JOIN 
            (
                SELECT DISTINCT cast(`Time` as unsigned) as `YEAR_NO`
                FROM `internet_db`.`ld_csv_wb_data`
                WHERE cast(nullif(`Time`,'') as unsigned) BETWEEN 2012
												              AND 2017
                ORDER BY 1
            ) b
          ON 1 = 1 
        ORDER BY 1,7
    ) natural_key
LEFT JOIN
    (
        SELECT 
            `﻿Country Name` as COUNTRY_NM,
            `Country Code` as COUNTRY_CD,
            `Series Name` as SERIES_NM,
            `Series Code` as SERIES_CD,
            cast(`Time` as unsigned)  as `YEAR_NO`,
            `Time Code`,
            `Value`,
            cast(nullif(trim(`Value`),'') as decimal(24,20)) as INTERNET_USER_RATE
        FROM `internet_db`.`ld_csv_wb_data`
        WHERE cast(nullif(`Time`,'') as unsigned) BETWEEN 2012
						                              AND 2017
          AND `Series Code` = 'IT.NET.USER.ZS'
        ORDER BY 2,5
    ) internet
  ON natural_key.WB_COUNTRY_CD = internet.COUNTRY_CD
 AND natural_key.YEAR_NO = internet.YEAR_NO
LEFT JOIN
    (
        SELECT 
            `Entity`,
            `Code` as COUNTRY_CD,
            cast(`Year` as unsigned) as YEAR_NO,
            cast(`Corruption Perception Index` as unsigned) as CORRUPTION_INDEX
        FROM `internet_db`.`ld_csv_corruption_data`
        WHERE cast(nullif(`Year`,'') as unsigned) BETWEEN 2012
						                              AND 2017
        ORDER BY 1,3
    ) corruption
  ON natural_key.TI_COUNTRY_CD = corruption.COUNTRY_CD
 AND natural_key.YEAR_NO = corruption.YEAR_NO
LEFT JOIN
    (
        SELECT 
            `Entity`,
            `Code` as COUNTRY_CD,
            cast(`Year` as unsigned) as YEAR_NO,
            `Value`,
            CASE 
                WHEN  `Value` = '1500'
                THEN -1
                WHEN  `Value` = '2500'
                THEN 0
                WHEN  `Value` = '3500'
                THEN 1
            END as FREEDOM_IND,
            CASE 
                WHEN  `Value` = '1500'
                THEN 'Not Free'
                WHEN  `Value` = '2500'
                THEN 'Partly Free'
                WHEN  `Value` = '3500'
                THEN 'Free'
            END as FREEDOM_STATUS
        FROM `internet_db`.`ld_csv_freedom_data`
        WHERE cast(nullif(`Year`,'') as unsigned) BETWEEN 2012
						                              AND 2017
        ORDER BY 2,3
    ) freedom
  ON natural_key.FRD_COUNTRY_CD = freedom.COUNTRY_CD
 AND natural_key.YEAR_NO = freedom.YEAR_NO
LEFT JOIN
    (
        SELECT 
            `scode` as COUNTRY_CD,
            `country`,
            cast(`year` as unsigned) as `YEAR_NO`,
            cast(nullif(trim(`polity2`),'') as signed) as POLITY_SCORE,
            CASE 
                WHEN cast(nullif(trim(`polity2`),'') as signed) between -10 and -6
                THEN 'Autocracy'
                WHEN cast(nullif(trim(`polity2`),'') as signed) between -5 and 0
                THEN 'Closed Anocracy'
                WHEN cast(nullif(trim(`polity2`),'') as signed) between 0 and 5
                THEN 'Open Anocracy'
                WHEN cast(nullif(trim(`polity2`),'') as signed) between 6 and 10
                THEN 'Democracy'
                WHEN nullif(trim(`polity2`),'') is null
                THEN 'No Score'
            END REGIME_STATUS
        FROM `internet_db`.`ld_csv_regime_data`
        WHERE cast(nullif(`year`,'') as unsigned) BETWEEN 2012
										              AND 2017 
        ORDER BY 1,3
    ) regime
  ON natural_key.REG_COUNTRY_CD = regime.COUNTRY_CD
 AND natural_key.YEAR_NO = regime.YEAR_NO
ORDER BY 1,3;

-- Export query
SELECT 
    INTERNET_FREEDOM_ID,
    COUNTRY_CD,
    YEAR_NO,
    COUNTRY_NM,
    INTERNET_USER_RATE,
    POLITY_SCORE,
    REGIME_STATUS,
    FREEDOM_IND,
    FREEDOM_STATUS,
	CORRUPTION_INDEX
FROM internet_db.internet_freedom
WHERE 
      INTERNET_USER_RATE IS NOT NULL
  AND POLITY_SCORE IS NOT NULL
  AND FREEDOM_IND IS NOT NULL
  AND CORRUPTION_INDEX IS NOT NULL
ORDER BY 1,2;


