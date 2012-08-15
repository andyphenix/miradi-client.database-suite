/*
   Miradi Database Upgrade Script
   
*/

USE Miradi;

DROP VIEW TaskSubTask;
RENAME TABLE SubTask TO TaskSubTask;
ALTER TABLE TaskSubTask ADD COLUMN SubTaskID INTEGER AFTER Sequence;

CREATE VIEW SubTask AS                      /* SubTasks have the same properties as Tasks.
                                               They are associated to their parent Tasks
                                               through the table TaskSubTask.
                                            */
       SELECT ID, ProjectSummaryID, XID, Factor, TaskActivityMethod_Id AS SubTask_Id,
              Name, Details, Comments, CalculatedStartDate, CalculatedEndDate,
              CalculatedWorkUnitsTotal, CalculatedExpenseTotal,
              CalculatedTotalBudgetCost
         FROM TaskActivityMethod                 
        WHERE Factor = "Task";

DROP VIEW IF EXISTS v_SubTask;
CREATE VIEW v_SubTask AS
       SELECT TaskID, TaskXID, Sequence, Task.*
         FROM TaskSubTask, Task
        WHERE Task.ProjectSummaryID = TaskSubTask.ProjectSummaryID
          AND Task.XID = TaskSubTask.SubTaskXID;
          

DROP VIEW IF EXISTS ActivityTask;
CREATE VIEW ActivityTask AS                 /* IMPORTANT NOTE: The desired sequence to retrieve
                                               ActivityTask is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY ActivityTask.Sequence;
                                            */

       SELECT SubTask.ID, SubTask.ProjectSummaryID, SubTask.TaskID AS ActivityID,
              SubTask.TaskXID AS ActivityXID, SubTask.Sequence, 
              SubTask.SubTaskID AS TaskID, SubTask.SubTaskXID AS TaskXID
         FROM Activity AS Act, TaskSubTask SubTask
        WHERE SubTask.ProjectSummaryID = Act.ProjectSummaryID
          AND SubTask.TaskXID = Act.XID;


DROP VIEW IF EXISTS v_ActivityTask;
CREATE VIEW v_ActivityTask AS
       SELECT ActivityID, ActivityXID, Sequence, Task.*
         FROM ActivityTask ActTask, Task
        WHERE Task.ProjectSummaryID = ActTask.ProjectSummaryID
          AND Task.XID = ActTask.TaskXID;
          

DROP VIEW IF EXISTS MethodTask;
CREATE VIEW MethodTask AS                   /* IMPORTANT NOTE: The desired sequence to retrieve
                                               MethodTask is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY MethodTask.Sequence;
                                            */

       SELECT SubTask.ID, SubTask.ProjectSummaryID, SubTask.TaskID AS MethodID,
              SubTask.TaskXID AS MethodXID, SubTask.Sequence, 
              SubTask.SubTaskID AS TaskID, SubTask.SubTaskXID AS TaskXID
         FROM Method AS Meth, TaskSubTask SubTask
        WHERE SubTask.ProjectSummaryID = Meth.ProjectSummaryID
          AND SubTask.TaskXID = Meth.XID;


/************************************************************************************************/

DROP VIEW IF EXISTS v_ResultsChainStrategy;
CREATE VIEW v_ResultsChainStrategy
    AS SELECT RCDF.ResultsChainID, RCDF.ResultsChainXID, Str.*
         FROM ResultsChainDiagramFactor RCDF,
              DiagramFactor DF, Strategy Str
        WHERE Str.ProjectSummaryID = DF.ProjectSummaryID
          AND Str.XID = DF.WrappedByDiagramFactorXID
          AND DF.ID = RCDF.DiagramFactorID
          AND DF.WrappedByDiagramFactor = "Strategy";
          
          
