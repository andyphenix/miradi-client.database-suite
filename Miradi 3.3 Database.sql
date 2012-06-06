/*
   Miradi 3.3 Database v44.sql

   Miradi 3.3 Relational Database Schema
   Compatible with the MySQL Database Server, Version 5.0 and later.

   Developed by David Berg for The Nature Conservancy 
        and the Greater Conservation Community.

   This version of the schema is compatible with Miradi 3.3 and later versions employing 
   XMPZ XML data model http://xml.miradi.org/schema/ConservationProject/73.
   
   ** IMPORTANT NOTE: Views that join many parent/child tables join on XID rather than ID because 
                      the project import process actually inserts into the view, not the master
                      table. Parent IDs are not yet known at the time the views are populated during
                      the project import process; they get populated during post-load processing. 
                      Please do not attempt to "improve" these views by changing their join condition(s) 
                      to use ID instead of XID. The consequence of doing so will be that parent IDs will 
                      not get populated at all during post-load processing - and, thus, the views will 
                      select nothing ... a condition that does not necessarily become apparent until a user 
                      application accesses the view(s) some time later. (I know; I did it once - and had 
                      to undo all of them.)

   Revision History:
   Version 44 - 2012-03-07 - Added views v_StrategyActivity, v_ObjectiveIndicator,
                             v_Task/Activity/MethodAssignment, v_Task/Activity/MethodExpense,
                             v_TargetKeyAttribute, v_KeyAttributeIndicator, v_TargetIndicator.
                           - Amended views v_IndicatorMeasurement, v_ThreatIndicator.
                           - Change letter case on ENUM values to precisely match XML Schema Vocabulary.
                           - Redesign MiradiTables.
                           - Add MiradiColumns.
                           - Add function fn_StripTags().
                           - Add FiscalYear to DateUnitWorkUnits, DateUnitExpense and work/expense
                             plan views.
                           - Changed names of views of work/expense plan years to better reflect
                             their raison d'etre.
   Version 43 - 2011-09-28 - Added view v_IndicatorMeasurement.
   Version 42 - 2011-09-06 - Rename CalculatedWorkUnits and CalculatedExpense to
                             CalculatedWorkUnits and CalculatedExpense.
                           - Rename StressThreatRating to StressBasedThreatRating.
                           - Rename view KeyAttribute to v_KeyAttribute.
                           - Rename WorkUnitsEntry and ExpenseEntry to
                             CalculatedWorkUnits and CalculatedExpense.
                           - Rename StressThreatRating to StressBasedThreatRating.
                           - Make Flag 64 an Object-level flag instead of an element-level flag.
                           - Allow Flag 8 to be an Object-level flag (in addition to an element-
                             level flag) to flag multi-valued sets (in addition to multi-
                             valued elements).
                           - Create table TaggedObjectSetFactor to contain WrappedByDiagramFactor
                             for Tagged Object Sets; fold WrappedByDiagramFactor into
                             DiagramFactor for simple diagrams.
                           - Ditto DiagramLinkBendPoint for DiagramPoints.v_TaskAss
   Version 41a - 2011-08-25 - Correct a couple of copy/paste errors.
   Version 41 - 2011-08-24 - Continued revisions and streamlining to the differentiation of
                             Tasks, Activities, Methods and their associations.
   Version 40 - 2011-07-23 - Add Factor to indexes on tables that have Factor references.
                           - Enlarge MeasurementValue to TEXT for those projects whose
                             Measurement Values contain data more suitable for Details.
   Version 39 - 2011-07-21 - Rename FactorType to Factor everywhere except Target and Result. 
   Version 38 - 2011-07-18 - Use new view v_DiagramLink to include To/From DiagramFactorID
                             and To/From WrappedByDiagramFactorXID.
                           - Add view v_ParentProject. 
   Version 37 - 2011-07-11 - Fix broken view.
   Version 36 - 2011-06-30 - Revise the differentiation of Tasks, Activities, and Methods within
                             the single Object Class (3) Task/ActivityMethod.
                             Rename Task and associated Tables to TaskActivityMethod 
                             (similar to Miradi Object Class 3). Rename v_Task View to Task.
                             This will avoid some confusion with regard to the Task XML object  
                             containing elements for Tasks, Activities, and Methods.
                           - Add column DeletedOrphans to ConservationProject Table.
   Version 35 - 2011-06-27 - Change Factor to Factor for all occurrences.
                           - Add new views to consolidate diagram factor, group box, diagram link,
                             and grouped diagram link data into as few query statements as possible.  
                           - Comment out domain tables for now. They will eventually need to be
                             placed into their own database. Will wait until the code to populate
                             them is developed.
   Version 34 - 2011-06-06 - Add domain tables from miradi.jar\resources\fieldoptions.
                           - Tune up views containing KEA.
                           - Add Indicator.IsActive based on Viability Mode compatibility.
                           - Create a view v_Projects to select the current version of a project
                             based on its ConPro ProjectID.
                           - Move xmlns into its own Conservation Project Table.
   Version 33 - 2011-05-23 - Add xmlns to ProjectSummary Table.
                           - Add views v_WorkYears, v_WorkAccts, v_WorkFunds
   Version 32 - 2011-05-13 - Add Factor XID columns to DiagramLink Table to simplify navigation.
                           - Add DiagramFactor/Link views and other minor adjustments.
                           - Add sp_DeleteProject script.
   Version 31 - 2011-05-09 - Add Factor to v_CalculatedYears and WorkUnits/CalculatedExpense
   Version 30 - 2011-04-27 - Add CalculatedWho and its corresponding views.
   Version 29 - 2011-04-26 - Changes corresponding to XML Schema Version 73
                           - Revised sp_StrategyThreat.
                           - Added Method Assignment/CalculatedWorkUnits/CalculatedExpense
                             not previously added.
   Version 28 - 2011-04-24 - Structural revisions to Version 27 to simplify parsing logic.
                           - Removed Factor from Target and Result intersections to
                             simplify Iterator EOF processing. Changed intersections to join
                             to their base tables (views) to enable selection on Factor Type.
   Version 27 - 2011-04-22 - Revise Version 26 for standalone tables CalculatedWorkUnits and CalculatedExpense.
   Version 26 - 2011-04-18 - Add structure for Calculated Costs in XML Schema Version 71.
                           - Add Sequence column for Method/Activity/Task intersections.
   Version 25 - 2011-04-15 - Additional normalization to eliminate some custom parsing of
                             Diagram features.
                             - Add WrappedByDiagramFactor as its own table and Drop Table
                             TaggedObjectSetFactor to simplify parsing of Diagram Factors
                             and Tagged Object Sets.
                           - Revise sp_StrategyThreat for new table structures in V24 & 25.
   Version 24 - 2011-04-14 - Change ScopeBox.TypeCode to ScopeBox.ScopeBoxTypeCode to
                             simplify parsing of Scobe Boxes.
                           - Add DiagramPoint as its own table to simplify parsing of Diagram
                             Factors and Diagram Links.
   Version 23 - 2011-04-11 - Updated sp_StrategyThreat procedure.
                           - Added Factor to Target and Result intersections.
                           - Reinstated below-removed views for shared intersections,
                             but using Factor from the intersection rather than a join.
   Version 22 - 2011-03-26 - Eliminate unnecessary views for Factor Types that share a
                             common table. Goal and Objective each becomes its own table,
                             as do their associations.
   Version 21 - 2011-03-24 - Replace Activity Assignment, Expense, and ProgressReport
                             Tables with Views on corresponding Task Tables.
   Version 20 - 2011-03-23 - Revise the paradigm of storing Expense and Work Unit Time
                             schedules.
   Version 19 - 2011-03-20 - Added Objective x Threat/Target and Threat x Target Tables
                             (the latter to replace the view ThreatTarget).
                           - Changed "ObjectType" to "Factor" for all occurrences.
   Version 18 - 2011-03-18 - Implemented changes in accordance with XML Schema Version 69.
   Version 17 - 2011-03-15 - Implemented changes in accordance with XML Schema Version 66.
   Version 16 - 2011-03-03 - Implemented changes in accordance with XML Schema Version 63.
                           - Changed all status/rating/ranking codes to numeric.
   Version 15 - 2011-02-22 - Changed to correspond to XML Schema Version 60.
                           - Added MiradiTables to store all table names in the database.
                           - Added functions RATING() and RANKING();
                           - Added procedure sp_StrategyThreat();
   Version 14 - 2011-02-16 - Changed ActivityTask Table to a View on TaskSubtask Table.
   Version 13 - 2011-02-13 - Changed to corrspond to XML Schema Version 58.
   Version 12 - 2011-01-31 - Revisions following successful run using Version 11.
   Version 11 - 2011-01-28 - Changes to reflect revised XML Schema released this date.
   Version 10 - 2011-01-27 - Add Progress Percent and Objective/Goal references.
                           - Revise structure of threat ratings.
   Version 09 - 2011-01-26 - Create and/or properly rename intersection tables for
                             Pool cross references.
   Version 08 - 2011-01-25 - Reverse Version 05 - Separate out Scope, Planning, Location.
   Version 07 - 2011-01-24 - Add indexes for all XID references.
   Version 06 - 2011-01-13 - Changes to CM and RC Diagram Tables/Elements.
   Version 05 - 2011-01-03 - Combine all ProjectSummary elements in ProjectSummary;
   Version 04 - 2010-12-30 - Added ENUM characteristics to constrained columns.
   Version 03 - 2010-12-29 - Changed "WID" to "XID".
                           - Added XIDs to iation Tables.
                           - Added Conceptual and Results Chain Models and Diagram Tables.
   Version 02 - 2010-08-23

*/

DROP DATABASE Miradi;
CREATE DATABASE Miradi;

USE Miradi;

DROP TABLE IF EXISTS ConservationProject;
CREATE TABLE ConservationProject
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER,
 xmlns VARCHAR(255),
 DatabaseImportDtm DATETIME,
 DeletedOrphans MEDIUMTEXT
);


DROP TABLE IF EXISTS ProjectID;
CREATE TABLE ProjectID
(ProjectID INTEGER AUTO_INCREMENT PRIMARY KEY
) AUTO_INCREMENT = 5001,
  ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO ProjectID VALUES(0);


DROP TABLE IF EXISTS ProjectSummary;
CREATE TABLE ProjectSummary             -- Objects-11
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectName TEXT,
 ShareOutsideOrganization BOOLEAN,
 ProjectLanguage ENUM("ab","aa","af","ak","sq","am","ar","an","hy","as",
                      "av","ae","ay","az","bm","ba","eu","be","bn","bh",
                      "bi","nb","bs","br","bg","my","ca","km","ch","ce",
                      "ny","zh","cu","cv","kw","co","cr","hr","cs","da",
                      "dv","nl","dz","en","eo","et","ee","fo","fj","fi",
                      "fr","ff","gd","gl","lg","ka","de","el","gn","gu",
                      "ht","ha","he","hz","hi","ho","hu","is","io","ig",
                      "id","ia","ie","iu","ik","ga","it","ja","jv","kl",
                      "kn","kr","ks","kk","ki","rw","ky","kv","kg","ko",
                      "kj","ku","lo","la","lv","li","ln","lt","lu","lb",
                      "mk","mg","ms","ml","mt","gv","mi","mr","mh","mo",
                      "mn","na","nv","nd","nr","ng","ne","se","no","nn",
                      "oc","oj","or","om","os","pi","pa","fa","pl","pt",
                      "ps","qu","ro","rm","rn","ru","sm","sg","sa","sc",
                      "sr","sn","ii","sd","si","sk","sl","so","st","es",
                      "su","sw","ss","sv","tl","ty","tg","ta","tt","te",
                      "th","bo","ti","to","ts","tn","tr","tk","tw","ug",
                      "uk","ur","uz","ve","vi","vo","wa","cy","fy","wo",
                      "xh","yi","yo","za","zu",""
                     ),
 DataEffectiveDate DATE,
 OtherOrgProjectNumber VARCHAR(255),
 OtherOrgRelatedProjects TEXT,
 ProjectURL TEXT,
 ProjectDescription TEXT,
 ProjectStatus TEXT,
 NextSteps TEXT,
 OverallProjectThreatRating CHAR(1),
 OverallProjectViabilityRating CHAR(1),
 ThreatRatingMode ENUM("Simple","StressBased"),
 QuarterColumnsVisibility ENUM("ShowQuarterColumns","HideQuarterColumns"),
 WorkPlanTimeUnit ENUM("QUARTERLY","YEARLY")
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ExternalProjectId;
CREATE TABLE ExternalProjectId          -- Objects-44
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL DEFAULT 0,
 ExternalApp VARCHAR(255),
 ProjectId INTEGER,
 FOREIGN KEY (ProjectSummaryID) References ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_Project;
CREATE VIEW v_Project AS                /* Selects the current version of a Project
                                           based on its ConPro ProjectID.
                                        */
       SELECT ProjectId, ProjectSummaryID,  ProjectName, ShareOutsideOrganization, ProjectLanguage, DataEffectiveDate,
              OtherOrgProjectNumber, OtherOrgRelatedProjects, ProjectURL, ProjectDescription, ProjectStatus, NextSteps,
              OverallProjectThreatRating, OverallProjectViabilityRating, ThreatRatingMode, QuarterColumnsVisibility,
              WorkPlanTimeUnit 
         FROM ProjectSummary Summ, ExternalProjectId PID
        WHERE PID.ProjectSummaryID = Summ.ID
          AND PID.ExternalApp = "ConPro"
          AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                           FROM ExternalProjectId PID2
                          WHERE PID2.ExternalApp = PID.ExternalApp
                            AND PID2.ProjectId = PID.ProjectId
                        );
         

DROP TABLE IF EXISTS ProjectScope;
CREATE TABLE ProjectScope                 -- Objects-11
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ShortProjectScope TEXT,
 ProjectScope TEXT,
 ProjectVision TEXT,
 ScopeComments TEXT,
 ProjectArea VARCHAR(50),
 ProjectAreaNote TEXT,
 HumanPopulation INTEGER,
 HumanPopulationNotes TEXT,
 SocialContext TEXT,
 ProtectedAreaCategoryNotes TEXT,
 LegalStatus TEXT,
 LegislativeContext TEXT,
 PhysicalDescription TEXT,
 BiologicalDescription TEXT,
 SocioEconomicInformation TEXT,
 HistoricalDescription TEXT,
 CulturalDescription TEXT,
 AccessInformation TEXT,
 VisitationInformation TEXT,
 CurrentLandUses TEXT,
 ManagementResources TEXT,
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ProjectPlanning;
CREATE TABLE ProjectPlanning              -- Objects-11
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StartDate DATE,
 ExpectedEndDate DATE,
 WorkPlanStartDate DATE,
 WorkPlanEndDate DATE,
 FiscalYearStart SMALLINT,          -- ''|'10'|'7'|'4'
 FullTimeEmployeeDaysPerYear DECIMAL(4,1),
 PlanningComments TEXT,
 CurrencyType VARCHAR(25),
 CurrencySymbol CHAR(5),
 CurrencyDecimalPlaces TINYINT,
 TotalBudgetForFunding DECIMAL,
 BudgetSecuredPercent DECIMAL(5,2),
 KeyFundingSources TEXT,
 FinancialComments TEXT,
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS Audience;
CREATE TABLE Audience                     -- Obejcts-55
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL DEFAULT 0,
 XID INTEGER NOT NULL,
 Name TEXT,
 PeopleCount VARCHAR(255),
 Summary TEXT,
 INDEX (ProjectSummaryID,XID),
 FOREIGN KEY (ProjectSummaryID) References ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS IUCNRedListSpecies;  -- Objects-53
CREATE TABLE IUCNRedListSpecies
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL DEFAULT 0,
 XID INTEGER NOT NULL,
 Name TEXT,
 INDEX (ProjectSummaryID,XID),
 FOREIGN KEY (ProjectSummaryID) References ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS OtherNotableSpecies; -- Objects-54
CREATE TABLE OtherNotableSpecies
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL DEFAULT 0,
 XID INTEGER NOT NULL,
 Name TEXT,
 INDEX (ProjectSummaryID,XID),
 FOREIGN KEY (ProjectSummaryID) References ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ProtectedAreaCategories;
