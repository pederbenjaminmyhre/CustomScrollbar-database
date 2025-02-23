CREATE PROCEDURE [dbo].[SwapAndRefreshAnalyticalTable] AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @RowCount INT;

	-- Step 1: Calculate customSort, hasChildren, and childCount
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Agg1]') AND type in (N'U'))
	DROP TABLE [dbo].[Agg1]

    SELECT 
        id,
        parentId,
        name,
        ROW_NUMBER() OVER (PARTITION BY parentId ORDER BY FORMAT(id, '00000')) AS customSort,
        CASE WHEN EXISTS (SELECT 1 FROM dbo.TransactionalTable c WHERE c.parentId = t1.id) THEN 1 ELSE 0 END AS hasChildren,
        (SELECT COUNT(*) FROM dbo.TransactionalTable c WHERE c.parentId = t1.id) AS childCount,
        revenue
	into Agg1
    FROM dbo.TransactionalTable t1;
	SET @RowCount = @@ROWCOUNT;
	PRINT 'Step 1: Created temp table ''Agg1'' with ' + FORMAT(@RowCount, 'N0') + ' records.'

	-- Step 2: Calculate TreeLevel (1 is Highest Level)
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Agg2]') AND type in (N'U'))
	DROP TABLE [dbo].[Agg2]

	;WITH CTE AS (
		-- Base case: Top-level nodes (root nodes)
		SELECT 
			id, 
			parentId, 
			1 AS TreeLevel
		FROM Agg1
		WHERE parentId = 0  -- Change this if your root condition is different

		UNION ALL

		-- Recursive case: Join child nodes to their parents
		SELECT 
			child.id, 
			child.parentId, 
			parent.TreeLevel + 1
		FROM Agg1 AS child
		INNER JOIN CTE AS parent ON child.parentId = parent.id
	)
	select YT.*, 0 descendantCount, 0 TotalRevenue, CTE.TreeLevel
	into agg2
	FROM Agg1 YT
	INNER JOIN CTE ON YT.id = CTE.id
	order by YT.id;
	SET @RowCount = @@ROWCOUNT;
	PRINT 'Step 2: Created temp table ''Agg2'' with ' + FORMAT(@RowCount, 'N0') + ' records.'

	-- Step 3: Recursive aggregation for totalRevenue and descendantCount
	declare @currentLevel int = (select max(TreeLevel) from agg2); 
	print 'The highest ancestor in Agg2 is Level 1. The lowest leaf is ' + cast(@currentLevel as varchar(20))
	while @currentLevel > 0
	begin

			update dbo.Agg2 
				set descendantCount = agg3.childCount,         -- Does NOT count this parent node
					TotalRevenue = Agg2.revenue + agg3.revenue -- DOES count this parent node's revenue

			from dbo.Agg2 inner join 
			(
				select parentId, sum(1+descendantCount) childCount, sum(CASE WHEN TotalRevenue <> 0 then TotalRevenue else revenue+TotalRevenue end) revenue
				from dbo.Agg2
				where TreeLevel = @currentLevel
				group by parentId
			) agg3 on agg2.id = agg3.parentId
			where dbo.Agg2.Treelevel = @currentLevel - 1
			SET @RowCount = @@ROWCOUNT;
			PRINT '	Updated ' + FORMAT(@RowCount, 'N0') + ' rows in Level ' + cast(@currentLevel - 1 as varchar(20)) + ' with aggregates from Level ' + cast(@currentLevel as varchar(20))
		SET @currentLevel = @currentLevel - 1;
	end
	PRINT 'Step 3: Finished updating temp table ''Agg2'''

    -- Step 4: Determine the inactive table
    DECLARE @InactiveTable NVARCHAR(128);
    SELECT @InactiveTable = base_object_name
    FROM sys.synonyms 
    WHERE name = 'InactiveAnalyticalTable';
	PRINT 'Step 4: InactiveTable is: ' + @InactiveTable

    -- Step 5: Drop indexes on the inactive table
    IF @InactiveTable IS NOT NULL
    BEGIN
        EXEC('DROP INDEX IF EXISTS IX_Analytical_customSort ON ' + @InactiveTable);
        EXEC('DROP INDEX IF EXISTS IX_Analytical_ID ON ' + @InactiveTable);
    END
	PRINT 'Step 5: Dropped indexes on ' + @InactiveTable

    -- Step 6: Truncate the inactive table
    EXEC('TRUNCATE TABLE ' + @InactiveTable);
	PRINT 'Step 6: Truncated ' + @InactiveTable;

	-- Step 7: Calculate customSort, hasChildren, childCount and load Inactive Analytical Table
    INSERT INTO InactiveAnalyticalTable (
		id, parentId, name, customSort, hasChildren, childCount, revenue, totalRevenue, descendantCount, 
		Col1, Col2, Col3, Col4, Col5, Col6, Col7, Col8, Col9, Col10,
		Col11, Col12, Col13, Col14, Col15, Col16, Col17, Col18, Col19, Col20,
		Col21, Col22, Col23, Col24, Col25, Col26, Col27, Col28, Col29, Col30,
		Col31, Col32, Col33, Col34, Col35, Col36, Col37, Col38, Col39, Col40,
		Col41, Col42, Col43, Col44, Col45, Col46, Col47, Col48, Col49, Col50,
		Col51, Col52, Col53, Col54, Col55, Col56, Col57, Col58, Col59, Col60,
		Col61, Col62, Col63, Col64, Col65, Col66, Col67, Col68, Col69, Col70,
		Col71, Col72, Col73, Col74, Col75, Col76, Col77, Col78, Col79, Col80,
		Col81, Col82, Col83, Col84, Col85, Col86, Col87, Col88, Col89, Col90,
		Col91, Col92, Col93, Col94, Col95, Col96, Col97, Col98, Col99, Col100,
		Col101, Col102, Col103, Col104, Col105, Col106, Col107, Col108, Col109, Col110,
		Col111, Col112, Col113, Col114, Col115, Col116, Col117, Col118, Col119, Col120,
		Col121, Col122, Col123, Col124, Col125, Col126, Col127, Col128, Col129, Col130,
		Col131, Col132, Col133, Col134, Col135, Col136, Col137, Col138, Col139, Col140,
		Col141, Col142, Col143, Col144, Col145, Col146, Col147, Col148, Col149, Col150,
		Col151, Col152, Col153, Col154, Col155, Col156, Col157, Col158, Col159, Col160,
		Col161, Col162, Col163, Col164, Col165, Col166, Col167, Col168, Col169, Col170,
		Col171, Col172, Col173, Col174, Col175, Col176, Col177, Col178, Col179, Col180,
		Col181, Col182, Col183, Col184, Col185, Col186, Col187, Col188, Col189, Col190,
		Col191, Col192, Col193, Col194, Col195, Col196, Col197, Col198, Col199, Col200,
		Col201, Col202, Col203, Col204, Col205, Col206, Col207, Col208, Col209, Col210,
		Col211, Col212, Col213, Col214, Col215, Col216, Col217, Col218, Col219, Col220,
		Col221, Col222, Col223, Col224, Col225, Col226, Col227, Col228, Col229, Col230,
		Col231, Col232, Col233, Col234, Col235, Col236, Col237, Col238, Col239, Col240,
		Col241, Col242, Col243, Col244, Col245, Col246, Col247, Col248, Col249, Col250,
		Col251, Col252, Col253, Col254, Col255, Col256, Col257, Col258, Col259, Col260,
		Col261, Col262, Col263, Col264, Col265, Col266, Col267, Col268, Col269, Col270,
		Col271, Col272, Col273, Col274, Col275, Col276, Col277, Col278, Col279, Col280,
		Col281, Col282, Col283, Col284, Col285, Col286, Col287, Col288, Col289, Col290,
		Col291, Col292, Col293, Col294, Col295, Col296, Col297, Col298, Col299, Col300)
    SELECT 
        T1.id,
        T1.parentId,
        T1.name,
        Agg2.customSort,
        Agg2.hasChildren,
        Agg2.childCount,
        T1.revenue,
        Agg2.totalRevenue,
        Agg2.descendantCount, -- Corrected to initialize as 1
        T1.col1, T1.col2, T1.col3, T1.col4, T1.col5, T1.col6, T1.col7, T1.col8, T1.col9, T1.col10,
		T1.Col11, T1.Col12, T1.Col13, T1.Col14, T1.Col15, T1.Col16, T1.Col17, T1.Col18, T1.Col19, T1.Col20,
		T1.Col21, T1.Col22, T1.Col23, T1.Col24, T1.Col25, T1.Col26, T1.Col27, T1.Col28, T1.Col29, T1.Col30,
		T1.Col31, T1.Col32, T1.Col33, T1.Col34, T1.Col35, T1.Col36, T1.Col37, T1.Col38, T1.Col39, T1.Col40,
		T1.Col41, T1.Col42, T1.Col43, T1.Col44, T1.Col45, T1.Col46, T1.Col47, T1.Col48, T1.Col49, T1.Col50,
		T1.Col51, T1.Col52, T1.Col53, T1.Col54, T1.Col55, T1.Col56, T1.Col57, T1.Col58, T1.Col59, T1.Col60,
		T1.Col61, T1.Col62, T1.Col63, T1.Col64, T1.Col65, T1.Col66, T1.Col67, T1.Col68, T1.Col69, T1.Col70,
		T1.Col71, T1.Col72, T1.Col73, T1.Col74, T1.Col75, T1.Col76, T1.Col77, T1.Col78, T1.Col79, T1.Col80,
		T1.Col81, T1.Col82, T1.Col83, T1.Col84, T1.Col85, T1.Col86, T1.Col87, T1.Col88, T1.Col89, T1.Col90,
		T1.Col91, T1.Col92, T1.Col93, T1.Col94, T1.Col95, T1.Col96, T1.Col97, T1.Col98, T1.Col99, T1.Col100,
		T1.Col101, T1.Col102, T1.Col103, T1.Col104, T1.Col105, T1.Col106, T1.Col107, T1.Col108, T1.Col109, T1.Col110,
		T1.Col111, T1.Col112, T1.Col113, T1.Col114, T1.Col115, T1.Col116, T1.Col117, T1.Col118, T1.Col119, T1.Col120,
		T1.Col121, T1.Col122, T1.Col123, T1.Col124, T1.Col125, T1.Col126, T1.Col127, T1.Col128, T1.Col129, T1.Col130,
		T1.Col131, T1.Col132, T1.Col133, T1.Col134, T1.Col135, T1.Col136, T1.Col137, T1.Col138, T1.Col139, T1.Col140,
		T1.Col141, T1.Col142, T1.Col143, T1.Col144, T1.Col145, T1.Col146, T1.Col147, T1.Col148, T1.Col149, T1.Col150,
		T1.Col151, T1.Col152, T1.Col153, T1.Col154, T1.Col155, T1.Col156, T1.Col157, T1.Col158, T1.Col159, T1.Col160,
		T1.Col161, T1.Col162, T1.Col163, T1.Col164, T1.Col165, T1.Col166, T1.Col167, T1.Col168, T1.Col169, T1.Col170,
		T1.Col171, T1.Col172, T1.Col173, T1.Col174, T1.Col175, T1.Col176, T1.Col177, T1.Col178, T1.Col179, T1.Col180,
		T1.Col181, T1.Col182, T1.Col183, T1.Col184, T1.Col185, T1.Col186, T1.Col187, T1.Col188, T1.Col189, T1.Col190,
		T1.Col191, T1.Col192, T1.Col193, T1.Col194, T1.Col195, T1.Col196, T1.Col197, T1.Col198, T1.Col199, T1.Col200,
		T1.Col201, T1.Col202, T1.Col203, T1.Col204, T1.Col205, T1.Col206, T1.Col207, T1.Col208, T1.Col209, T1.Col210,
		T1.Col211, T1.Col212, T1.Col213, T1.Col214, T1.Col215, T1.Col216, T1.Col217, T1.Col218, T1.Col219, T1.Col220,
		T1.Col221, T1.Col222, T1.Col223, T1.Col224, T1.Col225, T1.Col226, T1.Col227, T1.Col228, T1.Col229, T1.Col230,
		T1.Col231, T1.Col232, T1.Col233, T1.Col234, T1.Col235, T1.Col236, T1.Col237, T1.Col238, T1.Col239, T1.Col240,
		T1.Col241, T1.Col242, T1.Col243, T1.Col244, T1.Col245, T1.Col246, T1.Col247, T1.Col248, T1.Col249, T1.Col250,
		T1.Col251, T1.Col252, T1.Col253, T1.Col254, T1.Col255, T1.Col256, T1.Col257, T1.Col258, T1.Col259, T1.Col260,
		T1.Col261, T1.Col262, T1.Col263, T1.Col264, T1.Col265, T1.Col266, T1.Col267, T1.Col268, T1.Col269, T1.Col270,
		T1.Col271, T1.Col272, T1.Col273, T1.Col274, T1.Col275, T1.Col276, T1.Col277, T1.Col278, T1.Col279, T1.Col280,
		T1.Col281, T1.Col282, T1.Col283, T1.Col284, T1.Col285, T1.Col286, T1.Col287, T1.Col288, T1.Col289, T1.Col290,
		T1.Col291, T1.Col292, T1.Col293, T1.Col294, T1.Col295, T1.Col296, T1.Col297, T1.Col298, T1.Col299, T1.Col300
    FROM dbo.TransactionalTable t1
	left outer join Agg2 ON t1.id = Agg2.id;
	SET @RowCount = @@ROWCOUNT;
	PRINT 'Step 7: Inserted ' + FORMAT(@RowCount, 'N0') + ' records into ' + @InactiveTable

    -- Step 7: Recreate indexes on the inactive table
    IF @InactiveTable IS NOT NULL
    BEGIN
        EXEC('CREATE CLUSTERED INDEX IX_Analytical_customSort ON ' + @InactiveTable + '(parentId, customSort)');
		EXEC('CREATE UNIQUE INDEX IX_Analytical_ID on ' + @InactiveTable + '(ID)');
    END
	PRINT 'Step 7: Created indexes on ' + @InactiveTable

    -- Step 8: Swap Synonyms
    DROP SYNONYM ActiveAnalyticalTable;
    DROP SYNONYM InactiveAnalyticalTable;
	PRINT 'Step 8: Dropped table synonyms'

	-- Step 9: Create synonyms
    IF @InactiveTable = '[AnalyticalTable1]'
    BEGIN
        CREATE SYNONYM ActiveAnalyticalTable FOR AnalyticalTable1;
        CREATE SYNONYM InactiveAnalyticalTable FOR AnalyticalTable2;
    END
    ELSE
    BEGIN
        CREATE SYNONYM ActiveAnalyticalTable FOR AnalyticalTable2;
        CREATE SYNONYM InactiveAnalyticalTable FOR AnalyticalTable1;
    END

    SELECT @InactiveTable = base_object_name
    FROM sys.synonyms 
    WHERE name = 'InactiveAnalyticalTable';
	PRINT 'Step 9: 
	InactiveTable is: ' + @InactiveTable

	DECLARE @ActiveTable NVARCHAR(128);
    SELECT @ActiveTable = base_object_name
    FROM sys.synonyms 
    WHERE name = 'ActiveAnalyticalTable';
	PRINT '	ActiveTable is: ' + @ActiveTable

END;
