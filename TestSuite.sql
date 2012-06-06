/*
   TestSuite_v10.sql
   
   Test Suite for the Miradi Database.

   Each query reports the data items found on one particular Miradi screen/window/tab/view/box.

   This file is a work-in-progress. Additions will be released as they are developed.

   Developed by David Berg for The Nature Conservancy 
        and the Greater Conservation Community.
   
   Revision History:
   Version 10 - 2012-02-18 - Revised view names in accordance with Miradi Database V44 changes.
   Version 9a - 2011-09-26 - Corrected joins to TaggedObjectSetFactor.
   Version 09 - 2011-09-06 - Changed corresponding with those documented for Database V 42a.
   Version 08 - 2011-08-24 - Changes corresponding with those documented for Database V 41 
                             and import procedures V 49.
   Version 07 - 2011-07-21 - Rename FactorType to Factor everywhere except Target and Result. 
   Version 06 - 2011-07-11 - Remove Draft Strategies and Indicators associated with 
                             Draft Strategies from work plans and work plan aggregations.
                           - A myriad of other fixes and enhancements.
*/

USE Miradi;

/* Project Summary */

#DROP VIEW IF EXISTS vSummaryProject;
#CREATE VIEW vSummaryProject AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,
       CASE WHEN ShareOutsideOrganization = TRUE THEN "Yes" ELSE "No" END AS DataSharing,
       ProjectLanguage,DataEffectiveDate,OtherOrgProjectNumber,OtherOrgRelatedProjects,
       ProjectURL,ProjectDescription,ProjectStatus,NextSteps,
       RANK(OverallProjectThreatRating) AS OverallThreatRank,
       RATING(OverallProjectViabilityRating) AS OverallViabilityRating,ThreatRatingMode
  FROM ProjectSummary Summ, ExternalProjectID PID
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
 ORDER BY ProjectSummaryID DESC;


/* Project Team Summary */

#DROP VIEW IF EXISTS vSummaryTeam;
#CREATE VIEW vSummaryTeam AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,
       GivenName,Surname,Resource_ID,Organization,Position,
       Location,Email,OfficePhoneNumber
  FROM ProjectSummary Summ, ExternalProjectID PID, ProjectResource Rsrc
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Rsrc.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,GivenName,Surname;


/* Project Team Detail */

#DROP VIEW IF EXISTS vSummaryTeamMember;
#CREATE VIEW vSummaryTeamMember AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,GivenName,Surname,
       CONCAT(LEFT(GivenName,1),LEFT(Surname,1)) AS Initials,Code AS Role,Organization,
       Position,Location,OfficePhoneNumber,PhoneNumberHome,PhoneNumberMobile,PhoneNumberOther,
       Email,AlternativeEmail,IMAddress,IMService,DateUpdated,Comments,Custom1,Custom2
  FROM ProjectSummary Summ, ExternalProjectID PID, ProjectResource Rsrc,
       ProjectResourceRoleCodes Code
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Code.ProjectResourceID = Rsrc.ID
   AND Rsrc.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,GivenName,Surname;


/* Project Summary - Organizations */

#DROP VIEW IF EXISTS vSummaryOtherOrgs;
#CREATE VIEW vSummaryOtherOrgs AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Organization_ID,Name,
       RolesDescription,GivenName,Surname,Email,PhoneNumber,Comments
  FROM ProjectSummary Summ, ExternalProjectID PID, Organization Org
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Org.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,Name;


/* Project Summary - Scope - Scope and Vision */

#DROP VIEW IF EXISTS vSummaryScopeScope;
#CREATE VIEW vSummaryScopeScope AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,ShortProjectScope,
       ProjectScope,ProjectVision,ScopeComments,Box.Name AS ScopeBoxName,
       Box.Details AS ScopeBoxDetails,
       TRIM(LEADING "." FROM
       CONCAT(CASE WHEN CM.ConceptualModel_Id IS NOT NULL
                  THEN CONCAT(CM.ConceptualModel_Id,". ")
                  ELSE ""
               END,
              CASE WHEN CM.Name IS NOT NULL THEN CM.Name ELSE "" END
             )
           ) AS ConceptualModels,
       TRIM(LEADING "." FROM
       CONCAT(CASE WHEN RC.ResultsChain_Id IS NOT NULL THEN CONCAT(RC.ResultsChain_Id,". ") ELSE "" END,
              CASE WHEN RC.Name IS NOT NULL THEN RC.Name ELSE "" END
             )
           ) AS ResultsChains
  FROM ProjectSummary Summ, ExternalProjectID PID,
       ProjectScope Scope
          LEFT JOIN (ScopeBox Box, DiagramFactor Diag)
                 ON (    Diag.ProjectSummaryID = Box.ProjectSummaryID
                     AND Diag.WrappedByDiagramFactorXID = Box.XID
                     AND Box.ProjectSummaryID = Scope.ProjectSummaryID
                    )
          LEFT JOIN (ConceptualModelDiagramFactor CMFctr, ConceptualModel CM)
                 ON (    CM.ID = CMFctr.ConceptualModelID
                     AND CMFctr.DiagramFactorID = Diag.ID
                    )
          LEFT JOIN (ResultsChainDiagramFactor RCFctr, ResultsChain RC)
                 ON (    RC.ID = RCFctr.ResultsChainID
                     AND RCFctr.DiagramFactorID = Diag.ID
                    )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Scope.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,CM.ID,RC.ID;


/* Project Summary - Scope - Biodiversity */

#DROP VIEW IF EXISTS vSummaryScopeBiodiversity;
#CREATE VIEW vSummaryScopeBiodiversity AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,ProjectArea,ProjectAreaNote
  FROM ProjectSummary Summ, ExternalProjectID PID,ProjectScope Scope
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Scope.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC;


/* Project Summary - Scope - IUCN Redlist */

#DROP VIEW IF EXISTS vSummaryScopeIUCN;
#CREATE VIEW vSummaryScopeIUCN AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,XID,Name
  FROM ProjectSummary Summ, ExternalProjectID PID,IUCNRedListSpecies Red
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Red.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,Name;


/* Project Summary - Scope - Other Notable Species */

#DROP VIEW IF EXISTS vSummaryScopeOther;
#CREATE VIEW vSummaryScopeOther AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,XID,Name
  FROM ProjectSummary Summ, ExternalProjectID PID,OtherNotableSpecies Othr
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Othr.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,Name;


/* Project Summary - Scope - Human Stakeholders */

#DROP VIEW IF EXISTS vSummaryScopeHuman;
#CREATE VIEW vSummaryScopeHuman AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,HumanPopulation,
       HumanPopulationNotes,SocialContext
  FROM ProjectSummary Summ, ExternalProjectID PID,ProjectScope Scope
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Scope.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC;


/* Project Summary - Scope - Protected Areas */

#DROP VIEW IF EXISTS vSummaryScopeProtected;
#CREATE VIEW vSummaryScopeProtected AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Code,LegalStatus,
       LegislativeContext,PhysicalDescription,BiologicalDescription,
       SocioEconomicInformation,HistoricalDescription,CulturalDescription,
       AccessInformation,VisitationInformation,CurrentLandUses,ManagementResources
  FROM ProjectSummary Summ,
       ProjectScope Scope
          LEFT JOIN ProtectedAreaCategories Area
            ON Area.ProjectScopeID = Scope.ID,
       ExternalProjectID PID
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Scope.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,Area.ID;


/* Project Summary - Location */

#DROP VIEW IF EXISTS vSummaryLocation;
#CREATE VIEW vSummaryLocation AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Latitude,Longitude,
       Code AS Country,StateAndProvinces,Municipalities, LegislativeDistricts,LocationDetail,
       SiteMapReference,LocationComments
  FROM ProjectSummary Summ,
       ProjectLocation Loc
          LEFT JOIN GeospatialLocation Geo
            ON Geo.ProjectLocationID = Loc.ID
          LEFT JOIN ProjectCountries Cntry
            ON Cntry.ProjectLocationID = Loc.ID,
       ExternalProjectID PID
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Loc.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC;


/* Project Summary - Planning - Work Plan */

#DROP VIEW IF EXISTS vSummaryPlanningWork;
#CREATE VIEW vSummaryPlanningWork AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,StartDate,ExpectedEndDate,
       WorkPlanStartDate,WorkPlanEndDate,FiscalYearStart,DiagramDataInclusion,
       FullTimeEmployeeDaysPerYear AS "FTE Days per Year",QuarterColumnsVisibility,
       PlanningComments
  FROM ProjectSummary Summ, ExternalProjectID PID, ProjectPlanning Plan,
       PlanningViewConfiguration Config
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Config.ProjectSummaryId = Plan.ProjectSummaryID
   AND Plan.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC;


/* Project Summary - Planning - Financial Plan */

#DROP VIEW IF EXISTS vSummaryPlanningFinancial;
#CREATE VIEW vSummaryPlanningFinancial AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,CurrencyType,CurrencySymbol,
       CurrencyDecimalPlaces,TotalBudgetForFunding,BudgetSecuredPercent,
       KeyFundingSources,FinancialComments
  FROM ProjectSummary Summ, ExternalProjectID PID, ProjectPlanning Plan
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Plan.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC;


/* Project Summary - Planning View Configuration */

#DROP VIEW IF EXISTS vSummaryPlanningView;
#CREATE VIEW vSummaryPlanningView AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Name,DiagramDataInclusion,
       StrategyObjectiveOrder,TargetNodePosition
  FROM ProjectSummary Summ, ExternalProjectID PID, PlanningViewConfiguration Config
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Config.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Name;


/* Project Summary - TNC */

#DROP VIEW IF EXISTS vSummaryTNC;
#CREATE VIEW vSummaryTNC AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,DatabaseDownloadDate,
       TNC.OtherOrgRelatedProjects,Place.Code AS PlaceType,Prior.Code AS OrgPriority,
       PlanningTeamComments,ConProParentChildProjectText,OU.Code AS OperatingUnit,
       Terr.Code AS TerrestrialEcoregion,Marine.Code AS MarineEcoregion,
       Fresh.Code AS FreshwaterEcoregion,LessonsLearned,ProjectResourcesScorecard,
       ProjectLevelComments,ProjectCitations,CAPStandardsScorecard
  FROM ProjectSummary Summ,ExternalProjectID PID,
       TNCProjectData TNC
          LEFT JOIN TNCOrganizationalPriorities Prior
            ON Prior.TNCProjectDataID = TNC.ID
          LEFT JOIN TNCProjectPlaceTypes Place
            ON Place.TNCProjectDataID = TNC.ID
          LEFT JOIN TNCMarineEcoregion Marine
            ON Marine.TNCProjectDataID = TNC.ID
          LEFT JOIN TNCTerrestrialEcoregion Terr
            ON Terr.TNCProjectDataID = TNC.ID
          LEFT JOIN TNCFreshwaterEcoregion Fresh
            ON Fresh.TNCProjectDataID = TNC.ID
          LEFT JOIN TNCOperatingUnits OU
            ON OU.TNCProjectDataID = TNC.ID
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND TNC.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC;


/* Target Summary (Target Factor Window) */

#DROP VIEW IF EXISTS vTargetSummary;
#CREATE VIEW vTargetSummary AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus),Tgt.Details,CurrentStatusJustification,
       SpeciesLatinName,Code AS HabitatAssociation, CM.Name AS "CM Pages", RC.Name AS "RC Pages",
       Tag.Name AS Tags
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN TargetHabitatAssociation TgtHab
                 ON TgtHab.TargetID = Tgt.ID

          LEFT JOIN (DiagramFactor DF, ConceptualModelDiagramFactor CMDF, ConceptualModel CM)
                 ON (    CM.ID = CMDF.ConceptualModelID
                     AND CMDF.DiagramFactorID = DF.ID
                     AND DF.ProjectSummaryID = Tgt.ProjectSummaryID
                     AND DF.WrappedByDiagramFactor LIKE "%Target"
                     AND DF.WrappedByDiagramFactorXID = Tgt.XID
                    )

          LEFT JOIN (DiagramFactor DF2, ResultsChainDiagramFactor RCDF, ResultsChain RC)
                 ON (    RC.ID = RCDF.ResultsChainID
                     AND RCDF.DiagramFactorID = DF2.ID
                     AND DF2.ProjectSummaryID = Tgt.ProjectSummaryID
                     AND DF2.WrappedByDiagramFactor LIKE "%Target"
                     AND DF2.WrappedByDiagramFactorXID = Tgt.XID
                    )

          LEFT JOIN (TaggedObjectSetFactor TF, TaggedObjectSet Tag)
                 ON (    Tag.ID = TF.ID
                     AND TF.ProjectSummaryID = Tgt.ProjectSummaryID
                     AND TF.WrappedByDiagramFactor LIKE "%Target"
                     AND TF.WrappedByDiagramFactorXID = Tgt.XID
                    )

 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Name;


/* Target Goals (Target Factor Window) */

#DROP VIEW IF EXISTS vTargetGoals;
#CREATE VIEW vTargetGoals AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus),Goal_Id,Goal.Name,
       Goal.Details,Tgt.Name AS AssocTarget,Thr.Name AS RelatedThreats,
       TRIM(LEADING "." FROM
       CONCAT(CASE WHEN Ind.Indicator_Id IS NOT NULL THEN Ind.Indicator_Id ELSE "" END,". ",
              CASE WHEN Ind.Name IS NOT NULL THEN Ind.Name ELSE "" END
             )
       ) AS Indicators,
       TRIM(LEADING "." FROM
       CONCAT(CASE WHEN Str.Strategy_Id IS NOT NULL THEN Str.Strategy_Id ELSE "" END,". ",
              CASE WHEN Str.Name IS NOT NULL THEN Str.Name ELSE "" END
             )
       ) AS RelatedStrategies,
       TRIM(LEADING "." FROM
       CONCAT(CASE WHEN Act.Activity_Id IS NOT NULL THEN Act.Activity_Id ELSE "" END,". ",
              CASE WHEN Act.Name IS NOT NULL THEN Act.Name ELSE "" END
             )
       ) AS RelatedActivities,Goal.Comments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          JOIN (TargetGoal TgGl, Goal)
            ON (    Goal.ID = TgGl.GoalID
                AND TgGl.TargetID = Tgt.ID
               )
          LEFT JOIN (ThreatTarget ThrTgt, Threat Thr)
                 ON (    Thr.ID = ThrTgt.ThreatID
                     AND ThrTgt.TargetID = TgGl.TargetID
                    )
          LEFT JOIN (GoalRelevantStrategy GlStr, Strategy Str)
                 ON (    Str.ID = GlStr.StrategyID
                     AND GlStr.GoalID = TgGl.GoalID
                     AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
                    )
          LEFT JOIN (GoalRelevantIndicator GlInd, Indicator Ind)
                 ON (    Ind.ID = GlInd.IndicatorID
                     AND GlInd.GoalID = TgGl.GoalID
                     AND Ind.IsActive = TRUE
                    )
          LEFT JOIN (GoalRelevantActivity GlAct, Activity Act)
                 ON (    Act.ID = GlAct.ActivityID
                     AND GlAct.GoalID = TgGl.GoalID
                    )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY Summ.ID,Tgt.Name,Goal.Name;


/* Target Viability Indicator Pane (Target Factor Window) */

#DROP VIEW IF EXISTS vTargetViabilityIndicator;
#CREATE VIEW vTargetViabilityIndicator AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       KeyEcologicalAttribute_Id,KEA.Name AS "KEA Name",KEA.Details AS "KEA Details",
       CASE WHEN TgtKea.ID IS NOT NULL THEN KeaType(KEA.KeyEcologicalAttributeType) END AS "Type",
       KEA.Comments AS "KEA Comments",
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.Indicator_id ELSE Ind2.Indicator_Id
        END AS Indicator_Id,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Name ELSE Ind2.Name END AS IndName,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Details ELSE Ind2.Details END AS IndDetails,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Comments ELSE Ind2.Comments END AS IndComments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN (TargetIndicator TgtInd, Indicator Ind1)
                 ON (    Ind1.ID = TgtInd.IndicatorID
                     AND TgtInd.TargetID = Tgt.ID
                     AND Tgt.ViabilityMode = "Simple"
                     AND Ind1.IsActive = TRUE
                    )
          LEFT JOIN (v_TargetKEA TgtKea, KeyEcologicalAttribute KEA)
                 ON (    KEA.ID = TgtKea.KEAID
                     AND TgtKea.TargetID = Tgt.ID
                     AND Tgt.ViabilityMode = "KEA"
                    )
          LEFT JOIN (v_KEAIndicator KeaInd, Indicator Ind2)
                 ON (    Ind2.ID = KeaInd.IndicatorID
                     AND KeaInd.KEAID = KEA.ID
                     AND Ind2.IsActive = TRUE
                    )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectId,Tgt.Name,KEA.Name,Ind1.Name,Ind2.Name;