DROP VIEW IF EXISTS v_ResultsChainTarget;
CREATE VIEW v_ResultsChainTarget
    AS SELECT RCDF.ResultsChainID, RCDF.ResultsChainXID, Tgt.*
         FROM ResultsChainDiagramFactor RCDF,
              DiagramFactor DF, Target Tgt
        WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
          AND Tgt.XID = DF.WrappedByDiagramFactorXID
          AND DF.ID = RCDF.DiagramFactorID
          AND DF.WrappedByDiagramFactor LIKE "%Target";
          
          
DROP VIEW IF EXISTS v_ConceptualModelStrategy;
CREATE VIEW v_ConceptualModelStrategy
    AS SELECT CMDF.ConceptualModelID, CMDF.ConceptualModelXID, Str.*
         FROM ConceptualModelDiagramFactor CMDF,
              DiagramFactor DF, Strategy Str
        WHERE Str.ProjectSummaryID = DF.ProjectSummaryID
          AND Str.XID = DF.WrappedByDiagramFactorXID
          AND DF.ID = CMDF.DiagramFactorID
          AND DF.WrappedByDiagramFactor = "Strategy";
          
          
DROP VIEW IF EXISTS v_ConceptualModelTarget;
CREATE VIEW v_ConceptualModelTarget
    AS SELECT CMDF.ConceptualModelID, CMDF.ConceptualModelXID, Tgt.*
         FROM ConceptualModelDiagramFactor CMDF,
              DiagramFactor DF, Target Tgt
        WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
          AND Tgt.XID = DF.WrappedByDiagramFactorXID
          AND DF.ID = CMDF.DiagramFactorID
          AND DF.WrappedByDiagramFactor LIKE "%Target";
          
          
DROP VIEW IF EXISTS v_StrategyProgressReport;
CREATE VIEW v_StrategyProgressReport AS
       SELECT StrategyID, StrategyXID, Rpt.*
         FROM StrategyProgressReport StrRpt, ProgressReport Rpt
        WHERE Rpt.ID = StrRpt.ProgressReportID;


DROP VIEW IF EXISTS v_TaskProgressReport;
CREATE VIEW v_TaskProgressReport AS
       SELECT TaskID, TaskXID, Rpt.*
         FROM TaskProgressReport TaskRpt, ProgressReport Rpt
        WHERE Rpt.ID = TaskRpt.ProgressReportID;


DROP VIEW IF EXISTS v_MethodProgressReport;
CREATE VIEW v_MethodProgressReport AS
       SELECT MethodID, MethodXID, Rpt.*
         FROM MethodProgressReport MethRpt, ProgressReport Rpt
        WHERE Rpt.ID = MethRpt.ProgressReportID;


DROP VIEW IF EXISTS v_IndicatorProgressReport;
CREATE VIEW v_IndicatorProgressReport AS
       SELECT IndicatorID, IndicatorXID, Rpt.*
         FROM IndicatorProgressReport IndRpt, ProgressReport Rpt
        WHERE Rpt.ID = IndRpt.ProgressReportID;


DROP VIEW IF EXISTS v_ObjectiveProgressReport;
CREATE VIEW v_ObjectiveProgressReport AS
            SELECT ObjectiveID, ObjectiveXID, Rpt.*
              FROM ObjectiveProgressReport ObjRpt, ProgressReport Rpt
             WHERE Rpt.ID = ObjRpt.ProgressReportID;


DROP VIEW IF EXISTS v_GoalProgressReport;
CREATE VIEW v_GoalProgressReport AS
            SELECT GoalID, GoalXID, Rpt.*
              FROM GoalProgressReport GoalRpt, ProgressReport Rpt
             WHERE Rpt.ID = GoalRpt.ProgressReportID;


DROP VIEW IF EXISTS v_ObjectiveProgressPercent;
CREATE VIEW v_ObjectiveProgressPercent AS
            SELECT ObjectiveID, ObjectiveXID, Pct.*
              FROM ObjectiveProgressPercent ObjPct, ProgressPercent Pct
             WHERE Pct.ID = ObjPct.ProgressPercentID;


DROP VIEW IF EXISTS v_GoalProgressPercent;
CREATE VIEW v_GoalProgressPercent AS
            SELECT GoalID, GoalXID, Pct.*
              FROM GoalProgressPercent GoalPct, ProgressPercent Pct
             WHERE Pct.ID = GoalPct.ProgressPercentID;


