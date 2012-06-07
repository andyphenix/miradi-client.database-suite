/*
   sp_StrategyThreat_v13.sql

   Traverses the Conceptual Model and Results Chain diagram paths from Strategies, Objectives,
   and Threats to their Threats / Threat Reduction Results and Targets, to create database
   associations between Strategies and Objectives and the Threats / Targets they address.

   (Initially coded to populate Strategy x Threat associations, later amended to also
    populate Strategy x Target, Objective x Threat/Target and Threat x Target.)

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

   CALL sp_StrategyThreat(ProjectSummaryID, Trace)

        Where ProjectSummaryID represents the Project whose links tp Threats/Targets
              to associate (ProjectSummaryID = 0 all projects in the database);
              
              Trace is a Boolean flag, when set to TRUE causes Trace/Debug statements 
              to be written at the beginning and end of the process and at the end of 
              each oscillation.

   Revision History:
   Version 13 - 2012-03-05 - Consolidate ANALYZE TABLE statements.
   Version 12 - 2011-07-23 - Revise indexes for performance.
   Version 11 - 2011-07-21 - Insert code to terminate traversal of a link chain if its
                             path recourses onto itself.
                           - Rename FactorType to Factor everywhere except Target and Result. 
   Version 10 - 2011-07-12 - Use new view v_DiagramLink to include To/From DiagramFactorID
                             and To/From WrappedByDiagramFactorXID.
   Version 09 - 2011-05-18 - Add ID field to Trace.
   Version 08 - 2011-05-16 - Change to use new DiagramLink FactorXID columns.
   Version 07 - 2011-04-26 - Terminate the link walk at the first encountered Target.
   Version 06 - 2011-04-24 - Remove Factor from Target intersections. Selection on Factor
                             is now enabled in their views in the database structure.
   Version 05 - 2011-04-15 - Additional normalization of the database to remove custom parsing
                             of diagram features that are used in this process.
                           - Recognize that a Threat Reduction Result may, in fact, legitimately
                             not reference a Direct Threat. (Direct Threat = Unspecified).
                           - Add Trace feature.
   Version 04 - 2011-04-11 - Differentiate Threats from other Causes when linking from Objectives.
                           - Add Factor to Target intersections.
   Version 03 - 2011-03-20 - Add Objective x Threat/Target and Threat x Target associations.
   Version 02 - 2011-03-15 - Add Strategy x Target associations.
   Version 01 - 2011-02-21 - Initial Version.
*/

USE Miradi;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_StrategyThreat $$
CREATE PROCEDURE sp_StrategyThreat (pProjectSummaryID INTEGER)

