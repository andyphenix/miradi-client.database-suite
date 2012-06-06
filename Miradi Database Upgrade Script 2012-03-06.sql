/* Miradi Database Upgrade 2012-03-06

   - Added views v_StrategyActivity, v_ObjectiveIndicator,
     v_Task/Activity/MethodAssignment, v_Task/Activity/MethodExpense,
     v_TargetKeyAttribute, v_KeyAttributeIndicator, v_TargetIndicator.
   - Amended views v_IndicatorMeasurement, v_ThreatIndicator.   
   - Change letter case on ENUM values to precisely match XML Schema Vocabulary.
   - Add function fn_StripTags().
   - Change letter case on ENUM values to match XML Schema Vocabulary.
   - Add FiscalYear to DateUnitWorkUnits, DateUnitExpense and their views.
   - Revise views that associate Work/Expense Plan Factors with Years.
   - Add function fn_ExpenseName().


*/

USE Miradi;

DROP VIEW IF EXISTS v_ThreatIndicator;               -- Joins CauseIndicator with Indicator.
CREATE VIEW v_ThreatIndicator AS
       SELECT CauseID AS ThreatID, CauseXID AS ThreatXID, Ind.*
         FROM Threat Thr, CauseIndicator ThrInd, Indicator Ind
        WHERE Ind.ID = ThrInd.IndicatorID
          AND ThrInd.CauseID = Thr.ID;


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


ALTER TABLE ProjectSummary
      MODIFY COLUMN WorkPlanTimeUnit ENUM("QUARTERLY","YEARLY");
      
      
ALTER TABLE ProtectedAreaCategories CHANGE Code code ENUM("Ia","Ib","II","III","IV","V","VI");
ALTER TABLE ProjectCountries CHANGE Code code CHAR(3);
ALTER TABLE GeospatialLocation 
      CHANGE Latitude latitude DECIMAL(6,4),
      CHANGE Longitude longitude DECIMAL(7,4);
      
      
ALTER TABLE DateUnitWorkUnits
      ADD COLUMN FiscalYear SMALLINT AFTER EndDate;
      
