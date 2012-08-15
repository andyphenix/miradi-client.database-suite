/*
   TableDumps_v47.sql
   
   Table Dumps for the Miradi Database.

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
   Miradi Database Suite. If not, it is situated at < http://www.gnu.org/licenses/gpl.html >
   and is incorporated herein by reference.
   
   **********************************************************************************************

   Revision History:
   Version 47 - 2012-07-01 - Corresponds to Miradi 3.3 Database_v47a.
*/

USE Miradi;

SELECT * FROM ConservationProject ORDER BY ProjectSummaryID DESC;
SELECT * FROM ProjectID;
SELECT * FROM ProjectSummary ORDER BY ID DESC;
SELECT * FROM v_Project ORDER BY ProjectSummaryId DESC;
SELECT * FROM v_ParentProject ORDER BY ProjectId DESC; 
SELECT * FROM ProjectScope ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM ProjectPlanning ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM Audience ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM PlanningViewConfiguration ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ExternalProjectID ORDER BY ProjectId, ProjectSummaryID DESC;
SELECT * FROM ProtectedAreaCategories ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM ProjectLocation ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM ProjectCountries ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM GeospatialLocation ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM Organization ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TNCProjectData ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM TNCProjectPlaceTypes ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM TNCOrganizationalPriorities ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM TNCOperatingUnits ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM TNCTerrestrialEcoregion ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM TNCMarineEcoregion ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM TNCFreshwaterEcoregion ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM WWFProjectData ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM WWFManagingOffices ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM WWFRegions ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM WWFEcoregions ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM WCSData ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM RareProjectData ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM FosProjectData ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM ProjectResource ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM ProjectResourceRoleCodes ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM AccountingCode ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM FundingSource ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM BudgetCategoryOne ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM BudgetCategoryTwo ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ResourceAssignment ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM CalculatedWorkUnits ORDER BY ProjectSummaryID DESC, Factor, FactorXID;
SELECT * FROM CalculatedWho ORDER BY ProjectSummaryID DESC, Factor, FactorXID;
SELECT * FROM DateUnitWorkUnits ORDER BY ProjectSummaryID DESC, Factor, FactorXID;
SELECT * FROM ExpenseAssignment ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM CalculatedExpense ORDER BY ProjectSummaryID DESC, Factor, FactorXID;
SELECT * FROM DateUnitExpense ORDER BY ProjectSummaryID DESC, Factor, FactorXID;
SELECT * FROM v_PlanYears ORDER BY ProjectSummaryID DESC, PlanYear, Factor;
SELECT * FROM v_AcctYears ORDER BY ProjectSummaryID DESC, AcctYear, Factor, AccountingCodeID;
SELECT * FROM v_FundYears ORDER BY ProjectSummaryID DESC, FundYear, Factor, FundingSourceID;
SELECT * FROM v_RsrcYears ORDER BY ProjectSummaryID DESC, RsrcYear, Factor, ProjectResourceID;
SELECT * FROM TaskActivityMethod ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TaskActivityMethodProgressReport ORDER BY ProjectSummaryID DESC, TaskActivityMethodXID;
SELECT * FROM TaskActivityMethodAssignment ORDER BY ProjectSummaryID DESC, TaskActivityMethodXID;
SELECT * FROM TaskActivityMethodExpense ORDER BY ProjectSummaryID DESC, TaskActivityMethodXID;
SELECT * FROM TaskSubTask ORDER BY ProjectSummaryID DESC;
SELECT * FROM Target ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM BiodiversityTarget ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM HumanWelfareTarget ORDER BY ProjectSummaryID DESC, ID;
SELECT * FROM SubTarget ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TargetSubTarget ORDER BY ProjectSummaryID DESC, TargetXID, SubTargetXID;
SELECT * FROM BiodiversityTargetSubTarget ORDER BY ProjectSummaryID DESC, BiodiversityTargetXID, SubTargetXID;
SELECT * FROM HumanWelfareTargetSubTarget ORDER BY ProjectSummaryID DESC, HumanWelfareTargetXID, SubTargetXID;
SELECT * FROM TargetHabitatAssociation ORDER BY ProjectSummaryID DESC, TargetXID;
SELECT * FROM BiodiversityTargetHabitatAssociation ORDER BY ProjectSummaryID DESC, BiodiversityTargetXID;
SELECT * FROM KeyEcologicalAttribute ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TargetKeyEcologicalAttribute ORDER BY ProjectSummaryID DESC, TargetXID, KeyEcologicalAttributeXID;
SELECT * FROM v_TargetKeyAttribute ORDER BY ProjectSummaryID DESC, TargetXID, XID;
SELECT * FROM BiodiversityTargetKeyEcologicalAttribute ORDER BY ProjectSummaryID DESC, BiodiversityTargetXID, KeyEcologicalAttributeXID;
SELECT * FROM v_BiodiversityTargetKeyAttribute ORDER BY ProjectSummaryID DESC, BiodiversityTargetXID, XID;
SELECT * FROM HumanWelfareTargetKeyEcologicalAttribute ORDER BY ProjectSummaryID DESC, HumanWelfareTargetXID, KeyEcologicalAttributeXID;;
SELECT * FROM v_HumanWelfareTargetKeyAttribute ORDER BY ProjectSummaryID DESC, HumanWelfareTargetXID, XID;
SELECT * FROM Indicator ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TargetIndicator ORDER BY ProjectSummaryID DESC, TargetXID, IndicatorXID;
SELECT * FROM v_TargetIndicator ORDER BY ProjectSummaryID DESC, TargetXID, XID;
SELECT * FROM BiodiversityTargetIndicator ORDER BY ProjectSummaryID DESC, BiodiversityTargetXID, IndicatorXID;
SELECT * FROM v_BiodiversityTargetIndicator ORDER BY ProjectSummaryID DESC, BiodiversityTargetXID, XID;
SELECT * FROM HumanWelfareTargetIndicator ORDER BY ProjectSummaryID DESC, HumanWelfareTargetXID, IndicatorXID;
SELECT * FROM v_HumanWelfareTargetIndicator ORDER BY ProjectSummaryID DESC, HumanWelfareTargetXID, XID;
SELECT * FROM KeyEcologicalAttributeIndicator ORDER BY ProjectSummaryID DESC, KeyEcologicalAttributeXID, IndicatorXID;
SELECT * FROM v_KeyAttributeIndicator ORDER BY ProjectSummaryID DESC, KeyAttributeXID, XID;
SELECT * FROM IndicatorThreshold ORDER BY ProjectSummaryID DESC, IndicatorXID, StatusCode;
SELECT * FROM ProgressReport ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM IndicatorProgressReport ORDER BY ProjectSummaryID DESC, IndicatorXID, ProgressReportXID;
SELECT * FROM v_IndicatorProgressReport ORDER BY ProjectSummaryID DESC, IndicatorXID, XID;
SELECT * FROM Measurement ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM IndicatorMeasurement ORDER BY ProjectSummaryID DESC, IndicatorXID, MeasurementXID;
SELECT * FROM v_IndicatorMeasurement ORDER BY ProjectSummaryID DESC, IndicatorXID, XID;
SELECT * FROM IndicatorMethod ORDER BY ProjectSummaryID DESC, IndicatorXID, Sequence;
SELECT * FROM v_IndicatorMethod ORDER BY ProjectSummaryID DESC, IndicatorXID, Sequence;
SELECT * FROM IndicatorAssignment ORDER BY ProjectSummaryID DESC, IndicatorXID, ResourceAssignmentXID;
SELECT * FROM v_IndicatorAssignment ORDER BY ProjectSummaryID DESC, IndicatorXID, XID;
SELECT * FROM IndicatorCalculatedWorkUnits ORDER BY ProjectSummaryID DESC, IndicatorXID, ProjectResourceXID;
SELECT * FROM IndicatorCalculatedWho ORDER BY ProjectSummaryID DESC, IndicatorXID, ProjectResourceXID;
SELECT * FROM IndicatorExpense ORDER BY ProjectSummaryID DESC, IndicatorXID, ExpenseAssignmentXID;
SELECT * FROM v_IndicatorExpense ORDER BY ProjectSummaryID DESC, IndicatorXID, XID;
SELECT * FROM IndicatorCalculatedExpense ORDER BY ProjectSummaryID DESC, IndicatorXID;
SELECT * FROM Method ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM MethodProgressReport ORDER BY ProjectSummaryID DESC, MethodXID, ProgressReportXID;
SELECT * FROM v_MethodProgressReport ORDER BY ProjectSummaryID DESC, MethodXID, XID;
SELECT * FROM MethodAssignment ORDER BY ProjectSummaryID DESC, MethodXID, ResourceAssignmentXID;
SELECT * FROM v_MethodAssignment ORDER BY ProjectSummaryID DESC, MethodXID, XID;
SELECT * FROM MethodCalculatedWorkUnits ORDER BY ProjectSummaryID DESC, MethodXID, ProjectResourceXID;
SELECT * FROM MethodCalculatedWho ORDER BY ProjectSummaryID DESC, MethodXID, ProjectResourceXID;
SELECT * FROM MethodExpense ORDER BY ProjectSummaryID DESC, MethodXID, ExpenseAssignmentXID;
SELECT * FROM v_MethodExpense ORDER BY ProjectSummaryID DESC, MethodXID, XID;
SELECT * FROM MethodCalculatedExpense ORDER BY ProjectSummaryID DESC, MethodXID;
SELECT * FROM MethodTask ORDER BY ProjectSummaryID DESC, MethodXID, Sequence;
SELECT * FROM v_MethodTask ORDER BY ProjectSummaryID DESC, MethodXID, Sequence;
SELECT * FROM Strategy ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM StrategyProgressReport ORDER BY ProjectSummaryID DESC, StrategyXID, ProgressReportXID;
SELECT * FROM v_StrategyProgressReport ORDER BY ProjectSummaryID DESC, StrategyXID, XID;
SELECT * FROM StrategyAssignment ORDER BY ProjectSummaryID DESC, StrategyXID, ResourceAssignmentXID;
SELECT * FROM v_StrategyAssignment ORDER BY ProjectSummaryID DESC, StrategyXID, XID;
SELECT * FROM StrategyCalculatedWorkUnits ORDER BY ProjectSummaryID DESC, StrategyXID, ProjectResourceXID;
SELECT * FROM StrategyCalculatedWho ORDER BY ProjectSummaryID DESC, StrategyXID, ProjectResourceXID;
SELECT * FROM StrategyExpense ORDER BY ProjectSummaryID DESC, StrategyXID, ExpenseAssignmentXID;
SELECT * FROM v_StrategyExpense ORDER BY ProjectSummaryID DESC, StrategyXID, XID;
SELECT * FROM StrategyCalculatedExpense ORDER BY ProjectSummaryID DESC, StrategyXID;
SELECT * FROM StrategyIndicator ORDER BY ProjectSummaryID DESC, StrategyXID, IndicatorXID;
SELECT * FROM StrategyThreat ORDER BY ProjectSummaryID DESC, StrategyXID, ThreatXID;
SELECT * FROM StrategyTarget ORDER BY ProjectSummaryID DESC, StrategyXID, TargetXID;
SELECT * FROM v_StrategyThreatTarget ORDER BY ProjectSummaryID DESC, StrategyXID, ThreatXID, TargetXID;
SELECT * FROM StrategyObjective ORDER BY ProjectSummaryID DESC, StrategyXID, ObjectiveXID;
SELECT * FROM v_StrategyObjective ORDER BY ProjectSummaryID DESC, StrategyXID, XID;
SELECT * FROM StrategyGoal ORDER BY ProjectSummaryID DESC, StrategyXID, GoalXID;
SELECT * FROM v_StrategyGoal ORDER BY ProjectSummaryID DESC, StrategyXID, XID;
SELECT * FROM StrategyActivity ORDER BY ProjectSummaryID DESC, StrategyXID, Sequence;
SELECT * FROM v_StrategyActivity ORDER BY ProjectSummaryID DESC, StrategyXID, Sequence;
SELECT * FROM Activity ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ActivityProgressReport ORDER BY ProjectSummaryID DESC, ActivityXID, ProgressReportXID;
SELECT * FROM v_ActivityProgressReport ORDER BY ProjectSummaryID DESC, ActivityXID, XID;
SELECT * FROM ActivityAssignment ORDER BY ProjectSummaryID DESC, ActivityXID, ResourceAssignmentXID;
SELECT * FROM v_ActivityAssignment ORDER BY ProjectSummaryID DESC, ActivityXID, XID;
SELECT * FROM ActivityCalculatedWorkUnits ORDER BY ProjectSummaryID DESC, ActivityXID, ProjectResourceXID;
SELECT * FROM ActivityCalculatedWho ORDER BY ProjectSummaryID DESC, ActivityXID, ProjectResourceXID;
SELECT * FROM ActivityExpense ORDER BY ProjectSummaryID DESC, ActivityXID, ExpenseAssignmentXID;
SELECT * FROM v_ActivityExpense ORDER BY ProjectSummaryID DESC, ActivityXID, XID;
SELECT * FROM ActivityCalculatedExpense ORDER BY ProjectSummaryID DESC, ActivityXID;
SELECT * FROM ActivityTask ORDER BY ProjectSummaryID DESC, ActivityXID, Sequence;
SELECT * FROM v_ActivityTask ORDER BY ProjectSummaryID DESC, XID, Sequence;
SELECT * FROM Task ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM v_SubTask ORDER BY ProjectSummaryID DESC, TaskXID, Sequence;
SELECT * FROM TaskProgressReport ORDER BY ProjectSummaryID DESC, TaskXID, ProgressReportXID;
SELECT * FROM TaskAssignment ORDER BY ProjectSummaryID DESC, TaskXID, ResourceAssignmentXID;
SELECT * FROM v_TaskAssignment ORDER BY ProjectSummaryID DESC, TaskXID, XID;
SELECT * FROM TaskCalculatedWorkUnits ORDER BY ProjectSummaryID DESC, TaskXID, ProjectResourceXID;
SELECT * FROM TaskCalculatedWho ORDER BY ProjectSummaryID DESC, TaskXID, ProjectResourceXID;
SELECT * FROM TaskExpense ORDER BY ProjectSummaryID DESC, TaskXID, ExpenseAssignmentXID;
SELECT * FROM v_TaskExpense ORDER BY ProjectSummaryID DESC, TaskXID, XID;
SELECT * FROM TaskCalculatedExpense ORDER BY ProjectSummaryID DESC, TaskXID;
SELECT * FROM Objective ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM Goal ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TargetGoal ORDER BY ProjectSummaryID DESC, TargetXID, GoalXID;
SELECT * FROM BiodiversityTargetGoal ORDER BY ProjectSummaryID DESC, BiodiversityTargetXID, GoalID;
SELECT * FROM HumanWelfareTargetGoal ORDER BY ProjectSummaryID DESC, HumanWelfareTargetXID, GoalXID;
SELECT * FROM v_TargetGoal ORDER BY ProjectSummaryID DESC, TargetXID, XID;
SELECT * FROM ObjectiveRelevantIndicator ORDER BY ProjectSummaryID DESC, ObjectiveXID, IndicatorXID;
SELECT * FROM v_ObjectiveRelevantIndicator ORDER BY ProjectSummaryID DESC, ObjectiveXID, XID;
SELECT * FROM GoalRelevantIndicator ORDER BY ProjectSummaryID DESC, GoalXID, IndicatorXID;
SELECT * FROM v_GoalRelevantIndicator ORDER BY ProjectSummaryID DESC, GoalXID, XID;
SELECT * FROM ObjectiveProgressReport ORDER BY ProjectSummaryID DESC, ObjectiveXID, ProgressReportXID;
SELECT * FROM v_ObjectiveProgressReport ORDER BY ProjectSummaryID DESC, ObjectiveXID, XID;
SELECT * FROM GoalProgressReport ORDER BY ProjectSummaryID DESC, GoalXID, ProgressReportXID;
SELECT * FROM v_GoalProgressReport ORDER BY ProjectSummaryID DESC, GoalXID, XID;
SELECT * FROM ObjectiveRelevantStrategy ORDER BY ProjectSummaryID DESC, ObjectiveXID, StrategyXID;
SELECT * FROM v_ObjectiveRelevantStrategy ORDER BY ProjectSummaryID DESC, ObjectiveXID, XID;
SELECT * FROM GoalRelevantStrategy ORDER BY ProjectSummaryID DESC, GoalXID, StrategyXID;
SELECT * FROM v_GoalRelevantStrategy ORDER BY ProjectSummaryID DESC, GoalXID, XID;
SELECT * FROM ObjectiveRelevantActivity ORDER BY ProjectSummaryID DESC, ObjectiveXID, ActivityXID;
SELECT * FROM v_ObjectiveRelevantActivity ORDER BY ProjectSummaryID DESC, ObjectiveXID, XID;
SELECT * FROM GoalRelevantActivity ORDER BY ProjectSummaryID DESC, GoalXID, ActivityXID;
SELECT * FROM v_GoalRelevantActivity ORDER BY ProjectSummaryID DESC, GoalXID, XID;
SELECT * FROM ProgressPercent ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ObjectiveProgressPercent ORDER BY ProjectSummaryID DESC, ObjectiveXID, ProgressPercentXID;
SELECT * FROM v_ObjectiveProgressPercent ORDER BY ProjectSummaryID DESC, ObjectiveXID, XID;
SELECT * FROM GoalProgressPercent ORDER BY ProjectSummaryID DESC, GoalXID, ProgressPercentXID;
SELECT * FROM v_GoalProgressPercent ORDER BY ProjectSummaryID DESC, GoalXID, XID;
SELECT * FROM Cause ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM Threat ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM CauseIndicator ORDER BY ProjectSummaryID DESC, CauseXID, IndicatorXID;
SELECT * FROM CauseObjective ORDER BY ProjectSummaryID DESC, CauseXID, ObjectiveXID;
SELECT * FROM Stress ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TargetStress ORDER BY ProjectSummaryID DESC, TargetXID, StressXID;
SELECT * FROM BiodiversityTargetStress ORDER BY ProjectSummaryID DESC, BiodiversityTargetXID, StressXID;
SELECT * FROM HumanWelfareTargetStress ORDER BY ProjectSummaryID DESC, HumanWelfareTargetXID, StressXID;
SELECT * FROM ThreatRating ORDER BY ProjectSummaryID DESC, TargetXID, ThreatXID;
SELECT * FROM ThreatTarget ORDER BY ProjectSummaryID DESC, ThreatXID, TargetXID;
SELECT * FROM SimpleThreatRating ORDER BY ProjectSummaryID DESC, ThreatRatingXID;
SELECT * FROM StressBasedThreatRating ORDER BY ProjectSummaryID DESC, StressXID, ThreatRatingXID;
SELECT * FROM Result ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ThreatReductionResult ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM IntermediateResult ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ResultIndicator ORDER BY ProjectSummaryID DESC, ResultXID, IndicatorXID;
SELECT * FROM IntermediateResultIndicator ORDER BY ProjectSummaryID DESC, IntermediateResultXID, IndicatorXID;
SELECT * FROM ThreatReductionResultIndicator ORDER BY ProjectSummaryID DESC, ThreatReductionResultXID, IndicatorXID;
SELECT * FROM ResultObjective ORDER BY ProjectSummaryID DESC, ResultXID, ObjectiveXID;
SELECT * FROM IntermediateResultObjective ORDER BY ProjectSummaryID DESC, IntermediateResultXID, ObjectiveXID;;
SELECT * FROM ThreatReductionResultObjective ORDER BY ProjectSummaryID DESC, ThreatReductionResultXID, ObjectiveXID;
SELECT * FROM DiagramFactor ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM DiagramLink ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM v_DiagramLink ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM DiagramLinkBendPoint ORDER BY ProjectSummaryID DESC, DiagramLinkXID;
SELECT * FROM GroupedDiagramLink ORDER BY ProjectSummaryID DESC, DiagramLinkXID, DiagramLinkRef;
SELECT * FROM v_GroupedDiagramLink ORDER BY ProjectSummaryID DESC, DiagramLinkXID, DiagramLinkRef;
SELECT * FROM GroupBox ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM GroupBoxChildren ORDER BY ProjectSummaryID DESC, DiagramFactorXID, DiagramFactorRef;
SELECT * FROM v_GroupBoxChildren ORDER BY ProjectSummaryID DESC, DiagramFactorXID;
SELECT * FROM TextBox ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ScopeBox ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TaggedObjectSet ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM TaggedObjectSetFactor ORDER BY ProjectSummaryID DESC, TaggedObjectSetXID;
SELECT * FROM ConceptualModel ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ConceptualModelDiagramFactor ORDER BY ProjectSummaryID DESC, ConceptualModelXID, DiagramFactorXID;
SELECT * FROM v_ConceptualModelFactor ORDER BY ProjectSummaryID DESC, ConceptualModelXID;
SELECT * FROM ConceptualModelDiagramLink ORDER BY ProjectSummaryID DESC, ConceptualModelXID, DiagramLinkXID;
SELECT * FROM v_ConceptualModelLink ORDER BY ProjectSummaryID DESC, ConceptualModelXID;
SELECT * FROM ConceptualModelHiddenTypes ORDER BY ProjectSummaryID DESC, ConceptualModelXID;
SELECT * FROM ConceptualModelTaggedObjectSet ORDER BY ProjectSummaryID DESC, ConceptualModelXID, TaggedObjectSetXID;
SELECT * FROM ResultsChain ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ResultsChainDiagramFactor ORDER BY ProjectSummaryID DESC, ResultsChainXID, DiagramFactorXID;
SELECT * FROM v_ResultsChainFactor ORDER BY ProjectSummaryID DESC, ResultsChainXID;
SELECT * FROM ResultsChainDiagramLink ORDER BY ProjectSummaryID DESC, ResultsChainXID, DiagramLinkXID;
SELECT * FROM v_ResultsChainLink ORDER BY ProjectSummaryID DESC, ResultsChainXID;
SELECT * FROM ResultsChainHiddenTypes ORDER BY ProjectSummaryID DESC, ResultsChainXID;
SELECT * FROM ResultsChainTaggedObjectSet ORDER BY ProjectSummaryID DESC, ResultsChainXID, TaggedObjectSetXID;
SELECT * FROM Dashboard ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM StatusEntry ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM DashboardFlags ORDER BY ProjectSummaryID DESC, StatusEntryXID;
SELECT * FROM ExtraDataSection ORDER BY ProjectSummaryID DESC, XID;
SELECT * FROM ExtraDataItem ORDER BY ProjectSummaryID DESC, ExtraDataSectionXID;