/* Target Viability Summary Pane and Measurement Pane (Target Factor Window) */

#DROP VIEW IF EXISTS vTargetViabilityMeasurement;
#CREATE VIEW vTargetViabilityMeasurement AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name AS TgtName,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       KeyEcologicalAttribute_Id,KEA.Name AS "KEA Name",KEA.Details AS "KEA Details",
       CASE WHEN TgtKea.ID IS NOT NULL THEN KeaType(KEA.KeyEcologicalAttributeType) END AS "Type",
       KEA.Comments AS "KEA Comments",
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.Indicator_id ELSE Ind2.Indicator_Id
        END AS Indicator_Id,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Name ELSE Ind2.Name END AS IndName,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Details ELSE Ind2.Details END AS IndDetails,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Comments ELSE Ind2.Comments END AS IndComments,
       CASE WHEN Meas.ID IS NOT NULL THEN Meas.Date ELSE Meas2.Date END AS MeasDate,
       CASE WHEN Meas.ID IS NOT NULL
            THEN Meas.MeasurementValue ELSE Meas2.MeasurementValue
        END AS MeasValue,
       CASE WHEN Meas.ID IS NOT NULL
            THEN RATING(Meas.Rating) ELSE RATING(Meas2.Rating)
        END AS MeasRating,
       CASE WHEN Meas.ID IS NOT NULL THEN Meas.Trend ELSE Meas2.Trend END AS MeasTrend,
       CASE WHEN Meas.ID IS NOT NULL THEN Meas.Source ELSE Meas2.Source END AS MeasSource,
       CASE WHEN Meas.ID IS NOT NULL THEN Meas.Detail ELSE Meas2.Detail END AS MeasDetail,
       CASE WHEN Meas.ID IS NOT NULL THEN Meas.Comments ELSE Meas2.Comments END AS MeasComments

  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN (TargetIndicator TgtInd, Indicator Ind1)
                 ON (    Ind1.ID = TgtInd.IndicatorID
                     AND TgtInd.TargetID = Tgt.ID
                     AND Tgt.ViabilityMode = "Simple"
                    )
          LEFT JOIN (IndicatorMeasurement IndMeas, Measurement Meas)
                 ON (    Meas.ID = IndMeas.MeasurementID
                     AND IndMeas.IndicatorID = Ind1.ID
                    )
          LEFT JOIN (v_TargetKEA TgtKea, KeyEcologicalAttribute KEA)
                 ON (    KEA.ID = TgtKea.KEAID
                     AND TgtKea.TargetID = Tgt.ID
                     AND Tgt.ViabilityMode = "KEA"
                    )
          LEFT JOIN (v_KEAIndicator KeaInd, Indicator Ind2)
                 ON (    Ind2.ID = KeaInd.IndicatorID
                     AND KeaInd.KeaID = KEA.ID
                    )
          LEFT JOIN (IndicatorMeasurement IndMeas2, Measurement Meas2)
                 ON (    Meas2.ID = IndMeas2.MeasurementID
                     AND IndMeas2.IndicatorID = Ind2.ID
                    )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID

 UNION ALL

SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       KeyEcologicalAttribute_Id,KEA.Name AS "KEA Name",KEA.Details AS "KEA Details",
       CASE WHEN TgtKea.ID IS NOT NULL THEN KeaType(KEA.KeyEcologicalAttributeType) END AS "Type",
       KEA.Comments AS "KEA Comments",
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.Indicator_id ELSE Ind2.Indicator_Id
        END AS Indicator_Id,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Name ELSE Ind2.Name END AS IndName,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Details ELSE Ind2.Details END AS IndDetails,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Comments ELSE Ind2.Comments END AS IndComments,
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.FutureStatusDate ELSE Ind2.FutureStatusDate
        END AS MeasDate,
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.FutureStatusSummary ELSE Ind2.FutureStatusSummary
        END AS MeasValue,
       CASE WHEN Ind1.ID IS NOT NULL
            THEN RATING(Ind1.FutureStatusRating) ELSE RATING(Ind2.FutureStatusRating)
        END AS MeasRating, NULL AS MeasTrend, NULL AS MeasSource,
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.FutureStatusDetails ELSE Ind2.FutureStatusDetails
        END AS MeasDetail,
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.FutureStatusComments ELSE Ind2.FutureStatusComments
        END AS MeasComments

  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN (TargetIndicator TgtInd, Indicator Ind1)
                 ON (    Ind1.ID = TgtInd.IndicatorID
                     AND TgtInd.TargetID = Tgt.ID
                     AND ViabilityMode = "Simple"
                    )
          LEFT JOIN (IndicatorMeasurement IndMeas, Measurement Meas)
                 ON (    Meas.ID = IndMeas.MeasurementID
                     AND IndMeas.IndicatorID = Ind1.ID
                    )
          LEFT JOIN (v_TargetKEA TgtKea, KeyEcologicalAttribute KEA)
                 ON (    KEA.ID = TgtKea.KEAID
                     AND TgtKea.TargetID = Tgt.ID
                     AND ViabilityMode = "KEA"
                    )
          LEFT JOIN (v_KEAIndicator KeaInd, Indicator Ind2)
                 ON (    Ind2.ID = KeaInd.IndicatorID
                     AND KeaInd.KeaID = KEA.ID
                    )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectId,TgtName,"Kea Name",IndName,MeasDate;


/* Target Viability Ratings Thresholds (Target Factor Window) */

#DROP VIEW IF EXISTS vTargetViabilityRatings;
#CREATE VIEW vTargetViabilityRatings AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       KeyEcologicalAttribute_Id, KEA.Name AS "KEA Name",KeaType(KEA.KeyEcologicalAttributeType) AS "KEA Type",
       Ind.Indicator_Id,Ind.Name AS IndicatorName,
       RATING(StatusCode) AS Rating, ThresholdValue, ThresholdDetails,
       RatingSource,ViabilityRatingsComments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN (v_TargetKEA TgtKea, KeyEcologicalAttribute KEA)
                 ON (    KEA.ID = TgtKEA.KEAID
                     AND TgtKea.TargetID = Tgt.ID
                    )
          LEFT JOIN (v_KEAIndicator KEAInd, Indicator Ind)
                 ON (    Ind.ID = KEAInd.IndicatorID
                     AND KEAInd.KEAID = KEA.ID
                     AND Ind.IsActive = TRUE
                    )
          LEFT JOIN IndicatorThreshold Thresh
                 ON Thresh.IndicatorID = Ind.ID

 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
   AND Tgt.ViabilityMode = "KEA"
 ORDER BY ProjectId,Tgt.Name,KEA.Name,Ind.Name,StatusCode;



/* Target Viability Indicator Monitoring Summary (Target Factor Window) */

#DROP VIEW IF EXISTS vTargetViabilityMonitoring;
#CREATE VIEW vTargetViabilityMonitoring AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       KeyEcologicalAttribute_Id, KEA.Name AS "KEA Name",
       KeaType(KEA.KeyEcologicalAttributeType) AS "KEA Type",
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.Indicator_id ELSE Ind2.Indicator_Id
        END AS Indicator_Id,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Name ELSE Ind2.Name END AS IndicatorName,
       CASE WHEN Meth1.ID IS NOT NULL THEN Meth1.Method_Id ELSE Meth2.Method_Id END AS Method_Id,
       CASE WHEN Meth1.ID IS NOT NULL THEN Meth1.Name ELSE Meth2.Name END AS Name,
       CASE WHEN Meth1.ID IS NOT NULL THEN Meth1.Details ELSE Meth2.Details END AS Details,
       CASE WHEN Meth1.ID IS NOT NULL THEN Meth1.Comments ELSE Meth2.Comments END AS Comments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN (TargetIndicator TgtInd, Indicator Ind1)
                 ON (    Ind1.ID = TgtInd.IndicatorID
                     AND TgtInd.TargetID = Tgt.ID
                     AND ViabilityMode = "Simple"
                    )
          LEFT JOIN (IndicatorMethod IndMeth1, Method Meth1)
                 ON (    Meth1.ID = IndMeth1.MethodID
                     AND IndMeth1.IndicatorID = Ind1.ID
                     AND Ind1.IsActive = TRUE
                    )
           LEFT JOIN (v_TargetKEA TgtKea, KeyEcologicalAttribute KEA)
                 ON (    KEA.ID = TgtKEA.KEAID
                     AND TgtKea.TargetID = Tgt.ID
                     AND ViabilityMode = "KEA"
                    )
          LEFT JOIN (v_KEAIndicator KEAInd, Indicator Ind2)
                 ON (    Ind2.ID = KEAInd.IndicatorID
                     AND KEAInd.KEAID = KEA.ID
                     AND Ind2.IsActive = TRUE
                    )
          LEFT JOIN (IndicatorMethod IndMeth2, Method Meth2)
                 ON (    Meth2.ID = IndMeth2.MethodID
                     AND IndMeth2.IndicatorID = Ind2.ID
                     AND Ind2.IsActive = TRUE
                    )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectId,Tgt.Name,KEA.Name,IndicatorName;



/* Target Viability Progress (Target Factor Window) */

#DROP VIEW IF EXISTS vTargetViabilityProgress;
#CREATE VIEW vTargetViabilityProgress AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       KeyEcologicalAttribute_Id, KEA.Name AS "KEA Name",
       KeaType(KEA.KeyEcologicalAttributeType) AS "KEA Type",
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.Indicator_id ELSE Ind2.Indicator_Id
        END AS Indicator_Id,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Name ELSE Ind2.Name END AS IndicatorName,
       DATE(CASE WHEN Prog1.ID IS NOT NULL THEN Prog1.ProgressDate ELSE Prog2.ProgressDate END)
            AS ProgressDate,
       CASE WHEN Prog1.ID IS NOT NULL THEN Prog1.Details ELSE Prog2.Details END
            AS ProgressDetails,
       CASE WHEN Prog1.ID IS NOT NULL THEN Prog1.ProgressStatus ELSE Prog2.ProgressStatus END
            AS ProgressStatus
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN (TargetIndicator TgtInd, Indicator Ind1)
                 ON (    Ind1.ID = TgtInd.IndicatorID
                     AND TgtInd.TargetID = Tgt.ID
                     AND ViabilityMode = "Simple"
                    )
          LEFT JOIN (IndicatorProgressReport IndPrg1, ProgressReport Prog1)
                 ON (    Prog1.ID = IndPrg1.ProgressReportID
                     AND IndPrg1.IndicatorID = Ind1.ID
                     AND Ind1.IsActive = TRUE
                    )
          LEFT JOIN (v_TargetKEA TgtKea, KeyEcologicalAttribute KEA)
                 ON (    KEA.ID = TgtKEA.KEAID
                     AND TgtKea.TargetID = Tgt.ID
                     AND ViabilityMode = "KEA"
                    )
          LEFT JOIN (v_KEAIndicator KEAInd2, Indicator Ind2)
                 ON (    Ind2.ID = KEAInd2.IndicatorID
                     AND KEAInd2.KEAID = KEA.ID
                     AND Ind2.IsActive = TRUE
                    )
          LEFT JOIN (IndicatorProgressReport IndPrg2, ProgressReport Prog2)
                 ON (    Prog2.ID = IndPrg2.ProgressReportID
                     AND IndPrg2.IndicatorID = Ind2.ID
                     AND Ind2.IsActive = TRUE
                    )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectId,Tgt.Name,KEA.Name,IndicatorName;


/* Target Viability Desired Value & Status (Target Factor Window) */

#DROP VIEW IF EXISTS vTargetViabilityDesired;
#CREATE VIEW vTargetViabilityDesired AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       KeyEcologicalAttribute_Id, KEA.Name AS "KEA Name",
       KeaType(KEA.KeyEcologicalAttributeType) AS "KEA Type",
       CASE WHEN Ind1.ID IS NOT NULL
            THEN Ind1.Indicator_id ELSE Ind2.Indicator_Id
        END AS Indicator_Id,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Name ELSE Ind2.Name END AS IndicatorName,
       DATE(CASE WHEN Ind1.ID IS NOT NULL 
                 THEN Ind1.FutureStatusDate ELSE Ind2.FutureStatusDate
             END
           ) AS FutureStatusDate,
       CASE WHEN Ind1.ID IS NOT NULL 
            THEN Ind1.FutureStatusSummary ELSE Ind2.FutureStatusSummary
        END AS DesiredValue,
       RATING(CASE WHEN Ind1.ID IS NOT NULL 
                   THEN Ind1.FutureStatusRating ELSE Ind2.FutureStatusRating
               END
             ) AS DesiredRating,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.FutureStatusDetails ELSE Ind2.FutureStatusDetails END
            AS FutureStatusDetails,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.FutureStatusComments ELSE Ind2.FutureStatusComments END
            AS FutureStatusComments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN (TargetIndicator TgtInd, Indicator Ind1)
                 ON (    Ind1.ID = TgtInd.IndicatorID
                     AND TgtInd.TargetID = Tgt.ID
                     AND ViabilityMode = "Simple"
                    )
          LEFT JOIN (v_TargetKEA TgtKea, KeyEcologicalAttribute KEA)
                 ON (    KEA.ID = TgtKEA.KEAID
                     AND TgtKea.TargetID = Tgt.ID
                     AND ViabilityMode = "KEA"
                    )
          LEFT JOIN (v_KEAIndicator KEAInd2, Indicator Ind2)
                 ON (    Ind2.ID = KEAInd2.IndicatorID
                     AND KEAInd2.KEAID = KEA.ID
                     AND Ind2.IsActive = TRUE
                    )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectId,Tgt.Name,KEA.Name,IndicatorName;


/* Target Stress Details */

#DROP VIEW IF EXISTS vTargetStressDetails;
#CREATE VIEW vTargetStressDetails AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       Stress_Id,Stress.Name AS StressName,Stress.Details AS StressDetails,
       RANK(Scope) AS Scope,RANK(Severity) AS Severity,RANK(StressRating) AS Magnitude
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt, TargetStress AS TgtStr, Stress
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Stress.ID = TgtStr.StressID
   AND TgtStr.TargetID = Tgt.ID
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,Tgt.Name,Stress.Name;


/* Target Stress Comments */

#DROP VIEW IF EXISTS vTargetStressComments;
#CREATE VIEW vTargetStressComments AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       Stress_Id,Stress.Comments AS StressComments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt, TargetStress AS TgtStr, Stress
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Stress.ID = TgtStr.StressID
   AND TgtStr.TargetID = Tgt.ID
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC,Tgt.Name,Stress.Name;


/* Nested Targets */

#DROP VIEW IF EXISTS vTargetNested;
#CREATE VIEW vTargetNested AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Target_Id,
       Tgt.Name,ViabilityMode,RATING(ViabilityStatus) AS "Viab Rating",
       SubTarget_Id,Sub.Name AS "Nested Target Name",Sub.Details AS "Nested Target Details"
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt, TargetSubTarget AS TgtSub, SubTarget Sub
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
   AND Sub.ID = TgtSub.SubTargetID
   AND TgtSub.TargetID = Tgt.ID
 ORDER BY ProjectSummaryID DESC,Tgt.Name,Sub.Name;


/* Cause (& Threat) Summary */