StrThr:
BEGIN

      DECLARE pFirstTime BOOLEAN DEFAULT TRUE;

      IF  @Trace = TRUE THEN
          INSERT INTO Trace VALUES (0,"Begin sp_StrategyThreat()",CURRENT_TIME());
      END IF;

      DROP TABLE IF EXISTS t0;
      CREATE TEMPORARY TABLE t0
             SELECT DISTINCT Strat.ProjectSummaryID, "Strategy" AS Factor, 
                    Strat.ID AS FactorID, Strat.XID AS FactorXID,
                    "Strategy" AS RelatedFactor, Strat.XID AS RelatedFactorXID
               FROM Strategy Strat
              WHERE NOT (Strat.Status IS NOT NULL AND Strat.Status = "Draft")
                AND CASE WHEN pProjectSummaryID = 0
                         THEN TRUE
                         ELSE Strat.ProjectSummaryID = pProjectSummaryID
                     END

              UNION ALL

             /* Objectives are attached to related factors rather than linked to them,
                thus the 'Related Factor' is the factor to which they are attached.
             */

             SELECT DISTINCT Obj.ProjectSummaryID, "Objective" AS Factor, 
                    Obj.ID AS FactorID, Obj.XID AS FactorXID,
                    CASE WHEN Res.FactorType = "IR" THEN "IntermediateResult"
                         WHEN Res.FactorType = "TR" THEN "ThreatReductionResult"
                     END AS RelatedFactor,
                    ResultXID AS RelatedFactorXID
               FROM Objective Obj, ResultObjective ResObj, Result Res
              WHERE Res.ID = ResObj.ResultID
                AND ResObj.ObjectiveID = Obj.ID
                AND CASE WHEN pProjectSummaryID = 0
                         THEN TRUE
                         ELSE Obj.ProjectSummaryID = pProjectSummaryID
                     END

              UNION ALL

             SELECT DISTINCT Obj.ProjectSummaryID, "Objective" AS Factor, 
                    Obj.ID AS FactorID, Obj.XID AS FactorXID,
                    CASE WHEN Cs.IsDirectThreat = TRUE THEN "Threat"
                         ELSE "Cause"
                     END AS RelatedFactor,
                    CauseXID AS RelatedFactorXID
               FROM Objective Obj, CauseObjective CsObj, Cause Cs
              WHERE Cs.ID = CsObj.CauseID
                AND CsObj.ObjectiveID = Obj.ID
                AND CASE WHEN pProjectSummaryID = 0
                         THEN TRUE
                         ELSE Obj.ProjectSummaryID = pProjectSummaryID
                     END

              UNION ALL

             SELECT DISTINCT Thr.ProjectSummaryID, "Threat" AS Factor, 
                    Thr.ID AS FactorID, Thr.XID AS FactorXID,
                    "Cause" AS RelatedFactor, Thr.XID AS RelatedFactorXID
               FROM Threat Thr
              WHERE CASE WHEN pProjectSummaryID = 0
                         THEN TRUE
                         ELSE Thr.ProjectSummaryID = pProjectSummaryID
                     END;

      IF ROW_COUNT() = 0 THEN LEAVE StrThr; END IF;

      CREATE INDEX Ix1 ON t0 (ProjectSummaryID, RelatedFactorXID, RelatedFactor);

      DROP TABLE IF EXISTS t1;
      CREATE TEMPORARY TABLE t1

             /* When selecting the first linked factors from an Objective ...

                Because an Objective is attached directly to a factor rather than
                being a linked to it, we need to capture the factor to which
                the Objective is attached (if it is a Threat or Threat Reduction
                Result, else we will lose it (because this step naturally selects
                the next linked factor in the linked chain.)

                It should be noted that only Objectives will be affected by the
                conditional statements herein because only Objectives will be
                attached to Threats or Threat Reduction Results rather than linked
                to them, so we don't need to also filter on t0.Factor.
             */

             SELECT DISTINCT t0.ProjectSummaryID, t0.Factor, t0.FactorID, t0.FactorXID,
                    CASE WHEN RelatedFactor = "ThreatReductionResult"
                              THEN RelatedFactor
                         WHEN RelatedFactor = "Threat" THEN "Cause"
                         ELSE Link.DiagramLinkToDiagramFactor
                     END AS ToFactor,
                    CASE WHEN RelatedFactor
                                 IN ("ThreatReductionResult","Threat")
                         THEN RelatedFactorXID
                         ELSE Link.DiagramLinkToFactorXID
                     END AS ToFactorXID
               FROM t0, v_DiagramLink Link
              WHERE Link.ProjectSummaryID = t0.ProjectSummaryID
                AND Link.DiagramLinkFromDiagramFactor =
                       CASE WHEN t0.RelatedFactor = "Threat" THEN "Cause"
                            ELSE t0.RelatedFactor
                        END
                AND Link.DiagramLinkFromFactorXID = t0.RelatedFactorXID;

      IF ROW_COUNT() = 0 THEN LEAVE StrThr; END IF;

      CREATE INDEX Ix1 ON t1(ProjectSummaryID, FactorXID, Factor);
      CREATE INDEX Ix2 ON t1(ProjectSummaryID, ToFactorXID, ToFactor);

      DROP TABLE IF EXISTS t2;              -- We'll oscillate between t1 and t2
      CREATE TEMPORARY TABLE t2 LIKE t1;    -- as we follow the links from node to node.

      DROP TABLE IF EXISTS t3;              -- We need to keep a list of previously-visited 
      CREATE TEMPORARY TABLE t3 LIKE t1;    -- nodes to avoid looping when a path of links
                                            -- recourses back on itslf, creating a circular path.

      /* Trace/Debug statement */

      IF @Trace = TRUE THEN
         INSERT INTO Trace VALUES (0,"End t0 Oscillation",CURRENT_TIME());
      END IF;