DROP VIEW IF EXISTS v_IndicatorMethod;
CREATE VIEW v_IndicatorMethod AS
       SELECT IndicatorID, IndicatorXID, Sequence, Method.*
         FROM IndicatorMethod IndMeth, Method
        WHERE Method.ID = IndMeth.MethodID;


DROP VIEW IF EXISTS v_MethodTask;
CREATE VIEW v_MethodTask AS
       SELECT MethodID, MethodXID, Sequence, Task.*
         FROM MethodTask MethTask, Task
        WHERE Task.ProjectSummaryID = MethTask.ProjectSummaryID
          AND Task.XID = MethTask.TaskXID;
          

DROP VIEW IF EXISTS v_IndicatorAssignment;
CREATE VIEW v_IndicatorAssignment AS
       SELECT IndicatorID, IndicatorXID, Asgn.*
         FROM IndicatorAssignment Indasgn, ResourceAssignment Asgn
        WHERE Asgn.ID = IndAsgn.ResourceAssignmentID;


DROP VIEW IF EXISTS v_IndicatorExpense;
CREATE VIEW v_IndicatorExpense AS
       SELECT IndicatorID, IndicatorXID, Exp.*
         FROM IndicatorExpense IndExp, ExpenseAssignment Exp
        WHERE Exp.ID = IndExp.ExpenseAssignmentID;


DROP VIEW IF EXISTS v_StrategyObjective;
CREATE VIEW v_StrategyObjective AS
       SELECT StrategyID, StrategyXID, Obj.*
         FROM StrategyObjective StrObj, Objective Obj
        WHERE Obj.ID = StrObj.ObjectiveID;


DROP VIEW IF EXISTS v_StrategyGoal;
CREATE VIEW v_StrategyGoal AS
       SELECT StrategyID, StrategyXID, Goal.*
         FROM StrategyGoal StrGoal, Goal Goal
        WHERE Goal.ID = StrGoal.GoalID;


DROP VIEW IF EXISTS v_ObjectiveRelevantActivity;
CREATE VIEW v_ObjectiveRelevantActivity AS
       SELECT ObjectiveID, ObjectiveXID, Act.*
         FROM ObjectiveRelevantActivity ObjAct, Activity Act
        WHERE Act.ID = ObjAct.ActivityID;
        

DROP VIEW IF EXISTS v_GoalRelevantActivity;
CREATE VIEW v_GoalRelevantActivity AS
       SELECT GoalID, GoalXID, Act.*
         FROM GoalRelevantActivity GoalAct, Activity Act
        WHERE Act.ID = GoalAct.ActivityID;
        

DROP VIEW IF EXISTS v_ObjectiveRelevantStrategy;
CREATE VIEW v_ObjectiveRelevantStrategy AS
       SELECT ObjectiveID, ObjectiveXID, Str.*
         FROM ObjectiveRelevantStrategy ObjStr, Strategy Str
        WHERE Str.ID = ObjStr.StrategyID;


DROP VIEW IF EXISTS v_GoalRelevantStrategy;
CREATE VIEW v_GoalRelevantStrategy AS
       SELECT GoalID, GoalXID, Str.*
         FROM GoalRelevantStrategy GoalStr, Strategy Str
        WHERE Str.ID = GoalStr.StrategyID;


DROP VIEW IF EXISTS v_TargetGoal;
CREATE VIEW v_TargetGoal AS
       SELECT TargetID, TargetXID, Goal.*
         FROM TargetGoal TgtGoal, Goal
        WHERE Goal.ID = TgtGoal.GoalID;
        

DROP VIEW IF EXISTS v_ObjectiveIndicator;        -- Joins ObjectiveRelevantIndicator with Indicator.
CREATE VIEW v_ObjectiveRelevantIndicator AS
       SELECT ObjectiveID, ObjectiveXID, Ind.*
         FROM ObjectiveRelevantIndicator Obj, Indicator Ind
        WHERE Ind.ID = Obj.IndicatorID; 