ALTER TABLE DateUnitExpense
      ADD COLUMN FiscalYear SMALLINT AFTER EndDate;
      
      UPDATE DateUnitWorkUnits, ProjectPlanning Plan
         SET StartYear =
             CASE WHEN WorkUnitsDateUnit IN ("Month","Quarter","Year")
                       THEN SUBSTRING_INDEX(SUBSTRING_INDEX(WorkUnitsDate,"\"",2),"\"",-1)
                  WHEN WorkUnitsDateUnit = "Day"
                       THEN SUBSTRING_INDEX(SUBSTRING_INDEX(WorkUnitsDate,"-",1),"\"",-1)
                  WHEN WorkUnitsDateUnit LIKE "Full%"
                       THEN YEAR(CASE WHEN Plan.WorkPlanStartDate IS NOT NULL
                                           THEN Plan.WorkPlanStartDate
                                      WHEN Plan.StartDate IS NOT NULL
                                      THEN Plan.StartDate
                                      ELSE CURRENT_DATE()
                                  END
                                )
              END,
             StartMonth =
             CASE WHEN WorkUnitsDateUnit IN ("Month","Quarter","Year")
                       THEN SUBSTRING_INDEX(SUBSTRING_INDEX(WorkUnitsDate,"\"",4),"\"",-1)
                  WHEN WorkUnitsDateUnit = "Day"
                       THEN SUBSTRING_INDEX(SUBSTRING_INDEX(WorkUnitsDate,"-",2),"-",-1)
                  WHEN WorkUnitsDateUnit LIKE "Full%"
                       THEN MONTH(CASE WHEN Plan.WorkPlanStartDate IS NOT NULL
                                            THEN Plan.WorkPlanStartDate
                                       WHEN Plan.StartDate IS NOT NULL
                                       THEN Plan.StartDate
                                       ELSE CURRENT_DATE()
                                   END
                                 )
              END
       WHERE Plan.ProjectSummaryID = DateUnitWorkUnits.ProjectSummaryID;
         
      UPDATE DateUnitWorkUnits, ProjectPlanning Plan
         SET DateUnitWorkUnits.StartDate =
             CASE WHEN WorkUnitsDateUnit = "Day" THEN
                       DATE(SUBSTRING_INDEX(
                               SUBSTRING_INDEX(WorkUnitsDate,
                                               '"',2
                                              ),'"',-1
                                           )
                           )
                  WHEN WorkUnitsDateUnit IN ("Month","Quarter","Year") THEN
                       DATE(CONCAT(StartYear,"-",StartMonth,"-01"))
                  WHEN WorkUnitsDateUnit LIKE "%Full%" THEN
                       CASE WHEN Plan.WorkPlanStartDate IS NOT NULL
                                 THEN Plan.WorkPlanStartDate
                            WHEN Plan.StartDate IS NOT NULL
                                 THEN Plan.StartDate
                            ELSE CURRENT_DATE()
                        END
              END,
             DateUnitWorkUnits.EndDate =
             CASE WorkUnitsDateUnit
                  WHEN "Day" THEN
                       DATE(SUBSTRING_INDEX(
                               SUBSTRING_INDEX(WorkUnitsDate,
                                               '"',2
                                              ),'"',-1
                                           )
                           )
                  WHEN "Month" THEN
                       SUBDATE(ADDDATE(DATE(CONCAT(StartYear,"-",
                                                   StartMonth,
                                                   "-01"
                                                  )
                                           ),INTERVAL 1 MONTH
                                      ),INTERVAL 1 DAY
                             )
                  WHEN "Quarter" THEN
                       SUBDATE(ADDDATE(DATE(CONCAT(StartYear,"-",
                                                   StartMonth,
                                                   "-01"
                                                  )
                                           ),INTERVAL 3 MONTH
                                      ),INTERVAL 1 DAY
                             )
                  WHEN "Year" THEN
                       SUBDATE(ADDDATE(DATE(CONCAT(StartYear,"-",
                                                   StartMonth,
                                                   "-01"
                                                  )
                                           ),INTERVAL 1 YEAR
                                      ),INTERVAL 1 DAY
                             )
                  WHEN "FullProjectTimespan" THEN
                       CASE WHEN Plan.WorkPlanEndDate IS NOT NULL
                                 THEN Plan.WorkPlanEndDate
                            WHEN Plan.ExpectedEndDate IS NOT NULL
                                 THEN Plan.ExpectedEndDate
                            ELSE CURRENT_DATE()
                        END
              END
       WHERE Plan.ProjectSummaryID = DateUnitWorkUnits.ProjectSummaryID;

      UPDATE DateUnitWorkUnits Units, ProjectPlanning Plan
         SET FiscalYear = YEAR(CASE WHEN FiscalYearStart IS NULL
                                    THEN EndDate
                                    ELSE ADDDATE(EndDate,INTERVAL 12-FiscalYearStart+1 MONTH)
                                END
                              )
       WHERE Plan.ProjectSummaryID = Units.ProjectSummaryID;
         

      UPDATE DateUnitExpense, ProjectPlanning Plan
         SET StartYear =
             CASE WHEN ExpensesDateUnit IN ("Month","Quarter","Year")
                       THEN SUBSTRING_INDEX(SUBSTRING_INDEX(ExpensesDate,"\"",2),"\"",-1)
                  WHEN ExpensesDateUnit = "Day"
                       THEN SUBSTRING_INDEX(SUBSTRING_INDEX(ExpensesDate,"-",1),"\"",-1)
                  WHEN ExpensesDateUnit LIKE "Full%"
                       THEN YEAR(CASE WHEN Plan.WorkPlanStartDate IS NOT NULL
                                           THEN Plan.WorkPlanStartDate
                                      WHEN Plan.StartDate IS NOT NULL
                                      THEN Plan.StartDate
                                      ELSE CURRENT_DATE()
                                  END
                                )
              END,
             StartMonth =
             CASE WHEN ExpensesDateUnit IN ("Month","Quarter","Year")
                       THEN SUBSTRING_INDEX(SUBSTRING_INDEX(ExpensesDate,"\"",4),"\"",-1)
                  WHEN ExpensesDateUnit = "Day"
                       THEN SUBSTRING_INDEX(SUBSTRING_INDEX(ExpensesDate,"-",2),"-",-1)
                  WHEN ExpensesDateUnit LIKE "Full%"
                       THEN MONTH(CASE WHEN Plan.WorkPlanStartDate IS NOT NULL
                                            THEN Plan.WorkPlanStartDate
                                       WHEN Plan.StartDate IS NOT NULL
                                       THEN Plan.StartDate
                                       ELSE CURRENT_DATE()
                                   END
                                 )
              END
       WHERE Plan.ProjectSummaryID = DateUnitExpense.ProjectSummaryID;
         
      UPDATE DateUnitExpense, ProjectPlanning Plan
         SET DateUnitExpense.StartDate =
             CASE WHEN ExpensesDateUnit = "Day" THEN
                       DATE(SUBSTRING_INDEX(
                               SUBSTRING_INDEX(ExpensesDate,
                                               '"',2
                                              ),'"',-1
                                           )
                           )
                  WHEN ExpensesDateUnit IN ("Month","Quarter","Year") THEN
                       DATE(CONCAT(StartYear,"-",StartMonth,"-01"))
                  WHEN ExpensesDateUnit LIKE "%Full%" THEN
                       CASE WHEN Plan.WorkPlanStartDate IS NOT NULL
                                 THEN Plan.WorkPlanStartDate
                            WHEN Plan.StartDate IS NOT NULL
                                 THEN Plan.StartDate
                            ELSE CURRENT_DATE()
                        END
              END,
             DateUnitExpense.EndDate =
             CASE ExpensesDateUnit
                  WHEN "Day" THEN
                       DATE(SUBSTRING_INDEX(
                               SUBSTRING_INDEX(ExpensesDate,
                                               '"',2
                                              ),'"',-1
                                           )
                           )
                  WHEN "Month" THEN
                       SUBDATE(ADDDATE(DATE(CONCAT(StartYear,"-",
                                                   StartMonth,
                                                   "-01"
                                                  )
                                           ),INTERVAL 1 MONTH
                                      ),INTERVAL 1 DAY
                             )
                  WHEN "Quarter" THEN
                       SUBDATE(ADDDATE(DATE(CONCAT(StartYear,"-",
                                                   StartMonth,
                                                   "-01"
                                                  )
                                           ),INTERVAL 3 MONTH
                                      ),INTERVAL 1 DAY
                             )
                  WHEN "Year" THEN
                       SUBDATE(ADDDATE(DATE(CONCAT(StartYear,"-",
                                                   StartMonth,
                                                   "-01"
                                                  )
                                           ),INTERVAL 1 YEAR
                                      ),INTERVAL 1 DAY
                             )
                  WHEN "FullProjectTimespan" THEN
                       CASE WHEN Plan.WorkPlanEndDate IS NOT NULL
                                 THEN Plan.WorkPlanEndDate
                            WHEN Plan.ExpectedEndDate IS NOT NULL
                                 THEN Plan.ExpectedEndDate
                            ELSE CURRENT_DATE()
                        END
              END
       WHERE Plan.ProjectSummaryID = DateUnitExpense.ProjectSummaryID;
         
      UPDATE DateUnitExpense Exp, ProjectPlanning Plan
         SET FiscalYear = YEAR(CASE WHEN FiscalYearStart IS NULL
                                    THEN EndDate
                                    ELSE ADDDATE(EndDate,INTERVAL 12-FiscalYearStart+1 MONTH)
                                END
                              )
       WHERE Plan.ProjectSummaryID = Exp.ProjectSummaryID;