#DROP VIEW IF EXISTS vCauseSummary;
#CREATE VIEW vCauseSummary AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Cause_Id,Cs.Name,
       CASE WHEN IsDirectThreat = TRUE THEN "Threat" END AS Threat, Cs.Comments,
       Cs.Details,StandardClassification,CM.Name AS "CM Pages",
       RC.Name AS "RC Pages",Tag.Name AS Tags
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Cause Cs
          LEFT JOIN (DiagramFactor DF, ConceptualModelDiagramFactor CMDF, ConceptualModel CM)
                 ON (    CM.ID = CMDF.ConceptualModelID
                     AND CMDF.DiagramFactorID = DF.ID
                     AND DF.ProjectSummaryID = Cs.ProjectSummaryID
                     AND DF.WrappedByDiagramFactor = "Cause"
                     AND DF.WrappedByDiagramFactorXID = Cs.XID
                    )

          LEFT JOIN (DiagramFactor DF2, ResultsChainDiagramFactor RCDF, ResultsChain RC)
                 ON (    RC.ID = RCDF.ResultsChainID
                     AND RCDF.DiagramFactorID = DF2.ID
                     AND DF2.ProjectSummaryID = Cs.ProjectSummaryID
                     AND DF2.WrappedByDiagramFactor = "Cause"
                     AND DF2.WrappedByDiagramFactorXID = Cs.XID
                    )

          LEFT JOIN (TaggedObjectSetFactor TF, TaggedObjectSet Tag)
                 ON (    Tag.ID = TF.ID
                     AND TF.ProjectSummaryID = Cs.ProjectSummaryID
                     AND TF.WrappedByDiagramFactor = "Cause"
                     AND TF.WrappedByDiagramFactorXID = Cs.XID
                   )

 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Cs.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Name;


/* Cause (& Threat) Comments */

#DROP VIEW IF EXISTS vCauseComments;
#CREATE VIEW vCauseComments AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Cause_Id,Cs.Name,
       CASE WHEN IsDirectThreat = TRUE THEN "Threat" END AS Threat, Cs.Comments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Cause Cs
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Cs.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Name;


/* Result Summary */

#DROP VIEW IF EXISTS vResultSummary;
#CREATE VIEW vResultSummary AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Result_Id,Rslt.Name,
       Rslt.FactorType,Thr.Name AS "Threat Name",Rslt.Comments,Rslt.Details,
       CONCAT(CASE WHEN CM.ConceptualModel_Id IS NULL
                   THEN "" ELSE CONCAT(CM.ConceptualModel_Id,". ")
               END,
              CASE WHEN CM.Name IS NULL THEN "" ELSE CM.Name END
             ) AS "CM Pages",
       CONCAT(CASE WHEN RC.ResultsChain_Id IS NULL THEN "" ELSE CONCAT(RC.ResultsChain_Id,". ") END,
              CASE WHEN RC.Name IS NULL THEN "" ELSE RC.Name END
             ) AS "RC Pages",
       Tag.Name AS Tags
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Result Rslt
          LEFT JOIN Threat Thr
                 ON Thr.ID = Rslt.ThreatID

          LEFT JOIN (DiagramFactor DF, ConceptualModelDiagramFactor CMDF, ConceptualModel CM)
                 ON (    CM.ID = CMDF.ConceptualModelID
                     AND CMDF.DiagramFactorID = DF.ID
                     AND DF.ProjectSummaryID = Rslt.ProjectSummaryID
                     AND DF.WrappedByDiagramFactor LIKE "%Result"
                     AND DF.WrappedByDiagramFactorXID = Rslt.XID
                    )

          LEFT JOIN (DiagramFactor DF2, ResultsChainDiagramFactor RCDF, ResultsChain RC)
                 ON (    RC.ID = RCDF.ResultsChainID
                     AND RCDF.DiagramFactorID = DF2.ID
                     AND DF2.ProjectSummaryID = Rslt.ProjectSummaryID
                     AND DF2.WrappedByDiagramFactor LIKE "%Result"
                     AND DF2.WrappedByDiagramFactorXID = Rslt.XID
                    )

          LEFT JOIN (TaggedObjectSetFactor TF, TaggedObjectSet Tag)
                 ON (    Tag.ID = TF.ID
                     AND TF.ProjectSummaryID = Rslt.ProjectSummaryID
                     AND TF.WrappedByDiagramFactor LIKE "%Result"
                     AND TF.WrappedByDiagramFactorXID = Rslt.XID
                   )

 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Rslt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Name;


/* Result Comments */

#DROP VIEW IF EXISTS vResultComments;
#CREATE VIEW vResultComments AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Result_Id,Rslt.Name,
       Rslt.FactorType,Thr.Name AS "Threat Name",Rslt.Comments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Result Rslt
          LEFT JOIN Threat Thr
                 ON Thr.ID = Rslt.ThreatID

 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Rslt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Name;


/* Objective */

#DROP VIEW IF EXISTS vObjective;
#CREATE VIEW vObjective AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Obj.Objective_Id,
       Obj.Name,Obj.Details,
       CASE WHEN Rslt.ID IS NOT NULL THEN Rslt.Name
            WHEN Str.ID IS NOT NULL THEN Str.Name
            WHEN Cs.ID IS NOT NULL THEN Cs.Name
            WHEN Tgt2.ID IS NOT NULL THEN Tgt.Name
        END AS AssocFactor,Thr.Name AS RelatedThreats, Tgt.Name AS RelatedTargets,
       TRIM(LEADING "." FROM
       CONCAT(CASE WHEN Ind.Indicator_Id IS NOT NULL THEN Ind.Indicator_Id ELSE "" END,". ",
              CASE WHEN Ind.Name IS NOT NULL THEN Ind.Name ELSE "" END
             )
       ) AS Indicators,
       TRIM(LEADING "." FROM
       CONCAT(CASE WHEN Str2.Strategy_Id IS NOT NULL THEN Str2.Strategy_Id ELSE "" END,". ",
              CASE WHEN Str2.Name IS NOT NULL THEN Str2.Name ELSE "" END
             )
       ) AS RelatedStrategies,
       TRIM(LEADING "." FROM
       CONCAT(CASE WHEN Act.Activity_Id IS NOT NULL THEN Act.Activity_Id ELSE "" END,". ",
              CASE WHEN Act.Name IS NOT NULL THEN Act.Name ELSE "" END
             )
       ) AS RelatedActivities,Obj.Comments
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Objective Obj
          LEFT JOIN (ResultObjective RsltObj
                     JOIN Result Rslt
                       ON Rslt.ID = RsltObj.ResultID
                    )
                 ON RsltObj.ObjectiveID = Obj.ID

          LEFT JOIN (StrategyObjective StrObj
                     JOIN Strategy Str
                       ON Str.ID = StrObj.StrategyID
                      AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
                    )
                 ON StrObj.ObjectiveID = Obj.ID

          LEFT JOIN (CauseObjective CsObj
                     JOIN Cause Cs
                       ON Cs.ID = CsObj.CauseID
                    )
                 ON CsObj.ObjectiveID = Obj.ID

          LEFT JOIN (ObjectiveRelevantStrategy ObjStr
                     JOIN Strategy Str2
                       ON Str2.ID = ObjStr.StrategyID
                      AND CASE WHEN Str2.Status = "Draft" THEN FALSE ELSE TRUE END
                    )
                 ON ObjStr.ObjectiveID = Obj.ID

          LEFT JOIN (ObjectiveThreat ObjThr
                     JOIN Threat Thr
                       ON Thr.ID = ObjThr.ThreatID
                               )
                 ON ObjThr.ObjectiveID = Obj.ID

          LEFT JOIN (ObjectiveTarget ObjTgt
                     JOIN Target Tgt
                       ON Tgt.ID = ObjTgt.TargetID
                    )
                 ON ObjTgt.ObjectiveID = OBj.ID

          LEFT JOIN (ObjectiveRelevantIndicator ObjInd
                     JOIN Indicator Ind
                       ON Ind.ID = ObjInd.IndicatorID
                      AND Ind.IsActive = TRUE 
                    )
                 ON ObjInd.ObjectiveID = Obj.ID

          LEFT JOIN (ObjectiveRelevantActivity ObjAct
                     JOIN Activity Act
                       ON Act.ID = ObjAct.ActivityID
                    )
                 ON ObjAct.ObjectiveID = Obj.ID

          LEFT JOIN (TargetGoal TgtGl
                     JOIN Target Tgt2
                       ON Tgt2.ID = TgtGl.TargetID
                    )
                 ON TgtGl.GoalID = Obj.ID

 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Obj.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Objective_Id, Name;


/* Objective Progress Percent */

#DROP VIEW IF EXISTS vObjectiveProgress;
#CREATE VIEW vObjectiveProgress AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Obj.Objective_Id,
       Obj.Name,PercentDate,PercentComplete,Pct.Details
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Objective Obj
       LEFT JOIN (ObjectiveProgressPercent ObjPct, ProgressPercent Pct)
              ON (    Pct.ID = ObjPct.ProgressPercentID
                  AND ObjPct.ObjectiveID = Obj.ID
                 )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Obj.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Name, PercentDate DESC;


/* Target Viability (Target Viability Screen) */

#DROP VIEW IF EXISTS vTargetViability;
#CREATE VIEW vTargetViability AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Tgt.Name AS Target,
       KEA.Name AS KEA,KEA.KeyEcologicalAttributeType AS KEACatgy,
       CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.Name ELSE Ind2.Name END AS Indicator,
       DATE(CASE WHEN Ind1.ID IS NOT NULL THEN Ind1.FutureStatusDate ELSE Ind2.FutureStatusDate END)
            AS FutureStatusDate,
       RATING(CASE WHEN Ind1.ID IS NOT NULL 
                   THEN Ind1.FutureStatusRating ELSE Ind2.FutureStatusRating
               END
             ) AS FutureRating,
       DATE(CASE WHEN Meas1.Date IS NOT NULL THEN Meas1.Date ELSE Meas2.Date END) AS Date,
       CASE WHEN Meas1.ID IS NOT NULL
            THEN Meas1.MeasurementValue ELSE Meas2.MeasurementValue
        END AS MeasValue,
       CASE WHEN Meas1.ID IS NOT NULL
            THEN RATING(Meas1.Rating) ELSE RATING(Meas2.Rating)
        END AS MeasRating,
       CASE WHEN Meas1.ID IS NOT NULL THEN Meas1.Trend ELSE Meas2.Trend END AS MeasTrend,
       CASE WHEN Meas1.ID IS NOT NULL THEN Meas1.Source ELSE Meas2.Source END AS MeasSource,
       CASE WHEN Prg1.ID IS NOT NULL THEN Prg1.ProgressStatus ELSE Prg2.ProgressStatus END
            AS ProgressStatus
  FROM ProjectSummary Summ, ExternalProjectID PID,
       Target Tgt
          LEFT JOIN (TargetIndicator TgtInd, Indicator Ind1)
                 ON (    Ind1.ID = TgtInd.IndicatorID
                     AND TgtInd.TargetID = Tgt.ID
                     AND ViabilityMode = "Simple"
                    )
          LEFT JOIN (IndicatorMeasurement IndMeas1, Measurement Meas1)
                 ON (    Meas1.ID = IndMeas1.MeasurementID
                     AND IndMeas1.IndicatorID = Ind1.ID
                     AND Ind1.IsActive = TRUE
                    )
          LEFT JOIN (IndicatorProgressReport IndPrg1, ProgressReport Prg1)
                 ON (    Prg1.ID = IndPrg1.ProgressReportID
                     AND IndPrg1.IndicatorID = Ind1.ID
                     AND Ind1.IsActive = TRUE
                    )
          LEFT JOIN (v_TargetKEA TgtKea, KeyEcologicalAttribute KEA)
                 ON (    KEA.ID = TgtKEA.KEAID
                     AND TgtKea.TargetID = Tgt.ID
                     AND ViabilityMode = "KEA"
                    )
          LEFT JOIN (v_KEAIndicator KEAInd2, Indicator Ind2)
                 ON (    Ind2.ID = KEAInd2.IndicatorID
                     AND KEAInd2.KEAID = KEA.ID
                     AND Ind2.IsActive = TRUE
                    )
          LEFT JOIN (IndicatorMeasurement IndMeas2, Measurement Meas2)
                 ON (    Meas2.ID = IndMeas2.MeasurementID
                     AND IndMeas2.IndicatorID = Ind2.ID
                     AND Ind2.IsActive = TRUE
                    )
          LEFT JOIN (IndicatorProgressReport IndPrg2, ProgressReport Prg2)
                 ON (    Prg2.ID = IndPrg2.ProgressReportID
                     AND IndPrg2.IndicatorID = Ind2.ID
                     AND Ind2.IsActive = TRUE
                    )
  WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Target, KEA, Date DESC;


/* Threat Ratings */

#DROP VIEW IF EXISTS vThreatRatings;
#CREATE VIEW vThreatRatings AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Thr.Name AS Threat,
       Tgt.Name AS Target,ThreatRatingMode,RANK(ThreatTargetRating) AS ThreatTargetRating,
       RANK(Tgt.ThreatRating) AS SummaryTargetRating,
       RANK(Thr.ThreatRating) AS SummaryThreatRating,
       RANK(Summ.OverallProjectThreatRating) AS ProjectThreatRating
  FROM ProjectSummary Summ, ExternalProjectID PID, Target Tgt, Threat Thr,
       ThreatRating ThrRtg
/*       LEFT JOIN SimpleThreatRating Smpl
         ON Smpl.ThreatRatingID = ThrRtg.ID
       LEFT JOIN StressBasedThreatRating Stress
         ON Stress.ThreatRatingID = ThrRtg.ID
*/ WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ID = ThrRtg.TargetID
   AND Thr.ID = ThrRtg.ThreatID
/*   AND (   CASE WHEN ThreatRatingMode = "Simple"
                THEN Smpl.ThreatRatingID = ThrRtg.ID
                ELSE FALSE
            END
        OR CASE WHEN ThreatRatingMode = "StressBased"
                THEN Stress.ThreatRatingID = ThrRtg.ID
                ELSE FALSE
            END
       )
*/   AND ThrRtg.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Threat, Target;


/* Threat Ratings - Direct Threat Detail */

#DROP VIEW IF EXISTS vThreatRatingsDirect;
#CREATE VIEW vThreatRatingsDirect AS
SELECT DISTINCT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,Thr.Name AS Threat,
       Tgt.Name AS Target,ThreatRatingMode,
       RANK(ThreatTargetRating) AS ThreatTargetRating,
       CASE WHEN ThreatRatingMode = "Simple"
            THEN RANK(Smpl.Scope)
        END AS Thr_Scope,
       CASE WHEN ThreatRatingMode = "Simple"
            THEN RANK(Smpl.Severity)
        END AS Thr_Severity,
       CASE WHEN ThreatRatingMode = "Simple"
            THEN RANK(Smpl.Irreversibility)
        END AS Thr_Irreversibility,
       CASE WHEN ThreatRatingMode = "StressBased"
            THEN Stress.Name
        END AS StressName,
       CASE WHEN ThreatRatingMode = "StressBased"
            THEN RANK(Stress.StressRating)
        END AS Magnitude,
       CASE WHEN ThreatRatingMode = "StressBased"
            THEN RANK(StrThr.Contribution)
        END AS Contribution,
       CASE WHEN ThreatRatingMode = "StressBased"
            THEN RANK(StrThr.Irreversibility)
        END AS Str_Irreversibility,
       CASE WHEN ThreatRatingMode = "StressBased"
            THEN RANK(StrThr.ThreatStressRating)
        END AS SummaryRating
  FROM ProjectSummary Summ, ExternalProjectID PID, Target Tgt, Threat Thr,
       ThreatRating ThrRtg
          LEFT JOIN SimpleThreatRating Smpl
            ON Smpl.ThreatRatingID = ThrRtg.ID
          LEFT JOIN (StressBasedThreatRating StrThr
                     JOIN (TargetStress TgtStr
                           JOIN Stress
                             ON Stress.ID = TgtStr.StressID
                          )
                       ON TgtStr.StressID = StrThr.ID
                    )
            ON StrThr.ThreatRatingID = ThrRtg.ID
           AND Strthr.IsActive = TRUE
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Tgt.ID = ThrRtg.TargetID
   AND Thr.ID = ThrRtg.ThreatID
   AND (   CASE WHEN ThreatRatingMode = "Simple"
                THEN Smpl.ThreatRatingID = ThrRtg.ID
                ELSE FALSE
            END
        OR CASE WHEN ThreatRatingMode = "StressBased"
                THEN StrThr.ThreatRatingID = ThrRtg.ID
                ELSE FALSE
            END
       )
   AND ThrRtg.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID DESC, Threat, Target, StressName;


