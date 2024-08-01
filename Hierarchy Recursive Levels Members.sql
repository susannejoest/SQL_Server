/* simplest version */

	  with hierarchy as 
	  (
	  select id, par, name, 1 as level
	  from [dbo].[T_0_SJ_Hierarchy_Data]
	  where id = 1 and par is null /* root */
	
	  UNION ALL
	
	    select hd.id, hd.par, hd.name, h.level + 1
	  from [dbo].[T_0_SJ_Hierarchy_Data] hd
		inner join hierarchy h on h.id = hd.par
		where hd.par is not null /* non-root */
	)
	select * from hierarchy

/* more complex */

WITH Hierarchy AS (
    -- Anchor member (starting point)
    SELECT
        id,
        par,
        name,
        CAST(name AS NVARCHAR(MAX)) AS Path,
        1 AS Level
    FROM
        T_0_SJ_Hierarchy_Data
    WHERE
        name = 'Nicole'
    
    UNION ALL
    
    -- Recursive member
    SELECT
        m.id,
        m.par,
        m.name,
        CAST(h.Path + '->' + m.name AS NVARCHAR(MAX)),
        h.Level + 1
    FROM
        T_0_SJ_Hierarchy_Data m
    INNER JOIN
        Hierarchy h ON m.par = h.id
)
SELECT
    id,
    par,
    name,
    Path,
    Level
FROM
    Hierarchy
ORDER BY
    Path;


	WITH Hierarchy AS (
    -- Anchor member (starting point)
    SELECT
        id,
        par,
        name,
        CAST(name AS NVARCHAR(MAX)) AS Path,
        1 AS Level
    FROM
        T_0_SJ_Hierarchy_Data
    WHERE
        name = 'Nicole'
    
    UNION ALL
    
    -- Recursive member
    SELECT
        m.id,
        m.par,
        m.name,
        CAST(h.Path + '->' + m.name AS NVARCHAR(MAX)),
        h.Level + 1
    FROM
        T_0_SJ_Hierarchy_Data m
    INNER JOIN
        Hierarchy h ON m.par = h.id
)
SELECT
    id,
    par,
    name,
    Path,
    Level
FROM
    Hierarchy
ORDER BY
    Path;

	WITH Hierarchy AS (
    -- Anchor member (starting point)
    SELECT
        id,
        par,
        name,
        CAST(name AS NVARCHAR(MAX)) AS Path,
        1 AS Level
    FROM
        T_0_SJ_Hierarchy_Data
    WHERE
        name = 'Nicole'
    
    UNION ALL
    
    -- Recursive member
    SELECT
        m.id,
        m.par,
        m.name,
        CAST(h.Path + '->' + m.name AS NVARCHAR(MAX)),
        h.Level + 1
    FROM
        T_0_SJ_Hierarchy_Data m
    INNER JOIN
        Hierarchy h ON m.par = h.id
),
LeveledHierarchy AS (
    SELECT
        h1.id AS Level1_ID,
        h1.name AS Level1_Name,
        h2.id AS Level2_ID,
        h2.name AS Level2_Name,
        h3.id AS Level3_ID,
        h3.name AS Level3_Name
    FROM
        Hierarchy h1
        LEFT JOIN Hierarchy h2 ON h2.par = h1.id AND h2.Level = 2
        LEFT JOIN Hierarchy h3 ON h3.par = h2.id AND h3.Level = 3
    WHERE
        h1.Level = 1
)
SELECT
    Level1_Name,
    Level2_Name,
    Level3_Name
FROM
    LeveledHierarchy;


/* insert sample data */
    CREATE TABLE T_0_SJ_Hierarchy_Data (
        id INT PRIMARY KEY,
        par INT,
        name NVARCHAR(100)
    );
    
    INSERT INTO T_0_SJ_Hierarchy_Data (id, par, name) VALUES
    (1, NULL, 'Root'),
    (2, 1, 'Nicole'),
    (3, 1, 'Alex'),
    (4, 2, 'John'),
    (5, 2, 'Sophie'),
    (6, 3, 'Susanne')
    ;

