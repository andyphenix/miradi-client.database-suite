/* Miradi Database Upgrade 2011-09-20

   - Introduce views for 1:1 relationships among tables (which correspond to the
     necessary structure of the XMPZ XML Schema). 

*/

USE Miradi;

DROP VIEW IF EXISTS v_IndicatorMeasurement;
CREATE VIEW v_IndicatorMeasurement AS
       SELECT Ind.ProjectSummaryID, IndicatorID, IndicatorXID, Ind.MeasurementID, 
              Ind.MeasurementXID, Name, Date, Source, MeasurementValue, RATING(Rating),
              Trend, Detail, Comments 
        FROM IndicatorMeasurement Ind, Measurement Meas
       WHERE Meas.ID = Ind.MeasurementID;
       
/*
DROP VIEW IF EXISTS v_IndicatorProgressReport;
CREATE VIEW v_IndicatorProgressReport AS
       SELECT Ind.ProjectSummaryID, IndicatorID, IndicatorXID, Ind.ProgressReportID, 
              Ind.ProgressReportXID, ProgressDate, Details, ProgressStatus
        FROM IndicatorProgressReport Ind, ProgressReport Prog
       WHERE Prog.ID = Ind.ProgressReportID;
       
       
DROP VIEW IF EXISTS v_IndicatorAssignment;
CREATE VIEW v_IndicatorAssignment AS
       SELECT Ind.ProjectSummaryID, IndicatorID, IndicatorXID, Ind.ResourceAssignmentID, 
              Ind.ResourceAssignmentXID, Name, Details, ProjectResourceID,
              ProjectResourceXID, FundingSourceID, FundingSourceXID, AccountingCodeID,
              AccountingCodeXID, BudgetCategoryOneID, BudgetCategoryOneXID,
              BudgetCategoryTwoID, BudgetCategoryTwoXID
        FROM IndicatorAssignment Ind, ResourceAssignment Asgn
       WHERE Asgn.ID = Ind.ResourceAssignmentID;
*/       
       
RENAME TABLE ExternalProjectID TO ExternalProjectId;

DROP VIEW IF EXISTS v_Project;          -- Selects the current version of a Project
CREATE VIEW v_Project AS                -- based on its ConPro ProjectID.
       SELECT ProjectId, ProjectSummaryID, Summ.*
         FROM ProjectSummary Summ, ExternalProjectId PID
        WHERE PID.ProjectSummaryID = Summ.ID
          AND PID.ExternalApp = "ConPro"
          AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                           FROM ExternalProjectId PID2
                          WHERE PID2.ExternalApp = PID.ExternalApp
                            AND PID2.ProjectId = PID.ProjectId
                        );




-- END