CREATE TABLE ProtectedAreaCategories      -- Objects-11
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL DEFAULT 0,
 ProjectScopeID INTEGER NOT NULL DEFAULT 0,
 code ENUM("Ia","Ib","II","III","IV","V","VI"),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ProjectScopeID) REFERENCES ProjectScope(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ProjectLocation;
CREATE TABLE ProjectLocation              -- Objects-11
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StateAndProvinces TEXT,
 Municipalities TEXT,
 LegislativeDistricts TEXT,
 LocationDetail TEXT,
 SiteMapReference TEXT,
 LocationComments TEXT,
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ProjectCountries;
CREATE TABLE ProjectCountries             -- Objects-11
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL DEFAULT 0,
 ProjectLocationID INTEGER NOT NULL DEFAULT 0,
 code CHAR(3),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ProjectLocationID) REFERENCES ProjectLocation(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS GeospatialLocation;
CREATE TABLE GeospatialLocation           -- Objects-11
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL DEFAULT 0,
 ProjectLocationID INTEGER NOT NULL DEFAULT 0,
 latitude DECIMAL(6,4),
 longitude DECIMAL(7,4),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ProjectLocationID) REFERENCES ProjectLocation(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS Organization;
CREATE TABLE Organization                 -- Objects-42
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Organization_Id VARCHAR(255),
 Name TEXT,
 RolesDescription TEXT,
 GivenName TEXT,
 SurName TEXT,
 Email VARCHAR(255),
 PhoneNumber VARCHAR(50),
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 FOREIGN KEY (ProjectSummaryID) References ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TNCProjectData;
CREATE TABLE TNCProjectData               -- Objects-40
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 DatabaseDownloadDate DATE,
 OtherOrgRelatedProjects TEXT,
 PlanningTeamComments TEXT,
 ConProParentChildProjectText TEXT,
 LessonsLearned TEXT,
 ProjectResourcesScorecard TEXT,
 ProjectLevelComments TEXT,
 ProjectCitations TEXT,
 CAPStandardsScorecard TEXT,
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_ParentProject;
CREATE VIEW v_ParentProject AS
       SELECT ProjectId, Proj.ProjectSummaryID,
              SUBSTRING_INDEX(
                 SUBSTRING_INDEX(
                    SUBSTRING_INDEX(ConProParentChildProjectText,"ParentProject:",-1
                                   ),")",1
                                ),"Project ID: ",-1
                             ) AS ParentId
         FROM v_Project Proj, TNCProjectData TNC
        WHERE TNC.ProjectSummaryID = Proj.ProjectSummaryID
          AND LEFT(ConProParentChildProjectText,6) = "Parent";


DROP TABLE IF EXISTS TNCProjectPlaceTypes;
CREATE TABLE TNCProjectPlaceTypes
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TNCProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code VARCHAR(25),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TNCProjectDataID) REFERENCES TNCProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TNCOrganizationalPriorities;
CREATE TABLE TNCOrganizationalPriorities
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TNCProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code VARCHAR(25),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TNCProjectDataID) REFERENCES TNCProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TNCOperatingUnits;
CREATE TABLE TNCOperatingUnits
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TNCProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code VARCHAR(10),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TNCProjectDataID) REFERENCES TNCProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TNCTerrestrialEcoRegion;
CREATE TABLE TNCTerrestrialEcoRegion
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TNCProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code CHAR(5),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TNCProjectDataID) REFERENCES TNCProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TNCMarineEcoRegion;
CREATE TABLE TNCMarineEcoRegion
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TNCProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code CHAR(5),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TNCProjectDataID) REFERENCES TNCProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TNCFreshwaterEcoRegion;
CREATE TABLE TNCFreshwaterEcoRegion
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TNCProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code CHAR(5),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TNCProjectDataID) REFERENCES TNCProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS WWFProjectData;
CREATE TABLE WWFProjectData               -- Objects-30
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS WWFManagingOffices;
CREATE TABLE WWFManagingOffices
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 WWFProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code CHAR(4),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (WWFProjectDataID) REFERENCES WWFProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS WWFRegions;
CREATE TABLE WWFRegions
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 WWFProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code CHAR(2),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (WWFProjectDataID) REFERENCES WWFProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS WWFEcoRegions;
CREATE TABLE WWFEcoRegions
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 WWFProjectDataID INTEGER NOT NULL DEFAULT 0,
 Code INTEGER,
 CONSTRAINT FOREIGN KEY (WWFProjectDataID) REFERENCES WWFProjectData(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS WCSData;
CREATE TABLE WCSData                      -- Objects-39
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 OrganizationalFocus TEXT,
 OrganizationalLevel TEXT,
 SwotCompleted TEXT,
 SwotURL TEXT,
 StepCompleted TEXT,
 StepURL TEXT,
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS RareProjectData;
CREATE TABLE RareProjectData              -- Objects-38
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 Cohort TEXT,
 ThreatsAddressedNotes TEXT,
 NumberOfCommunitiesInCampaignArea TEXT,
 BiodiversityHotspots TEXT,
 FlagshipSpeciesCommonName TEXT,
 FlagshipSpeciesScientificName TEXT,
 FlagshipSpeciesDetail TEXT,
 CampaignTheoryOfChange TEXT,
 CampaignSlogan TEXT,
 SummaryOfKeyMessages TEXT,
 MainActivitiesNotes TEXT,
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS FosProjectData;
CREATE TABLE FosProjectData               -- Objects-41
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TrainingType CHAR(1),
 TrainingDates TEXT,
 Trainers TEXT,
 Coaches TEXT,
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ProjectResource;
CREATE TABLE ProjectResource              -- Objects-7
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Resource_Id VARCHAR(255),
 ResourceType ENUM("Person","Group"),
 GivenName TEXT,
 SurName TEXT,
 Organization VARCHAR(255),
 Position VARCHAR(255),
 Location VARCHAR(255),
 OfficePhoneNumber VARCHAR(50),
 PhoneNumberHome VARCHAR(50),
 PhoneNumberMobile VARCHAR(50),
 PhoneNumberOther VARCHAR(50),
 Email VARCHAR(255),
 AlternativeEmail VARCHAR(255),
 IMService VARCHAR(255),
 IMAddress VARCHAR(255),
 DailyRate DECIMAL(8,2),
 IsCCNCoach BOOLEAN,
 Custom1 TEXT,
 Custom2 TEXT,
 Comments TEXT,
 DateUpdated DATE,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ProjectResourceRoleCodes;
CREATE TABLE ProjectResourceRoleCodes     -- Objects-7
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ProjectResourceID INTEGER NOT NULL DEFAULT 0,
 ProjectResourceXID INTEGER NOT NULL,
 Code ENUM("TeamMember","Contact","Leader","Facilitator","Advisor","Stakeholder"),
 INDEX (ProjectSummaryID,ProjectResourceXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ProjectResourceID) REFERENCES ProjectResource(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS AccountingCode;
CREATE TABLE AccountingCode               -- Objects-15
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Name TEXT,
 Code VARCHAR(255),
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS FundingSource;
CREATE TABLE FundingSource                -- Objects-16
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Name TEXT,
 Code VARCHAR(255),
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS BudgetCategoryOne;
CREATE TABLE BudgetCategoryOne            -- Objects-56
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Label VARCHAR(255),
 Code VARCHAR(255),
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS BudgetCategoryTwo;
CREATE TABLE BudgetCategoryTwo            -- Objects-57
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Label VARCHAR(255),
 Code VARCHAR(255),
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ResourceAssignment;
CREATE TABLE ResourceAssignment           -- Objects-14
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Name TEXT,
 Details TEXT,
 ProjectResourceID INTEGER,
 ProjectResourceXID INTEGER,
 FundingSourceID INTEGER,
 FundingSourceXID INTEGER,
 AccountingCodeID INTEGER,
 AccountingCodeXID INTEGER,
 BudgetCategoryOneID INTEGER,
 BudgetCategoryOneXID INTEGER,
 BudgetCategoryTwoID INTEGER,
 BudgetCategoryTwoXID INTEGER,
 INDEX (ProjectSummaryID,XID),
 INDEX (ProjectSummaryID,ProjectResourceXID),
 INDEX (ProjectSummaryID,FundingSourceXID),
 INDEX (ProjectSummaryID,AccountingCodeXID),
 INDEX (ProjectSummaryID,BudgetCategoryOneXID),
 INDEX (ProjectSummaryID,BudgetCategoryTwoXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ProjectResourceID) REFERENCES ProjectResource(ID),
 CONSTRAINT FOREIGN KEY (FundingSourceID) REFERENCES FundingSource(ID),
 CONSTRAINT FOREIGN KEY (AccountingCodeID) REFERENCES AccountingCode(ID),
 CONSTRAINT FOREIGN KEY (BudgetCategoryOneID) REFERENCES BudgetCategoryOne(ID),
 CONSTRAINT FOREIGN KEY (BudgetCategoryTwoID) REFERENCES BudgetCategoryTwo(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS CalculatedWorkUnits; -- Same format as Resource Assignment for Calculated Costs.
CREATE TABLE CalculatedWorkUnits LIKE ResourceAssignment;
ALTER TABLE CalculatedWorkUnits           -- Table serves Strategy/Activity/Task/Indicator/Method.
      ADD COLUMN Factor VARCHAR(25) NOT NULL AFTER XID,
      ADD COLUMN FactorID INTEGER NOT NULL DEFAULT 0 AFTER Factor,
      ADD COLUMN FactorXID INTEGER NOT NULL AFTER FactorID,
      ADD INDEX (FactorID),
      ADD INDEX (ProjectSummaryID, FactorXID);


DROP TABLE IF EXISTS CalculatedWho;
CREATE TABLE CalculatedWho                -- Contains the list of ResourceIds for Calculated Costs.
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 Factor VARCHAR(25) NOT NULL DEFAULT "",
 FactorID INTEGER NOT NULL DEFAULT 0,
 FactorXID INTEGER NOT NULL,
 ProjectResourceID INTEGER NOT NULL DEFAULT 0,
 ProjectResourceXID INTEGER NOT NULL,
 INDEX (FactorID),
 INDEX (ProjectSummaryID, FactorXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS DateUnitWorkUnits;
CREATE TABLE DateUnitWorkUnits
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 Factor VARCHAR(25) NOT NULL,
 FactorID INTEGER NOT NULL DEFAULT 0,
 FactorXID INTEGER NOT NULL,
 WorkUnitsDateUnit VARCHAR(50),     -- These two columns
 WorkUnitsDate VARCHAR(50),            -- comprise the full text of WorkUnitsDateUnit
 StartYear SMALLINT,                -- pattern = "[0-9]{4}"                   \
 StartMonth TINYINT,                -- minInclusive="1" maxInclusive="12"      | Extracted
 StartDate DATE,                    -- pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}"  -  during
 EndDate DATE,                      -- pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}" /  import
 FiscalYear SMALLINT,
 NumberOfUnits DECIMAL(5,2),
 INDEX (ProjectSummaryID, FactorXID),
 INDEX (FactorID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ExpenseAssignment;
CREATE TABLE ExpenseAssignment            -- Objects-51
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Name TEXT,
 Details TEXT,
 FundingSourceID INTEGER,
 FundingSourceXID INTEGER,
 AccountingCodeID INTEGER,
 AccountingCodeXID INTEGER,
 BudgetCategoryOneID INTEGER,
 BudgetCategoryOneXID INTEGER,
 BudgetCategoryTwoID INTEGER,
 BudgetCategoryTwoXID INTEGER,
 INDEX (ProjectSummaryID,XID),
 INDEX (ProjectSummaryID,FundingSourceXID),
 INDEX (ProjectSummaryID,AccountingCodeXID),
 INDEX (ProjectSummaryID,BudgetCategoryOneXID),
 INDEX (ProjectSummaryID,BudgetCategoryTwoXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (FundingSourceID) REFERENCES FundingSource(ID),
 CONSTRAINT FOREIGN KEY (AccountingCodeID) REFERENCES AccountingCode(ID),
 CONSTRAINT FOREIGN KEY (BudgetCategoryOneID) REFERENCES BudgetCategoryOne(ID),
 CONSTRAINT FOREIGN KEY (BudgetCategoryTwoID) REFERENCES BudgetCategoryTwo(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS CalculatedExpense;  -- Same format as Expense Assignment for Calculated Costs.
CREATE TABLE CalculatedExpense LIKE ExpenseAssignment;
ALTER TABLE CalculatedExpense            -- Table serves Strategy/Activity/Task/Indicator/Method.
      ADD COLUMN Factor VARCHAR(25) NOT NULL AFTER XID,
      ADD COLUMN FactorID INTEGER NOT NULL DEFAULT 0 AFTER Factor,
      ADD COLUMN FactorXID INTEGER NOT NULL AFTER FactorID,
      ADD INDEX (FactorID),
      ADD INDEX (ProjectSummaryID, FactorXID);


DROP TABLE IF EXISTS DateUnitExpense;
CREATE TABLE DateUnitExpense
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 Factor VARCHAR(25) NOT NULL,
 FactorID INTEGER NOT NULL DEFAULT 0,
 FactorXID INTEGER NOT NULL,
 ExpensesDateUnit VARCHAR(50),       -- These two columns
 ExpensesDate VARCHAR(50),              -- comprise the full text of ExpensesDateUnit
 StartYear SMALLINT,                 -- pattern = "[0-9]{4}"                   \
 StartMonth TINYINT,                 -- minInclusive="1" maxInclusive="12"      | Extracted
 StartDate DATE,                     -- pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}"  -  during
 EndDate DATE,                       -- pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}" /   import
 FiscalYear SMALLINT,
 Expense DECIMAL(11,2),
 INDEX (ProjectSummaryID, FactorXID),
 INDEX (FactorID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_PlanYears;          /* A view to select all the Fiscal Years for which there
                                             exists a work plan (or expense) component. Note that
                                             this view includes Factors within each year for which
                                             such a component exits. These may be summarized out
                                             into a temp table when factor detail is not required.
                                          */
CREATE VIEW v_PlanYears AS
       SELECT Calc.ProjectSummaryID, Calc.Factor, Calc.FactorID,
              FiscalYear AS PlanYear
         FROM CalculatedWorkUnits Calc, DateUnitWorkUnits Work
        WHERE Work.Factor LIKE "%CalculatedWorkUnits"
          AND Work.FactorID = Calc.ID

        UNION

       SELECT Calc.ProjectSummaryID, Calc.Factor, Calc.FactorID,
              FiscalYear AS PlanYear
         FROM CalculatedExpense Calc, DateUnitExpense Exp
        WHERE Exp.Factor LIKE "%CalculatedExpense"
          AND Exp.FactorID = Calc.ID;


DROP VIEW IF EXISTS v_RsrcYears;          /* A view to select all the Fiscal Years and their 
                                             associated work plan resources, including the 
                                             absence of an assigned resource (ProjectResourceID = 0).
                                             Note that this view includes Resources within each year 
                                             for which such a resource exits. These may be summarized 
                                             out into a temp table when Resource detail is not required.
                                          */
CREATE VIEW v_RsrcYears AS
       SELECT Calc.ProjectSummaryID, Calc.Factor, Calc.FactorID,
              CASE WHEN ProjectResourceID IS NULL THEN 0
                   ELSE ProjectResourceID
               END AS ProjectResourceID,
              FiscalYear AS RsrcYear
         FROM CalculatedWorkUnits Calc, DateUnitWorkUnits Work
        WHERE Work.Factor LIKE "%CalculatedWorkUnits"
          AND Work.FactorID = Calc.ID;


DROP VIEW IF EXISTS v_AcctYears;          /* A view to select all the Fiscal Years for and their 
                                             associated work plan/expense accounts, including the
                                             absence of an assigned account. (AccountingCodeID = 0).
                                             Note that this view includes Accounts within each year 
                                             for which such an account exits. These may be summarized 
                                             out into a temp table when Account detail is not required.
                                          */
CREATE VIEW v_AcctYears AS
       SELECT Calc.ProjectSummaryID, Calc.Factor, Calc.FactorID,
              CASE WHEN AccountingCodeID IS NULL THEN 0
                   ELSE AccountingCodeID
               END AS AccountingCodeID,
              FiscalYear AS AcctYear
         FROM CalculatedWorkUnits Calc, DateUnitWorkUnits Work
        WHERE Work.Factor LIKE "%CalculatedWorkUnits"
          AND Work.FactorID = Calc.ID

        UNION

       SELECT Calc.ProjectSummaryID, Calc.Factor, Calc.FactorID,
              CASE WHEN AccountingCodeID IS NULL THEN 0
                   ELSE AccountingCodeID
               END AS AccountingCodeID,
              FiscalYear AS AcctYear
         FROM CalculatedExpense Calc, DateUnitExpense Exp
        WHERE Exp.Factor LIKE "%CalculatedExpense"
          AND Exp.FactorID = Calc.ID;


DROP VIEW IF EXISTS v_FundYears;          /* A view to select all the Fiscal Years for and their 
                                             associated work plan/expense funds, including the
                                             absence of an assigned fund. (FundingSourceID = 0).
                                             Note that this view includes Funds within each year 
                                             for which such an account exits. These may be summarized 
                                             out into a temp table when Fund detail is not required.
                                          */
CREATE VIEW v_FundYears AS
       SELECT Calc.ProjectSummaryID, Calc.Factor, Calc.FactorID,
              CASE WHEN FundingSourceID IS NULL THEN 0
                   ELSE FundingSourceID
               END AS FundingSourceID,
              FiscalYear AS FundYear
         FROM CalculatedWorkUnits Calc, DateUnitWorkUnits Work
        WHERE Work.Factor LIKE "%CalculatedWorkUnits"
          AND Work.FactorID = Calc.ID

        UNION

       SELECT Calc.ProjectSummaryID, Calc.Factor, Calc.FactorID,
              CASE WHEN FundingSourceID IS NULL THEN 0
                   ELSE FundingSourceID
               END AS FundingSourceID,
              FiscalYear AS FundYear
         FROM CalculatedExpense Calc, DateUnitExpense Exp
        WHERE Exp.Factor LIKE "%CalculatedExpense"
          AND Exp.FactorID = Calc.ID;


DROP TABLE IF EXISTS TaskActivityMethod;    /* Methods, Activities, and Tasks are all contained
                                               in the Task Pool with only the forward pointer of
                                               the Parent Object to differentiate them.
                                               Views are used to enable their differentiation,
                                               The table definition is located here to facilitate
                                               the view definitions that follow.
                                            */
CREATE TABLE TaskActivityMethod           -- Objects-3
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Factor ENUM("Task","Activity","Method"),
 TaskActivityMethod_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 CalculatedStartDate DATE,
 CalculatedEndDate DATE,
 CalculatedWorkUnitsTotal DECIMAL(7,2),
 CalculatedExpenseTotal DECIMAL(11,2),
 CalculatedTotalBudgetCost DECIMAL(11,2),
 INDEX (ProjectSummaryID, XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS Target;
CREATE TABLE Target                     -- Objects-22 (BioD) / Objects-52 (HW)
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 FactorType ENUM("BD","HW"),          -- BD = Biodiversity; HW = Human Welfare
 Target_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 ViabilityStatus TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 ViabilityMode VARCHAR(6),   -- Originates as "","TNC"; Changed to "Simple","KEA" on import.
 CurrentStatusJustification TEXT,
 ThreatRating TINYINT,       -- Vocabulary: 1, 2, 3, 4.
 SpeciesLatinName TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS BiodiversityTarget;
CREATE VIEW BiodiversityTarget AS
       SELECT ID, ProjectSummaryID, XID, FactorType, Target_Id AS BiodiversityTarget_Id,
              Name, Details, Comments, ViabilityStatus, ViabilityMode,
              CurrentStatusJustification, ThreatRating, SpeciesLatinName
         FROM Target WHERE FactorType = "BD";


DROP VIEW IF EXISTS HumanWelfareTarget;
CREATE VIEW HumanWelfareTarget AS
       SELECT ID, ProjectSummaryID, XID, FactorType, Target_Id AS HumanWelfareTarget_Id,
              Name, Details, Comments, ViabilityStatus, ViabilityMode,
              CurrentStatusJustification, ThreatRating, SpeciesLatinName
         FROM Target WHERE FactorType = "HW";


DROP TABLE IF EXISTS SubTarget;
CREATE TABLE SubTarget                    -- Objects-36
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 XID INTEGER NOT NULL,
 ProjectSummaryID INTEGER NOT NULL,
 SubTarget_Id TEXT,
 Name TEXT,
 Details TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TargetSubTarget;
CREATE TABLE TargetSubTarget
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL DEFAULT 0,
 TargetXID INTEGER NOT NULL,
 SubTargetID INTEGER NOT NULL DEFAULT 0,
 SubTargetXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,TargetXID),
 INDEX (ProjectSummaryID,SubTargetXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (SubTargetID) REFERENCES SubTarget(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS BiodiversityTargetSubTarget;
CREATE VIEW BiodiversityTargetSubTarget AS
       SELECT Sub.ID, Sub.ProjectSummaryID, Sub.TargetID AS BiodiversityTargetID,
              Sub.TargetXID AS BiodiversityTargetXID, SubTargetID, SubTargetXID
         FROM TargetSubTarget Sub, BiodiversityTarget Tgt
        WHERE Tgt.ProjectSummaryID = Sub.ProjectSummaryID
          AND Tgt.XID = Sub.TargetXID;


DROP VIEW IF EXISTS HumanWelfareTargetSubTarget;
CREATE VIEW HumanWelfareTargetSubTarget AS
       SELECT Sub.ID, Sub.ProjectSummaryID, Sub.TargetID AS HumanWelfareTargetID,
              Sub.TargetXID AS HumanWelfareTargetXID, SubTargetID, SubTargetXID
         FROM TargetSubTarget Sub, HumanWelfareTarget Tgt
        WHERE Tgt.ProjectSummaryID = Sub.ProjectSummaryID
          AND Tgt.XID = Sub.TargetXID;


DROP TABLE IF EXISTS TargetHabitatAssociation;
CREATE TABLE TargetHabitatAssociation
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL DEFAULT 0,
 TargetXID INTEGER NOT NULL,
 Code ENUM( "1","1.1","1.2","1.3","1.4","1.5","1.6","1.7","1.8","1.9",
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
          ),
 INDEX (ProjectSummaryID,TargetXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS BiodiversityTargetHabitatAssociation;
CREATE VIEW BiodiversityTargetHabitatAssociation AS
       SELECT Hab.ID, Hab.ProjectSummaryID, Hab.TargetID AS BiodiversityTargetID,
              Hab.TargetXID AS BiodiversityTargetXID, Code
         FROM TargetHabitatAssociation Hab, BiodiversityTarget Tgt
        WHERE Tgt.ProjectSummaryID = Hab.ProjectSummaryID
          AND Tgt.XID = Hab.TargetXID;


DROP TABLE IF EXISTS KeyEcologicalAttribute;
CREATE TABLE KeyEcologicalAttribute       -- Objects-17
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 KeyEcologicalAttribute_Id TEXT,
 Name TEXT,
 Comments TEXT,
 Details TEXT,
 KeyEcologicalAttributeType ENUM("","10","20","30"), -- Size, Condition, Context, respectively.
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_KeyAttribute;    -- An abbreviated name for KeyEcologicalAttribute
CREATE VIEW v_KeyAttribute AS
       SELECT ID, ProjectSummaryID, XID,KeyEcologicalAttribute_Id AS KeyAttribute_Id,
              Name, Comments, Details, KeyEcologicalAttributeType AS KeyAttributeType
         FROM KeyEcologicalAttribute;


DROP VIEW IF EXISTS v_KEA;             -- An abbreviated name for KeyEcologicalAttribute
CREATE VIEW v_KEA AS
       SELECT ID, ProjectSummaryID, XID, KeyEcologicalAttribute_Id AS KEA_Id,
              Name, Comments, Details, KeyEcologicalAttributeType AS KEAType
         FROM KeyEcologicalAttribute;


DROP TABLE IF EXISTS TargetKeyEcologicalAttribute;
CREATE TABLE TargetKeyEcologicalAttribute
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL DEFAULT 0,
 TargetXID INTEGER NOT NULL,
 KeyEcologicalAttributeID INTEGER NOT NULL DEFAULT 0,
 KeyEcologicalAttributeXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,TargetXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (KeyEcologicalAttributeID) REFERENCES KeyEcologicalAttribute(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_TargetKeyAttribute;     -- Joins TargetKeyEcologicalAttribute with v_KeyAttribute.
CREATE VIEW v_TargetKeyAttribute AS
       SELECT TargetID, TargetXID, KEA.*
         FROM TargetKeyEcologicalAttribute TgtKEA, v_KeyAttribute KEA
        WHERE KEA.ID = TgtKEA.KeyEcologicalAttributeID;
 

DROP VIEW IF EXISTS BiodiversityTargetKeyEcologicalAttribute;
CREATE VIEW BiodiversityTargetKeyEcologicalAttribute AS
       SELECT KEA.ID, KEA.ProjectSummaryID, KEA.TargetID AS BiodiversityTargetID,
              KEA.TargetXID AS BiodiversityTargetXID, KeyEcologicalAttributeID,
              KeyEcologicalAttributeXID
         FROM TargetKeyEcologicalAttribute KEA, BiodiversityTarget Tgt
        WHERE Tgt.ProjectSummaryID = KEA.ProjectSummaryID
          AND Tgt.XID = KEA.TargetXID;



DROP VIEW IF EXISTS v_BiodiversityTargetKeyAttribute; -- Joins BiodiversityTargetKeyEcologicalAttribute 
CREATE VIEW v_BiodiversityTargetKeyAttribute AS       -- with v_KeyAttribute.
       SELECT BiodiversityTargetID, BiodiversityTargetXID, KEA.*
         FROM BiodiversityTargetKeyEcologicalAttribute TgtKEA, v_KeyAttribute KEA
        WHERE KEA.ID = TgtKEA.KeyEcologicalAttributeID;


DROP VIEW IF EXISTS HumanWelfareTargetKeyEcologicalAttribute;
CREATE VIEW HumanWelfareTargetKeyEcologicalAttribute AS
       SELECT KEA.ID, KEA.ProjectSummaryID, KEA.TargetID AS HumanWelfareTargetID,
              KEA.TargetXID AS HumanWelfareTargetXID, KeyEcologicalAttributeId,
              KeyEcologicalAttributeXID
         FROM TargetKeyEcologicalAttribute KEA, HumanWelfareTarget Tgt
        WHERE Tgt.ProjectSummaryID = KEA.ProjectSummaryID
          AND Tgt.XID = KEA.TargetXID;


DROP VIEW IF EXISTS v_HumanWelfareTargetKeyAttribute; -- Joins HumanWelfareTargetKeyEcologicalAttribute 
CREATE VIEW v_HumanWelfareTargetKeyAttribute AS       -- with v_KeyAttribute.
       SELECT HumanWelfareTargetID, HumanWelfareTargetXID, KEA.*
         FROM HumanWelfareTargetKeyEcologicalAttribute TgtKEA, v_KeyAttribute KEA
        WHERE KEA.ID = TgtKEA.KeyEcologicalAttributeID;


DROP TABLE IF EXISTS Indicator;
CREATE TABLE Indicator                    -- Objects-8
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Indicator_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 IsActive BOOLEAN DEFAULT TRUE,  /* Used to differentiate Indicators associated with Targets that
                                    have components of both Simple and KEA Viability Mode. 
                                 
                                    Will be set to FALSE for Indicators that were created while in 
                                    Simple Viability Mode for Targets that are now in KEA Viability 
                                    Mode, or vice-versa.
                                     
                                    Value is set during post-import processing.
                                 */
 Priority TINYINT,            -- Vocabulary: 1, 2, 3, 4.
 RatingSource VARCHAR(25),
 FutureStatusDate DATE,
 FutureStatusDetails TEXT,
 FutureStatusRating TINYINT,  -- Vocabulary: 1, 2, 3, 4.
 FutureStatusComments TEXT,
 FutureStatusSummary TEXT,
 ViabilityRatingsComments TEXT,
 CalculatedStartDate DATE,
 CalculatedEndDate DATE,
 CalculatedWorkUnitsTotal DECIMAL(7,2),
 CalculatedExpenseTotal DECIMAL(11,2),
 CalculatedTotalBudgetCost DECIMAL(11,2),
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TargetIndicator;
CREATE TABLE TargetIndicator
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL DEFAULT 0,
 TargetXID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,TargetXID),
 INDEX (ProjectSummaryID,IndicatorXID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_TargetIndicator;          -- Joins TargetIndicator with Indicator.
CREATE VIEW v_TargetIndicator AS
       SELECT TargetID, TargetXID, Ind.*
         FROM TargetIndicator TgtInd, Indicator Ind
        WHERE Ind.ID = TgtInd.IndicatorID; 


DROP VIEW IF EXISTS BiodiversityTargetIndicator;
CREATE VIEW BiodiversityTargetIndicator AS
       SELECT Ind.ID, Ind.ProjectSummaryID, Ind.TargetID AS BiodiversityTargetID,
              Ind.TargetXID AS BiodiversityTargetXID,IndicatorXID, IndicatorID
         FROM TargetIndicator Ind, BiodiversityTarget Tgt
        WHERE Tgt.ProjectSummaryID = Ind.ProjectSummaryID
          AND Tgt.XID = Ind.TargetXID;



DROP VIEW IF EXISTS v_BiodiversityTargetIndicator;  -- Joins BiodiversityTargetIndicator with Indicator.
CREATE VIEW v_BiodiversityTargetIndicator AS
       SELECT BiodiversityTargetID, BiodiversityTargetXID, Ind.*
         FROM BiodiversityTargetIndicator TgtInd, Indicator Ind
        WHERE Ind.ID = TgtInd.IndicatorID; 


DROP VIEW IF EXISTS HumanWelfareTargetIndicator;
CREATE VIEW HumanWelfareTargetIndicator AS
       SELECT Ind.ID, Ind.ProjectSummaryID, Ind.TargetID AS HumanWelfareTargetID,
              Ind.TargetXID AS HumanWelfareTargetXID,IndicatorXID, IndicatorID
         FROM TargetIndicator Ind, HumanWelfareTarget Tgt
        WHERE Tgt.ProjectSummaryID = Ind.ProjectSummaryID
          AND Tgt.XID = Ind.TargetXID;


DROP VIEW IF EXISTS v_HumanWelfareTargetIndicator; -- Joins HumanWelfareTargetIndicator with Indicator.
CREATE VIEW v_HumanWelfareTargetIndicator AS
       SELECT HumanWelfareTargetID, HumanWelfareTargetXID, Ind.*
         FROM HumanWelfareTargetIndicator TgtInd, Indicator Ind
        WHERE Ind.ID = TgtInd.IndicatorID; 


DROP TABLE IF EXISTS KeyEcologicalAttributeIndicator;
CREATE TABLE KeyEcologicalAttributeIndicator
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 KeyEcologicalAttributeID INTEGER NOT NULL DEFAULT 0,
 KeyEcologicalAttributeXID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,KeyEcologicalAttributeXID),
 INDEX (ProjectSummaryID,IndicatorXID),
 CONSTRAINT FOREIGN KEY (KeyEcologicalAttributeID) REFERENCES KeyEcologicalAttribute(ID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_KeyAttributeIndicator; -- Joins KeyEcologicalAttributeIndicator with Indicator.
CREATE VIEW v_KeyAttributeIndicator AS
       SELECT KeyEcologicalAttributeID AS KeyAttributeID, 
              KeyEcologicalAttributeXID AS KeyAttributeXID, Ind.*
         FROM KeyEcologicalAttributeIndicator KeaInd, Indicator Ind
        WHERE Ind.ID = KeaInd.IndicatorID;


DROP TABLE IF EXISTS IndicatorThreshold;
CREATE TABLE IndicatorThreshold           -- Objects-8
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 StatusCode TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 ThresholdValue VARCHAR(255),
 ThresholdDetails TEXT,
 INDEX (ProjectSummaryID,IndicatorXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS Measurement;
CREATE TABLE Measurement                  -- Objects-32
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Name TEXT,
 Date DATE,
 Source ENUM("","RoughGuess","ExpertKnowledge","RapidAssessment","IntensiveAssessment"),
 MeasurementValue TEXT,
 Rating TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 Trend ENUM("","Unknown","StrongIncrease","MildIncrease","Flat","MildDecrease","StrongDecrease"),
 Detail TEXT,
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS IndicatorMeasurement;              -- View v_IndicatorMeasurement follows
CREATE TABLE IndicatorMeasurement                       -- CREATE FUNCTION RATING();
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 MeasurementID INTEGER NOT NULL DEFAULT 0,
 MeasurementXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,IndicatorXID),
 INDEX (ProjectSummaryID,MeasurementXID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (MeasurementID) REFERENCES Measurement(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



DROP TABLE IF EXISTS ProgressReport;
CREATE TABLE ProgressReport               -- Objects-37
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 ProgressDate DATE,
 Details TEXT,
 ProgressStatus ENUM("","Planned","MajorIssues","MinorIssues","OnTrack","Completed","Abandoned"),
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS IndicatorProgressReport;
CREATE TABLE IndicatorProgressReport
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 ProgressReportID INTEGER NOT NULL DEFAULT 0,
 ProgressReportXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,IndicatorXID),
 INDEX (ProjectSummaryID,ProgressReportXID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ProgressReportID) REFERENCES ProgressReport(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS Method;                 /* Methods, Activities, and Tasks are all contained
                                               in the Task Pool with only the forward pointer of
                                               the Parent Object to differentiate them.
                                               Views are used to enable their differentiation,
                                            */
CREATE VIEW Method AS
       SELECT ID,ProjectSummaryID,XID,Factor,
              TaskActivityMethod_Id AS Method_Id,Name,Details,Comments,
              CalculatedStartDate,CalculatedEndDate,CalculatedWorkUnitsTotal,
              CalculatedExpenseTotal,CalculatedTotalBudgetCost
         FROM TaskActivityMethod
        WHERE Factor = "Method";


DROP TABLE IF EXISTS IndicatorMethod;
CREATE TABLE IndicatorMethod
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 Sequence INTEGER NOT NULL DEFAULT 0,       /* IMPORTANT NOTE: The desired sequence to retrieve
                                               IndicatorMethod is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY IndicatorMethod.Sequence;
                                            */
 MethodID INTEGER NOT NULL DEFAULT 0,
 MethodXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,IndicatorXID,Sequence),
 INDEX (ProjectSummaryID,MethodXID),
 INDEX (IndicatorID,Sequence),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (MethodID) REFERENCES Method(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS IndicatorAssignment;
CREATE TABLE IndicatorAssignment
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 ResourceAssignmentID INTEGER NOT NULL DEFAULT 0,
 ResourceAssignmentXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,IndicatorXID),
 INDEX (ProjectSummaryID,ResourceAssignmentXID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ResourceAssignmentID) REFERENCES ResourceAssignment(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS IndicatorCalculatedWorkUnits;
CREATE VIEW IndicatorCalculatedWorkUnits AS
       SELECT Units.ID,Units.ProjectSummaryID,Units.XID,Factor,FactorID AS IndicatorID,
              FactorXID AS IndicatorXID,Units.Name,Units.Details,ProjectResourceID,
              FundingSourceID,AccountingCodeID,BudgetCategoryOneID,BudgetCategoryTwoID,
              ProjectResourceXID,FundingSourceXID,AccountingCodeXID,BudgetCategoryOneXID,
              BudgetCategoryTwoXID
         FROM CalculatedWorkUnits Units, Indicator Ind
        WHERE Ind.ProjectSummaryID = Units.ProjectSummaryID
          AND Ind.XID = Units.FactorXID
          AND Units.Factor = "Indicator";


DROP VIEW IF EXISTS IndicatorCalculatedWho;
CREATE VIEW IndicatorCalculatedWho AS
       SELECT Who.ID,Who.ProjectSummaryID,Factor,FactorID AS IndicatorID,
              FactorXID AS IndicatorXID,ProjectResourceID,ProjectResourceXID
         FROM CalculatedWho Who
        WHERE Factor = "Indicator";


DROP TABLE IF EXISTS IndicatorExpense;
CREATE TABLE IndicatorExpense
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 ExpenseAssignmentID INTEGER NOT NULL DEFAULT 0,
 ExpenseAssignmentXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,IndicatorXID),
 INDEX (ProjectSummaryID,ExpenseAssignmentXID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ExpenseAssignmentID) REFERENCES ExpenseAssignment(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS IndicatorCalculatedExpense;
CREATE VIEW IndicatorCalculatedExpense AS
       SELECT Exp.ID,Exp.ProjectSummaryID,Exp.XID,Factor,FactorID AS IndicatorID,
              FactorXID AS IndicatorXID,Exp.Name,Exp.Details,FundingSourceID,
              AccountingCodeID,BudgetCategoryOneID,BudgetCategoryTwoID,FundingSourceXID,
              AccountingCodeXID,BudgetCategoryOneXID,BudgetCategoryTwoXID
         FROM CalculatedExpense Exp, Indicator Ind
        WHERE Ind.ProjectSummaryID = Exp.ProjectSummaryID
          AND Ind.XID = Exp.FactorXID
          AND Exp.Factor = "Indicator";


DROP TABLE IF EXISTS Strategy;
CREATE TABLE Strategy                     -- Objects-21
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Strategy_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 Status CHAR(5),                   -- "Draft"|NULL
 StandardClassification CHAR(6),  /* "A10"|"A10.10"|"A10.30"|"A20"|"A20.10"|"A20.20"|
                                     "A20.30"|"A30"|"A30.10"|"A30.20"|"A30.30"|"A30.40"|
                                     "A40"|"A40.10"|"A40.20"|"A40.30"|"A50"|"A50.10"|
                                     "A50.20"|"A50.30"|"A50.40"|"A60"|"A60.10"|"A60.20"|
                                     "A60.30"|"A60.40"|"A60.50"|"A70"|"A70.10"|"A70.20"|
                                     "A70.30"|""
                                  */
 ImpactRating TINYINT,         -- Vocabulary: 1, 2, 3, 4.
 FeasibilityRating TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 LegacyTNCStrategyRanking TEXT,
 CalculatedStartDate DATE,
 CalculatedEndDate DATE,
 CalculatedWorkUnitsTotal DECIMAL(7,2),
 CalculatedExpenseTotal DECIMAL(11,2),
 CalculatedTotalBudgetCost DECIMAL(11,2),
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StrategyProgressReport;
CREATE TABLE StrategyProgressReport
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER NOT NULL DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 ProgressReportID INTEGER NOT NULL DEFAULT 0,
 ProgressReportXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,StrategyXID),
 INDEX (ProjectSummaryID,ProgressReportXID),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ProgressReportID) REFERENCES ProgressReport(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StrategyAssignment;
CREATE TABLE StrategyAssignment
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER NOT NULL DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 ResourceAssignmentID INTEGER NOT NULL DEFAULT 0,
 ResourceAssignmentXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,StrategyXID),
 INDEX (ProjectSummaryID,ResourceAssignmentXID),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ResourceAssignmentID) REFERENCES ResourceAssignment(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_StrategyAssignment;     /* Joins StrategyAssignment with ResourceAssignment. */
CREATE VIEW v_StrategyAssignment AS
       SELECT StrategyID, StrategyXID, Asgn.*
         FROM StrategyAssignment StrAsgn, ResourceAssignment Asgn
        WHERE Asgn.ID = StrAsgn.ResourceAssignmentID; 


DROP VIEW IF EXISTS StrategyCalculatedWorkUnits;
CREATE VIEW StrategyCalculatedWorkUnits AS
       SELECT Units.ID,Units.ProjectSummaryID,Units.XID,Factor,FactorID AS StrategyID,
              FactorXID AS StrategyXID,Units.Name,Units.Details,ProjectResourceID,
              ProjectResourceXID,FundingSourceID,FundingSourceXID,AccountingCodeID,
              AccountingCodeXID, BudgetCategoryOneID,BudgetCategoryOneXID,BudgetCategoryTwoID,
              BudgetCategoryTwoXID
         FROM CalculatedWorkUnits Units, Strategy Str
        WHERE Str.ProjectSummaryID = Units.ProjectSummaryID
          AND Str.XID = Units.FactorXID
          AND Units.Factor = "Strategy";


DROP VIEW IF EXISTS StrategyCalculatedWho;
CREATE VIEW StrategyCalculatedWho AS
       SELECT Who.ID,Who.ProjectSummaryID,Factor,FactorID AS StrategyID,
              FactorXID AS StrategyXID,ProjectResourceID,ProjectResourceXID
         FROM CalculatedWho Who
        WHERE Factor = "Strategy";


DROP TABLE IF EXISTS StrategyExpense;
CREATE TABLE StrategyExpense
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER NOT NULL DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 ExpenseAssignmentID INTEGER NOT NULL DEFAULT 0,
 ExpenseAssignmentXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,StrategyXID),
 INDEX (ProjectSummaryID,ExpenseAssignmentXID),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ExpenseAssignmentID) REFERENCES ExpenseAssignment(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS v_StrategyExpense;
CREATE VIEW v_StrategyExpense AS
       SELECT StrategyID, StrategyXID, Exp.*
         FROM StrategyExpense StrExp, ExpenseAssignment Exp
        WHERE Exp.ID = StrExp.ExpenseAssignmentID; 


DROP VIEW IF EXISTS StrategyCalculatedExpense;
CREATE VIEW StrategyCalculatedExpense AS
       SELECT Exp.ID,Exp.ProjectSummaryID,Exp.XID,Factor,FactorID AS StrategyID,
              FactorXID AS StrategyXID,Exp.Name,Exp.Details,FundingSourceID,
              FundingSourceXID,AccountingCodeID,AccountingCodeXID,BudgetCategoryOneID,
              BudgetCategoryOneXID,BudgetCategoryTwoID,BudgetCategoryTwoXID
         FROM CalculatedExpense Exp, Strategy Str
        WHERE Str.ProjectSummaryID = Exp.ProjectSummaryID
          AND Str.XID = Exp.FactorXID
          AND Exp.Factor = "Strategy";


DROP TABLE IF EXISTS StrategyIndicator;
CREATE TABLE StrategyIndicator
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER NOT NULL DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,StrategyXID),
 INDEX (ProjectSummaryID,IndicatorXID),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StrategyThreat;
CREATE TABLE StrategyThreat
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER NOT NULL,
 StrategyXID INTEGER NOT NULL,
 ThreatID INTEGER NOT NULL,
 ThreatXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,StrategyXID),
 INDEX (ProjectSummaryID,ThreatXID),
 UNIQUE INDEX (StrategyID,ThreatID),      -- Required because it's populated with REPLACE.
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ThreatID) REFERENCES Threat(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StrategyTarget;
CREATE TABLE StrategyTarget
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER NOT NULL,
 StrategyXID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL,
 TargetXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,StrategyXID),
 INDEX (ProjectSummaryID,TargetXID),
 UNIQUE INDEX (StrategyID,TargetID),      -- Required because it's populated with REPLACE.
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS Activity;               /* Methods, Activities, and Tasks are all contained
                                               in the Task Pool with only the forward pointer of
                                               the Parent Object to differentiate them.
                                               Views are used to enable their differentiation,
                                            */
CREATE VIEW Activity AS
       SELECT ID,ProjectSummaryID,XID,Factor,
              TaskActivityMethod_Id AS Activity_Id,Name,Details,Comments,
              CalculatedStartDate,CalculatedEndDate,CalculatedWorkUnitsTotal,
              CalculatedExpenseTotal,CalculatedTotalBudgetCost
         FROM TaskActivityMethod
        WHERE Factor = "Activity";

DROP TABLE IF EXISTS StrategyActivity;
CREATE TABLE StrategyActivity
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER NOT NULL DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 Sequence INTEGER NOT NULL DEFAULT 0,       /* IMPORTANT NOTE: The desired sequence to retrieve
                                               StrategyActivity is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY StrategyActivity.Sequence
                                            */

 ActivityID INTEGER NOT NULL DEFAULT 0,
 ActivityXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,StrategyXID,Sequence),
 INDEX (ProjectSummaryID,ActivityXID),
 INDEX (ActivityID,Sequence),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ActivityID) REFERENCES Activity(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_StrategyActivity;     -- Joins StrategyActivity with Activity
CREATE VIEW v_StrategyActivity AS
       SELECT StrategyID, StrategyXID, Sequence, Act.*
         FROM StrategyActivity StrAct, Activity Act
        WHERE Act.ID = StrAct.ActivityID; 


DROP VIEW IF EXISTS Task;                   /* Methods, Activities, and Tasks are all contained
                                               in the Task Pool with only the forward pointer of
                                               the Parent Object to differentiate them.
                                               Views are used to enable their differentiation,

                                               The TaskActivityMethod Table was created previously 
                                               in this script.
                                            */
CREATE VIEW Task AS                    
       SELECT ID, ProjectSummaryID, XID, Factor, TaskActivityMethod_Id AS Task_Id,
              Name, Details, Comments, CalculatedStartDate, CalculatedEndDate,
              CalculatedWorkUnitsTotal, CalculatedExpenseTotal,
              CalculatedTotalBudgetCost
         FROM TaskActivityMethod                 
        WHERE Factor = "Task";


DROP TABLE IF EXISTS SubTask;           
                                            /* Methods, Activities, and Tasks are all contained
                                               in the Task Pool with only the forward pointer of
                                               the Parent Object to differentiate them.
                                               Views are used to enable their differentiation,

                                               The TaskActivityMethod Table was created previously 
                                               in this script.
                                            */
CREATE TABLE SubTask         
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TaskID INTEGER NOT NULL DEFAULT 0,
 TaskXID INTEGER NOT NULL,
 Sequence INTEGER NOT NULL DEFAULT 0,       /* IMPORTANT NOTE: The desired sequence to retrieve
                                               TaskSubtask is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY TaskSubtask.Sequence;
                                            */

 SubtaskRef INTEGER NOT NULL DEFAULT 0,
 INDEX (ProjectSummaryID,TaskXID,Sequence),
 INDEX (ProjectSummaryID,SubtaskRef),
 INDEX (TaskID,Sequence),
 CONSTRAINT FOREIGN KEY (TaskID) REFERENCES TaskActivityMethod(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS TaskSubTask;
CREATE VIEW TaskSubTask AS                  /* IMPORTANT NOTE: The desired sequence to retrieve
                                               TaskSubtask is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY TaskSubtask.Sequence;
                                            */
       SELECT Subtask.ID, Subtask.ProjectSummaryID, Subtask.TaskID,          
              Subtask.TaskXID, Subtask.Sequence, Subtask.SubTaskRef 
         FROM Task, SubTask
        WHERE Subtask.ProjectSummaryID = Task.ProjectSummaryID
          AND Subtask.TaskXID = Task.XID;


DROP VIEW IF EXISTS v_TaskSubTask;
CREATE VIEW v_TaskSubTask AS
       SELECT TaskID, TaskXID, Sequence, Task.*
         FROM TaskSubTask, Task
        WHERE Task.ProjectSummaryID = TaskSubTask.ProjectSummaryID
          AND Task.XID = TaskSubTask.TaskXID;
          

DROP VIEW IF EXISTS ActivityTask;
CREATE VIEW ActivityTask AS                 /* IMPORTANT NOTE: The desired sequence to retrieve
                                               ActivityTask is the physical sequence their
                                               associations were exported in the XML.
                                               That sequence can be robustly assured with
                                               SELECT ... ORDER BY ActivityTask.Sequence;
                                            */

       SELECT Subtask.ID, Subtask.ProjectSummaryID, Subtask.TaskID AS ActivityID,
              Subtask.TaskXID AS ActivityXID, Subtask.Sequence, 
              Subtask.SubtaskRef AS TaskXID
         FROM Activity AS Act, SubTask
        WHERE Subtask.ProjectSummaryID = Act.ProjectSummaryID
          AND Subtask.TaskXID = Act.XID;


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

       SELECT SubTask.ID, Subtask.ProjectSummaryID, SubTask.TaskID AS MethodID,
              SubTask.TaskXID AS MethodXID, SubTask.Sequence, 
              SubTask.SubTaskRef AS TaskXID
         FROM Method AS Meth, SubTask
        WHERE Subtask.ProjectSummaryID = Meth.ProjectSummaryID
          AND Subtask.TaskXID = Meth.XID;


DROP TABLE IF EXISTS TaskActivityMethodProgressReport;
CREATE TABLE TaskActivityMethodProgressReport
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TaskActivityMethodID INTEGER NOT NULL DEFAULT 0,
 TaskActivityMethodXID INTEGER NOT NULL,
 ProgressReportID INTEGER NOT NULL DEFAULT 0,
 ProgressReportXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,TaskActivityMethodXID),
 INDEX (ProjectSummaryID,ProgressReportXID),
 CONSTRAINT FOREIGN KEY (TaskActivityMethodID) REFERENCES TaskActivityMethod(ID),
 CONSTRAINT FOREIGN KEY (ProgressReportID) REFERENCES ProgressReport(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS TaskProgressReport;
CREATE VIEW TaskProgressReport AS
       SELECT Rpt.ID, Rpt.ProjectSummaryID, Rpt.TaskActivityMethodID AS TaskID, 
              Rpt.TaskActivityMethodXID AS TaskXID,
              ProgressReportID, ProgressReportXID
         FROM TaskActivityMethodProgressReport Rpt, Task
        WHERE Task.ProjectSummaryID = Rpt.ProjectSummaryID
          AND Task.XID = Rpt.TaskActivityMethodXID;


DROP VIEW IF EXISTS ActivityProgressReport;
CREATE VIEW ActivityProgressReport AS
       SELECT Rpt.ID, Rpt.ProjectSummaryID, Rpt.TaskActivityMethodID AS ActivityID, 
              Rpt.TaskActivityMethodXID AS ActivityXID,
              ProgressReportID, ProgressReportXID
         FROM TaskActivityMethodProgressReport Rpt, Activity Act
        WHERE Act.ProjectSummaryID = Rpt.ProjectSummaryID
          AND Act.XID = Rpt.TaskActivityMethodXID;


DROP VIEW IF EXISTS MethodProgressReport;
CREATE VIEW MethodProgressReport AS
       SELECT Rpt.ID, Rpt.ProjectSummaryID, Rpt.TaskActivityMethodID AS MethodID, 
              Rpt.TaskActivityMethodXID AS MethodXID,
              ProgressReportID, ProgressReportXID
         FROM TaskActivityMethodProgressReport Rpt, Method
        WHERE Method.ProjectSummaryID = Rpt.ProjectSummaryID
          AND Method.XID = Rpt.TaskActivityMethodXID;


DROP TABLE IF EXISTS TaskActivityMethodAssignment;
CREATE TABLE TaskActivityMethodAssignment
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TaskActivityMethodID INTEGER NOT NULL DEFAULT 0,
 TaskActivityMethodXID INTEGER NOT NULL,
 ResourceAssignmentID INTEGER NOT NULL DEFAULT 0,
 ResourceAssignmentXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,TaskActivityMethodXID),
 INDEX (ProjectSummaryID,ResourceAssignmentXID),
 CONSTRAINT FOREIGN KEY (TaskActivityMethodID) REFERENCES TaskActivityMethod(ID),
 CONSTRAINT FOREIGN KEY (ResourceAssignmentID) REFERENCES ResourceAssignment(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS TaskAssignment;
CREATE VIEW TaskAssignment AS
       SELECT Asgn.ID, Asgn.ProjectSummaryID, Asgn.TaskActivityMethodID AS TaskID, 
              Asgn.TaskActivityMethodXID AS TaskXID,
              ResourceAssignmentID, ResourceAssignmentXID
         FROM TaskActivityMethodAssignment Asgn, Task
        WHERE Task.ProjectSummaryID = Asgn.ProjectSummaryID
          AND Task.XID = Asgn.TaskActivityMethodXID;
          
          
DROP VIEW IF EXISTS v_TaskAssignment;
CREATE VIEW v_TaskAssignment AS
       SELECT TaskID, TaskXID, Asgn.*
         FROM TaskAssignment TaskAsgn, ResourceAssignment Asgn
        WHERE Asgn.ID = TaskAsgn.ResourceAssignmentID; 


DROP VIEW IF EXISTS ActivityAssignment;
CREATE VIEW ActivityAssignment AS
       SELECT Asgn.ID, Asgn.ProjectSummaryID, Asgn.TaskActivityMethodID AS ActivityID, 
              Asgn.TaskActivityMethodXID AS ActivityXID,
              ResourceAssignmentID, ResourceAssignmentXID
         FROM TaskActivityMethodAssignment Asgn, Activity Act
        WHERE Act.ProjectSummaryID = Asgn.ProjectSummaryID
          AND Act.XID = Asgn.TaskActivityMethodXID;


DROP VIEW IF EXISTS v_ActivityAssignment;
CREATE VIEW v_ActivityAssignment AS
       SELECT ActivityID, ActivityXID, Asgn.*
         FROM ActivityAssignment ActAsgn, ResourceAssignment Asgn
        WHERE Asgn.ID = ActAsgn.ResourceAssignmentID; 


DROP VIEW IF EXISTS MethodAssignment;
CREATE VIEW MethodAssignment AS
       SELECT Asgn.ID, Asgn.ProjectSummaryID, Asgn.TaskActivityMethodID AS MethodID, 
              Asgn.TaskActivityMethodXID AS MethodXID,
              ResourceAssignmentID,ResourceAssignmentXID
         FROM TaskActivityMethodAssignment Asgn, Method Meth
        WHERE Meth.ProjectSummaryID = Asgn.ProjectSummaryID
          AND Meth.XID = Asgn.TaskActivityMethodXID;


DROP VIEW IF EXISTS v_MethodAssignment;
CREATE VIEW v_MethodAssignment AS
       SELECT MethodID, MethodXID, Asgn.*
         FROM MethodAssignment MethAsgn, ResourceAssignment Asgn
        WHERE Asgn.ID = MethAsgn.ResourceAssignmentID; 


/*
DROP VIEW IF EXISTS TaskActivityMethodCalculatedWorkUnits;
CREATE VIEW TaskActivityMethodCalculatedWorkUnits AS
       SELECT Units.ID, Units.ProjectSummaryID, Units.XID, Units.Factor,
              FactorID AS TaskActivityMethodID, FactorXID AS TaskActivityMethodXID,
              Units.Name, Units.Details, ProjectResourceID,
              ProjectResourceXID, FundingSourceID, FundingSourceXID, AccountingCodeID,
              AccountingCodeXID, BudgetCategoryOneID, BudgetCategoryOneXID,
              BudgetCategoryTwoID,BudgetCategoryTwoXID
         FROM CalculatedWorkUnits Units
        WHERE Factor IN ("Task","Activity","Method");
*/

DROP VIEW IF EXISTS TaskCalculatedWorkUnits;
CREATE VIEW TaskCalculatedWorkUnits AS
       SELECT Units.ID,Units.ProjectSummaryID,Units.XID,Units.Factor,FactorID AS TaskID,
              FactorXID AS TaskXID,Units.Name,Units.Details,ProjectResourceID,
              ProjectResourceXID,FundingSourceID,FundingSourceXID,AccountingCodeID,
              AccountingCodeXID,BudgetCategoryOneID,BudgetCategoryOneXID,
              BudgetCategoryTwoID,BudgetCategoryTwoXID
         FROM CalculatedWorkUnits Units, Task
        WHERE Task.ProjectSummaryID = Units.ProjectSummaryID
          AND Task.XID = Units.FactorXID
          AND Units.Factor = "Task";


DROP VIEW IF EXISTS ActivityCalculatedWorkUnits;
CREATE VIEW ActivityCalculatedWorkUnits AS
       SELECT Units.ID,Units.ProjectSummaryID,Units.XID,Units.Factor,FactorID AS ActivityID,
              FactorXID AS ActivityXID,Units.Name,Units.Details,ProjectResourceID,
              ProjectResourceXID,FundingSourceID,FundingSourceXID,AccountingCodeID,
              AccountingCodeXID,BudgetCategoryOneID,BudgetCategoryOneXID,BudgetCategoryTwoID,
              BudgetCategoryTwoXID
         FROM CalculatedWorkUnits Units, Activity Act
        WHERE Act.ProjectSummaryID = Units.ProjectSummaryID
          AND Act.XID = Units.FactorXID
          AND Units.Factor = "Activity";


DROP VIEW IF EXISTS MethodCalculatedWorkUnits;
CREATE VIEW MethodCalculatedWorkUnits AS
       SELECT Units.ID,Units.ProjectSummaryID,Units.XID,Units.Factor,FactorID AS MethodID,
              FactorXID AS MethodXID,Units.Name,Units.Details,ProjectResourceID,
              ProjectResourceXID,FundingSourceID,FundingSourceXID,AccountingCodeID,
              AccountingCodeXID,BudgetCategoryOneID,BudgetCategoryOneXID,BudgetCategoryTwoID,
              BudgetCategoryTwoXID
         FROM CalculatedWorkUnits Units, Method Meth
        WHERE Meth.ProjectSummaryID = Units.ProjectSummaryID
          AND Meth.XID = Units.FactorXID
          AND Units.Factor = "Method";

/*
DROP VIEW IF EXISTS TaskActivityMethodCalculatedWho;
CREATE VIEW TaskActivityMethodCalculatedWho AS
       SELECT Who.ID, Who.ProjectSummaryID, Factor,
              FactorID AS TaskActivityMethodID, FactorXID AS TaskActivityMethodXID,
              ProjectResourceID, ProjectResourceXID
         FROM CalculatedWho Who
        WHERE Factor IN ("Task","Activity","Method");
*/

DROP VIEW IF EXISTS TaskCalculatedWho;
CREATE VIEW TaskCalculatedWho AS
       SELECT Who.ID,Who.ProjectSummaryID,Factor,FactorID AS TaskID,
              FactorXID AS TaskXID,ProjectResourceID,ProjectResourceXID
         FROM CalculatedWho Who
        WHERE Factor = "Task";


DROP VIEW IF EXISTS ActivityCalculatedWho;
CREATE VIEW ActivityCalculatedWho AS
       SELECT Who.ID, Who.ProjectSummaryID, Factor, FactorID AS ActivityID,
              FactorXID AS ActivityXID, ProjectResourceID, ProjectResourceXID
         FROM CalculatedWho Who
        WHERE Factor = "Activity";


DROP VIEW IF EXISTS MethodCalculatedWho;
CREATE VIEW MethodCalculatedWho AS
       SELECT Who.ID, Who.ProjectSummaryID, Factor, FactorID AS MethodID,
              FactorXID AS MethodXID, ProjectResourceID, ProjectResourceXID
         FROM CalculatedWho Who
        WHERE Factor = "Method";


DROP TABLE IF EXISTS TaskActivityMethodExpense;
CREATE TABLE TaskActivityMethodExpense
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TaskActivityMethodID INTEGER NOT NULL DEFAULT 0,
 TaskActivityMethodXID INTEGER NOT NULL,
 ExpenseAssignmentID INTEGER NOT NULL DEFAULT 0,
 ExpenseAssignmentXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,TaskActivityMethodXID),
 INDEX (ProjectSummaryID,ExpenseAssignmentXID),
 CONSTRAINT FOREIGN KEY (TaskActivityMethodID) REFERENCES TaskActivityMethod(ID),
 CONSTRAINT FOREIGN KEY (ExpenseAssignmentID) REFERENCES ExpenseAssignment(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS TaskExpense;
CREATE VIEW TaskExpense AS
       SELECT Exp.ID, Exp.ProjectSummaryID, Exp.TaskActivityMethodID AS TaskID, 
              Exp.TaskActivityMethodXID AS TaskXID,
              ExpenseAssignmentID, ExpenseAssignmentXID
         FROM TaskActivityMethodExpense Exp, Task
        WHERE Task.ProjectSummaryID = Exp.ProjectSummaryID
          AND Task.XID = Exp.TaskActivityMethodXID;


DROP VIEW IF EXISTS v_TaskExpense;
CREATE VIEW v_TaskExpense AS
       SELECT TaskID, TaskXID, Exp.*
         FROM TaskExpense TaskExp, ExpenseAssignment Exp
        WHERE Exp.ID = TaskExp.ExpenseAssignmentID; 


DROP VIEW IF EXISTS ActivityExpense;
CREATE VIEW ActivityExpense AS
       SELECT Exp.ID, Exp.ProjectSummaryID, Exp.TaskActivityMethodID AS ActivityID, 
              Exp.TaskActivityMethodXID AS ActivityXID,
              ExpenseAssignmentID, ExpenseAssignmentXID
         FROM TaskActivityMethodExpense Exp, Activity Act
        WHERE Act.ProjectSummaryID = Exp.ProjectSummaryID
          AND Act.XID = Exp.TaskActivityMethodXID;


DROP VIEW IF EXISTS v_ActivityExpense;
CREATE VIEW v_ActivityExpense AS
       SELECT ActivityID, ActivityXID, Exp.*
         FROM ActivityExpense ActExp, ExpenseAssignment Exp
        WHERE Exp.ID = ActExp.ExpenseAssignmentID; 


DROP VIEW IF EXISTS MethodExpense;
CREATE VIEW MethodExpense AS
       SELECT Exp.ID, Exp.ProjectSummaryID, Exp.TaskActivityMethodID AS MethodID, 
              Exp.TaskActivityMethodXID AS MethodXID,
              ExpenseAssignmentID, ExpenseAssignmentXID
         FROM TaskActivityMethodExpense Exp, Method Meth
        WHERE Meth.ProjectSummaryID = Exp.ProjectSummaryID
          AND Meth.XID = Exp.TaskActivityMethodXID;


DROP VIEW IF EXISTS v_MethodExpense;
CREATE VIEW v_MethodExpense AS
       SELECT MethodID, MethodXID, Exp.*
         FROM MethodExpense MethExp, ExpenseAssignment Exp
        WHERE Exp.ID = MethExp.ExpenseAssignmentID; 

/*
DROP VIEW IF EXISTS TaskActivityMethodCalculatedExpense;
CREATE VIEW TaskActivityMethodCalculatedExpense AS
       SELECT Exp.ID, Exp.ProjectSummaryID, Exp.XID, Exp.Factor,
              FactorID AS TaskActivityMethodID, FactorXID AS TaskActivityMethodXID,
              Exp.Name, Exp.Details, FundingSourceID,
              FundingSourceXID, AccountingCodeID, AccountingCodeXID,
              BudgetCategoryOneID, BudgetCategoryOneXID, BudgetCategoryTwoID,
              BudgetCategoryTwoXID
         FROM CalculatedExpense Exp
        WHERE Factor IN ("Task","Activity","Method");
*/

DROP VIEW IF EXISTS TaskCalculatedExpense;
CREATE VIEW TaskCalculatedExpense AS
       SELECT Exp.ID,Exp.ProjectSummaryID,Exp.XID,Exp.Factor,FactorID AS TaskID,
              FactorXID AS TaskXID,Exp.Name,Exp.Details,FundingSourceID,
              FundingSourceXID,AccountingCodeID,AccountingCodeXID,
              BudgetCategoryOneID,BudgetCategoryOneXID,BudgetCategoryTwoID,
              BudgetCategoryTwoXID
         FROM CalculatedExpense Exp, Task
        WHERE Task.ProjectSummaryID = Exp.ProjectSummaryID
          AND Task.XID = Exp.FactorXID
          AND Exp.Factor = "Task";


DROP VIEW IF EXISTS ActivityCalculatedExpense;
CREATE VIEW ActivityCalculatedExpense AS
       SELECT Exp.ID,Exp.ProjectSummaryID,Exp.XID,Exp.Factor,FactorID AS ActivityID,
              FactorXID AS ActivityXID,Exp.Name,Exp.Details,FundingSourceID,
              FundingSourceXID,AccountingCodeID,AccountingCodeXID,BudgetCategoryOneID,
              BudgetCategoryOneXID,BudgetCategoryTwoID,BudgetCategoryTwoXID
         FROM CalculatedExpense Exp, Activity Act
        WHERE Act.ProjectSummaryID = Exp.ProjectSummaryID
          AND Act.XID = Exp.FactorXID
          AND Exp.Factor = "Activity";


DROP VIEW IF EXISTS MethodCalculatedExpense;
CREATE VIEW MethodCalculatedExpense AS
       SELECT Exp.ID,Exp.ProjectSummaryID,Exp.XID,Exp.Factor,FactorID AS MethodID,
              FactorXID AS MethodXID,Exp.Name,Exp.Details,FundingSourceID,
              FundingSourceXID,AccountingCodeID,AccountingCodeXID,BudgetCategoryOneID,
              BudgetCategoryOneXID,BudgetCategoryTwoID,BudgetCategoryTwoXID
         FROM CalculatedExpense Exp, Method Meth
        WHERE Meth.ProjectSummaryID = Exp.ProjectSummaryID
          AND Meth.XID = Exp.FactorXID
          AND Exp.Factor = "Method";


DROP TABLE IF EXISTS Objective;
CREATE TABLE Objective                   -- Objects-9
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Objective_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
 ) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS Goal;
CREATE TABLE Goal                       -- Objects-10
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Goal_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
 ) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TargetGoal;
CREATE TABLE TargetGoal
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL DEFAULT 0,
 TargetXID INTEGER NOT NULL,
 GoalID INTEGER NOT NULL DEFAULT 0,
 GoalXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,TargetXID),
 INDEX (ProjectSummaryID,GoalXID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (GoalID) REFERENCES Goal(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS BiodiversityTargetGoal;
CREATE VIEW BiodiversityTargetGoal AS
       SELECT Goal.ID, Goal.ProjectSummaryID, Goal.TargetID AS BiodiversityTargetID,
              Goal.TargetXID AS BiodiversityTargetXID, GoalID, GoalXID
         FROM TargetGoal Goal, BiodiversityTarget Tgt
        WHERE Tgt.ProjectSummaryID = Goal.ProjectSummaryID
          AND Tgt.XID = Goal.TargetXID;


DROP VIEW IF EXISTS HumanWelfareTargetGoal;
CREATE VIEW HumanWelfareTargetGoal AS
       SELECT Goal.ID, Goal.ProjectSummaryID,TargetID AS HumanWelfareTargetID,
              Goal.TargetXID AS HumanWelfareTargetXID,GoalID, GoalXID
         FROM TargetGoal Goal, HumanWelfareTarget Tgt
        WHERE Tgt.ProjectSummaryID = Goal.ProjectSummaryID
          AND Tgt.XID = Goal.TargetXID;


DROP TABLE IF EXISTS ObjectiveRelevantIndicator;
CREATE TABLE ObjectiveRelevantIndicator
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL DEFAULT 0,
 ObjectiveXID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ObjectiveXID),
 INDEX (ProjectSummaryID,IndicatorXID),
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_ObjectiveIndicator;        -- Joins ObjectiveRelevantIndicator with Indicator.
CREATE VIEW v_ObjectiveIndicator AS
       SELECT ObjectiveID, ObjectiveXID, Ind.*
         FROM ObjectiveRelevantIndicator Obj, Indicator Ind
        WHERE Ind.ID = Obj.IndicatorID; 


DROP TABLE IF EXISTS GoalRelevantIndicator;
CREATE TABLE GoalRelevantIndicator
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 GoalID INTEGER NOT NULL DEFAULT 0,
 GoalXID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,GoalXID),
 INDEX (ProjectSummaryID,IndicatorXID),
 CONSTRAINT FOREIGN KEY (GoalID) REFERENCES Goal(ID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ObjectiveThreat;
CREATE TABLE ObjectiveThreat
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL,
 ObjectiveXID INTEGER NOT NULL,
 ThreatID INTEGER NOT NULL,
 ThreatXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ObjectiveXID),
 INDEX (ProjectSummaryID,ThreatXID),
 UNIQUE INDEX (ObjectiveID,ThreatID),      -- Required because it's populated with REPLACE.
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (ThreatID) REFERENCES Threat(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ObjectiveTarget;
CREATE TABLE ObjectiveTarget
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL,
 ObjectiveXID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL,
 TargetXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ObjectiveXID),
 INDEX (ProjectSummaryID,TargetXID),
 UNIQUE INDEX (ObjectiveID,TargetID),      -- Required because it's populated with REPLACE.
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ObjectiveProgressReport;
CREATE TABLE ObjectiveProgressReport
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL DEFAULT 0,
 ObjectiveXID INTEGER NOT NULL,
 ProgressReportID INTEGER NOT NULL DEFAULT 0,
 ProgressReportXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ObjectiveXID),
 INDEX (ProjectSummaryID,ProgressReportXID),
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (ProgressReportID) REFERENCES ProgressReport(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS GoalProgressReport;
CREATE TABLE GoalProgressReport
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 GoalID INTEGER NOT NULL DEFAULT 0,
 GoalXID INTEGER NOT NULL,
 ProgressReportID INTEGER NOT NULL DEFAULT 0,
 ProgressReportXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,GoalXID),
 INDEX (ProjectSummaryID,ProgressReportXID),
 CONSTRAINT FOREIGN KEY (GoalID) REFERENCES Goal(ID),
 CONSTRAINT FOREIGN KEY (ProgressReportID) REFERENCES ProgressReport(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ObjectiveRelevantStrategy;
CREATE TABLE ObjectiveRelevantStrategy
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL DEFAULT 0,
 ObjectiveXID INTEGER NOT NULL,
 StrategyID INTEGER DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ObjectiveXID),
 INDEX (ProjectSummaryID,StrategyXID),
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS GoalRelevantStrategy;
CREATE TABLE GoalRelevantStrategy
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 GoalID INTEGER NOT NULL DEFAULT 0,
 GoalXID INTEGER NOT NULL,
 StrategyID INTEGER DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,GoalXID),
 INDEX (ProjectSummaryID,StrategyXID),
 CONSTRAINT FOREIGN KEY (GoalID) REFERENCES Goal(ID),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StrategyObjective;