DROP VIEW IF EXISTS v_GoalRelevantIndicator;        -- Joins GoalRelevantIndicator with Indicator.
CREATE VIEW v_GoalRelevantIndicator AS
       SELECT GoalID, GoalXID, Ind.*
         FROM GoalRelevantIndicator Goal, Indicator Ind
        WHERE Ind.ID = Goal.IndicatorID; 




/*
   sp_DeleteProject_v3.sql

   Delete entire projects from the Miradi database by ProjectSummaryID.
   
   **********************************************************************************************
   
   Developed by David Berg for The Nature Conservancy and the greater conservation community.
   
   Copyright (c) 2010 - 2012 David I. Berg. Distributed under the terms of the GPL version 3.
   
   This file is part of the Miradi Database Suite.
   
   The Miradi Database Suite is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License Version 3 as published by
   the Free Software Foundation, or (at your option) any later version.

   The Miradi Database Suite is distributed in the hope that it will be useful, but 
   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with the 
   Miradi Database Suite. If not, it is situated at <http://www.gnu.org/licenses/gpl.html>
   and is incorporated herein by reference.
   
   **********************************************************************************************

  If you specify ProjectSummaryID = 0, all projects will be deleted!

  To invoke this procedure for all projects in the Miradi Database ...
   
        CALL sp_DeleteProjects(0); [or ("0") ]
        
   To invoke this procedure for selected projects in the Miradi Database, you need to determine
   the ProjectSummaryID for the projects you wish to delete. To view them ...
   
        SELECT * FROM v_Project;
        
   ... and note the ProjectSummaryID for each project you wish to delete. Then, invoke 
  the procedure with a comma-separated list of ProjectSummaryIDs, all enclosed in quotes ...
   
        CALL sp_DeleteProject("43,44,45,...");


   Revision History:
   Version 03 - 2011-08-10 - Enable the specification of multiple projects.
   Version 02 - 2011-11-09 - Add table MiradiColumns to exclusion list.
   Version 01 - 2010-12-27 - Initial Version.
*/

USE Miradi;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_DeleteProject $$
CREATE PROCEDURE sp_DeleteProject (ProjectSummaryList VARCHAR(255))

BEGIN

      DECLARE pTableName VARCHAR(255);      -- Table whose rows are being deleted.
      DECLARE EOF BOOLEAN DEFAULT FALSE;

      /* Cursor to select each table name from the Table Catalog. */

      DECLARE c_Table CURSOR FOR
              SELECT Tbl.TABLE_NAME
                FROM information_schema.TABLES Tbl, information_schema.COLUMNS Col
               WHERE Col.TABLE_SCHEMA = Tbl.TABLE_SCHEMA
                 AND Col.TABLE_NAME = Tbl.TABLE_NAME
                 AND Tbl.TABLE_SCHEMA = DATABASE()
                 AND Tbl.TABLE_TYPE = "BASE TABLE"
                 AND (   (Tbl.TABLE_NAME = "ProjectSummary" AND COLUMN_NAME = "ID")
                      OR COLUMN_NAME = "ProjectSummaryID"
                     );

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET EOF = TRUE;

      OPEN c_Table;
      WHILE NOT EOF DO
            FETCH c_Table INTO pTableName;
            IF  NOT EOF THEN
                SET @SQLStmt =
                    CONCAT("DELETE FROM ",pTableName,
                           " WHERE ",
                           CASE WHEN ProjectSummaryList = "0"
                                THEN "TRUE"
                                ELSE CASE WHEN pTableName = "ProjectSummary"
                                          THEN CONCAT("ID IN (",ProjectSummaryList,")")
                                          ELSE CONCAT("ProjectSummaryID IN (",ProjectSummaryList,")")
                                      END
                            END
                          );
                     PREPARE SQLStmt FROM @SQLStmt;
                     EXECUTE SQLStmt;
            END IF;
      END WHILE;

END $$

DELIMITER ;