DROP VIEW IF EXISTS v_WorkYears;          /* A view to select all the Fiscal Years for which there
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


DROP VIEW IF EXISTS v_WorkRsrcs;          /* A view to select all the Fiscal Years and their 
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


DROP VIEW IF EXISTS v_WorkAccts;          /* A view to select all the Fiscal Years for and their 
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


DROP VIEW IF EXISTS v_WorkFunds;          /* A view to select all the Fiscal Years for and their 
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

DROP VIEW IF EXISTS v_IndicatorMeasurement;     /* Joins IndicatorMeasurement with Measurement,
                                                   including the RATING() value of Measurement.Rating
                                                   
                                                   Has to follow function RATING(). 
                                                */
CREATE VIEW v_IndicatorMeasurement AS
       SELECT IndicatorID, IndicatorXID, Meas.*, RATING(Rating) AS IndicatorRating
         FROM IndicatorMeasurement Ind, Measurement Meas
        WHERE Meas.ID = Ind.MeasurementID;
        

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


CREATE VIEW v_TargetIndicator AS
       SELECT TargetID, TargetXID, Ind.*
         FROM TargetIndicator TgtInd, Indicator Ind
        WHERE Ind.ID = TgtInd.IndicatorID; 


CREATE VIEW v_BiodiversityTargetIndicator AS
       SELECT BiodiversityTargetID, BiodiversityTargetXID, Ind.*
         FROM BiodiversityTargetIndicator TgtInd, Indicator Ind
        WHERE Ind.ID = TgtInd.IndicatorID; 


CREATE VIEW v_HumanWelfareTargetIndicator AS
       SELECT HumanWelfareTargetID, HumanWelfareTargetXID, Ind.*
         FROM HumanWelfareTargetIndicator TgtInd, Indicator Ind
        WHERE Ind.ID = TgtInd.IndicatorID; 


CREATE VIEW v_KeyAttributeIndicator AS
       SELECT KeyEcologicalAttributeID AS KeyAttributeID, 
              KeyEcologicalAttributeXID AS KeyAttributeXID, Ind.*
         FROM KeyEcologicalAttributeIndicator KeaInd, Indicator Ind
        WHERE Ind.ID = KeaInd.IndicatorID;



-- END