/* Strategy x Threat Associations */

#DROP VIEW IF EXISTS vStrategyThreat;
#CREATE VIEW vStrategyThreat AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,StrThr.StrategyID,
       StrThr.StrategyXID,Str.Name AS StrategyName,StrThr.ThreatID,StrThr.
       ThreatXID,Thr.Name AS ThreatName
  FROM ProjectSummary Summ, ExternalProjectId PID, StrategyThreat StrThr,
       Threat Thr, Strategy Str
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ID = StrThr.StrategyID
   AND Thr.ID = StrThr.ThreatID
   AND StrThr.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
 ORDER BY ProjectSummaryID DESC,StrategyID,ThreatID;


/* Strategy x Target Associations */

#DROP VIEW IF EXISTS vStrategyTarget;
#CREATE VIEW vStrategyTarget AS
SELECT Summ.ID AS ProjectSummaryID,ProjectName,ProjectId,StrTgt.StrategyID,
       StrTgt.StrategyXID,Str.Name AS StrategyName,StrTgt.TargetID,StrTgt.
       TargetXID,Tgt.Name AS TargetName
  FROM ProjectSummary Summ, ExternalProjectId PID, StrategyTarget StrTgt,
       Target Tgt, Strategy Str
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ID = StrTgt.StrategyID
   AND Tgt.ID = StrTgt.TargetID
   AND StrTgt.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
 ORDER BY ProjectSummaryID DESC,StrategyID,TargetID;


/* Strategy/Activity/Task Work Plans */

#DROP VIEW IF EXISTS vWorkPlanByStrategy;
#CREATE VIEW vWorkPlanByStrategy AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy,
       NULL AS StrActSeq, NULL AS Activity, NULL AS ActTskSeq, NULL AS Task,
       ProgressStatus, fn_CalcWho(Str.ProjectSummaryID,"Strategy",Str.ID) AS Who,
       CalculatedStartDate, CalculatedEndDate, Years.PlanYear As "Year",
       (SELECT ROUND(SUM(NumberOfUnits),1) AS WorkUnits
          FROM StrategyCalculatedWorkUnits StrWrk, DateUnitWorkUnits Work
         WHERE Work.Factor = "CalculatedWorkUnits"
           AND Work.FactorID = StrWrk.ID
           AND StrWrk.StrategyID = Years.FactorID
           AND YEAR(Work.EndDate) = Years.PlanYear
       ) AS WorkUnits,
       ROUND(CalculatedWorkUnitsTotal,1) AS CalculatedWorkUnitsTotal,
       (SELECT ROUND(SUM(Expense),1) AS Expense
          FROM StrategyCalculatedExpense StrExp, DateUnitExpense Exp
         WHERE Exp.Factor = "CalculatedExpense"
           AND Exp.FactorID = StrExp.ID
           AND StrExp.StrategyID = Years.FactorID
           AND YEAR(Exp.EndDate) = Years.PlanYear
       ) AS Expense,
       ROUND(CalculatedExpenseTotal,1) AS CalculatedExpenseTotal,
       ROUND(CalculatedTotalBudgetCost,1) AS CalculatedTotalBudgetCost
  FROM ProjectSummary Summ, ExternalProjectId PID,
       Strategy Str
          LEFT JOIN (StrategyProgressReport StrPrg, ProgressReport Prg)
            ON (    Prg.ID = StrPrg.ProgressReportID
                AND StrPrg.StrategyID = Str.ID
                AND Prg.XID = (SELECT MAX(StrPrg2.ProgressReportXID)
                                 FROM StrategyProgressReport StrPrg2
                                WHERE StrPrg2.StrategyID = StrPrg.StrategyID
                                  AND CASE WHEN EXISTS
                                                (SELECT ProgressDate
                                                   FROM StrategyProgressReport StrPrg3,
                                                        ProgressReport Prg3
                                                  WHERE Prg3.ID = StrPrg3.ProgressReportID
                                                    AND StrPrg3.StrategyID = StrPrg2.StrategyID
                                                )
                                           THEN ProgressDate =
                                                   (SELECT MAX(ProgressDate)
                                                      FROM StrategyProgressReport StrPrg4,
                                                           ProgressReport Prg4
                                                     WHERE Prg4.ID = StrPrg4.ProgressReportID
                                                       AND StrPrg4.StrategyID = StrPrg2.StrategyID
                                                   )
                                           ELSE TRUE
                                       END
                              )
               ),
       v_PlanYears Years
 WHERE Years.ProjectSummaryID = Str.ProjectSummaryID
   AND Years.FactorID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
 GROUP BY ProjectSummaryID, Str.ID, Who, `Year`
       HAVING WorkUnits > 0 OR Expense > 0

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy, StrAct.Sequence,
       CONCAT(CASE WHEN Activity_Id IS NULL THEN "" ELSE CONCAT(Activity_Id,". ") END,
              CASE WHEN Act.Name IS NULL THEN "" ELSE Act.Name END
             ) AS Activity, NULL AS ActTskSeq, NULL AS Task,
       ProgressStatus, fn_CalcWho(Act.ProjectSummaryID,"Activity",Act.ID) AS Who,
       Act.CalculatedStartDate, Act.CalculatedEndDate, Years.PlanYear As "Year",
       (SELECT ROUND(SUM(NumberOfUnits),1) AS WorkUnits
          FROM ActivityCalculatedWorkUnits ActWrk, DateUnitWorkUnits Work
         WHERE Work.Factor = "CalculatedWorkUnits"
           AND Work.FactorID = ActWrk.ID
           AND ActWrk.ActivityID = Years.FactorID
           AND YEAR(Work.EndDate) = Years.PlanYear
       ) AS WorkUnits,
       ROUND(Act.CalculatedWorkUnitsTotal,1) AS CalculatedWorkUnitsTotal,
       (SELECT ROUND(SUM(Expense),1) AS Expense
          FROM ActivityCalculatedExpense ActExp, DateUnitExpense Exp
         WHERE Exp.Factor = "CalculatedExpense"
           AND Exp.FactorID = ActExp.ID
           AND ActExp.ActivityID = Years.FactorID
           AND YEAR(Exp.EndDate) = Years.PlanYear
       ) AS Expense,
       ROUND(Act.CalculatedExpenseTotal,1) AS CalculatedExpenseTotal,
       ROUND(Act.CalculatedTotalBudgetCost,1) AS CalculatedTotalBudgetCost
  FROM ProjectSummary Summ, ExternalProjectId PID, Strategy Str, StrategyActivity StrAct,
       Activity Act
          LEFT JOIN (ActivityProgressReport ActPrg, ProgressReport Prg)
                 ON (    Prg.ID = ActPrg.ProgressReportID
                     AND ActPrg.ActivityID = Act.ID
                     AND Prg.XID = (SELECT MAX(ActPrg2.ProgressReportXID)
                                      FROM ActivityProgressReport ActPrg2
                                     WHERE ActPrg2.ActivityID = ActPrg.ActivityID
                                       AND CASE WHEN EXISTS
                                                     (SELECT ProgressDate
                                                        FROM ActivityProgressReport ActPrg3,
                                                             ProgressReport Prg3
                                                       WHERE Prg3.ID = ActPrg3.ProgressReportID
                                                         AND ActPrg3.ActivityID = ActPrg2.ActivityID
                                                     )
                                                THEN ProgressDate =
                                                     (SELECT MAX(ProgressDate)
                                                        FROM ActivityProgressReport ActPrg4,
                                                             ProgressReport Prg4
                                                       WHERE Prg4.ID = ActPrg4.ProgressReportID
                                                         AND ActPrg4.ActivityID = ActPrg2.ActivityID
                                                     )
                                                ELSE TRUE
                                            END
                                   )
                    ),
       v_PlanYears AS Years
 WHERE Years.ProjectSummaryID = Years.ProjectSummaryID
   AND Years.FactorID = Act.ID
   AND Act.ID = StrAct.ActivityID
   AND StrAct.StrategyID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
 GROUP BY ProjectSummaryID, Str.ID, Act.ID, Who, `Year`
       HAVING WorkUnits > 0 OR Expense > 0

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy, StrAct.Sequence,
       CONCAT(CASE WHEN Activity_Id IS NULL THEN "" ELSE CONCAT(Activity_Id,". ") END,
              CASE WHEN Act.Name IS NULL THEN "" ELSE Act.Name END
             ) AS Activity, ActTask.Sequence,
       CONCAT(CASE WHEN Task_Id IS NULL THEN "" ELSE CONCAT(Task_Id,". ") END,
              CASE WHEN Task.Name IS NULL THEN "" ELSE Task.Name END
             ) AS Task,
       ProgressStatus, fn_CalcWho(Task.ProjectSummaryID,"Task",Task.ID) AS Who,
       Task.CalculatedStartDate, Task.CalculatedEndDate, Years.PlanYear As "Year",
       (SELECT ROUND(SUM(NumberOfUnits),1) AS WorkUnits
          FROM TaskCalculatedWorkUnits TaskWrk, DateUnitWorkUnits Work
         WHERE Work.Factor = "CalculatedWorkUnits"
           AND Work.FactorID = TaskWrk.ID
           AND TaskWrk.TaskID = Years.FactorID
           AND YEAR(Work.EndDate) = Years.PlanYear
       ) AS WorkUnits,
       ROUND(Task.CalculatedWorkUnitsTotal,1) AS CalculatedWorkUnitsTotal,
       (SELECT ROUND(SUM(Expense),1) AS Expense
          FROM TaskCalculatedExpense TaskExp, DateUnitExpense Exp
         WHERE Exp.Factor = "CalculatedExpense"
           AND Exp.FactorID = TaskExp.ID
           AND TaskExp.TaskID = Years.FactorID
           AND YEAR(Exp.EndDate) = Years.PlanYear
       ) AS Expense,
       ROUND(Task.CalculatedExpenseTotal,1) AS CalculatedExpenseTotal,
       ROUND(Task.CalculatedTotalBudgetCost,1) AS CalculatedTotalBudgetCost
  FROM ProjectSummary Summ, ExternalProjectId PID, Strategy Str, StrategyActivity StrAct,
       Activity Act, ActivityTask ActTask,
       Task Task
          LEFT JOIN (TaskProgressReport TaskPrg, ProgressReport Prg)
                 ON (    Prg.ID = TaskPrg.ProgressReportID
                     AND TaskPrg.TaskID = Task.ID
                     AND Prg.XID = (SELECT MAX(TaskPrg2.ProgressReportXID)
                                      FROM TaskProgressReport TaskPrg2
                                     WHERE TaskPrg2.TaskID = TaskPrg.TaskID
                                       AND CASE WHEN EXISTS
                                                     (SELECT ProgressDate
                                                        FROM TaskProgressReport TaskPrg3,
                                                             ProgressReport Prg3
                                                       WHERE Prg3.ID = TaskPrg3.ProgressReportID
                                                         AND TaskPrg3.TaskID = TaskPrg2.TaskID
                                                     )
                                                THEN ProgressDate =
                                                     (SELECT MAX(ProgressDate)
                                                        FROM TaskProgressReport TaskPrg4,
                                                             ProgressReport Prg4
                                                       WHERE Prg4.ID = TaskPrg4.ProgressReportID
                                                         AND TaskPrg4.TaskID = TaskPrg2.TaskID
                                                     )
                                                ELSE TRUE
                                            END
                                   )
                    ),
       v_PlanYears AS Years
 WHERE Years.ProjectSummaryID = Task.ProjectSummaryID
   AND Years.FactorID = Task.ID
   AND Task.ProjectSummaryID = ActTask.ProjectSummaryID
   AND Task.XID = ActTask.TaskXID
   AND ActTask.ActivityID = Act.ID
   AND Act.ID = StrAct.ActivityID
   AND StrAct.StrategyID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
 GROUP BY ProjectSummaryID, Str.ID, Act.ID, Task.ID, Who, `Year`
       HAVING WorkUnits > 0 OR Expense > 0
 ORDER BY ProjectSummaryID DESC, Strategy, StrActSeq, ActTskSeq, Year;


/* Strategy/Activity/Task Resource Assignments */

