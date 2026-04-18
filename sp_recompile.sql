/*
sp_recompile: Force a recompile of stored procedures,
triggers, or user-defined functions the next time they 
run, typically to update an outdated execution plan.
*/

-- Examples
-- 1. Recompile a specific stored procedure
EXEC 
	sp_recompile 
	N'DB_DEMO.dbo.usp_UpdateAllPendingInvoices';
GO
-- 2. Recompile All Objects Referencing a Table
EXEC 
	sp_recompile 
	N'DB_DEMO.dbo.TblInvoiceHeader';
GO
-- 3. Recompile a Trigger
USE [DB_DEMO];
GO
EXEC sp_recompile 
		N'trg_NewInvoiceTracker';
GO
-- 4. Recompiles stored proc only for that specific run.
EXEC 
	DB_DEMO.dbo.usp_UpdateAllPendingInvoices 
	@A = 10 
	WITH RECOMPILE;
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link and 
name of the file on the video description. This and 
other solutions are given "AS IS" under no warranty 
or claim.
*/