CREATE TABLE StrategyObjective
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL DEFAULT 0,
 ObjectiveXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ObjectiveXID),
 INDEX (ProjectSummaryID,StrategyXID),
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StrategyGoal;
CREATE TABLE StrategyGoal
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StrategyID INTEGER DEFAULT 0,
 StrategyXID INTEGER NOT NULL,
 GoalID INTEGER NOT NULL DEFAULT 0,
 GoalXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,GoalXID),
 INDEX (ProjectSummaryID,StrategyXID),
 CONSTRAINT FOREIGN KEY (GoalID) REFERENCES Goal(ID),
 CONSTRAINT FOREIGN KEY (StrategyID) REFERENCES Strategy(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ObjectiveRelevantActivity;
CREATE TABLE ObjectiveRelevantActivity
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL DEFAULT 0,
 ObjectiveXID INTEGER NOT NULL,
 ActivityID INTEGER DEFAULT 0,
 ActivityXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ObjectiveXID),
 INDEX (ProjectSummaryID,ActivityXID),
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (ActivityID) REFERENCES Activity(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS GoalRelevantActivity;
CREATE TABLE GoalRelevantActivity
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 GoalID INTEGER NOT NULL DEFAULT 0,
 GoalXID INTEGER NOT NULL,
 ActivityID INTEGER DEFAULT 0,
 ActivityXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,GoalXID),
 INDEX (ProjectSummaryID,ActivityXID),
 CONSTRAINT FOREIGN KEY (GoalID) REFERENCES Goal(ID),
 CONSTRAINT FOREIGN KEY (ActivityID) REFERENCES Activity(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ProgressPercent;
CREATE TABLE ProgressPercent
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL DEFAULT 0,
 XID INTEGER NOT NULL,
 PercentDate DATE,
 PercentComplete DECIMAL(4,1),
 Details TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ObjectiveProgressPercent;
CREATE TABLE ObjectiveProgressPercent
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL DEFAULT 0,
 ObjectiveXID INTEGER NOT NULL,
 ProgressPercentID INTEGER NOT NULL DEFAULT 0,
 ProgressPercentXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ObjectiveXID),
 INDEX (ProjectSummaryID,ProgressPercentXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (ProgressPercentID) REFERENCES ProgressPercent(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS GoalProgressPercent;
CREATE TABLE GoalProgressPercent
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 GoalID INTEGER NOT NULL DEFAULT 0,
 GoalXID INTEGER NOT NULL,
 ProgressPercentID INTEGER NOT NULL DEFAULT 0,
 ProgressPercentXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,GoalXID),
 INDEX (ProjectSummaryID,ProgressPercentXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (GoalID) REFERENCES Goal(ID),
 CONSTRAINT FOREIGN KEY (ProgressPercentID) REFERENCES ProgressPercent(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS Cause;
CREATE TABLE Cause                        -- Objects-20
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Cause_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 IsDirectThreat BOOLEAN,
 StandardClassification ENUM("","T10","T10.10","T10.20","T10.30","T20","T20.10",
                             "T20.30","T20.40","T20.50","T30","T30.10","T30.20",
                             "T30.30","T40","T40.10","T40.20","T40.30","T40.40",
                             "T50","T50.10","T50.20","T50.30","T50.40","T60",
                             "T60.10","T60.20","T60.30","T70","T70.10","T70.20",
                             "T70.30","T80","T80.10","T80.20","T80.30","T91",
                             "T91.10","T91.20","T91.30","T91.40","T91.50","T91.60",
                             "T100","T100.10","T100.20","T100.30","T110","T110.10",
                             "T110.20","T110.30","T110.40"
                            ),
 ThreatRating TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS Threat;
CREATE VIEW Threat AS
       SELECT ID, ProjectSummaryID, XID, Cause_Id AS Threat_Id, Name,Details,
              Comments, IsDirectThreat, StandardClassification, ThreatRating
         FROM Cause WHERE IsDirectThreat = TRUE;


DROP TABLE IF EXISTS CauseIndicator;
CREATE TABLE CauseIndicator
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 CauseID INTEGER NOT NULL DEFAULT 0,
 CauseXID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,CauseXID),
 INDEX (ProjectSummaryID,IndicatorXID),
 CONSTRAINT FOREIGN KEY (CauseID) REFERENCES Cause(ID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_ThreatIndicator;               -- Joins CauseIndicator with Indicator.
CREATE VIEW v_ThreatIndicator AS
       SELECT CauseID AS ThreatID, CauseXID AS ThreatXID, Ind.*
         FROM Threat Thr, CauseIndicator ThrInd, Indicator Ind
        WHERE Ind.ID = ThrInd.IndicatorID
          AND ThrInd.CauseID = Thr.ID;


DROP TABLE IF EXISTS CauseObjective;
CREATE TABLE CauseObjective
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 CauseId INTEGER NOT NULL DEFAULT 0,
 CauseXID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL DEFAULT 0,
 ObjectiveXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,CauseXID),
 INDEX (ProjectSummaryID,ObjectiveXID),
 CONSTRAINT FOREIGN KEY (CauseID) REFERENCES Cause(ID),
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ThreatTarget;
CREATE TABLE ThreatTarget
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ThreatID INTEGER NOT NULL,
 ThreatXID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL,
 TargetXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ThreatXID),
 INDEX (ProjectSummaryID,TargetXID),
 UNIQUE INDEX (ThreatID,TargetID),      -- Required because it's populated with REPLACE.
 CONSTRAINT FOREIGN KEY (ThreatID) REFERENCES Threat(ID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_StrategyThreatTarget;
CREATE VIEW v_StrategyThreatTarget AS
       SELECT StrThr.ProjectSummaryID, StrThr.StrategyID, StrThr.StrategyXID,
              StrThr.ThreatID, StrThr.ThreatXID, ThrTgt.TargetID, ThrTgt.TargetXID
         FROM StrategyThreat StrThr, ThreatTarget ThrTgt
        WHERE ThrTgt.ThreatID = StrThr.ThreatID;
        
        
DROP TABLE IF EXISTS Stress;
CREATE TABLE Stress                       -- Objects-33
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Stress_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 Severity TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 Scope TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 StressRating TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TargetStress;
CREATE TABLE TargetStress
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL DEFAULT 0,
 TargetXID INTEGER NOT NULL,
 StressID INTEGER NOT NULL DEFAULT 0,
 StressXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,TargetXID),
 INDEX (ProjectSummaryID,StressXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (StressID) REFERENCES KeyEcologicalAttribute(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS BiodiversityTargetStress;
CREATE VIEW BiodiversityTargetStress AS
       SELECT Str.ID, Str.ProjectSummaryID, Str.TargetID AS BiodiversityTargetID,
              Str.TargetXID AS BiodiversityTargetXID, StressID, StressXID
         FROM TargetStress Str, BiodiversityTarget Tgt
        WHERE Tgt.ProjectSummaryID = Str.ProjectSummaryID
          AND Tgt.XID = Str.TargetXID;



DROP VIEW IF EXISTS HumanWelfareTargetStress;
CREATE VIEW HumanWelfareTargetStress AS
       SELECT Str.ID, Str.ProjectSummaryID, Str.TargetID AS HumanWelfareTargetID,
              Str.TargetXID AS HumanWelfareTargetXID, StressID, StressXID
         FROM TargetStress Str, HumanWelfareTarget Tgt
        WHERE Tgt.ProjectSummaryID = Str.ProjectSummaryID
          AND Tgt.XID = Str.TargetXID;



DROP TABLE IF EXISTS ThreatRating;
CREATE TABLE ThreatRating
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 XID INTEGER NOT NULL,
 ProjectSummaryID INTEGER NOT NULL,
 TargetID INTEGER NOT NULL DEFAULT 0,
 TargetXID INTEGER NOT NULL,
 ThreatID INTEGER NOT NULL DEFAULT 0,
 ThreatXID INTEGER NOT NULL,
 ThreatTargetRating TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 Comments TEXT,                           -- Objects 49
 INDEX (ProjectSummaryID,XID),
 INDEX (ProjectSummaryID,TargetXID),
 INDEX (ProjectSummaryID,ThreatXID),
 CONSTRAINT FOREIGN KEY (TargetID) REFERENCES Target(ID),
 CONSTRAINT FOREIGN KEY (ThreatID) REFERENCES Threat(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS SimpleThreatRating;  -- An extraction from Objects-33 and -34
CREATE TABLE SimpleThreatRating
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ThreatRatingID INTEGER NOT NULL DEFAULT 0,
 ThreatRatingXID INTEGER NOT NULL,
 Scope TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 Severity TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 Irreversibility TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 INDEX (ProjectSummaryID,ThreatRatingXID),
 CONSTRAINT FOREIGN KEY (ThreatRatingID) REFERENCES ThreatRating(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StressBasedThreatRating;  -- An extraction from Objects-33 and -34
CREATE TABLE StressBasedThreatRating
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ThreatRatingID INTEGER NOT NULL DEFAULT 0,
 ThreatRatingXID INTEGER NOT NULL,
 StressID INTEGER NOT NULL DEFAULT 0,
 StressXID INTEGER NOT NULL,
 IsActive BOOLEAN DEFAULT FALSE,
 Irreversibility TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 Contribution TINYINT,       -- Vocabulary: 1, 2, 3, 4.
 StressRating TINYINT,       -- Vocabulary: 1, 2, 3, 4.
 ThreatStressRating TINYINT, -- Vocabulary: 1, 2, 3, 4.
 INDEX (ProjectSummaryID,ThreatRatingXID),
 INDEX (ProjectSummaryID,StressXID),
 CONSTRAINT FOREIGN KEY (ThreatRatingID) REFERENCES ThreatRating(ID),
 CONSTRAINT FOREIGN KEY (StressID) REFERENCES Stress(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS Result;
CREATE TABLE Result                         -- Objects-23 (IR) / Objects-25 (TRR)
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Result_Id VARCHAR(255),
 FactorType ENUM("TR","IR"),                -- "IR" = Intermediate; "TR" = Threat Reduction
 ThreatID INTEGER,                          -- When NOT NULL then is a TRR.
 ThreatXID INTEGER,                         -- When NOT NULL then is a TRR.
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 INDEX (ProjectSummaryID,ThreatXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ThreatID) REFERENCES Threat(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS ThreatReductionResult;
CREATE VIEW ThreatReductionResult AS
       SELECT ID, ProjectSummaryID, XID, Result_Id AS ThreatReductionResult_Id,
              FactorType, ThreatID, ThreatXID, Name, Details, Comments
         FROM Result WHERE FactorType = "TR";


DROP VIEW IF EXISTS IntermediateResult;
CREATE VIEW IntermediateResult AS
       SELECT ID, ProjectSummaryID, XID, Result_Id AS IntermediateResult_Id,
              FactorType, ThreatID, ThreatXID, Name, Details, Comments
         FROM Result WHERE FactorType = "IR";


DROP TABLE IF EXISTS ResultIndicator;
CREATE TABLE ResultIndicator
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ResultID INTEGER NOT NULL DEFAULT 0,
 ResultXID INTEGER NOT NULL,
 IndicatorID INTEGER NOT NULL DEFAULT 0,
 IndicatorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ResultXID),
 INDEX (ProjectSummaryID,IndicatorXID),
 CONSTRAINT FOREIGN KEY (ResultID) REFERENCES Result(ID),
 CONSTRAINT FOREIGN KEY (IndicatorID) REFERENCES Indicator(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS IntermediateResultIndicator;
CREATE VIEW IntermediateResultIndicator AS
       SELECT Ind.ID, Ind.ProjectSummaryID,ResultID AS IntermediateResultID,
              Ind.ResultXID AS IntermediateResultXID, IndicatorID, IndicatorXID
         FROM ResultIndicator Ind, IntermediateResult Res
        WHERE Res.ProjectSummaryID = Ind.ProjectSummaryID
          AND Res.XID = Ind.ResultXID;



DROP VIEW IF EXISTS ThreatReductionResultIndicator;
CREATE VIEW ThreatReductionResultIndicator AS
       SELECT Ind.ID, Ind.ProjectSummaryID,ResultID AS ThreatReductionResultID,
              Ind.ResultXID AS ThreatReductionResultXID, IndicatorID, IndicatorXID
         FROM ResultIndicator Ind, ThreatReductionResult Res
        WHERE Res.ProjectSummaryID = Ind.ProjectSummaryID
          AND Res.XID = Ind.ResultXID;


DROP TABLE IF EXISTS ResultObjective;
CREATE TABLE ResultObjective
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ResultID INTEGER NOT NULL DEFAULT 0,
 ResultXID INTEGER NOT NULL,
 ObjectiveID INTEGER NOT NULL DEFAULT 0,
 ObjectiveXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ResultXID),
 INDEX (ProjectSummaryID,ObjectiveXID),
 CONSTRAINT FOREIGN KEY (ResultID) REFERENCES Result(ID),
 CONSTRAINT FOREIGN KEY (ObjectiveID) REFERENCES Objective(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS IntermediateResultObjective;
CREATE VIEW IntermediateResultObjective AS
       SELECT Obj.ID, Obj.ProjectSummaryID,ResultID AS IntermediateResultID,
              Obj.ResultXID AS IntermediateResultXID, ObjectiveID, ObjectiveXID
         FROM ResultObjective Obj, IntermediateResult Res
        WHERE Res.ProjectSummaryID = Obj.ProjectSummaryID
          AND Res.XID = Obj.ResultXID;


DROP VIEW IF EXISTS ThreatReductionResultObjective;
CREATE VIEW ThreatReductionResultObjective AS
       SELECT Obj.ID, Obj.ProjectSummaryID,ResultID AS ThreatReductionResultID,
              Obj.ResultXID AS ThreatReductionResultXID, ObjectiveID, ObjectiveXID
         FROM ResultObjective Obj, ThreatReductionResult Res
        WHERE Res.ProjectSummaryID = Obj.ProjectSummaryID
          AND Res.XID = Obj.ResultXID;


DROP TABLE IF EXISTS DiagramFactor;
CREATE TABLE DiagramFactor                -- Objects-18
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Name TEXT,
 X INTEGER,
 Y INTEGER,
 Width SMALLINT,
 Height SMALLINT,
 WrappedByDiagramFactor VARCHAR(25),
 WrappedByDiagramFactorXID INTEGER,
 TextBoxZOrderCode ENUM("Back","Front"),
 DiagramFactorFontSize DECIMAL(3,2),          -- 1.0|0.5|0.75|0.9|1.25|1.75|2.5
 DiagramFactorFontStyle ENUM("","<B>","<U>","<S>"),
 DiagramFactorFontColor ENUM("#000000","#4E4848","#FF0000","#FF6600","#FFCC00","#007F00",
                             "#0000CC","#9900FF","#C85A17","#6D7B8D","#FFFFFF","#FF00FF",
                             "#FF8040","#FFFFCC","#5FFB17","#00CCFF","#CC99FF","#EDE275"
                            ),
 DiagramFactorBackgroundColor ENUM("LightGray","White","Pink","Orange","LightYellow",
                                   "LightGreen","LightBlue","LightPurple","Tan","Black",
                                   "DarkGray","Red","DarkOrange","DarkYellow","DarkGreen",
                                   "DarkBlue","DarkPurple","Brown"
                                  ),
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS DiagramLink;
CREATE TABLE DiagramLink                  -- Objects-6
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Name TEXT,
 DiagramLinkFromDiagramFactor VARCHAR(25),
 DiagramLinkFromDiagramFactorXID INTEGER NOT NULL,
 DiagramLinkToDiagramFactor VARCHAR(25),
 DiagramLinkToDiagramFactorXID INTEGER NOT NULL,
 Color ENUM("black","darkGray","red","DarkOrange","DarkYellow","darkGreen","darkBlue",
            "DarkPurple","brown","lightGray","White","pink","orange","yellow","lightGreen",
            "lightBlue","LightPurple","tan"
           ),
 IsBidirectionalLink BOOLEAN,
 INDEX (ProjectSummaryID, XID),
 INDEX (ProjectSummaryID, DiagramLinkFromDiagramFactorXID, DiagramLinkFromDiagramFactor),
 INDEX (ProjectSummaryID, DiagramLinkToDiagramFactorXID, DiagramLinkToDiagramFactor),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_DiagramLink;             /* View on DiagramLink that includes From/To
                                                  DiagramFactorID ... AND ...
                                                  From/To WrappedByDiagramFactorXID
                                               */
CREATE VIEW v_DiagramLink AS
       SELECT Link.ID, Link.ProjectSummaryID, Link.XID, Link.Name,
              DiagramLinkFromDiagramFactor, DiagramLinkFromDiagramFactorXID,
              FromFactor.ID AS DiagramLinkFromDiagramFactorID,
              FromFactor.WrappedByDiagramFactorXID AS DiagramLinkFromFactorXID,
              DiagramLinkToDiagramFactor, DiagramLinkToDiagramFactorXID,
              ToFactor.ID AS DiagramLinkToDiagramFactorID,
              ToFactor.WrappedByDiagramFactorXID AS DiagramLinkToFactorXID,
              Color, IsBidirectionalLink
         FROM DiagramLink Link, DiagramFactor FromFactor,
              DiagramFactor ToFactor
        WHERE FromFactor.ProjectSummaryID = Link.ProjectSummaryID
          AND FromFactor.WrappedByDiagramFactor = Link.DiagramLinkFromDiagramFactor
          AND FromFactor.XID = Link.DiagramLinkFromDiagramFactorXID
          AND ToFactor.ProjectSummaryID = Link.ProjectSummaryID
          AND ToFactor.WrappedByDiagramFactor = Link.DiagramLinkToDiagramFactor
          AND ToFactor.XID = Link.DiagramLinkToDiagramFactorXID;
          
          
DROP TABLE IF EXISTS DiagramLinkBendPoint;
CREATE TABLE DiagramLinkBendPoint
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 DiagramLinkID INTEGER NOT NULL DEFAULT 0,
 DiagramLinkXID INTEGER NOT NULL,
 X SMALLINT,
 Y SMALLINT,
 INDEX (ProjectSummaryID, DiagramLinkXID),
 FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 FOREIGN KEY (DiagramLinkID) REFERENCES DiagramLink(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS GroupedDiagramLink;
CREATE TABLE GroupedDiagramLink
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 DiagramLinkID INTEGER NOT NULL DEFAULT 0,   -- Grouped Diagram Link
 DiagramLinkXID INTEGER NOT NULL,
 DiagramLinkRef INTEGER NOT NULL DEFAULT 0,  -- Group's Child Diagram Link
 INDEX (ProjectSummaryID,DiagramLinkXID),
 INDEX (ProjectSummaryID,DiagramLinkRef),
 CONSTRAINT FOREIGN KEY (DiagramLinkID) REFERENCES DiagramLink(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_GroupedDiagramLink;
CREATE VIEW v_GroupedDiagramLink AS     /* View on GroupedDiagramLink that includes DiagramLink
                                           factor data for child links.
                                        */
       SELECT GL.*, DL1.DiagramLinkFromDiagramFactor, DL1.DiagramLinkFromDiagramFactorID, 
              DL1.DiagramLinkFromDiagramFactorXID, DL1.DiagramLinkFromFactorXID,
              DL1.DiagramLinkToDiagramFactor, DL1.DiagramLinkToDiagramFactorID,
              DL1.DiagramLinkToDiagramFactorXID, DL1.DiagramLinkToFactorXID,
              DL2.DiagramLinkFromDiagramFactor AS ChildLinkFromDiagramFactor, 
              DL2.DiagramLinkFromDiagramFactorID AS ChildLinkFromDiagramFactorID, 
              DL2.DiagramLinkFromDiagramFactorXID AS ChildLinkFromDiagramFactorXID,
              DL2.DiagramLinkFromFactorXID AS ChildLinkFromFactorXID,
              DL2.DiagramLinkToDiagramFactor AS ChildLinkToDiagramFactor, 
              DL2.DiagramLinkToDiagramFactorID AS ChildLinkToDiagramFactorID, 
              DL2.DiagramLinkToDiagramFactorXID AS ChildLinkToDiagramFactorXID ,
              DL2.DiagramLinkToFactorXID AS ChildLinkToFactorXID
  FROM GroupedDiagramLink GL, v_DiagramLink DL1, v_DiagramLink DL2
 WHERE DL2.ProjectSummaryID = GL.ProjectSummaryID
   AND DL2.XID = GL.DiagramLinkRef
   AND DL1.ID = GL.DiagramLinkID
 GROUP BY ProjectSummaryID, DiagramLinkID, DiagramLinkRef;


DROP TABLE IF EXISTS GroupBox;
CREATE TABLE GroupBox                     -- Objects-35
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 GroupBox_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS GroupBoxChildren;
CREATE TABLE GroupBoxChildren
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 DiagramFactorID INTEGER NOT NULL DEFAULT 0,   -- Group Box Diagram Factor
 DiagramFactorXID INTEGER NOT NULL,
 DiagramFactorRef INTEGER NOT NULL DEFAULT 0,  -- Group Box Child's Diagram Factor
 INDEX (ProjectSummaryID,DiagramFactorXID),
 INDEX (ProjectSummaryID,DiagramFactorRef),
 CONSTRAINT FOREIGN KEY (DiagramFactorID) REFERENCES DiagramFactor(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_GroupBoxChildren; /* View on GroupBox that includes diagram elements from
                                           v_DiagramFactor, and WrappedByDiagramFactor elements
                                           from GroupBoxChildren.
                                        */
CREATE VIEW v_GroupBoxChildren AS
       SELECT GB.*, DF1.ID AS DiagramFactorID, DF1.XID AS DiagramFactorXID, 
              DF1.x, DF1.y, DF1.Width, DF1.Height, DF1.TextBoxZOrderCode, DF1.DiagramFactorFontSize,
              DF1.DiagramFactorFontStyle, DF1.DiagramFactorFontColor, DF1.DiagramFactorBackgroundColor, 
              DF2.ID AS ChildDiagramFactorID,
              DF2.XID AS ChildDiagramFactorXID,
              DF2.WrappedByDiagramFactor,DF2.WrappedByDiagramFactorXID
         FROM GroupBox GB, DiagramFactor DF1, GroupBoxChildren GBC, 
              DiagramFactor DF2
        WHERE DF2.ProjectSummaryID = GBC.ProjectSummaryID
          AND DF2.XID = GBC.DiagramFactorRef
          AND GBC.DiagramFactorID = DF1.ID
          AND DF1.ProjectSummaryID = GB.ProjectSummaryID
          AND DF1.WrappedByDiagramFactor = "GroupBox"
          AND DF1.WrappedByDiagramFactorXID = GB.XID
        GROUP BY ProjectSummaryID, ID, ChildDiagramFactorID;


DROP TABLE IF EXISTS TextBox;
CREATE TABLE TextBox                      -- Objects-26
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 TextBox_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ScopeBox;
CREATE TABLE ScopeBox                     -- Objects-50
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 ScopeBox_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 Comments TEXT,
 ScopeBoxTypeCode ENUM("Biodiversity","HumanWelfare"),
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TaggedObjectSet;
CREATE TABLE TaggedObjectSet              -- Objects-47
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 TaggedObjectSet_Id VARCHAR(255),
 Name TEXT,
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS TaggedObjectSetFactor;
CREATE TABLE TaggedObjectSetFactor
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 TaggedObjectSetID INTEGER NOT NULL DEFAULT 0,
 TaggedObjectSetXID INTEGER NOT NULL,
 WrappedByDiagramFactor VARCHAR(25) NOT NULL,
 WrappedByDiagramFactorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID, TaggedObjectSetXID),
 INDEX (ProjectSummaryID, WrappedByDiagramFactorXID, WrappedByDiagramFactor),
 FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 FOREIGN KEY (TaggedObjectSetID) REFERENCES TaggedObjectSet (ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ConceptualModel;
CREATE TABLE ConceptualModel              -- Objects-19
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 ConceptualModel_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 ZoomScale FLOAT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ConceptualModelDiagramFactor;
CREATE TABLE ConceptualModelDiagramFactor
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ConceptualModelID INTEGER NOT NULL DEFAULT 0,
 ConceptualModelXID INTEGER NOT NULL,
 DiagramFactorID INTEGER NOT NULL DEFAULT 0,
 DiagramFactorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ConceptualModelXID),
 INDEX (ProjectSummaryID,DiagramFactorXID),
 CONSTRAINT FOREIGN KEY (ConceptualModelID) REFERENCES ConceptualModel(ID),
 CONSTRAINT FOREIGN KEY (DiagramFactorID) REFERENCES DiagramFactor(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_ConceptualModelFactor;  -- Lists all factors within each Conceptual Model
CREATE VIEW v_ConceptualModelFactor AS
       SELECT CM.ProjectSummaryID, CM.ID AS ConceptualModelID, CM.XID AS ConceptualModelXID,
              ConceptualModel_Id, CM.Name,
              WrappedByDiagramFactor AS Factor,
              WrappedByDiagramFactorXID AS FactorXID
         FROM ConceptualModel CM, ConceptualModelDiagramFactor CMDF, DiagramFactor DF
        WHERE DF.ID = CMDF.DiagramFactorID
          AND CMDF.ConceptualModelID = CM.ID;


DROP TABLE IF EXISTS ConceptualModelDiagramLink;
CREATE TABLE ConceptualModelDiagramLink
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ConceptualModelID INTEGER NOT NULL DEFAULT 0,
 ConceptualModelXID INTEGER NOT NULL,
 DiagramLinkID INTEGER NOT NULL DEFAULT 0,
 DiagramLinkXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ConceptualModelXID),
 INDEX (ProjectSummaryID,DiagramLinkXID),
 CONSTRAINT FOREIGN KEY (ConceptualModelID) REFERENCES ConceptualModel(ID),
 CONSTRAINT FOREIGN KEY (DiagramLinkID) REFERENCES DiagramLink(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_ConceptualModelLink;  -- Lists all links within each Conceptual Model
CREATE VIEW v_ConceptualModelLink AS
       SELECT CMF.ProjectSummaryID, CMF.ConceptualModelID, CMF.ConceptualModelXID,
              CMF.ConceptualModel_Id, CMF.Name, CMF.Factor, CMF.FactorXID,
              FromDL.DiagramLinkFromDiagramFactor AS FromFactor,
              FromDL.DiagramLinkFromFactorXID AS FromFactorXID,
              ToDL.DiagramLinkToDiagramFactor AS ToFactor,
              ToDL.DiagramLinkToFactorXID AS ToFactorXID
         FROM v_ConceptualModelFactor CMF
                 LEFT JOIN (ConceptualModelDiagramLink FromCMDL,
                            v_DiagramLink FromDL
                           )
                   ON (    FromDL.DiagramLinkToDiagramFactor = CMF.Factor
                       AND FromDL.DiagramLinkToFactorXID = CMF.FactorXID
                       AND FromDL.ID = FromCMDL.DiagramLinkID
                       AND FromCMDL.ConceptualModelID = CMF.ConceptualModelID
                      )
                 LEFT JOIN (ConceptualModelDiagramLink ToCMDL,
                            v_DiagramLink ToDL
                           )
                   ON (    ToDL.DiagramLinkFromDiagramFactor = CMF.Factor
                       AND ToDL.DiagramLinkFromFactorXID = CMF.FactorXID
                       AND ToDL.ID = ToCMDL.DiagramLinkID
                       AND ToCMDL.ConceptualModelID = CMF.ConceptualModelID
                      )
        GROUP BY ProjectSummaryID, ConceptualModelID, Factor, FactorXID, 
                 FromFactor, FromFactorXID, ToFactor, ToFactorXID
              HAVING FromFactorXID IS NOT NULL OR ToFactorXID IS NOT NULL;


DROP TABLE IF EXISTS ConceptualModelHiddenTypes;
CREATE TABLE ConceptualModelHiddenTypes
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ConceptualModelID INTEGER NOT NULL DEFAULT 0,
 ConceptualModelXID INTEGER NOT NULL,
 Code ENUM("Strategy","DraftStrategy","ContributingFactor","DirectThreat","Target",
           "HumanWelfareTarget","Link","Goal","Objective","Indicator","TextBox", "ScopeBox",
           "Stress","Activity","IntermediateResult","ThreatReductionResult","GroupBox"
          ),
 INDEX (ProjectSummaryID,ConceptualModelXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ConceptualModelID) REFERENCES ConceptualModel(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ConceptualModelTaggedObjectSet;
CREATE TABLE ConceptualModelTaggedObjectSet
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ConceptualModelID INTEGER NOT NULL DEFAULT 0,
 ConceptualModelXID INTEGER NOT NULL,
 TaggedObjectSetID INTEGER NOT NULL DEFAULT 0,
 TaggedObjectSetXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ConceptualModelXID),
 INDEX (ProjectSummaryID,TaggedObjectSetXID),
 CONSTRAINT FOREIGN KEY (ConceptualModelID) REFERENCES ConceptualModel(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ResultsChain;
CREATE TABLE ResultsChain                 -- Objects-24
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 ResultsChain_Id VARCHAR(255),
 Name TEXT,
 Details TEXT,
 ZoomScale FLOAT,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ResultsChainDiagramFactor;
CREATE TABLE ResultsChainDiagramFactor
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ResultsChainID INTEGER NOT NULL NOT NULL DEFAULT 0,
 ResultsChainXID INTEGER NOT NULL,
 DiagramFactorID INTEGER NOT NULL DEFAULT 0,
 DiagramFactorXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ResultsChainXID),
 INDEX (ProjectSummaryID,DiagramFactorXID),
 CONSTRAINT FOREIGN KEY (ResultsChainID) REFERENCES ResultsChain(ID),
 CONSTRAINT FOREIGN KEY (DiagramFactorID) REFERENCES DiagramFactor(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_ResultsChainFactor;  -- Lists all factors within each Results Chain
CREATE VIEW v_ResultsChainFactor AS
       SELECT RC.ProjectSummaryID, RC.ID AS ResultsChainID, RC.XID AS ResultsChainXID,
              ResultsChain_Id, RC.Name,
              WrappedByDiagramFactor AS Factor,
              WrappedByDiagramFactorXID AS FactorXID
         FROM ResultsChain RC, ResultsChainDiagramFactor RCDF, DiagramFactor DF
        WHERE DF.ID = RCDF.DiagramFactorID
          AND RCDF.ResultsChainID = RC.ID;


DROP TABLE IF EXISTS ResultsChainDiagramLink;
CREATE TABLE ResultsChainDiagramLink
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ResultsChainID INTEGER NOT NULL DEFAULT 0,
 ResultsChainXID INTEGER NOT NULL,
 DiagramLinkID INTEGER NOT NULL DEFAULT 0,
 DiagramLinkXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ResultsChainXID),
 INDEX (ProjectSummaryID,DiagramLinkXID),
 CONSTRAINT FOREIGN KEY (ResultsChainID) REFERENCES ResultsChain(ID),
 CONSTRAINT FOREIGN KEY (DiagramLinkID) REFERENCES DiagramLink(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS v_ResultsChainLink;   -- Lists all links within each Results Chain
CREATE VIEW v_ResultsChainLink AS
       SELECT RCF.ProjectSummaryID, RCF.ResultsChainID, RCF.ResultsChainXID, 
              RCF.ResultsChain_Id, RCF.Name, RCF.Factor, RCF.FactorXID,
              FromDL.DiagramLinkFromDiagramFactor AS FromFactor,
              FromDL.DiagramLinkFromFactorXID AS FromFactorXID,
              ToDL.DiagramLinkToDiagramFactor AS ToFactor,
              ToDL.DiagramLinkToFactorXID AS ToFactorXID
         FROM v_ResultsChainFactor RCF
                 LEFT JOIN (ResultsChainDiagramLink FromRCDL,
                            v_DiagramLink FromDL
                           )
                   ON (    FromDL.DiagramLinkToDiagramFactor = RCF.Factor
                       AND FromDL.DiagramLinkToFactorXID = RCF.FactorXID
                       AND FromDL.ID = FromRCDL.DiagramLinkID
                       AND FromRCDL.ResultsChainID = RCF.ResultsChainID
                      )
                 LEFT JOIN (ResultsChainDiagramLink ToRCDL,
                            v_DiagramLink ToDL
                           )
                   ON (    ToDL.DiagramLinkFromDiagramFactor = RCF.Factor
                       AND ToDL.DiagramLinkFromFactorXID = RCF.FactorXID
                       AND ToDL.ID = ToRCDL.DiagramLinkID
                       AND ToRCDL.ResultsChainID = RCF.ResultsChainID
                      )
        GROUP BY ProjectSummaryID, ResultsChainID, Factor, FactorXID, 
                 FromFactor, FromFactorXID, ToFactor, ToFactorXID
              HAVING FromFactorXID IS NOT NULL OR ToFactorXID IS NOT NULL;


DROP TABLE IF EXISTS ResultsChainHiddenTypes;
CREATE TABLE ResultsChainHiddenTypes
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ResultsChainID INTEGER NOT NULL DEFAULT 0,
 ResultsChainXID INTEGER NOT NULL,
 Code ENUM("Strategy","DraftStrategy","ContributingFactor","DirectThreat","Target",
           "HumanWelfareTarget","Link","Goal","Objective","Indicator","TextBox", "ScopeBox",
           "Stress","Activity","IntermediateResult","ThreatReductionResult","GroupBox"
          ),
 INDEX (ProjectSummaryID,ResultsChainXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ResultsChainID) REFERENCES ResultsChain(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ResultsChainTaggedObjectSet;
CREATE TABLE ResultsChainTaggedObjectSet
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ResultsChainID INTEGER NOT NULL DEFAULT 0,
 ResultsChainXID INTEGER NOT NULL,
 TaggedObjectSetID INTEGER NOT NULL DEFAULT 0,
 TaggedObjectSetXID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,ResultsChainXID),
 INDEX (ProjectSummaryID,TaggedObjectSetXID),
 CONSTRAINT FOREIGN KEY (ResultsChainID) REFERENCES ResultsChain(ID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS PlanningViewConfiguration;
CREATE TABLE PlanningViewConfiguration    -- Objects-29
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Name TEXT,
 DiagramDataInclusion ENUM("AllTypes","IncludeConceptualModelData",
                           "IncludeResultsChainData"
                          ),
 StrategyObjectiveOrder ENUM("ObjectiveContainsStrategy","StrategyContainsObjective"),
 TargetNodePosition ENUM("TargetNodesChildrenOfDiagramObjects",
                         "TargetNodesTopOfPlanningTree"
                        ),
 INDEX (ProjectSummaryID,XID),
 FOREIGN KEY (ProjectSummaryID) References ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS Dashboard;
CREATE TABLE Dashboard                    -- Objects-58
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StatusEntry;
CREATE TABLE StatusEntry
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 DashboardID INTEGER NOT NULL DEFAULT 0,
 DashboardXID INTEGER NOT NULL,
 StatusKey TEXT,
 Progress TINYINT,    -- Vocabulary: 1, 2, 3, 4.
 Comments TEXT,
 INDEX (ProjectSummaryID,XID),
 INDEX (ProjectSummaryID,DashboardXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (DashboardID) REFERENCES Dashboard(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS DashboardFlags;
CREATE TABLE DashboardFlags
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 StatusEntryID INTEGER NOT NULL DEFAULT 0,
 StatusEntryXID INTEGER NOT NULL,
 Code ENUM("NeedsAttention"),
 INDEX (ProjectSummaryID,StatusEntryXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (StatusEntryID) REFERENCES StatusEntry(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ExtraDataSection;
CREATE TABLE ExtraDataSection             -- Objects-5
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 XID INTEGER NOT NULL,
 Owner VARCHAR(255),
 INDEX (ProjectSummaryID,XID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ExtraDataItem;
CREATE TABLE ExtraDataItem
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER NOT NULL,
 ExtraDataSectionID INTEGER NOT NULL DEFAULT 0,
 ExtraDataSectionXID INTEGER NOT NULL,
 Name VARCHAR(255) NOT NULL,
 Value MEDIUMTEXT,
 INDEX (ProjectSummaryID,ExtraDataSectionXID),
 CONSTRAINT FOREIGN KEY (ProjectSummaryID) REFERENCES ProjectSummary(ID),
 CONSTRAINT FOREIGN KEY (ExtraDataSectionID) REFERENCES ExtraDataSection(ID)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


/* Domain Tables from miradi.jar\resources\fieldoptions */
/*
DROP TABLE IF EXISTS Countries;
CREATE TABLE Countries
(Code CHAR(3) PRIMARY KEY,
 Name VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS EcoRegions;
CREATE TABLE EcoRegions
(Code INTEGER PRIMARY KEY,
 Level1 VARCHAR(20),
 Level2 VARCHAR(20),
 Level3 VARCHAR(100),
 Comments VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS StrategyTaxonomies;
CREATE TABLE StrategyTaxonomies
(Code CHAR(7) PRIMARY KEY,
 Level1 VARCHAR(255),
 Level2 Varchar(255),
 Level1_Description VARCHAR(255),
 Level2_Description VARCHAR(255)
 ) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS ThreatTaxonomies;
CREATE TABLE ThreatTaxonomies
(Code CHAR(7) PRIMARY KEY,
 Level1 VARCHAR(255),
 Level2 Varchar(255),
 Level1_Description VARCHAR(255),
 Level2_Description VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
 
 
DROP TABLE IF EXISTS TNCFreshwaterEcoRegionsList;
CREATE TABLE TNCFreshwaterEcoRegionsList
(Code CHAR(5) PRIMARY KEY,
 Name VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
 
 
DROP TABLE IF EXISTS TNCMarineEcoRegionsList;
CREATE TABLE TNCMarineEcoRegionsList
(Code CHAR(5) PRIMARY KEY,
 Name VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
 
 
DROP TABLE IF EXISTS TNCTerrestrialEcoRegionsList;
CREATE TABLE TNCTerrestrialEcoRegionsList
(Code CHAR(5) PRIMARY KEY,
 Name VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
 
 
DROP TABLE IF EXISTS TNCOperatingUnitsList;
CREATE TABLE TNCOperatingUnitsList
(Code CHAR(5) PRIMARY KEY,
 Name VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS WWFLinkToGlobalTargets;
CREATE TABLE WWFLinkToGlobalTargets
(Code CHAR(4) PRIMARY KEY,
 Description VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS WWFManagingOfficesList;
CREATE TABLE WWFManagingOfficesList
(Code CHAR(4) PRIMARY KEY,
 RegionCode CHAR(2),
 RegionName VARCHAR(255),
 Name VARCHAR(255),
 Location2 VARCHAR(255)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS WWFRegionsList;
CREATE TABLE WWFRegionsList
(Code CHAR(2) PRIMARY KEY,
 Name VARCHAR(255),
 Abbr CHAR(3),
 Active BOOLEAN
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


/* Create a table of tables in this database for the import process to know which
   Objects in the imported XML data stream correspond to database tables. This step
   is necessary because information_schema.TABLES is unindexed and cannot be indexed by
   even a root user. 
*/

DROP TABLE IF EXISTS MiradiTables;
CREATE TABLE MiradiTables
(TableName VARCHAR(255),
 TableType CHAR(5)
)
ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO MiradiTables
       SELECT TABLE_NAME, RIGHT(Table_Type,5)
         FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = (SELECT DATABASE());

CREATE INDEX Tbl_IX1 ON MiradiTables(TableName);
ANALYZE TABLE MiradiTables;

           
/* User-Defined Functions */

/* Function RATING()

   Returns the Viability Rating corresponding to the cardinal value passed to it.

   Call syntax: RATING(n) where n is the cardinal value representing a Viability Rating.
*/

DROP FUNCTION IF EXISTS RATING;

DELIMITER //

CREATE FUNCTION RATING (rating TINYINT) RETURNS CHAR(13)
BEGIN
RETURN CASE rating
            WHEN 1 THEN "Poor"
            WHEN 2 THEN "Fair"
            WHEN 3 THEN "Good"
            WHEN 4 THEN "Very Good"
            ELSE NULL
        END;
END;
//

DELIMITER ;


DROP VIEW IF EXISTS v_IndicatorMeasurement;     /* Joins IndicatorMeasurement and Measurement,
                                                   including the RATING() value of Measurement.Rating
                                                   
                                                   Has to follow function RATING(). 
                                                */
CREATE VIEW v_IndicatorMeasurement AS
       SELECT IndicatorID, IndicatorXID, Meas.*, RATING(Rating) AS IndicatorRating
         FROM IndicatorMeasurement Ind, Measurement Meas
        WHERE Meas.ID = Ind.MeasurementID;


/* Function RANK()

   Returns the Threat Rank corresponding to the cardinal value passed to it.

   Call syntax: RANK(n) where n is the cardinal value representing a Viability Rating.
*/

DROP FUNCTION IF EXISTS RANK;

DELIMITER //

CREATE FUNCTION RANK (rank TINYINT) RETURNS CHAR(13)
BEGIN
RETURN CASE rank
            WHEN 1 THEN "Low"
            WHEN 2 THEN "Medium"
            WHEN 3 THEN "High"
            WHEN 4 THEN "Very High"
            ELSE NULL
        END;
END;
//

DELIMITER ;


/* Function KeaTYPE()

   Returns the KEA Type corresponding to the cardinal value passed to it.

   Call syntax: KeaType(n) where n is the cardinal value representing a KEA Type.
*/

DROP FUNCTION IF EXISTS KeaTYPE;

DELIMITER //

CREATE FUNCTION KeaTYPE (KeaType CHAR(2)) RETURNS CHAR(20)
BEGIN
RETURN CASE KeaType
            WHEN "10" THEN "Size"
            WHEN "20" THEN "Condition"
            WHEN "30" THEN "Landscape Context"
            ELSE NULL
        END;
END;
//

DELIMITER ;


/*
   fn_CalcWho.sql

   Function to concatenate multiple Resource_Ids for a Factor into one field.
*/

USE Miradi;

DROP FUNCTION IF EXISTS fn_CalcWho;

DELIMITER //

CREATE FUNCTION fn_CalcWho (fProjectSummaryID INTEGER,fFactor VARCHAR(25),fFactorID INTEGER)
                   RETURNS VARCHAR(255)
BEGIN

DECLARE fResource_Id VARCHAR(255) DEFAULT "";
DECLARE fResource_Ids VARCHAR(255) DEFAULT "";
DECLARE EOF BOOLEAN DEFAULT FALSE;

DECLARE c_who CURSOR FOR
        SELECT Resource_Id
          FROM CalculatedWho Who, ProjectResource Rsrc
         WHERE Rsrc.ID = Who.ProjectResourceID
           AND Who.ProjectSummaryID = fProjectSummaryID
           AND Factor = fFactor
           AND FactorID = fFactorID;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET EOF = TRUE;

OPEN c_who;
WHILE TRUE DO
      FETCH c_who INTO fResource_Id;
      IF EOF THEN RETURN TRIM(TRAILING ", " FROM fResource_Ids); END IF;
      SET fResource_Ids = CONCAT(fResource_Ids,
                                 CASE WHEN fResource_Id IS NULL 
                                      THEN "" ELSE fResource_Id 
                                  END,", "
                                );
END WHILE;
CLOSE c_who;

END;
//

DELIMITER ;


/* fn_StripTags.sql

   Strip formatting tags from a text string.
   Based on http://www.artfulsoftware.com/infotree/queries.php#567.
   
*/

DELIMITER $$ 

DROP FUNCTION IF EXISTS fn_StripTags $$

CREATE FUNCTION fn_StripTags (TextString TEXT) RETURNS TEXT
DETERMINISTIC  
BEGIN 
  DECLARE fStart, fEnd, fLENGTH INTEGER; 
  
  SET fStart = LOCATE( "<", TextString );
  
  IF   fStart > 0 THEN
       SET fEnd = LOCATE( ">", TextString, fStart); 
       SET fLength = fEnd - fStart + 1;
  ELSE SET fEnd = 0, fLength = 0;
  END IF;
  
  WHILE fLength > 0 DO 
        SET TextString = Insert( TextString, fStart, fLength, ""); 
        SET fStart = LOCATE( "<", TextString );
  
        IF   fStart > 0 THEN
             SET fEnd = LOCATE( ">", TextString, fStart); 
             SET fLength = fEnd - fStart + 1;
        ELSE SET fEnd = 0, fLength = 0;
        END IF;
        
  END WHILE; 
  
  RETURN TextString; 
END $$ 

DELIMITER ; 


/*
   fn_ExpenseName _v3.sql

   Function to list all Expense Assignment Names that are associated with a 
   common set of Dimensions (whose IDs are parameters to the function) for
   a particular Factor (e.g. Strategy or Activity).
   
   Designed specifically to support sp_AccountPlan, that reports an
   expense/budget plan by Factor within Account.
   
   Revision History:
   Version 03 - 2012-03-01 - Abandon new view and use exclusive left joins instead. The view 
                             created the risk of Server Error 1267 - Invalid mix of collations.
   Version 02 - 2012-02-29 - Use new view FactorExpense which UNIONs all Factor Expesne Associations.
                           - Limit total length of each Expense Name to 255.
                           - Change delimiter between expense names to ';'.
   Version 01 - 2012-02-28 - Initial Version.
*/

DROP FUNCTION IF EXISTS fn_ExpenseName;

DELIMITER $$

CREATE FUNCTION fn_ExpenseName (fFactor VARCHAR(25), fFactorID INTEGER,
                                fAccountingCodeID INTEGER, fFundingSourceID INTEGER,
                                fBudgetCategoryOneID INTEGER, fBudgetCategoryTwoID INTEGER
                               ) RETURNS TEXT
BEGIN

DECLARE fExpenseName VARCHAR(255) DEFAULT "";
DECLARE fExpenseNames TEXT DEFAULT "";
DECLARE EOF BOOLEAN DEFAULT FALSE;

DECLARE c_Exp CURSOR FOR
        SELECT LEFT(Exp.Name,255)
          FROM ExpenseAssignment Exp 
          
                  LEFT JOIN StrategyExpense StrExp
                    ON StrExp.ExpenseAssignmentID = Exp.ID
                   AND StrExp.StrategyID = fFactorID
                   AND fFactor = "Strategy"
                   
                  LEFT JOIN TaskActivityMethodExpense ActExp
                    ON ActExp.ExpenseAssignmentID = Exp.ID
                   AND ActExp.TaskActivityMethodID = fFactorID
                   AND fFactor IN ("Task","Activity","Method")
                   
                  LEFT JOIN IndicatorExpense IndExp
                    ON IndExp.ExpenseAssignmentID = Exp.ID
                   AND IndExp.IndicatorID = fFactorID
                   AND fFactor = "Indicator"
                   
         WHERE Exp.AccountingCodeID <=> fAccountingCodeId 
           AND Exp.FundingSourceID <=> fFundingSourceId 
           AND Exp.BudgetCategoryOneID <=> fBudgetCategoryOneId 
           AND Exp.BudgetCategoryTwoID <=> fBudgetCategoryTwoId
           AND CASE WHEN fFactor = "Strategy" THEN StrategyID
                    WHEN fFactor IN ("Task","Activity","Method") THEN TaskActivityMethodID
                    WHEN fFactor = "Indicator" THEN IndicatorID
                END = fFactorID;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET EOF = TRUE;

OPEN c_Exp;
WHILE TRUE DO
      FETCH c_Exp INTO fExpenseName;
      IF EOF THEN RETURN TRIM(TRAILING "; " FROM fExpenseNames); END IF;
      SET fExpenseNames = CONCAT(fExpenseNames,fExpenseName,"; ");
END WHILE;

END $$

DELIMITER ;

/*
   sp_DeleteProject_v2.sql

   Delete entire projects from the Miradi database by ProjectSummaryID.
   
   CALL sp_DeleteProject(nn), where nn = ProjectSummaryID.
   
   If you specify ProjectSummaryID = 0, all projects will be deleted!

   Developed by David Berg for The Nature Conservancy.

   Revision History:
   Version 02 - 2011-11-09 - Add table MiradiColumns to exclusion list.
   Version 01 - 2010-12-27 - Initial Version.
*/

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_DeleteProject $$
CREATE PROCEDURE sp_DeleteProject (pProjectSummaryID INTEGER)

BEGIN

      DECLARE pTableName VARCHAR(255);      -- Table whose rows are being deleted.
      DECLARE EOF BOOLEAN DEFAULT FALSE;

      /* Cursor to select each table name from the Table Catalog. */

      DECLARE c_Table CURSOR FOR
              SELECT TABLE_NAME
                FROM information_schema.TABLES
               WHERE TABLE_SCHEMA = DATABASE()
                 AND TABLE_TYPE = "BASE TABLE"
                 AND TABLE_NAME NOT IN ("ProjectID","MiradiTables","MiradiColumns","XMPZSchema");

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET EOF = TRUE;

      OPEN c_Table;
      WHILE NOT EOF DO
            FETCH c_Table INTO pTableName;
            IF NOT EOF
               THEN SET @SQLStmt =
                           CONCAT("DELETE FROM ",pTableName, " WHERE ",
                                  CASE WHEN pProjectSummaryID = 0
                                       THEN "TRUE"
                                       ELSE CONCAT(CASE WHEN pTableName = "ProjectSummary"
                                                        THEN "ID = "
                                                        ELSE "ProjectSummaryID = "
                                                    END,
                                                   pProjectSummaryID
                                                  )
                                   END
                                 );
                     PREPARE SQLStmt FROM @SQLStmt;
                     EXECUTE SQLStmt;
            END IF;
      END WHILE;

END $$

DELIMITER ;

-- END