#DROP VIEW IF EXISTS vResourceAssignments;
#CREATE VIEW vResourceAssignments AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy,
       NULL AS StrActSeq, NULL AS Activity, NULL AS ActTskSeq, NULL AS Task,
       CONCAT(CASE WHEN Resource_Id IS NULL THEN "" ELSE CONCAT(Resource_Id,": ") END,
              CONCAT(CASE WHEN GivenName IS NULL THEN "" ELSE CONCAT(GivenName," ") END,
                     CASE WHEN SurName IS NULL THEN "" ELSE SurName END
                    )
             ) AS Who, DailyRate,
       CONCAT(CASE WHEN Acct.Code IS NOT NULL THEN CONCAT(Acct.Code,": ") ELSE "" END,
              CASE WHEN Acct.Name IS NOT NULL THEN Acct.Name ELSE "" END
             ) AS AcctCode,
       CONCAT(CASE WHEN Fund.Code IS NOT NULL THEN CONCAT(Fund.Code,": ") ELSE "" END,
              CASE WHEN Fund.Name IS NOT NULL THEN Fund.Name ELSE "" END
             ) AS FundCode, BC1.Code AS CategoryOne, BC2.Code AS CategoryTwo,
       WorkUnitsDateUnit, WorkUnitsDate, StartDate, EndDate, NumberOfUnits AS WorkUnits,
       (SELECT SUM(NumberOfUnits)
          FROM DateUnitWorkUnits Work1
         WHERE Work1.Factor = "ResourceAssignment"
           AND Work1.FactorID = RsrcAsgn.ID
       ) AS Total
  FROM ProjectSummary Summ, ExternalProjectId PID, Strategy Str, StrategyAssignment StrAsgn,
       ResourceAssignment RsrcAsgn
          LEFT JOIN AccountingCode Acct
            ON RsrcAsgn.AccountingCodeID = Acct.ID
          LEFT JOIN FundingSource Fund
            ON RsrcAsgn.FundingSourceID = Fund.ID
          LEFT JOIN BudgetCategoryOne BC1
            ON RsrcAsgn.BudgetCategoryOneID = BC1.ID
          LEFT JOIN BudgetCategoryTwo BC2
            ON RsrcAsgn.BudgetCategoryTwoID = BC2.ID,
       ProjectResource Rsrc, DateUnitWorkUnits Work
 WHERE Work.Factor = "ResourceAssignment"
   AND Work.FactorID = RsrcAsgn.ID
   AND Rsrc.ID = RsrcAsgn.ProjectResourceID
   AND RsrcAsgn.ID = StrAsgn.ResourceAssignmentID
   AND StrAsgn.StrategyID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy, StrAct.Sequence,
       CONCAT(CASE WHEN Activity_Id IS NULL THEN "" ELSE CONCAT(Activity_Id,". ") END,
              CASE WHEN Act.Name IS NULL THEN "" ELSE Act.Name END
             ) AS Activity, NULL AS ActTskSeq, NULL AS Task,
       CONCAT(CASE WHEN Resource_Id IS NULL THEN "" ELSE CONCAT(Resource_Id,": ") END,
              CONCAT(CASE WHEN GivenName IS NULL THEN "" ELSE CONCAT(GivenName," ") END,
                     CASE WHEN SurName IS NULL THEN "" ELSE SurName END
                    )
             ) AS Who, DailyRate,
       CONCAT(CASE WHEN Acct.Code IS NOT NULL THEN CONCAT(Acct.Code,": ") ELSE "" END,
              CASE WHEN Acct.Name IS NOT NULL THEN Acct.Name ELSE "" END
             ) AS AcctCode,
       CONCAT(CASE WHEN Fund.Code IS NOT NULL THEN CONCAT(Fund.Code,": ") ELSE "" END,
              CASE WHEN Fund.Name IS NOT NULL THEN Fund.Name ELSE "" END
             ) AS FundCode, BC1.Code AS CategoryOne, BC2.Code AS CategoryTwo,
       WorkUnitsDateUnit, WorkUnitsDate, StartDate, EndDate, NumberOfUnits AS WorkUnits,
       (SELECT SUM(NumberOfUnits)
          FROM DateUnitWorkUnits Work1
         WHERE Work1.Factor = "ResourceAssignment"
           AND Work1.FactorID = RsrcAsgn.ID
       ) AS Total
  FROM ProjectSummary Summ, ExternalProjectId PID, Strategy Str, StrategyActivity StrAct,
       Activity Act, ActivityAssignment ActAsgn,
       ResourceAssignment RsrcAsgn
          LEFT JOIN AccountingCode Acct
            ON RsrcAsgn.AccountingCodeID = Acct.ID
          LEFT JOIN FundingSource Fund
            ON RsrcAsgn.FundingSourceID = Fund.ID
          LEFT JOIN BudgetCategoryOne BC1
            ON RsrcAsgn.BudgetCategoryOneID = BC1.ID
          LEFT JOIN BudgetCategoryTwo BC2
            ON RsrcAsgn.BudgetCategoryTwoID = BC2.ID,
       ProjectResource Rsrc, DateUnitWorkUnits Work
 WHERE Work.Factor = "ResourceAssignment"
   AND Work.FactorID = RsrcAsgn.ID
   AND Rsrc.ID = RsrcAsgn.ProjectResourceID
   AND RsrcAsgn.ID = ActAsgn.ResourceAssignmentID
   AND ActAsgn.ActivityID = Act.ID
   AND Act.ID = StrAct.ActivityID
   AND StrAct.StrategyID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy, StrAct.Sequence,
       CONCAT(CASE WHEN Activity_Id IS NULL THEN "" ELSE CONCAT(Activity_Id,". ") END,
              CASE WHEN Act.Name IS NULL THEN "" ELSE Act.Name END
             ) AS Activity, ActTask.Sequence,
       CONCAT(CASE WHEN Task_Id IS NULL THEN "" ELSE CONCAT(Task_Id,". ") END,
              CASE WHEN Task.Name IS NULL THEN "" ELSE Task.Name END
             ) AS Task,
       CONCAT(CASE WHEN Resource_Id IS NULL THEN "" ELSE CONCAT(Resource_Id,": ") END,
              CONCAT(CASE WHEN GivenName IS NULL THEN "" ELSE CONCAT(GivenName," ") END,
                     CASE WHEN SurName IS NULL THEN "" ELSE SurName END
                    )
             ) AS Who, DailyRate,
       CONCAT(CASE WHEN Acct.Code IS NOT NULL THEN CONCAT(Acct.Code,": ") ELSE "" END,
              CASE WHEN Acct.Name IS NOT NULL THEN Acct.Name ELSE "" END
             ) AS AcctCode,
       CONCAT(CASE WHEN Fund.Code IS NOT NULL THEN CONCAT(Fund.Code,": ") ELSE "" END,
              CASE WHEN Fund.Name IS NOT NULL THEN Fund.Name ELSE "" END
             ) AS FundCode, BC1.Code AS CategoryOne, BC2.Code AS CategoryTwo,
       WorkUnitsDateUnit, WorkUnitsDate, StartDate, EndDate, NumberOfUnits AS WorkUnits,
       (SELECT SUM(NumberOfUnits)
          FROM DateUnitWorkUnits Work1
         WHERE Work1.Factor = "ResourceAssignment"
           AND Work1.FactorID = RsrcAsgn.ID
       ) AS Total
  FROM ProjectSummary Summ, ExternalProjectId PID, Strategy Str, StrategyActivity StrAct,
       Activity Act, ActivityTask ActTask, Task, TaskAssignment TaskAsgn,
       ResourceAssignment RsrcAsgn
          LEFT JOIN AccountingCode Acct
            ON RsrcAsgn.AccountingCodeID = Acct.ID
          LEFT JOIN FundingSource Fund
            ON RsrcAsgn.FundingSourceID = Fund.ID
          LEFT JOIN BudgetCategoryOne BC1
            ON RsrcAsgn.BudgetCategoryOneID = BC1.ID
          LEFT JOIN BudgetCategoryTwo BC2
            ON RsrcAsgn.BudgetCategoryTwoID = BC2.ID,
       ProjectResource Rsrc, DateUnitWorkUnits Work
 WHERE Work.Factor = "ResourceAssignment"
   AND Work.FactorID = RsrcAsgn.ID
   AND Rsrc.ID = RsrcAsgn.ProjectResourceID
   AND RsrcAsgn.ID = TaskAsgn.ResourceAssignmentID
   AND TaskAsgn.TaskID = Task.ID
   AND Task.ProjectSummaryID = ActTask.ProjectSummaryID
   AND Task.XID = ActTask.TaskXID
   AND ActTask.ActivityID = Act.ID
   AND Act.ID = StrAct.ActivityID
   AND StrAct.StrategyID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
 ORDER BY ProjectSummaryID DESC, Strategy, StrActSeq, ActTskSeq, Who, StartDate;


/* Strategy/Activity/Task Expense Assignments */

#DROP VIEW IF EXISTS vExpenseAssignments;
#CREATE VIEW vExpenseAssignments AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy,
       NULL AS StrActSeq, NULL AS Activity, NULL AS ActTskSeq, NULL AS Task,
       ExpAsgn.Name,
       CONCAT(CASE WHEN Acct.Code IS NOT NULL THEN CONCAT(Acct.Code,": ") ELSE "" END,
              CASE WHEN Acct.Name IS NOT NULL THEN Acct.Name ELSE "" END
             ) AS AcctCode,
       CONCAT(CASE WHEN Fund.Code IS NOT NULL THEN CONCAT(Fund.Code,": ") ELSE "" END,
              CASE WHEN Fund.Name IS NOT NULL THEN Fund.Name ELSE "" END
             ) AS FundCode, BC1.Code AS CategoryOne, BC2.Code AS CategoryTwo,
       ExpensesDateUnit, ExpensesDate, StartDate, EndDate, Expense,
       (SELECT SUM(Expense)
          FROM DateUnitExpense Exp1
         WHERE Exp1.Factor = "ExpenseAssignment"
           AND Exp1.FactorID = ExpAsgn.ID
       ) AS Total
  FROM ProjectSummary Summ, ExternalProjectId PID, Strategy Str, StrategyExpense StrExp,
       ExpenseAssignment ExpAsgn
          LEFT JOIN AccountingCode Acct
            ON ExpAsgn.AccountingCodeID = Acct.ID
          LEFT JOIN FundingSource Fund
            ON ExpAsgn.FundingSourceID = Fund.ID
          LEFT JOIN BudgetCategoryOne BC1
            ON ExpAsgn.BudgetCategoryOneID = BC1.ID
          LEFT JOIN BudgetCategoryTwo BC2
            ON ExpAsgn.BudgetCategoryTwoID = BC2.ID,
       DateUnitExpense Exp
 WHERE Exp.Factor = "ExpenseAssignment"
   AND Exp.FactorID = ExpAsgn.ID
   AND ExpAsgn.ID = StrExp.ExpenseAssignmentID
   AND StrExp.StrategyID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy, StrAct.Sequence,
       CONCAT(CASE WHEN Activity_Id IS NULL THEN "" ELSE CONCAT(Activity_Id,". ") END,
              CASE WHEN Act.Name IS NULL THEN "" ELSE Act.Name END
             ) AS Activity, NULL AS ActTskSeq, NULL AS Task,
       ExpAsgn.Name,
       CONCAT(CASE WHEN Acct.Code IS NOT NULL THEN CONCAT(Acct.Code,": ") ELSE "" END,
              CASE WHEN Acct.Name IS NOT NULL THEN Acct.Name ELSE "" END
             ) AS AcctCode,
       CONCAT(CASE WHEN Fund.Code IS NOT NULL THEN CONCAT(Fund.Code,": ") ELSE "" END,
              CASE WHEN Fund.Name IS NOT NULL THEN Fund.Name ELSE "" END
             ) AS FundCode, BC1.Code AS CategoryOne, BC2.Code AS CategoryTwo,
       ExpensesDateUnit, ExpensesDate, StartDate, EndDate, Expense,
       (SELECT SUM(Expense)
          FROM DateUnitExpense Exp1
         WHERE Exp1.Factor = "ExpenseAssignment"
           AND Exp1.FactorID = ExpAsgn.ID
       ) AS Total
  FROM ProjectSummary Summ, ExternalProjectId PID, Strategy Str, StrategyActivity StrAct,
       Activity Act, ActivityExpense ActExp,
       ExpenseAssignment ExpAsgn
          LEFT JOIN AccountingCode Acct
            ON ExpAsgn.AccountingCodeID = Acct.ID
          LEFT JOIN FundingSource Fund
            ON ExpAsgn.FundingSourceID = Fund.ID
          LEFT JOIN BudgetCategoryOne BC1
            ON ExpAsgn.BudgetCategoryOneID = BC1.ID
          LEFT JOIN BudgetCategoryTwo BC2
            ON ExpAsgn.BudgetCategoryTwoID = BC2.ID,
       DateUnitExpense Exp
 WHERE Exp.Factor = "ExpenseAssignment"
   AND Exp.FactorID = ExpAsgn.ID
   AND ExpAsgn.ID = ActExp.ExpenseAssignmentID
   AND ActExp.ActivityID = Act.ID
   AND Act.ID = StrAct.ActivityID
   AND StrAct.StrategyID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Strategy_Id IS NULL THEN "" ELSE CONCAT(Strategy_Id,". ") END,
              CASE WHEN Str.Name IS NULL THEN "" ELSE Str.Name END
             ) AS Strategy, StrAct.Sequence,
       CONCAT(CASE WHEN Activity_Id IS NULL THEN "" ELSE CONCAT(Activity_Id,". ") END,
              CASE WHEN Act.Name IS NULL THEN "" ELSE Act.Name END
             ) AS Activity, ActTask.Sequence,
       CONCAT(CASE WHEN Task_Id IS NULL THEN "" ELSE CONCAT(Task_Id,". ") END,
              CASE WHEN Task.Name IS NULL THEN "" ELSE Task.Name END
             ) AS Task,
       ExpAsgn.Name,
       CONCAT(CASE WHEN Acct.Code IS NOT NULL THEN CONCAT(Acct.Code,": ") ELSE "" END,
              CASE WHEN Acct.Name IS NOT NULL THEN Acct.Name ELSE "" END
             ) AS AcctCode,
       CONCAT(CASE WHEN Fund.Code IS NOT NULL THEN CONCAT(Fund.Code,": ") ELSE "" END,
              CASE WHEN Fund.Name IS NOT NULL THEN Fund.Name ELSE "" END
             ) AS FundCode, BC1.Code AS CategoryOne, BC2.Code AS CategoryTwo,
       ExpensesDateUnit, ExpensesDate, StartDate, EndDate, Expense,
       (SELECT SUM(Expense)
          FROM DateUnitExpense Exp1
         WHERE Exp1.Factor = "ExpenseAssignment"
           AND Exp1.FactorID = ExpAsgn.ID
       ) AS Total
  FROM ProjectSummary Summ, ExternalProjectId PID, Strategy Str, StrategyActivity StrAct,
       Activity Act, ActivityTask ActTask, Task Task, TaskExpense TaskExp,
       ExpenseAssignment ExpAsgn
          LEFT JOIN AccountingCode Acct
            ON ExpAsgn.AccountingCodeID = Acct.ID
          LEFT JOIN FundingSource Fund
            ON ExpAsgn.FundingSourceID = Fund.ID
          LEFT JOIN BudgetCategoryOne BC1
            ON ExpAsgn.BudgetCategoryOneID = BC1.ID
          LEFT JOIN BudgetCategoryTwo BC2
            ON ExpAsgn.BudgetCategoryTwoID = BC2.ID,
       DateUnitExpense Exp
 WHERE Exp.Factor = "ExpenseAssignment"
   AND Exp.FactorID = ExpAsgn.ID
   AND ExpAsgn.ID = TaskExp.ExpenseAssignmentID
   AND TaskExp.TaskID = Task.ID
   AND Task.ProjectSummaryID = ActTask.ProjectSummaryID
   AND Task.XID = ActTask.TaskXID
   AND ActTask.ActivityID = Act.ID
   AND Act.ID = StrAct.ActivityID
   AND StrAct.StrategyID = Str.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Str.ProjectSummaryID = Summ.ID
   AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
 ORDER BY ProjectSummaryID DESC, Strategy, StrActSeq, ActTskSeq, Name, StartDate;


/* Indicator/Method Work Plans */