STLoop:
      WHILE TRUE DO

            REPLACE INTO StrategyThreat (ID, ProjectSummaryID, StrategyID, ThreatID,
                                         StrategyXID, ThreatXID
                                        )
                    SELECT 0, t1.ProjectSummaryId, t1.FactorID, Thr.ID,
                           t1.FactorXID, t1.ToFactorXID
                      FROM t1, Threat Thr
                     WHERE Thr.ProjectSummaryID = t1.ProjectSummaryId
                       AND Thr.XID = t1.ToFactorXID
                       AND t1.Factor = "Strategy"
                       AND t1.ToFactor = "Cause";

            REPLACE INTO StrategyThreat (ID, ProjectSummaryID, StrategyID, ThreatID,
                                         StrategyXID, ThreatXID
                                        )
                    SELECT 0, t1.ProjectSummaryID, t1.FactorID, TRR.ThreatID,
                           t1.FactorXID, TRR.ThreatXID
                      FROM t1, ThreatReductionResult TRR
                     WHERE TRR.ProjectSummaryID = t1.ProjectSummaryID
                       AND TRR.XID = ToFactorXID
                       AND t1.Factor = "Strategy"
                       AND t1.ToFactor = "ThreatReductionResult"
                       AND TRR.ThreatID IS NOT NULL;

            REPLACE INTO StrategyTarget (ID, ProjectSummaryID, StrategyID, TargetID,
                                         StrategyXID, TargetXID
                                        )
                    SELECT 0, t1.ProjectSummaryId, t1.FactorID, Tgt.ID,
                           t1.FactorXID, t1.ToFactorXID
                      FROM t1, Target Tgt
                     WHERE Tgt.ProjectSummaryID = t1.ProjectSummaryId
                       AND Tgt.XID = t1.ToFactorXID
                       AND t1.Factor = "Strategy"
                       AND t1.ToFactor LIKE "%Target";

            REPLACE INTO ObjectiveThreat (ID, ProjectSummaryID, ObjectiveID, ThreatID,
                                          ObjectiveXID, ThreatXID
                                         )
                    SELECT 0, t1.ProjectSummaryId, t1.FactorID, Thr.ID,
                           t1.FactorXID, t1.ToFactorXID
                      FROM t1, Threat Thr
                     WHERE Thr.ProjectSummaryID = t1.ProjectSummaryId
                       AND Thr.XID = t1.ToFactorXID
                       AND t1.Factor = "Objective"
                       AND t1.ToFactor = "Cause";

            /* The following statement is intentionally omitted because Objective x
               Direct Threat associations are not displayed for Objectives contained
               in a Results Chain. The statement is included here, commented
               out, so its omission won't be viewed as an oversight.

            REPLACE INTO ObjectiveThreat (ID, ProjectSummaryID, ObjectiveID, ThreatID,
                                          ObjectiveXID, ThreatXID
                                         )
                    SELECT 0, t1.ProjectSummaryID, t1.FactorID, TRR.ThreatID,
                           t1.FactorXID, TRR.ThreatXID
                      FROM t1, ThreatReductionResult TRR
                     WHERE TRR.ProjectSummaryID = t1.ProjectSummaryID
                       AND TRR.XID = t1.ToFactorXID
                       AND t1.Factor = "Objective"
                       AND t1.ToFactor = "ThreatReductionResult"
                       AND TRR.ThreatID IS NOT NULL;
            */

            REPLACE INTO ObjectiveTarget (ID, ProjectSummaryID, ObjectiveID, TargetID,
                                          ObjectiveXID, TargetXID
                                         )
                    SELECT 0, t1.ProjectSummaryId, t1.FactorID, Tgt.ID,
                           t1.FactorXID, t1.ToFactorXID
                      FROM t1, Target Tgt
                     WHERE Tgt.ProjectSummaryID = t1.ProjectSummaryId
                       AND Tgt.XID = t1.ToFactorXID
                       AND t1.Factor = "Objective"
                       AND t1.ToFactor LIKE "%Target";

            REPLACE INTO ThreatTarget (ID, ProjectSummaryID, ThreatID, TargetID,
                                       ThreatXID, TargetXID
                                      )
                    SELECT 0 ,t1.ProjectSummaryId, t1.FactorID, Tgt.ID,
                           t1.FactorXID, t1.ToFactorXID
                      FROM t1, Target Tgt
                     WHERE Tgt.ProjectSummaryID = t1.ProjectSummaryId
                       AND Tgt.XID = t1.ToFactorXID
                       AND t1.Factor = "Threat"
                       AND t1.ToFactor LIKE "%Target";
                       
            INSERT INTO t3 SELECT * FROM t1;   -- For trapping circular paths.
            
            /* Trace/Debug statement */

            IF @Trace = TRUE THEN
               INSERT INTO Trace VALUES (0,"End t1 Oscillation",CURRENT_TIME());
            END IF;

            TRUNCATE TABLE t2;
            INSERT INTO t2
                   SELECT DISTINCT t1.ProjectSummaryID, t1.Factor, t1.FactorID, 
                          t1.FactorXID, Link.DiagramLinkToDiagramFactor,
                          Link.DiagramLinkToFactorXID
                     FROM t1, v_DiagramLink Link
                    WHERE Link.ProjectSummaryID = t1.ProjectSummaryID
                      AND Link.DiagramLinkFromDiagramFactor = t1.ToFactor
                      AND Link.DiagramLinkFromFactorXID = t1.ToFactorXID
                      
                      /* Stop at the first-encountered Target ... */

                      AND NOT t1.ToFactor LIKE "%Target"  
                      
                      /* ... or if we encountered a circular path. */
                      
                      AND NOT (    t1.ToFactor = t1.Factor
                               AND t1.ToFactorXID = t1.FactorXID
                              ) 
                      AND NOT EXISTS (SELECT 1 FROM t3
                                       WHERE t3.ProjectSummaryID = t1.ProjectSummaryID
                                         AND t3.Factor = t1.Factor
                                         AND t3.FactorXID = t1.FactorXID
                                         AND t3.ProjectSummaryID = Link.ProjectSummaryID
                                         AND t3.ToFactor = Link.DiagramLinkToDiagramFactor
                                         AND t3.ToFactorXID = Link.DiagramLinkToFactorXID
                                     ); 
                                     
            IF ROW_COUNT() = 0 THEN LEAVE STLoop; END IF;
            
            IF pFirstTime THEN ANALYZE TABLE t1, t2, t3; SET pFirstTime = FALSE; END IF;

            REPLACE INTO StrategyThreat (ID, ProjectSummaryID, StrategyID, ThreatID,
                                         StrategyXID, ThreatXID
                                        )
                    SELECT 0, t2.ProjectSummaryId, t2.FactorID, Thr.ID,
                           t2.FactorXID, t2.ToFactorXID
                      FROM t2, Threat Thr
                     WHERE Thr.ProjectSummaryID = t2.ProjectSummaryId
                       AND Thr.XID = t2.ToFactorXID
                       AND t2.Factor = "Strategy"
                       AND t2.ToFactor = "Cause";

            REPLACE INTO StrategyThreat (ID, ProjectSummaryID, StrategyID, ThreatID,
                                         StrategyXID, ThreatXID
                                        )
                    SELECT 0, t2.ProjectSummaryID, t2.FactorID, TRR.ThreatID,
                           t2.FactorXID, TRR.ThreatXID
                      FROM t2, ThreatReductionResult TRR
                     WHERE TRR.ProjectSummaryID = t2.ProjectSummaryID
                       AND TRR.XID = ToFactorXID
                       AND t2.Factor = "Strategy"
                       AND t2.ToFactor = "ThreatReductionResult"
                       AND TRR.ThreatID IS NOT NULL;

            REPLACE INTO StrategyTarget (ID, ProjectSummaryID, StrategyID, TargetID,
                                         StrategyXID, TargetXID
                                        )
                    SELECT 0, t2.ProjectSummaryId, t2.FactorID, Tgt.ID,
                           t2.FactorXID, t2.ToFactorXID
                      FROM t2, Target Tgt
                     WHERE Tgt.ProjectSummaryID = t2.ProjectSummaryId
                       AND Tgt.XID = t2.ToFactorXID
                       AND t2.Factor = "Strategy"
                       AND t2.ToFactor LIKE "%Target";

            REPLACE INTO ObjectiveThreat (ID, ProjectSummaryID, ObjectiveID, ThreatID,
                                          ObjectiveXID, ThreatXID
                                         )
                    SELECT 0, t2.ProjectSummaryId, t2.FactorID, Thr.ID,
                           t2.FactorXID, t2.ToFactorXID
                      FROM t2, Threat Thr
                     WHERE Thr.ProjectSummaryID = t2.ProjectSummaryId
                       AND Thr.XID = t2.ToFactorXID
                       AND t2.Factor = "Objective"
                       AND t2.ToFactor = "Cause";

            /* The following statement is intentionally omitted because Objective x
               Direct Threat associations are not displayed for Objectives contained
               in a Results Chain. The statement is included here, commented
               out, so its omission won't be viewed as an oversight.

            REPLACE INTO ObjectiveThreat (ID, ProjectSummaryID, ObjectiveID, ThreatID,
                                          ObjectiveXID, ThreatXID
                                         )
                    SELECT 0, t2.ProjectSummaryID, t2.FactorID, TRR.ThreatID,
                           t2.FactorXID, TRR.ThreatXID
                      FROM t2, ThreatReductionResult TRR
                     WHERE TRR.ProjectSummaryID = t2.ProjectSummaryID
                       AND TRR.XID = t2.ToFactorXID
                       AND t2.Factor = "Objective"
                       AND t2.ToFactor = "ThreatReductionResult"
                       AND TRR.ThreatID IS NOT NULL;
            */

            REPLACE INTO ObjectiveTarget (ID, ProjectSummaryID, ObjectiveID, TargetID,
                                          ObjectiveXID, TargetXID
                                         )
                    SELECT 0, t2.ProjectSummaryId, t2.FactorID, Tgt.ID,
                           t2.FactorXID, t2.ToFactorXID
                      FROM t2, Target Tgt
                     WHERE Tgt.ProjectSummaryID = t2.ProjectSummaryID
                       AND Tgt.XID = t2.ToFactorXID
                       AND t2.Factor = "Objective"
                       AND t2.ToFactor LIKE "%Target";

            REPLACE INTO ThreatTarget (ID, ProjectSummaryID, ThreatID, TargetID,
                                       ThreatXID, TargetXID
                                      )
                    SELECT 0 ,t2.ProjectSummaryId, t2.FactorID, Tgt.ID,
                           t2.FactorXID, t2.ToFactorXID
                      FROM t2, Target Tgt
                     WHERE Tgt.ProjectSummaryID = t2.ProjectSummaryID
                       AND Tgt.XID = t2.ToFactorXID
                       AND t2.Factor = "Threat"
                       AND t2.ToFactor LIKE "%Target";

            INSERT INTO t3 SELECT * FROM t2;   -- For trapping circular paths.

            /* Trace/Debug statement */

            IF @Trace = TRUE THEN
               INSERT INTO Trace VALUES (0,"End t2 Oscillation",CURRENT_TIME());
            END IF;

            TRUNCATE TABLE t1;
            INSERT INTO t1
                   SELECT DISTINCT t2.ProjectSummaryID, t2.Factor, t2.FactorID, 
                          t2.FactorXID, Link.DiagramLinkToDiagramFactor,
                          Link.DiagramLinkToFactorXID
                     FROM t2, v_DiagramLink Link
                    WHERE Link.ProjectSummaryID = t2.ProjectSummaryID
                      AND Link.DiagramLinkFromDiagramFactor = t2.ToFactor
                      AND Link.DiagramLinkFromFactorXID = t2.ToFactorXID
                      
                      /* Stop at the first-encountered Target ... */

                      AND NOT t2.ToFactor LIKE "%Target"  
                      
                      /* ... or if we encountered a circular path. */
                      
                      AND NOT (    t2.ToFactor = t2.Factor
                               AND t2.ToFactorXID = t2.FactorXID
                              ) 
                      AND NOT EXISTS (SELECT 1 FROM t3
                                       WHERE t3.ProjectSummaryID = t2.ProjectSummaryID
                                         AND t3.Factor = t2.Factor
                                         AND t3.FactorXID = t2.FactorXID
                                         AND t3.ProjectSummaryID = Link.ProjectSummaryID
                                         AND t3.ToFactor = Link.DiagramLinkToDiagramFactor
                                         AND t3.ToFactorXID = Link.DiagramLinkToFactorXID
                                     ); 
                                     
            IF ROW_COUNT() = 0 THEN LEAVE STLoop; END IF;

      END WHILE STLoop;

      ANALYZE TABLE StrategyThreat, StrategyTarget, ObjectiveThreat, ObjectiveTarget, ThreatTarget;

      DROP TABLE t0;
      DROP TABLE t1;
      DROP TABLE t2;
      DROP TABLE t3;

      /* Trace/Debug statement */

      IF  @Trace = TRUE THEN
          INSERT INTO Trace VALUES (0,"End sp_StrategyThreat()",CURRENT_TIME());
      END IF;

END StrThr $$

DELIMITER ;

-- END