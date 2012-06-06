/* Miradi Database Upgrade 2012-03-06

   - For Dan and Annette only.

*/

USE Miradi;

DROP VIEW IF EXISTS v_IndicatorMeasurement;     /* Joins IndicatorMeasurement and Measurement,
                                                   including the RATING() value of Measurement.Rating
                                                   
                                                   Has to follow function RATING(). 
                                                */
CREATE VIEW v_IndicatorMeasurement AS
       SELECT IndicatorID, IndicatorXID, Meas.*, RATING(Rating) AS IndicatorRating
         FROM IndicatorMeasurement Ind, Measurement Meas
        WHERE Meas.ID = Ind.MeasurementID;


DROP VIEW IF EXISTS v_ThreatIndicator;               -- Joins CauseIndicator with Indicator.
CREATE VIEW v_ThreatIndicator AS
       SELECT CauseID AS ThreatID, CauseXID AS ThreatXID, Ind.*
         FROM Threat Thr, CauseIndicator ThrInd, Indicator Ind
        WHERE Ind.ID = ThrInd.IndicatorID
          AND ThrInd.CauseID = Thr.ID;


CREATE VIEW v_StrategyAssignment AS
       SELECT StrategyID, StrategyXID, Asgn.*
         FROM StrategyAssignment StrAsgn, ResourceAssignment Asgn
        WHERE Asgn.ID = StrAsgn.ResourceAssignmentID; 


CREATE VIEW v_TaskAssignment AS
       SELECT TaskID, TaskXID, Asgn.*
         FROM TaskAssignment TaskAsgn, ResourceAssignment Asgn
        WHERE Asgn.ID = TaskAsgn.ResourceAssignmentID; 


CREATE VIEW v_ActivityAssignment AS
       SELECT ActivityID, ActivityXID, Asgn.*
         FROM ActivityAssignment ActAsgn, ResourceAssignment Asgn
        WHERE Asgn.ID = ActAsgn.ResourceAssignmentID; 


CREATE VIEW v_MethodAssignment AS
       SELECT MethodID, MethodXID, Asgn.*
         FROM MethodAssignment MethAsgn, ResourceAssignment Asgn
        WHERE Asgn.ID = MethAsgn.ResourceAssignmentID; 


CREATE VIEW v_StrategyExpense AS
       SELECT StrategyID, StrategyXID, Exp.*
         FROM StrategyExpense StrExp, ExpenseAssignment Exp
        WHERE Exp.ID = StrExp.ExpenseAssignmentID; 


CREATE VIEW v_TaskExpense AS
       SELECT TaskID, TaskXID, Exp.*
         FROM TaskExpense TaskExp, ExpenseAssignment Exp
        WHERE Exp.ID = TaskExp.ExpenseAssignmentID; 


CREATE VIEW v_ActivityExpense AS
       SELECT ActivityID, ActivityXID, Exp.*
         FROM ActivityExpense ActExp, ExpenseAssignment Exp
        WHERE Exp.ID = ActExp.ExpenseAssignmentID; 


CREATE VIEW v_MethodExpense AS
       SELECT MethodID, MethodXID, Exp.*
         FROM MethodExpense MethExp, ExpenseAssignment Exp
        WHERE Exp.ID = MethExp.ExpenseAssignmentID; 


CREATE VIEW v_StrategyActivity AS
       SELECT StrategyID, StrategyXID, Act.*
         FROM StrategyActivity StrAct, Activity Act
        WHERE Act.ID = StrAct.ActivityID; 


CREATE VIEW v_ActivityTask AS
       SELECT ActivityID, ActivityXID, Task.*
         FROM ActivityTask ActTask, Task
        WHERE Task.ProjectSummaryID = ActTask.ProjectSummaryID
          AND Task.XID = ActTask.TaskXID;
          

CREATE VIEW v_TaskSubTask AS
       SELECT TaskID, TaskXID, Sequence, Task.*
         FROM TaskSubTask, Task
        WHERE Task.ProjectSummaryID = TaskSubTask.ProjectSummaryID
          AND Task.XID = TaskSubTask.TaskXID;
          

CREATE VIEW v_ActivityTask AS
       SELECT ActivityID, ActivityXID, Sequence, Task.*
         FROM ActivityTask ActTask, Task
        WHERE Task.ProjectSummaryID = ActTask.ProjectSummaryID
          AND Task.XID = ActTask.TaskXID;
          

DROP VIEW IF EXISTS v_ObjectiveIndicator;
CREATE VIEW v_ObjectiveIndicator AS
       SELECT ObjectiveID, ObjectiveXID, Ind.*
         FROM ObjectiveRelevantIndicator Obj, Indicator Ind
        WHERE Ind.ID = Obj.IndicatorID; 


DROP VIEW IF EXISTS v_TargetKeyAttribute;     -- Joins TargetKeyEcologicalAttribute with v_KeyAttribute.
CREATE VIEW v_TargetKeyAttribute AS
       SELECT TargetID, TargetXID, KEA.*
         FROM TargetKeyEcologicalAttribute TgtKEA, v_KeyAttribute KEA
        WHERE KEA.ID = TgtKEA.KeyEcologicalAttributeID;
 

DROP VIEW IF EXISTS v_BiodiversityTargetKeyAttribute; -- Joins BiodiversityTargetKeyEcologicalAttribute 
CREATE VIEW v_BiodiversityTargetKeyAttribute AS       -- with v_KeyAttribute.
       SELECT BiodiversityTargetID, BiodiversityTargetXID, KEA.*
         FROM BiodiversityTargetKeyEcologicalAttribute TgtKEA, v_KeyAttribute KEA
        WHERE KEA.ID = TgtKEA.KeyEcologicalAttributeID;


DROP VIEW IF EXISTS v_HumanWelfareTargetKeyAttribute; -- Joins HumanWelfareTargetKeyEcologicalAttribute 
CREATE VIEW v_HumanWelfareTargetKeyAttribute AS       -- with v_KeyAttribute.
       SELECT HumanWelfareTargetID, HumanWelfareTargetXID, KEA.*
         FROM HumanWelfareTargetKeyEcologicalAttribute TgtKEA, v_KeyAttribute KEA
        WHERE KEA.ID = TgtKEA.KeyEcologicalAttributeID;


DROP VIEW IF EXISTS v_TargetIndicator;
CREATE VIEW v_TargetIndicator AS
       SELECT TargetID, TargetXID, Ind.*
         FROM TargetIndicator TgtInd, Indicator Ind
        WHERE Ind.ID = TgtInd.IndicatorID; 

CREATE VIEW v_KeyAttributeIndicator AS
       SELECT KeyEcologicalAttributeID AS KeyAttributeID, 
              KeyEcologicalAttributeXID AS KeyAttributeXID, Ind.*
         FROM KeyEcologicalAttributeIndicator KeaInd, Indicator Ind
        WHERE Ind.ID = KeaInd.IndicatorID;


-- END