#DROP VIEW IF EXISTS vWorkPlanByIndicator;
#CREATE VIEW vWorkPlanByIndicator AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Indicator_Id IS NULL THEN "" ELSE CONCAT(Indicator_Id,". ") END,
              CASE WHEN Ind.Name IS NULL THEN "" ELSE Ind.Name END
             ) AS Indicator,
       NULL AS IndMethSeq, NULL AS Method, NULL AS MethTskSeq, NULL AS Task,
       ProgressStatus, fn_CalcWho(Ind.ProjectSummaryID,"Indicator",Ind.ID) AS Who,
       CalculatedStartDate, CalculatedEndDate, Years.PlanYear As "Year",
       (SELECT ROUND(SUM(NumberOfUnits),1) AS WorkUnits
          FROM IndicatorCalculatedWorkUnits IndWrk, DateUnitWorkUnits Work
         WHERE Work.Factor = "CalculatedWorkUnits"
           AND Work.FactorID = IndWrk.ID
           AND IndWrk.IndicatorID = Years.FactorID
           AND YEAR(Work.EndDate) = Years.PlanYear
       ) AS WorkUnits,
       ROUND(CalculatedWorkUnitsTotal,1) AS CalculatedWorkUnitsTotal,
       (SELECT ROUND(SUM(Expense),1) AS Expense
          FROM IndicatorCalculatedExpense IndExp, DateUnitExpense Exp
         WHERE Exp.Factor = "CalculatedExpense"
           AND Exp.FactorID = IndExp.ID
           AND IndExp.IndicatorID = Years.FactorID
           AND YEAR(Exp.EndDate) = Years.PlanYear
       ) AS Expense,
       ROUND(CalculatedExpenseTotal,1) AS CalculatedExpenseTotal,
       ROUND(CalculatedTotalBudgetCost,1) AS CalculatedTotalBudgetCost
  FROM ProjectSummary Summ, ExternalProjectId PID,
       Indicator Ind
          LEFT JOIN (IndicatorProgressReport IndPrg, ProgressReport Prg)
                 ON (    Prg.ID = IndPrg.ProgressReportID
                     AND IndPrg.IndicatorID = Ind.ID
                     AND Prg.XID = (SELECT MAX(IndPrg2.ProgressReportXID)
                                      FROM IndicatorProgressReport IndPrg2
                                     WHERE IndPrg2.IndicatorID = IndPrg.IndicatorID
                                       AND CASE WHEN EXISTS
                                                     (SELECT ProgressDate
                                                        FROM IndicatorProgressReport IndPrg3,
                                                             ProgressReport Prg3
                                                       WHERE Prg3.ID = IndPrg3.ProgressReportID
                                                         AND IndPrg3.IndicatorID = IndPrg2.IndicatorID
                                                     )
                                                THEN ProgressDate =
                                                     (SELECT MAX(ProgressDate)
                                                        FROM IndicatorProgressReport IndPrg4,
                                                             ProgressReport Prg4
                                                       WHERE Prg4.ID = IndPrg4.ProgressReportID
                                                         AND IndPrg4.IndicatorID = IndPrg2.IndicatorID
                                                     )
                                                ELSE TRUE
                                            END
                                   )
                    ),
       v_PlanYears AS Years
 WHERE Years.FactorID = Ind.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Ind.ProjectSummaryID = Summ.ID
   AND Ind.IsActive = TRUE
 GROUP BY ProjectSummaryID, Ind.ID, Who, `Year`
       HAVING WorkUnits > 0 OR Expense > 0

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Indicator_Id IS NULL THEN "" ELSE CONCAT(Indicator_Id,". ") END,
              CASE WHEN Ind.Name IS NULL THEN "" ELSE Ind.Name END
             ) AS Indicator, IndMeth.Sequence,
       CONCAT(CASE WHEN Method_Id IS NULL THEN "" ELSE CONCAT(Method_Id,". ") END,
              CASE WHEN Meth.Name IS NULL THEN "" ELSE Meth.Name END
             ) AS Method, NULL AS MethTskSeq, NULL AS Task,
       ProgressStatus, fn_CalcWho(Meth.ProjectSummaryID,"Method",Meth.ID) AS Who,
       Meth.CalculatedStartDate, Meth.CalculatedEndDate, Years.PlanYear As "Year",
       (SELECT ROUND(SUM(NumberOfUnits),1) AS WorkUnits
          FROM MethodCalculatedWorkUnits MethWrk, DateUnitWorkUnits Work
         WHERE Work.Factor = "CalculatedWorkUnits"
           AND Work.FactorID =MethWrk.ID
           AND MethWrk.MethodID = Years.FactorID
           AND YEAR(Work.EndDate) = Years.PlanYear
       ) AS WorkUnits,
       ROUND(Meth.CalculatedWorkUnitsTotal,1) AS CalculatedWorkUnitsTotal,
       (SELECT ROUND(SUM(Expense),1) AS Expense
          FROM MethodCalculatedExpense MethExp, DateUnitExpense Exp
         WHERE Exp.Factor = "CalculatedExpense"
           AND Exp.FactorID = MethExp.ID
           AND MethExp.MethodID = Years.FactorID
           AND YEAR(Exp.EndDate) = Years.PlanYear
       ) AS Expense,
       ROUND(Meth.CalculatedExpenseTotal,1) AS CalculatedExpenseTotal,
       ROUND(Meth.CalculatedTotalBudgetCost,1) AS CalculatedTotalBudgetCost
  FROM ProjectSummary Summ, ExternalProjectId PID, Indicator Ind, IndicatorMethod IndMeth,
       Method Meth
          LEFT JOIN (MethodProgressReport MethPrg, ProgressReport Prg)
                 ON (    Prg.ID = MethPrg.ProgressReportID
                     AND MethPrg.MethodID = Meth.ID
                     AND Prg.XID = (SELECT MAX(MethPrg2.ProgressReportXID)
                                      FROM MethodProgressReport MethPrg2
                                     WHERE MethPrg2.MethodID = MethPrg.MethodID
                                       AND CASE WHEN EXISTS
                                                     (SELECT ProgressDate
                                                        FROM MethodProgressReport MethPrg3,
                                                             ProgressReport Prg3
                                                       WHERE Prg3.ID = MethPrg3.ProgressReportID
                                                         AND MethPrg3.MethodID = MethPrg2.MethodID
                                                     )
                                                THEN ProgressDate =
                                                     (SELECT MAX(ProgressDate)
                                                        FROM MethodProgressReport MethPrg4,
                                                             ProgressReport Prg4
                                                       WHERE Prg4.ID = MethPrg4.ProgressReportID
                                                         AND MethPrg4.MethodID = MethPrg2.MethodID
                                                     )
                                                ELSE TRUE
                                            END
                                   )
                    ),
       v_PlanYears AS Years
 WHERE Years.FactorID = Meth.ID
   AND Meth.ID = IndMeth.MethodID
   AND IndMeth.IndicatorID = Ind.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Meth.ProjectSummaryID = Summ.ID
   AND Ind.IsActive = TRUE
 GROUP BY ProjectSummaryID, Ind.ID, Meth.ID, Who, `Year`
       HAVING WorkUnits > 0 OR Expense > 0
 ORDER BY ProjectSummaryID DESC, Indicator, IndMethSeq;


/* Work Plan Project Resource Summary */

#DROP VIEW IF EXISTS vWorkPlanByResource;
#CREATE VIEW vWorkPlanByResource AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CASE WHEN Rsrcs.ProjectResourceID = 0
            THEN "Unspecified"
            ELSE CONCAT(CASE WHEN Resource_Id IS NOT NULL
                             THEN CONCAT(Resource_id,": ")
                             ELSE ""
                         END,
                        CONCAT(CASE WHEN GivenName IS NOT NULL
                                    THEN CONCAT(GivenName," ")
                                    ELSE ""
                                END,
                               CASE WHEN SurName IS NOT NULL THEN SurName ELSE "" END
                              )
                       )
        END AS Who,
       Rsrcs.RsrcYear AS FiscalYear, SUM(WorkUnits) AS WorkUnits,
       SUM(WorkCost) AS BudgetCost
  FROM ProjectSummary Summ, ExternalProjectID PID,
       (SELECT DISTINCT ProjectSummaryID, ProjectResourceID, RsrcYear
          FROM v_RsrcYears
       ) AS Rsrcs

       LEFT JOIN ProjectResource Rsrc
         ON Rsrc.ID = Rsrcs.ProjectResourceID

       LEFT JOIN
            (SELECT Entry.ProjectSummaryID,
                    CASE WHEN Entry.ProjectResourceID IS NULL THEN 0
                         ELSE Entry.ProjectResourceID
                     END AS ProjectResourceID,
                    FiscalYear AS PlanYear,
                    SUM(NumberOfUnits) AS WorkUnits,
                    CASE WHEN NumberOfUnits IS NULL THEN 0
                         ELSE ROUND(SUM(NumberOfUnits*
                                        CASE WHEN DailyRate IS NULL THEN 0 ELSE DailyRate END
                                       ),2
                                   )
                     END AS WorkCost
               FROM CalculatedWorkUnits Entry
                       LEFT JOIN ProjectResource Rsrc2
                         ON Entry.ProjectSummaryID = Rsrc2.ProjectSummaryID
                        AND Entry.ProjectResourceID = Rsrc2.ID,
                    DateUnitWorkUnits Units
              WHERE Units.Factor = "CalculatedWorkUnits"
                AND Units.FactorID = Entry.ID
                AND (   (    Entry.Factor = "Strategy"
                         AND (SELECT CASE WHEN Status = "Draft" THEN FALSE ELSE TRUE END
                                FROM Strategy
                               WHERE ID = Entry.FactorID 
                             ) = TRUE 
                        )
                     OR (    Entry.Factor = "Indicator"
                         AND (SELECT IsActive FROM Indicator
                               WHERE ID = Entry.FactorID 
                             ) = TRUE
                        ) 
                    )
#                AND Units.WorkUnitsDateUnit != "FullProjectTimespan"
              GROUP BY ProjectSummaryId, ProjectResourceID, PlanYear
            ) AS tWork
         ON tWork.ProjectSummaryID = Rsrcs.ProjectSummaryID
        AND tWork.ProjectResourceID = Rsrcs.ProjectResourceID
        AND tWork.PlanYear = Rsrcs.RsrcYear
 WHERE Rsrcs.ProjectSummaryID = Summ.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
 GROUP BY ProjectSummaryID, Who, FiscalYear
       HAVING WorkUnits > 0
 ORDER BY ProjectSummaryID DESC, Who, FiscalYear;



/* Work Plan Accounting Code Summary */

#DROP VIEW IF EXISTS vWorkPlanByAccount;
#CREATE VIEW vWorkPlanByAccount AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CASE WHEN Accts.AccountingCodeID = 0 THEN "Unspecified"
            ELSE CONCAT(CASE WHEN Acct.Code IS NOT NULL THEN CONCAT(Acct.Code,": ") ELSE "" END,
                        CASE WHEN Acct.Name IS NOT NULL THEN Acct.Name ELSE "" END
                       )
        END AS AcctCode,
       Accts.AcctYear AS FiscalYear, SUM(WorkUnits) AS WorkUnits,
       SUM(Expenses) AS Expenses,
       CASE WHEN WorkCost IS NULL THEN 0 ELSE SUM(WorkCost) END +
          CASE WHEN Expenses IS NULL THEN 0 ELSE SUM(Expenses) END AS BudgetCost
  FROM ProjectSummary Summ, ExternalProjectID PID,
       (SELECT DISTINCT ProjectSummaryID, AccountingCodeID, AcctYear
          FROM v_AcctYears
       ) AS Accts

       LEFT JOIN AccountingCode Acct
         ON Acct.ID = Accts.AccountingCodeID

       LEFT JOIN
            (SELECT Entry.ProjectSummaryID,
                    CASE WHEN Entry.AccountingCodeID IS NULL THEN 0
                         ELSE Entry.AccountingCodeID
                     END AS AccountingCodeID,
                    FiscalYear AS PlanYear,
                    SUM(NumberOfUnits) AS WorkUnits,
                    ROUND(SUM(NumberOfUnits*
                              CASE WHEN DailyRate IS NULL THEN 0 ELSE DailyRate END
                             ),2
                         ) AS WorkCost
               FROM CalculatedWorkUnits Entry
                       LEFT JOIN ProjectResource Rsrc
                         ON Entry.ProjectResourceID = Rsrc.ID,
                    DateUnitWorkUnits Units
              WHERE Units.Factor = "CalculatedWorkUnits"
                AND Units.FactorID = Entry.ID
                AND (   (    Entry.Factor = "Strategy"
                         AND (SELECT CASE WHEN Status = "Draft" THEN FALSE ELSE TRUE END
                                FROM Strategy
                               WHERE ID = Entry.FactorID 
                             ) = TRUE 
                        )
                     OR (    Entry.Factor = "Indicator"
                         AND (SELECT IsActive FROM Indicator
                               WHERE ID = Entry.FactorID 
                             ) = TRUE
                        ) 
                    )
#                AND Units.WorkUnitsDateUnit != "FullProjectTimespan"
              GROUP BY 1,2,3
            ) AS tWork
         ON tWork.ProjectSummaryID = Accts.ProjectSummaryID
        AND tWork.AccountingCodeID = Accts.AccountingCodeID
        AND tWork.PlanYear = Accts.AcctYear

        LEFT JOIN
            (SELECT Entry.ProjectSummaryID,
                    CASE WHEN Entry.AccountingCodeID IS NULL THEN 0
                         ELSE Entry.AccountingCodeID
                     END AS AccountingCodeID,
                     FiscalYear AS ExpYear,
                    SUM(Expense) AS Expenses
               FROM CalculatedExpense Entry, DateUnitExpense Exp
              WHERE Exp.Factor = "CalculatedExpense"
                AND Exp.FactorID = Entry.ID
                AND (   (    Entry.Factor = "Strategy"
                         AND (SELECT CASE WHEN Status = "Draft" THEN FALSE ELSE TRUE END
                                FROM Strategy
                               WHERE ID = Entry.FactorID 
                             ) = TRUE 
                        )
                     OR (    Entry.Factor = "Indicator"
                         AND (SELECT IsActive FROM Indicator
                               WHERE ID = Entry.FactorID 
                             ) = TRUE
                        ) 
                    )
#                AND Exp.ExpensesDateUnit != "FullProjectTimespan"
              GROUP BY 1,2,3
             ) AS tExp
         ON tExp.ProjectSummaryID = Accts.ProjectSummaryID
        AND tExp.AccountingCodeID = Accts.AccountingCodeID
        AND tExp.ExpYear = Accts.AcctYear
 WHERE Accts.ProjectSummaryID = Summ.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
 GROUP BY ProjectSummaryID, AcctCode, FiscalYear
       HAVING WorkUnits > 0 OR Expenses > 0
 ORDER BY ProjectSummaryID DESC, AcctCode, FiscalYear;



/* Work Plan Funding Source Summary */

#DROP VIEW IF EXISTS vWorkPlanByFund;
#CREATE VIEW vWorkPlanByFund AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CASE WHEN Funds.FundingSourceID = 0 THEN "Unspecified"
            ELSE CONCAT(CASE WHEN Fund.Code IS NOT NULL THEN CONCAT(Fund.Code,": ") ELSE "" END,
                        CASE WHEN Fund.Name IS NOT NULL THEN Fund.Name ELSE "" END
                       )
        END AS FundCode,
       Funds.FundYear AS FiscalYear, SUM(WorkUnits) AS WorkUnits,
       SUM(Expenses) AS Expenses,
       CASE WHEN WorkCost IS NULL THEN 0 ELSE SUM(WorkCost) END +
          CASE WHEN Expenses IS NULL THEN 0 ELSE SUM(Expenses) END AS BudgetCost
  FROM ProjectSummary Summ, ExternalProjectID PID,
       (SELECT DISTINCT ProjectSummaryID, FundingSourceID, FundYear
          FROM v_FundYears
       ) AS Funds

       LEFT JOIN FundingSource Fund
         ON Fund.ProjectSummaryID = Funds.ProjectSummaryID
        AND Fund.ID = Funds.FundingSourceID

       LEFT JOIN
            (SELECT Entry.ProjectSummaryID,
                    CASE WHEN Entry.FundingSourceID IS NULL THEN 0
                         ELSE Entry.FundingSourceID
                     END AS FundingSourceID,
                    FiscalYear AS PlanYear,
                    SUM(NumberOfUnits) AS WorkUnits,
                    ROUND(SUM(NumberOfUnits*
                              CASE WHEN DailyRate IS NULL THEN 0 ELSE DailyRate END
                              ),2
                         ) AS WorkCost
               FROM CalculatedWorkUnits Entry
                       LEFT JOIN ProjectResource Rsrc
                         ON Entry.ProjectResourceID = Rsrc.ID,
                    DateUnitWorkUnits Work
              WHERE Work.Factor = "CalculatedWorkUnits"
                AND Work.FactorID = Entry.ID
                AND (   (    Entry.Factor = "Strategy"
                         AND (SELECT CASE WHEN Status = "Draft" THEN FALSE ELSE TRUE END
                                FROM Strategy
                               WHERE ID = Entry.FactorID 
                             ) = TRUE 
                        )
                     OR (    Entry.Factor = "Indicator"
                         AND (SELECT IsActive FROM Indicator
                               WHERE ID = Entry.FactorID 
                             ) = TRUE
                        ) 
                    )
#                AND Work.WorkUnitsDateUnit != "FullProjectTimespan"
              GROUP BY 1,2,3
            ) AS tWork
         ON tWork.ProjectSummaryID = Funds.ProjectSummaryID
        AND tWork.FundingSourceID = Funds.FundingSourceID
        AND tWork.PlanYear = Funds.FundYear

        LEFT JOIN
            (SELECT Entry.ProjectSummaryID,
                    CASE WHEN Entry.FundingSourceID IS NULL THEN 0
                         ELSE Entry.FundingSourceID
                     END AS FundingSourceID,
                    FiscalYear AS ExpYear,
                    SUM(Expense) AS Expenses
               FROM CalculatedExpense Entry, DateUnitExpense Exp
              WHERE Exp.Factor = "CalculatedExpense"
                AND Exp.FactorID = Entry.ID
                AND (   (    Entry.Factor = "Strategy"
                         AND (SELECT CASE WHEN Status = "Draft" THEN FALSE ELSE TRUE END
                                FROM Strategy
                               WHERE ID = Entry.FactorID 
                             ) = TRUE 
                        )
                     OR (    Entry.Factor = "Indicator"
                         AND (SELECT IsActive FROM Indicator
                               WHERE ID = Entry.FactorID 
                             ) = TRUE
                        ) 
                    )
#                AND Exp.ExpensesDateUnit != "FullProjectTimespan"
              GROUP BY 1,2,3
             ) AS tExp
         ON tExp.ProjectSummaryID = Funds.ProjectSummaryID
        AND tExp.FundingSourceID = Funds.FundingSourceID
        AND tExp.ExpYear = Funds.FundYear
 WHERE Funds.ProjectSummaryID = Summ.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
 GROUP BY ProjectSummaryID, FundCode, FiscalYear
       HAVING WorkUnits > 0 OR Expenses > 0
 ORDER BY ProjectSummaryID DESC, FundCode, FiscalYear;


