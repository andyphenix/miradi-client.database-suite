/*
   Miradi Database Upgrade Script
   
*/

USE Miradi;

ALTER TABLE ProjectResource 
      CHANGE SurName Surname TEXT,
      CHANGE IsCCNCoach IsCcnCoach BOOLEAN;
ALTER TABLE ProjectResourceRoleCodes 
      CHANGE Code code ENUM("TeamMember","Contact","Leader","Facilitator","Advisor","Stakeholder");
ALTER TABLE Organization CHANGE SurName Surname TEXT;
ALTER TABLE TNCProjectData CHANGE CAPStandardsScorecard CapStandardsScorecard TEXT;
ALTER TABLE TNCProjectPlaceTypes CHANGE Code code VARCHAR(25);
ALTER TABLE TNCOrganizationalPriorities CHANGE Code code VARCHAR(25);
ALTER TABLE TNCOperatingUnits CHANGE Code code VARCHAR(10);
ALTER TABLE TNCTerrestrialEcoRegion CHANGE Code code CHAR(5);
ALTER TABLE TNCMarineEcoRegion CHANGE Code code CHAR(5);
ALTER TABLE TNCFreshwaterEcoRegion CHANGE Code code CHAR(5);
ALTER TABLE WWFManagingOffices CHANGE Code code CHAR(4);
ALTER TABLE WWFRegions CHANGE Code code CHAR(2);
ALTER TABLE WWFEcoRegions CHANGE Code code INTEGER;
ALTER TABLE WCSData CHANGE SwotURL SwotUrl TEXT, CHANGE StepURL StepUrl TEXT;
ALTER TABLE DiagramFactor CHANGE X x INTEGER, CHANGE Y y INTEGER,
                          CHANGE Width width SMALLINT, CHANGE Height height SMALLINT,
                          MODIFY DiagramFactorFontSize CHAR(4);
UPDATE DiagramFactor
   SET DiagramFactorFontSize = CASE DiagramFactorFontSize
                                    WHEN "0.50" THEN "0.5"
                                    WHEN "0.90" THEN "0.9"
                                    WHEN "1.00" THEN "1.0"
                                    WHEN "2.50" THEN "2.5"
                                    ELSE DiagramFactorFontSize
                                END;
ALTER TABLE DiagramLinkBendPoint CHANGE X x INTEGER, CHANGE Y y INTEGER;
ALTER TABLE TargetHabitatAssociation 
      CHANGE Code code ENUM( "1","1.1","1.2","1.3","1.4","1.5","1.6","1.7","1.8","1.9",
            "2","2.1","2.2","3","3.1","3.2","3.3","3.4","3.5","3.6","3.7","3.8",
            "4","4.1","4.2","4.3","4.4","4.5","4.6","4.7",
            "5","5.1","5.2","5.3","5.4","5.5","5.6","5.7","5.8","5.9","5.10",
            "5.11","5.12","5.13","5.14","5.15","5.16","5.17","5.18",
            "6","7","7.1","7.2","8","8.1","8.2","8.3",
            "9","9.1","9.2","9.3","9.5","9.6","9.7","9.8","9.8.1","9.8.2","9.8.3",
            "9.8.4","9.8.5","9.8.6","9.9","9.10","10","10.1","10.2","10.3","10.4",
            "11","11.1","11.1.1","11.1.2","11.2","11.3","11.4","11.5","11.6",
            "12","12.1","12.2","12.3","12.4","12.5","12.6","12.7",
            "13","13.1","13.2","13.3","13.4","13.5",
            "14","14.1","14.2","14.3","14.4","14.5","14.6",
            "15","15.1","15.2","15.3","15.4","15.5","15.6","15.7","15.8","15.9",
            "15.10","15.11","15.12","15.13","16","TNC1","TNC2","TNC3","17","18"
          );
DROP VIEW IF EXISTS BiodiversityTargetHabitatAssociation;
CREATE VIEW BiodiversityTargetHabitatAssociation AS
       SELECT Hab.ID, Hab.ProjectSummaryID, Hab.TargetID AS BiodiversityTargetID,
              Hab.TargetXID AS BiodiversityTargetXID, code
         FROM TargetHabitatAssociation Hab, BiodiversityTarget Tgt
        WHERE Tgt.ProjectSummaryID = Hab.ProjectSummaryID
          AND Tgt.XID = Hab.TargetXID;

ALTER TABLE ProjectSummary ADD COLUMN DatabaseImportDtm DATETIME;
      
ALTER TABLE ConservationProject DROP COLUMN DatabaseImportDtm;

ALTER TABLE SubTask CHANGE SubtaskRef SubTaskXID INTEGER;

DROP VIEW IF EXISTS TaskSubTask;
CREATE VIEW TaskSubTask AS                  /* IMPORTANT NOTE: The desired sequence to retrieve
                                               TaskSubtask is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY TaskSubtask.Sequence;
                                            */
       SELECT SubTask.ID, SubTask.ProjectSummaryID, SubTask.TaskID,          
              SubTask.TaskXID, SubTask.Sequence, SubTask.SubTaskXID
         FROM Task, SubTask
        WHERE Subtask.ProjectSummaryID = Task.ProjectSummaryID
          AND Subtask.TaskXID = Task.XID;


DROP VIEW IF EXISTS ActivityTask;
CREATE VIEW ActivityTask AS                 /* IMPORTANT NOTE: The desired sequence to retrieve
                                               ActivityTask is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY ActivityTask.Sequence;
                                            */

       SELECT SubTask.ID, SubTask.ProjectSummaryID, SubTask.TaskID AS ActivityID,
              SubTask.TaskXID AS ActivityXID, SubTask.Sequence, 
              SubTask.SubTaskXID AS TaskXID
         FROM Activity AS Act, SubTask
        WHERE SubTask.ProjectSummaryID = Act.ProjectSummaryID
          AND SubTask.TaskXID = Act.XID;

DROP VIEW IF EXISTS MethodTask;
CREATE VIEW MethodTask AS                   /* IMPORTANT NOTE: The desired sequence to retrieve
                                               MethodTask is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY MethodTask.Sequence;
                                            */

       SELECT SubTask.ID, SubTask.ProjectSummaryID, SubTask.TaskID AS MethodID,
              SubTask.TaskXID AS MethodXID, SubTask.Sequence, 
              SubTask.SubTaskXID AS TaskXID
         FROM Method AS Meth, SubTask
        WHERE SubTask.ProjectSummaryID = Meth.ProjectSummaryID
          AND SubTask.TaskXID = Meth.XID;

ALTER TABLE ExtraDataSection CHANGE Owner owner VARCHAR(255);

ALTER TABLE DashboardFlags CHANGE Code code ENUM("needsAttention");