/* Strategic Plan Action Plan */

#DROP VIEW IF EXISTS vStrategicPlanAction;
#CREATE VIEW vStrategicPlanAction AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ResultsChain_Id IS NOT NULL THEN CONCAT(ResultsChain_Id,". ") ELSE "" END,
              CASE WHEN RC.Name IS NOT NULL THEN RC.Name ELSE "" END
             ) AS Model, NULL AS Target, NULL AS Goal, NULL AS Objective, NULL AS Strategy,
       NULL AS Who, NULL AS Progress, RC.Details, NULL AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ResultsChain RC
 WHERE RC.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ResultsChain_Id IS NOT NULL THEN CONCAT(ResultsChain_Id,". ") ELSE "" END,
              CASE WHEN RC.Name IS NOT NULL THEN RC.Name ELSE "" END
             ) AS Model,
       CONCAT(CASE WHEN Target_Id IS NOT NULL THEN CONCAT(Target_Id,". ") ELSE "" END,
              CASE WHEN Tgt.Name IS NOT NULL THEN Tgt.Name ELSE "" END
             ) AS Target, NULL AS Goal, NULL AS Objective, NULL AS Strategy,
      NULL AS Who, NULL AS Progress, Tgt.Details, RATING(ViabilityStatus) AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ResultsChain RC, ResultsChainDiagramFactor RCDF,
       DiagramFactor DF, Target Tgt
 WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
   AND Tgt.XID = DF.WrappedByDiagramFactorXID
   AND DF.WrappedByDiagramFactor LIKE "%Target"
   AND DF.ID = RCDF.DiagramFactorID
   AND RCDF.ResultsChainID = RC.ID
   AND RC.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ResultsChain_Id IS NOT NULL THEN CONCAT(ResultsChain_Id,". ") ELSE "" END,
              CASE WHEN RC.Name IS NOT NULL THEN RC.Name ELSE "" END
             ) AS Model,
       CONCAT(CASE WHEN Target_Id IS NOT NULL THEN CONCAT(Target_Id,". ") ELSE "" END,
              CASE WHEN Tgt.Name IS NOT NULL THEN Tgt.Name ELSE "" END
             ) AS Target,
       CONCAT(CASE WHEN Goal_Id IS NOT NULL THEN CONCAT(Goal_Id,". ") ELSE "" END,
              CASE WHEN Goal.Name IS NOT NULL THEN Goal.Name ELSE "" END
             ) AS Goal, NULL AS Objective, NULL AS Strategy,
      NULL AS Who, PercentComplete AS Progress, Goal.Details, NULL AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ResultsChain RC, ResultsChainDiagramFactor RCDF,
       DiagramFactor DF,
       Target Tgt
          LEFT JOIN
               (TargetGoal TgtGl,
                Goal
                   LEFT JOIN (GoalProgressPercent GlPct, ProgressPercent Pct)
                     ON (    Pct.ID = GlPct.ProgressPercentID
                         AND GlPct.GoalID = Goal.ID
                         AND Pct.XID = (SELECT MAX(GlPct.ProgressPercentXID)
                                          FROM GoalProgressPercent GlPct2
                                         WHERE GlPct2.GoalID = GlPct.GoalID
                                           AND CASE WHEN EXISTS
                                                         (SELECT PercentDate
                                                            FROM GoalProgressPercent GlPct3,
                                                                 ProgressPercent Pct3
                                                           WHERE Pct3.ID = GlPct3.ProgressPercentID
                                                             AND GlPct3.GoalID = GlPct2.GoalID
                                                         )
                                                    THEN PercentDate =
                                                         (SELECT MAX(PercentDate)
                                                            FROM GoalProgressPercent GlPct4,
                                                                 ProgressPercent Pct4
                                                           WHERE Pct4.ID = GlPct4.ProgressPercentID
                                                             AND GlPct4.GoalID = GlPct2.GoalID
                                                         )
                                                    ELSE TRUE
                                                END
                                     )
                        )
               )
            ON (    Goal.ID = TgtGl.GoalID
                AND TgtGl.TargetID = Tgt.ID
               )
 WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
   AND Tgt.XID = DF.WrappedByDiagramFactorXID
   AND DF.WrappedByDiagramFactor LIKE "%Target"
   AND DF.ID = RCDF.DiagramFactorID
   AND RCDF.ResultsChainID = RC.ID
   AND RC.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ResultsChain_Id IS NOT NULL THEN CONCAT(ResultsChain_Id,". ") ELSE "" END,
              CASE WHEN RC.Name IS NOT NULL THEN RC.Name ELSE "" END
             ) AS Model,
       CONCAT(CASE WHEN Target_Id IS NOT NULL THEN CONCAT(Target_Id,". ") ELSE "" END,
              CASE WHEN Tgt.Name IS NOT NULL THEN Tgt.Name ELSE "" END
             ) AS Target, NULL AS Goal,
       CONCAT(CASE WHEN Objective_Id IS NOT NULL THEN CONCAT(Objective_Id,". ") ELSE "" END,
              CASE WHEN Obj.Name IS NOT NULL THEN Obj.Name ELSE "" END
             ) AS Objective, NULL AS Strategy,
       NULL AS Who, PercentComplete AS Progress, Obj.Details, NULL AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ResultsChain RC, ResultsChainDiagramFactor RCDF,
       DiagramFactor DF,
       Target Tgt
          LEFT JOIN
               (ObjectiveTarget ObjTgt,
                Objective Obj
                   LEFT JOIN (ObjectiveProgressPercent ObjPct, ProgressPercent Pct)
                     ON (    Pct.ID = ObjPct.ProgressPercentID
                         AND ObjPct.ObjectiveID = Obj.ID
                         AND Pct.XID = (SELECT MAX(ObjPct.ProgressPercentXID)
                                          FROM ObjectiveProgressPercent ObjPct2
                                         WHERE ObjPct2.ObjectiveID = ObjPct.ObjectiveID
                                           AND CASE WHEN EXISTS
                                                         (SELECT PercentDate
                                                            FROM ObjectiveProgressPercent ObjPct3,
                                                                 ProgressPercent Pct3
                                                           WHERE Pct3.ID = ObjPct3.ProgressPercentID
                                                             AND ObjPct3.ObjectiveID = ObjPct2.ObjectiveID
                                                         )
                                                    THEN PercentDate =
                                                         (SELECT MAX(PercentDate)
                                                            FROM ObjectiveProgressPercent ObjPct4,
                                                                 ProgressPercent Pct4
                                                           WHERE Pct4.ID = ObjPct4.ProgressPercentID
                                                             AND ObjPct4.ObjectiveID = ObjPct2.ObjectiveID
                                                         )
                                                    ELSE TRUE
                                                END
                                     )
                        )
               )

            ON (    Obj.ID = ObjTgt.ObjectiveID
                AND ObjTgt.TargetID = Tgt.ID
               )
 WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
   AND Tgt.XID = DF.WrappedByDiagramFactorXID
   AND DF.WrappedByDiagramFactor LIKE "%Target"
   AND DF.ID = RCDF.DiagramFactorID
   AND RCDF.ResultsChainID = RC.ID
   AND RC.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ResultsChain_Id IS NOT NULL THEN CONCAT(ResultsChain_Id,". ") ELSE "" END,
              CASE WHEN RC.Name IS NOT NULL THEN RC.Name ELSE "" END
             ) AS Model,
       CONCAT(CASE WHEN Target_Id IS NOT NULL THEN CONCAT(Target_Id,". ") ELSE "" END,
              CASE WHEN Tgt.Name IS NOT NULL THEN Tgt.Name ELSE "" END
             ) AS Target, NULL AS Goal,
       CONCAT(CASE WHEN Objective_Id IS NOT NULL THEN CONCAT(Objective_Id,". ") ELSE "" END,
              CASE WHEN Obj.Name IS NOT NULL THEN Obj.Name ELSE "" END
             ) AS Objective,
       CONCAT(CASE WHEN Strategy_Id IS NOT NULL THEN CONCAT(Strategy_Id,". ") ELSE "" END,
              CASE WHEN Str.Name IS NOT NULL THEN Str.Name ELSE "" END
             )       AS Strategy,
       fn_CalcWho(Str.ProjectSummaryID,"Strategy",Str.ID) AS Who,
       ProgressStatus AS Progress, Str.Details, NULL AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ResultsChain RC, ResultsChainDiagramFactor RCDF,
       DiagramFactor DF,
       Target Tgt
          LEFT JOIN
               (ObjectiveTarget ObjTgt,
                Objective Obj
                   LEFT JOIN (ObjectiveProgressPercent ObjPct, ProgressPercent Pct)
                     ON (    Pct.ID = ObjPct.ProgressPercentID
                         AND ObjPct.ObjectiveID = Obj.ID
                         AND Pct.XID = (SELECT MAX(ObjPct.ProgressPercentXID)
                                          FROM ObjectiveProgressPercent ObjPct2
                                         WHERE ObjPct2.ObjectiveID = ObjPct.ObjectiveID
                                           AND CASE WHEN EXISTS
                                                         (SELECT PercentDate
                                                            FROM ObjectiveProgressPercent ObjPct3,
                                                                 ProgressPercent Pct3
                                                           WHERE Pct3.ID = ObjPct3.ProgressPercentID
                                                             AND ObjPct3.ObjectiveID = ObjPct2.ObjectiveID
                                                         )
                                                    THEN PercentDate =
                                                         (SELECT MAX(PercentDate)
                                                            FROM ObjectiveProgressPercent ObjPct4,
                                                                 ProgressPercent Pct4
                                                           WHERE Pct4.ID = ObjPct4.ProgressPercentID
                                                             AND ObjPct4.ObjectiveID = ObjPct2.ObjectiveID
                                                         )
                                                    ELSE TRUE
                                                END
                                     )
                        )
                   LEFT JOIN (ObjectiveRelevantStrategy ObjStr,
                              Strategy Str
                                 LEFT JOIN (StrategyProgressReport StrPrg, ProgressReport Prg)
                                   ON (    Prg.ID = StrPrg.ProgressReportID
                                       AND StrPrg.StrategyID = Str.ID
                                       AND Prg.XID = (SELECT MAX(StrPrg2.ProgressReportXID)
                                                        FROM StrategyProgressReport StrPrg2
                                                       WHERE StrPrg2.StrategyID = StrPrg.StrategyID
                                                         AND CASE WHEN EXISTS
                                                                     (SELECT ProgressDate
                                                                        FROM StrategyProgressReport StrPrg3,
                                                                             ProgressReport Prg3
                                                                       WHERE Prg3.ID = StrPrg3.ProgressReportID
                                                                         AND StrPrg3.StrategyID = StrPrg2.StrategyID
                                                                     )
                                                                  THEN ProgressDate =
                                                                     (SELECT MAX(ProgressDate)
                                                                        FROM StrategyProgressReport StrPrg4,
                                                                             ProgressReport Prg4
                                                                       WHERE Prg4.ID = StrPrg4.ProgressReportID
                                                                         AND StrPrg4.StrategyID = StrPrg2.StrategyID
                                                                     )
                                                                  ELSE TRUE
                                                              END
                                                     )
                                      )
                             )
                     ON (    Str.ID = ObjStr.StrategyID
                         AND ObjStr.ObjectiveID = Obj.ID
                         AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
                        )
               )

            ON (    Obj.ID = ObjTgt.ObjectiveID
                AND ObjTgt.TargetID = Tgt.ID
               )

 WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
   AND Tgt.XID = DF.WrappedByDiagramFactorXID
   AND DF.WrappedByDiagramFactor LIKE "%Target"
   AND DF.ID = RCDF.DiagramFactorID
   AND RCDF.ResultsChainID = RC.ID
   AND RC.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ConceptualModel_Id IS NOT NULL THEN CONCAT(ConceptualModel_Id,". ") ELSE "" END,
              CASE WHEN CM.Name IS NOT NULL THEN CM.Name ELSE "" END
             ) AS Model, NULL AS Target, NULL AS Goal, NULL AS Objective, NULL AS Strategy,
       NULL AS Who, NULL AS Progress, CM.Details, NULL AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ConceptualModel CM
 WHERE CM.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ConceptualModel_Id IS NOT NULL THEN CONCAT(ConceptualModel_Id,". ") ELSE "" END,
              CASE WHEN CM.Name IS NOT NULL THEN CM.Name ELSE "" END
             ) AS Model,
       CONCAT(CASE WHEN Target_Id IS NOT NULL THEN CONCAT(Target_Id,". ") ELSE "" END,
              CASE WHEN Tgt.Name IS NOT NULL THEN Tgt.Name ELSE "" END
             ) AS Target, NULL AS Goal, NULL AS Objective, NULL AS Strategy,
      NULL AS Who, NULL AS Progress, Tgt.Details, RATING(ViabilityStatus) AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ConceptualModel CM, ConceptualModelDiagramFactor CMDF,
       DiagramFactor DF, Target Tgt
 WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
   AND Tgt.XID = DF.WrappedByDiagramFactorXID
   AND DF.WrappedByDiagramFactor LIKE "%Target"
   AND DF.ID = CMDF.DiagramFactorID
   AND CMDF.ConceptualModelID = CM.ID
   AND CM.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ConceptualModel_Id IS NOT NULL THEN CONCAT(ConceptualModel_Id,". ") ELSE "" END,
              CASE WHEN CM.Name IS NOT NULL THEN CM.Name ELSE "" END
             ) AS Model,
       CONCAT(CASE WHEN Target_Id IS NOT NULL THEN CONCAT(Target_Id,". ") ELSE "" END,
              CASE WHEN Tgt.Name IS NOT NULL THEN Tgt.Name ELSE "" END
             ) AS Target,
       CONCAT(CASE WHEN Goal_Id IS NOT NULL THEN CONCAT(Goal_Id,". ") ELSE "" END,
              CASE WHEN Goal.Name IS NOT NULL THEN Goal.Name ELSE "" END
             ) AS Goal, NULL AS Objective, NULL AS Strategy,
      NULL AS Who, PercentComplete AS Progress, Goal.Details, NULL AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ConceptualModel CM, ConceptualModelDiagramFactor CMDF,
       DiagramFactor DF,
       Target Tgt
          LEFT JOIN
               (TargetGoal TgtGl,
                Goal
                   LEFT JOIN (GoalProgressPercent GlPct, ProgressPercent Pct)
                     ON (    Pct.ID = GlPct.ProgressPercentID
                         AND GlPct.GoalID = Goal.ID
                         AND Pct.XID = (SELECT MAX(GlPct.ProgressPercentXID)
                                          FROM GoalProgressPercent GlPct2
                                         WHERE GlPct2.GoalID = GlPct.GoalID
                                           AND CASE WHEN EXISTS
                                                         (SELECT PercentDate
                                                            FROM GoalProgressPercent GlPct3,
                                                                 ProgressPercent Pct3
                                                           WHERE Pct3.ID = GlPct3.ProgressPercentID
                                                             AND GlPct3.GoalID = GlPct2.GoalID
                                                         )
                                                    THEN PercentDate =
                                                         (SELECT MAX(PercentDate)
                                                            FROM GoalProgressPercent GlPct4,
                                                                 ProgressPercent Pct4
                                                           WHERE Pct4.ID = GlPct4.ProgressPercentID
                                                             AND GlPct4.GoalID = GlPct2.GoalID
                                                         )
                                                    ELSE TRUE
                                                END
                                     )
                        )
               )
            ON (    Goal.ID = TgtGl.GoalID
                AND TgtGl.TargetID = Tgt.ID
               )
 WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
   AND Tgt.XID = DF.WrappedByDiagramFactorXID
   AND DF.WrappedByDiagramFactor LIKE "%Target"
   AND DF.ID = CMDF.DiagramFactorID
   AND CMDF.ConceptualModelID = CM.ID
   AND CM.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ConceptualModel_Id IS NOT NULL THEN CONCAT(ConceptualModel_Id,". ") ELSE "" END,
              CASE WHEN CM.Name IS NOT NULL THEN CM.Name ELSE "" END
             ) AS Model,
       CONCAT(CASE WHEN Target_Id IS NOT NULL THEN CONCAT(Target_Id,". ") ELSE "" END,
              CASE WHEN Tgt.Name IS NOT NULL THEN Tgt.Name ELSE "" END
             ) AS Target, NULL AS Goal,
       CONCAT(CASE WHEN Objective_Id IS NOT NULL THEN CONCAT(Objective_Id,". ") ELSE "" END,
              CASE WHEN Obj.Name IS NOT NULL THEN Obj.Name ELSE "" END
             ) AS Objective, NULL AS Strategy,
       NULL AS Who, PercentComplete AS Progress, Obj.Details, NULL AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ConceptualModel CM, ConceptualModelDiagramFactor CMDF,
       DiagramFactor DF,
       Target Tgt
          LEFT JOIN
               (ObjectiveTarget ObjTgt,
                Objective Obj
                   LEFT JOIN (ObjectiveProgressPercent ObjPct, ProgressPercent Pct)
                     ON (    Pct.ID = ObjPct.ProgressPercentID
                         AND ObjPct.ObjectiveID = Obj.ID
                         AND Pct.XID = (SELECT MAX(ObjPct.ProgressPercentXID)
                                          FROM ObjectiveProgressPercent ObjPct2
                                         WHERE ObjPct2.ObjectiveID = ObjPct.ObjectiveID
                                           AND CASE WHEN EXISTS
                                                         (SELECT PercentDate
                                                            FROM ObjectiveProgressPercent ObjPct3,
                                                                 ProgressPercent Pct3
                                                           WHERE Pct3.ID = ObjPct3.ProgressPercentID
                                                             AND ObjPct3.ObjectiveID = ObjPct2.ObjectiveID
                                                         )
                                                    THEN PercentDate =
                                                         (SELECT MAX(PercentDate)
                                                            FROM ObjectiveProgressPercent ObjPct4,
                                                                 ProgressPercent Pct4
                                                           WHERE Pct4.ID = ObjPct4.ProgressPercentID
                                                             AND ObjPct4.ObjectiveID = ObjPct2.ObjectiveID
                                                         )
                                                    ELSE TRUE
                                                END
                                     )
                        )
               )

            ON (    Obj.ID = ObjTgt.ObjectiveID
                AND ObjTgt.TargetID = Tgt.ID
               )
 WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
   AND Tgt.XID = DF.WrappedByDiagramFactorXID
   AND DF.WrappedByDiagramFactor LIKE "%Target"
   AND DF.ID = CMDF.DiagramFactorID
   AND CMDF.ConceptualModelID = CM.ID
   AND CM.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN ConceptualModel_Id IS NOT NULL THEN CONCAT(ConceptualModel_Id,". ") ELSE "" END,
              CASE WHEN CM.Name IS NOT NULL THEN CM.Name ELSE "" END
             ) AS Model,
       CONCAT(CASE WHEN Target_Id IS NOT NULL THEN CONCAT(Target_Id,". ") ELSE "" END,
              CASE WHEN Tgt.Name IS NOT NULL THEN Tgt.Name ELSE "" END
             ) AS Target, NULL AS Goal,
       CONCAT(CASE WHEN Objective_Id IS NOT NULL THEN CONCAT(Objective_Id,". ") ELSE "" END,
              CASE WHEN Obj.Name IS NOT NULL THEN Obj.Name ELSE "" END
             ) AS Objective,
       CONCAT(CASE WHEN Strategy_Id IS NOT NULL THEN CONCAT(Strategy_Id,". ") ELSE "" END,
              CASE WHEN Str.Name IS NOT NULL THEN Str.Name ELSE "" END
             )       AS Strategy,
       fn_CalcWho(Str.ProjectSummaryID,"Strategy",Str.ID) AS Who,
       ProgressStatus AS Progress, Str.Details, NULL AS Rating
  FROM ProjectSummary Summ, ExternalProjectID PID, ConceptualModel CM, ConceptualModelDiagramFactor CMDF,
       DiagramFactor DF,
       Target Tgt
          LEFT JOIN
               (ObjectiveTarget ObjTgt,
                Objective Obj
                   LEFT JOIN (ObjectiveProgressPercent ObjPct, ProgressPercent Pct)
                     ON (    Pct.ID = ObjPct.ProgressPercentID
                         AND ObjPct.ObjectiveID = Obj.ID
                         AND Pct.XID = (SELECT MAX(ObjPct.ProgressPercentXID)
                                          FROM ObjectiveProgressPercent ObjPct2
                                         WHERE ObjPct2.ObjectiveID = ObjPct.ObjectiveID
                                           AND CASE WHEN EXISTS
                                                         (SELECT PercentDate
                                                            FROM ObjectiveProgressPercent ObjPct3,
                                                                 ProgressPercent Pct3
                                                           WHERE Pct3.ID = ObjPct3.ProgressPercentID
                                                             AND ObjPct3.ObjectiveID = ObjPct2.ObjectiveID
                                                         )
                                                    THEN PercentDate =
                                                         (SELECT MAX(PercentDate)
                                                            FROM ObjectiveProgressPercent ObjPct4,
                                                                 ProgressPercent Pct4
                                                           WHERE Pct4.ID = ObjPct4.ProgressPercentID
                                                             AND ObjPct4.ObjectiveID = ObjPct2.ObjectiveID
                                                         )
                                                    ELSE TRUE
                                                END
                                     )
                        )
                   LEFT JOIN (ObjectiveRelevantStrategy ObjStr,
                              Strategy Str
                                 LEFT JOIN (StrategyProgressReport StrPrg, ProgressReport Prg)
                                   ON (    Prg.ID = StrPrg.ProgressReportID
                                       AND StrPrg.StrategyID = Str.ID
                                       AND Prg.XID = (SELECT MAX(StrPrg2.ProgressReportXID)
                                                        FROM StrategyProgressReport StrPrg2
                                                       WHERE StrPrg2.StrategyID = StrPrg.StrategyID
                                                         AND CASE WHEN EXISTS
                                                                     (SELECT ProgressDate
                                                                        FROM StrategyProgressReport StrPrg3,
                                                                             ProgressReport Prg3
                                                                       WHERE Prg3.ID = StrPrg3.ProgressReportID
                                                                         AND StrPrg3.StrategyID = StrPrg2.StrategyID
                                                                     )
                                                                  THEN ProgressDate =
                                                                     (SELECT MAX(ProgressDate)
                                                                        FROM StrategyProgressReport StrPrg4,
                                                                             ProgressReport Prg4
                                                                       WHERE Prg4.ID = StrPrg4.ProgressReportID
                                                                         AND StrPrg4.StrategyID = StrPrg2.StrategyID
                                                                     )
                                                                  ELSE TRUE
                                                              END
                                                     )
                                      )
                             )
                     ON (    Str.ID = ObjStr.StrategyID
                         AND ObjStr.ObjectiveID = Obj.ID
                         AND CASE WHEN Str.Status = "Draft" THEN FALSE ELSE TRUE END
                        )
               )

            ON (    Obj.ID = ObjTgt.ObjectiveID
                AND ObjTgt.TargetID = Tgt.ID
               )

 WHERE Tgt.ProjectSummaryID = DF.ProjectSummaryID
   AND Tgt.XID = DF.WrappedByDiagramFactorXID
   AND DF.WrappedByDiagramFactor LIKE "%Target"
   AND DF.ID = CMDF.DiagramFactorID
   AND CMDF.ConceptualModelID = CM.ID
   AND CM.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )

 ORDER BY ProjectSummaryID DESC, Model, Target, Objective, Strategy, Goal;


/* Strategic Plan Monitoring */

#DROP VIEW IF EXISTS vStrategicPlanMonitoring;
#CREATE VIEW vStrategicPlanMonitoring AS
SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Objective_Id IS NULL THEN "" ELSE CONCAT(Objective_Id,". ") END,
              CASE WHEN Obj.Name IS NULL THEN "" ELSE Obj.Name END
             ) AS Objective,
       NULL AS Indicator, PercentComplete AS Progress, NULL AS Who, NULL AS CalculatedStartDate,
       NULL AS CalculatedEndDate, Obj.Details
  FROM ProjectSummary Summ, ExternalProjectId PID,
       Objective Obj
          LEFT JOIN (ObjectiveProgressPercent ObjPct, ProgressPercent Pct)
            ON (    Pct.ID = ObjPct.ProgressPercentID
                AND ObjPct.ObjectiveID = Obj.ID
                AND Pct.XID = (SELECT MAX(ObjPct2.ProgressPercentXID)
                                 FROM ObjectiveProgressPercent ObjPct2
                                WHERE ObjPct2.ObjectiveID = ObjPct.ObjectiveID
                                  AND CASE WHEN EXISTS
                                                (SELECT PercentDate
                                                   FROM ObjectiveProgressPercent ObjPct3,
                                                         ProgressPercent Pct3
                                                  WHERE Pct3.ID = ObjPct3.ProgressPercentID
                                                    AND ObjPct3.ObjectiveID = ObjPct2.ObjectiveID
                                                )
                                           THEN PercentDate =
                                                   (SELECT MAX(PercentDate)
                                                      FROM ObjectiveProgressPercent ObjPct4,
                                                           ProgressPercent Pct4
                                                     WHERE Pct4.ID = ObjPct4.ProgressPercentID
                                                       AND ObjPct4.ObjectiveID = ObjPct2.ObjectiveID
                                                   )
                                           ELSE TRUE
                                       END
                              )
               )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Obj.ProjectSummaryID = Summ.ID

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Goal_Id IS NULL THEN "" ELSE CONCAT(Goal_Id,". ") END,
              CASE WHEN Goal.Name IS NULL THEN "" ELSE Goal.Name END
             ) AS Objective,
       NULL AS Indicator, PercentComplete, NULL AS Who, NULL AS CalculatedStartDate,
       NULL AS CalculatedEndDate, Goal.Details
  FROM ProjectSummary Summ, ExternalProjectId PID,
       Goal Goal
          LEFT JOIN (GoalProgressPercent GoalPct, ProgressPercent Pct)
            ON (    Pct.ID = GoalPct.ProgressPercentID
                AND GoalPct.GoalID = Goal.ID
                AND Pct.XID = (SELECT MAX(GoalPct2.ProgressPercentXID)
                                 FROM GoalProgressPercent GoalPct2
                                WHERE GoalPct2.GoalID = GoalPct.GoalID
                                  AND CASE WHEN EXISTS
                                                (SELECT PercentDate
                                                   FROM GoalProgressPercent GoalPct3,
                                                         ProgressPercent Pct3
                                                  WHERE Pct3.ID = GoalPct3.ProgressPercentID
                                                    AND GoalPct3.GoalID = GoalPct2.GoalID
                                                )
                                           THEN PercentDate =
                                                   (SELECT MAX(PercentDate)
                                                      FROM GoalProgressPercent GoalPct4,
                                                           ProgressPercent Pct4
                                                     WHERE Pct4.ID = GoalPct4.ProgressPercentID
                                                       AND GoalPct4.GoalID = GoalPct2.GoalID
                                                   )
                                           ELSE TRUE
                                       END
                              )
               )
 WHERE PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Goal.ProjectSummaryID = Summ.ID

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Objective_Id IS NULL THEN "" ELSE CONCAT(Objective_Id,". ") END,
              CASE WHEN Obj.Name IS NULL THEN "" ELSE Obj.Name END
             ) AS Objective,
       CONCAT(CASE WHEN Indicator_Id IS NULL THEN "" ELSE CONCAT(Indicator_Id,". ") END,
              CASE WHEN Ind.Name IS NULL THEN "" ELSE Ind.Name END
             ) AS Indicator,
       ProgressStatus, fn_CalcWho(Ind.ProjectSummaryID,"Indicator",Ind.ID) AS Who,
       Ind.CalculatedStartDate, Ind.CalculatedEndDate, Ind.Details
  FROM ProjectSummary Summ, ExternalProjectId PID, Objective Obj, ObjectiveRelevantIndicator ObjInd,
       Indicator Ind
          LEFT JOIN (IndicatorProgressReport IndPrg, ProgressReport Prg)
                 ON (    Prg.ID = IndPrg.ProgressReportID
                     AND IndPrg.IndicatorID = Ind.ID
                     AND Prg.XID = (SELECT MAX(IndPrg2.ProgressReportXID)
                                      FROM IndicatorProgressReport IndPrg2
                                     WHERE IndPrg2.IndicatorID = IndPrg.IndicatorID
                                       AND CASE WHEN EXISTS
                                                     (SELECT ProgressDate
                                                        FROM IndicatorProgressReport IndPrg3,
                                                             ProgressReport Prg3
                                                       WHERE Prg3.ID = IndPrg3.ProgressReportID
                                                         AND IndPrg3.IndicatorID = IndPrg2.IndicatorID
                                                     )
                                                THEN ProgressDate =
                                                     (SELECT MAX(ProgressDate)
                                                        FROM IndicatorProgressReport IndPrg4,
                                                             ProgressReport Prg4
                                                       WHERE Prg4.ID = IndPrg4.ProgressReportID
                                                         AND IndPrg4.IndicatorID = IndPrg2.IndicatorID
                                                     )
                                                ELSE TRUE
                                            END
                                   )
                    )
 WHERE Ind.ID = ObjInd.IndicatorID
   AND ObjInd.ObjectiveID = Obj.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Ind.ProjectSummaryID = Summ.ID

 UNION ALL

SELECT Summ.ID AS ProjectSummaryID, ProjectName, ProjectId,
       CONCAT(CASE WHEN Goal_Id IS NULL THEN "" ELSE CONCAT(Goal_Id,". ") END,
              CASE WHEN Goal.Name IS NULL THEN "" ELSE Goal.Name END
             ) AS Objective,
       CONCAT(CASE WHEN Indicator_Id IS NULL THEN "" ELSE CONCAT(Indicator_Id,". ") END,
              CASE WHEN Ind.Name IS NULL THEN "" ELSE Ind.Name END
             ) AS Indicator,
       ProgressStatus, fn_CalcWho(Ind.ProjectSummaryID,"Indicator",Ind.ID) AS Who,
       Ind.CalculatedStartDate, Ind.CalculatedEndDate, Ind.Details
  FROM ProjectSummary Summ, ExternalProjectId PID, Goal Goal, GoalRelevantIndicator GoalInd,
       Indicator Ind
          LEFT JOIN (IndicatorProgressReport IndPrg, ProgressReport Prg)
                 ON (    Prg.ID = IndPrg.ProgressReportID
                     AND IndPrg.IndicatorID = Ind.ID
                     AND Prg.XID = (SELECT MAX(IndPrg2.ProgressReportXID)
                                      FROM IndicatorProgressReport IndPrg2
                                     WHERE IndPrg2.IndicatorID = IndPrg.IndicatorID
                                       AND CASE WHEN EXISTS
                                                     (SELECT ProgressDate
                                                        FROM IndicatorProgressReport IndPrg3,
                                                             ProgressReport Prg3
                                                       WHERE Prg3.ID = IndPrg3.ProgressReportID
                                                         AND IndPrg3.IndicatorID = IndPrg2.IndicatorID
                                                     )
                                                THEN ProgressDate =
                                                     (SELECT MAX(ProgressDate)
                                                        FROM IndicatorProgressReport IndPrg4,
                                                             ProgressReport Prg4
                                                       WHERE Prg4.ID = IndPrg4.ProgressReportID
                                                         AND IndPrg4.IndicatorID = IndPrg2.IndicatorID
                                                     )
                                                ELSE TRUE
                                            END
                                   )
                    )
 WHERE Ind.ID = GoalInd.IndicatorID
   AND GoalInd.GoalID = Goal.ID
   AND PID.ProjectSummaryID = Summ.ID
   AND PID.ExternalApp = "ConPro"
   AND Summ.ID = (SELECT MAX(ProjectSummaryID)
                    FROM ExternalProjectID PID2
                   WHERE PID2.ExternalApp = PID.ExternalApp
                     AND PID2.ProjectId = PID.ProjectId
                 )
   AND Ind.ProjectSummaryID = Summ.ID
 ORDER BY ProjectSummaryID, Objective, Indicator