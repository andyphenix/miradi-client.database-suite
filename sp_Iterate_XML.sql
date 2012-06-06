/*
   sp_Iterate_XML_v51c.sql
   
   Compatible with XMPZ XML data model http://xml.miradi.org/schema/ConservationProject/73.

   Revised and modified from its earlier recursively-called edition which was extremely
   performance-insensitive. This edition maintains its own variable stack in a temporary
   table and performs its own internal recursions.
   
   This is a recursively called procedure to populate the Miradi database with project data
   imported in an XMPZ XML stream. Source data is taken from the parsed XML Stream
   contained in the table XMLData. Subordinate Objects or references to Objects contained
   in each Object stream are processed by recursively calling this procedure from the first
   element of the subordinate Object through its end, denoted by an Element Name of "/ObjectName".

   Developed by David Berg for The Nature Conservancy 
        and the Greater Conservation Community.

   Revision History:
   Version 51 - 2011-09-28 - Fixed bug introduced in Version 50? where any column value that 
                             contains "(" would become corrupted. (Oops!) The column value list is now
                             anchored with the anchor character (^) while it is being populated. The
                             anchor is removed when the row is inserted. (Hopefully, no column value
                             contains the string "(^0", else it will become corrupted.)
                           - Moved the code that places XID in the column list up to the initialization step
                             for each recursion, since it has to be determined and saved there anyway.
   Version 50 - 2011-09-06 - Rename WorkUnitsEntry and ExpenseEntry to
                             CalculatedWorkUnits and CalculatedExpense.
                           - Rename StressThreatRating to StressBasedThreatRating.
                           - Make Flag 64 an Object-level flag instead of an element-level flag.
                           - Allow Flag 8 to be an Object-level flag (in addition to an element-
                             level flag) to flag multi-valued sets (in addition to multi-
                             valued elements).
                           - Create table TaggedObjectSetFactor to contain WrappedByDiagramFactor
                             for Tagged Object Sets; fold WrappedByDiagramFactor into
                             DiagramFactor for simple diagrams.
                           - Ditto DiagramLinkBendPoint for DiagramPoints.
                           - Simplify testing for the ConservationProject object (Flag = 512).
   Version 49 - 2011-08-24 - Much streamlining and rework to improve performance as well as
                             consistency, clarity, and comprehension. 
                           - Don't seed first row from XMLData in the call to Iterate_XML.
                             Since that procedure has long ceased being recursively called, 
                             Iterate_XML will fetch its own first row.
                           - Flag 256 (multiple factors share the same table) is now set
                             in Parse_XML and processed in Iterate_XML.
                           - WorkUnitsEntry, ExpenseEntry, CalculatedWho, and Task do not need
                             to be qualified by factor, thus simplifying their processing
                             considerably.
                           - Add Element Flag 2048 in the Object Header to signal that the
                             Object Header contains the XML Factor Header's ID attribute
                             in ElementValue to be assigned as its table's XID.
                           - Add Element Flag 4096 in the Object Header to signal that an XID 
                             needs to be created for a particular Factor.
                           - Add Element Flag 8192 in the Object Header to signal that the
                             Object Header contains the XML Factor Header's attribute
                             value in ElementValue to be assigned to its table's corresponding
                             column.
                           - Rework the handling of DateUnitWorkUnits/Expenses.
   Version 48 - 2011-08-05 - Performance enhancement WRT DateUnitWorkUnits/Expenses.
   Version 47 - 2011-07-21 - Rename FactorType to Factor everywhere except Target and Result. 
   Version 46 - 2011-07-12 - Use new view v_DiagramLink to include To/From DiagramFactorID
                             and To/From WrappedByDiagramFactorXID rather than populating 
                             them from here.
   Version 45 - 2011-07-11 - Assign Flag 1024 to denote ProjectSummary Parent instead of testing
                             ParentName.
                           - Set Indicator to Inactive if it is attached to a Draft Strategy. 
                           - Further enhance the differentiation of Tasks, Activities, and Methods.
   Version 44 - 2011-07-05 - Create independent element for xmlns.
                           - Assign Flag 512 to object ConservationProject.
                           - Move ANALYZE TABLE to end of iterative processing.
   Version 43 - 2011-06-30 - Revise the differentiation of Tasks, Activities, and Methods within
                             the single Object Class (3) Task/ActivityMethod.
   Version 42 - 2011-06-27 - Change FactorName to FactorType for all occurrences.
   Version 41 - 2011-06-10 - Transform Target.ViabilityMode from ("","TNC") to ("Simple","KEA").
                           - Set Indicator.IsActive based on Target.ViabilityMode.
                           - Fix bug when appending ProjectSummaryID to value list. 
   Version 40 - 2011-05-25 - Add xmlns to ProjectSummary Table.
                           - Make compound elements Flag 64 instead of their Object Headers.
                           - Relocate update of DiagramLink Factor IDs to where it will
                             actually do what it's supposed to.
   Version 39 - 2011-05-18 - Add ID field to Trace.
                           - Fix bug in setting @ProjectSummaryID.
   Version 38 - 2011-05-16 - Update new DiagramLink Factor (X)IDs
   Version 37 - 2011-05-09 - Add FactorName to CalculatedYears and WorkUnits/ExpenseEntry
   Version 36 - 2011-04-29 - Add the condition FactorName = pParentTable in the EOF logic to backfill
                             ParentIDs in Child Tables. Tables that share Factors may have two Factors
                             of different genres that just happen to have the same XID, particularly
                             if one of those XIDs is programattically generated by the parser.
   Version 35 - 2011-04-24 - Replace all RLIKE operators for performance sensitivity.
   Version 34 - 2011-04-24 - Removed FactorType from intersection tables to simplify EOF processing.
                             Selection on Factor Type is now enabled in their views in the
                             database structure.
   Version 33 - 2011-04-22 - Revisions to Version 36 to make it more robust.
   Version 32 - 2011-04-18 - Additions required to support Calculated Costs.
                           - Update Sequence column for Method/Activity/Task intersections.
   Version 31 - 2011-04-14 - DiagramPoint aand WrappedDiagramFactor become their own tables
                             with shared components from DiagramFactor and DiagramLink and
                             DiagramFactor and TaggedObjectSet, respectively.
   Version 30 - 2011-04-12 - Add Factor Type to Intersection Tables.
                             Version 29 - 2011-04-11 - Make the Debug/Trace an optional feature on call.
   Version 28 - 2011-03-31 - Relocate the code to flag Methods, Activities, and Tasks to prior
                             to backfilling Parent IDs into Child Tables as the latter depends
                             on the former.
   Version 27 - 2011-03-26 - Revise the handling of Factor Types that share a common table:
                             Biodiversity & Human Welfare Targets; Intermediate & Threat
                             Reduction Results. Goal and Objective each becomes its own table.
   Version 26 - 2011-03-23 - Revise the paradigm of storing Expense and Work Unit Time
                             schedules.
   Version 25 - 2011-03-18 - Simplify table name selection for ANALYZE TABLEs.
                           - Enlarge ElementValue and ColValues to MEDIUMTEXT to accommodate
                             ExtraDataItemValue.
   Version 24 - 2011-03-08 - Track the last Stack record inserted so it can be popped without
                             an extra SELECT MAX(... to obtain it. A significant performance
                             improvement.
   Version 23 - 2011-03-07 - Revise handling of Parent XIDs on the stack. That it was incorrect
                             became apparent only when we encountered a third nested level of
                             an Object that represents a Table.
                           - Revise the technique for trimming leading Object Names from Element
                             Names. Because TRIM() trims ALL occurrences of the trim string,
                             instances of Element Names that contained the Object Name were
                             incorrectly formed and had to be treated specially. This new technique
                             eliminates that requirement.
   Version 22 - 2011-03-02 - Reintroduce ChildID as a column in the ChildRefs table to isolate
                             updates of non-pool parents to this imported project only.
                           - Also set ProjectIdFlag = TRUE when a Project ID is imported from XML.
   Version 21 - 2011-02-21 - ChildIDs table doesn't need ChildID. Simplify by removing ChildID
                             and renaming the table ChildRefs.
                           - (02/28) Move ThreatRatingXID back into the parse script so pParentXID
                             gets properly set when the iterate script is processing StressThreatRating.
   Version 20 - 2011-02-09 - Replace recursive calls by maintaining our own stack of variables
                             for each recursive level. Resulting performance improvement is
                             an order of magnitude faster (in time units) than recursive calls.
                           - Additional performance improvements to backfilling of Parent IDs.
   Version 19 - 2011-02-08 - Further streamline backfilling of Parent IDs to one UPDATE per Table.
                           - More thorough annotations.
   Version 18 - 2011-02-07 - Streamline backfilling of Parent IDs and relevant bug fix.
                           - Other fixes & stuff.
   Version 17 - 2011-01-31 - Added creation of ProjectID if it wasn't imported.
                           - Added update of DateUnitExpense and DateUnitWorkUnit components.
   Version 16 - 2011-01-31 - Other code revisions following successful run of Version 15.
   Version 15 - 2011-01-24 - Add code to assign work plan time durations.
   Version 14 - 2011-01-21 - Add code to backfill parent IDs in child tables.
   Version 13 - 2011-01-19 - Restructure Child IDs.
   Version 12 - 2011-01-17 - Restructure Element Flags
                           - Eliminate table XMLObjects; use Element Flag instead.
   Version 11 - 2011-01-14 - Remove conditional code to insert ProjectSummaryID into each table.
                             It's now unconditional. ProjectSummaryID is a column in every table.
   Version 10 - 2011-01-13 - Further code improvements.
                           - Interpret Bit 8 of ElementFlags to signal a WrappedByDiagramFactor.
   Version 09 - 2011-01-12 - Improve generalizations as they apply to like situations.
   Version 08 - 2011-01-10 - Assign XIDs in association tables.
                           - Other miscellaneous fixes and changes.
   Version 07 - 2011-01-07 - Consolidate table-specific code from Version 06 updates into
                             generalizations that will apply to all like conditions.
   Version 06 - 2011-01-02 - Add code to insert the value for ProjectSummaryID in subordinate tables.
                           - Add the retention of child element IDs at all iteration levels to be
                             updated with references to their parent(s) once the parent ID is known.
                           - Properly form the table name for M:N associations.
   Version 05 - 2010-12-31 - Interpret bitwise Element Flags for processing lists.
   Version 04 - 2010-12-30 - Reposition cursor following a recursive iteration.
   Version 03 - 2010-12-29 - Discarded.
   Version 02 - 2010-12-28 - Added Trace statements.
                           - Used workaround for bug < IF varname IN (SELECT colname FROM tabname) >.
   Version 01 - 2010-12-27 - Initial Version.
*/

USE Miradi;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_Iterate_XML $$
CREATE PROCEDURE sp_Iterate_XML () 

BEGIN

      DECLARE pParentName VARCHAR(255) DEFAULT ""; -- The Parent that called this recursion.
      DECLARE pObjectName VARCHAR(255) DEFAULT ""; -- The Object of this recursion.
      DECLARE pObjectFlags INTEGER DEFAULT 0;     -- The Object's Element Flags.
      DECLARE pElementID INTEGER DEFAULT 0; -- Current Element ID
      DECLARE pElementName VARCHAR(255);    -- Current Element Name
      DECLARE pElementValue MEDIUMTEXT;     -- Current Element Value
      DECLARE pElementFlags INTEGER;        /* A seried of bitwise flags to direct special processing
                                               in called procedures ...

                                                  1 = Element is an Object header tag.
                                                  2 = Element is the Object header of a Pool of
                                                      multiple like Objects.
                                                  4 = Element is an Object for which exists a Table.
                                                  8 = Second and subsequent consecutive elements
                                                      that form a multi-valued list OR second
                                                      and subsequent element sets that form a
                                                      multi-valued set., e.g. IDs or Codes.
                                                 16 = Element is the Object header of a list of
                                                      Many-to-One-or-Many elements.
                                                 32 = Element is the Object header of a list of
                                                      One-to-Many elements.
                                                 64 = Object header for compound elements.
                                                      The element name is a Factor Name;
                                                      the element value is the Factor's XID.
                                                128 = Element is the Object header of a list of
                                                      recursive references.
                                                256 = Element contains a reference to a table that
                                                      shares multiple factors.
                                                512 = Element is the Object header for
                                                      ConservationProject.
                                               1024 = Element is the Object header for 
                                                      ProjectSummary.
                                               2048 = ElementValue contains the current Factor's 
                                                      XID Value.
                                               4096 = Factor requires that an XID be created for it.
                                               8192 = ElementValue contains the current Factor's 
                                                      Attribute Value.
                                            */
                                                 
      DECLARE pPoolName VARCHAR(255);       -- Pool Name being processed.
      DECLARE pPoolFlags INTEGER;           -- ElementFlags from Pool Header.
      DECLARE pTableName VARCHAR(255);      -- Table whose elements are being inserted.
      DECLARE pXID INTEGER DEFAULT 0;       -- XID of the row being inserted into pTableName
      DECLARE pParentTable VARCHAR(255);    -- Parent of pTableName in 1:N and M:N relationships.
      DECLARE pParentFlags INTEGER DEFAULT 0; -- Element Flags from Parent Header.
      DECLARE pParentXID INTEGER DEFAULT 0; -- Parent XID for bkwds rfrnc from embedded children.
      DECLARE pCoParent VARCHAR(255);       -- The Co-Parent in M:N relationships.
      DECLARE pColNames TEXT DEFAULT " (ID";  -- Seed for the set of column names being inserted.
      DECLARE pColValues MEDIUMTEXT DEFAULT "(^0"; /* Seed for the set of column values being inserted.
                                                      Anchor character (^) is used to prevent corruption
                                                      while constructing the value list and will be removed 
                                                      during INSERT.
                                                   */ 
      DECLARE pChildID INTEGER;             -- Child ID for EOF backfilling of Parent IDs.
      DECLARE pLastStackID INTEGER DEFAULT 0;  -- Pointer to next Stack record to be popped.
      DECLARE ProjectIdFlag BOOLEAN DEFAULT FALSE; -- TRUE = ProjectID was imported from XML.
      DECLARE pNewXID INTEGER DEFAULT 1;    -- Must create an ID for Factors that don't have one.
      DECLARE EOF BOOLEAN DEFAULT FALSE;

      /* Cursor to select each data element from the XML data stream, beginning
         with the first element following the previous recursion level.
      */

      DECLARE c_xml CURSOR FOR
              SELECT ID, ElementName, ElementValue, ElementFlags
                FROM XMLData
               WHERE ID > pElementID ORDER BY ID;

      /* Cursors to select child entries in 1:N and M:N relationships to backfill their
         Parent IDs. (When child records are written, we don't yet know their Parents' IDs.)
         We differentiate the processing for Objects that are (not) instances within a Pool.
      */

      DECLARE c_child1 CURSOR FOR
              SELECT DISTINCT ParentName, ParentFlags, TableName
                FROM ChildRefs
               WHERE ParentFlags & 2 = 2;

      DECLARE c_child2 CURSOR FOR
              SELECT DISTINCT ParentName, ParentFlags, TableName, ChildID
                FROM ChildRefs
               WHERE ParentFlags & 2 = FALSE;

      /* Cursor to select table names for ANALYZE TABLE statistics. */

      DECLARE c_analyze CURSOR FOR
              SELECT DISTINCT
                     CASE WHEN ElementName = "TaskSubTask" THEN "SubTask"
                          ELSE REPLACE(
                                  REPLACE(
                                     REPLACE(
                                        REPLACE(
                                           REPLACE(
                                              REPLACE(ElementName,"Threat","Cause"),
                                                      "BiodiversityTarget","Target"
                                                  ),"HumanWelfareTarget","Target"
                                               ),"IntermediateResult","Result"
                                            ),"ThreatReductionResult","Result" 
                                         ),"Task","TaskActivityMethod"
                                      ) 
                      END
                FROM XMLData
               WHERE ElementFlags & 4 = 4;

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET EOF = TRUE;
      
      SET @recur=@recur + 1;        -- Recursion level.
      OPEN c_xml;
      
      /* Seed the initial elements from the first row in XML_Data and then
         seed the Stack Table with those elements.
      */
      
      FETCH c_xml INTO pElementID, pElementName, pElementValue, pElementFlags;
      
      SET pObjectName = pElementName;
      SET pObjectFlags = pElementFlags;
      
      INSERT INTO Stack (ParentName,ObjectName,ObjectFlags,ElementID,
                         ElementName,ElementValue,ElementFlags,LastStackID
                        )
             VALUES (pParentName,pObjectName,pObjectFlags,pElementID,
                     pElementName,pElementValue,pElementFlags,pLastStackID
                    );
                    
      SET pLastStackID = pElementID;
      
Recur:
      WHILE @recur > 0 DO           -- For all elements at all recursion levels ...

            /* Trace/Debug statement */

            IF @Trace = TRUE THEN
               INSERT INTO Trace
                      VALUES (0,CONCAT(@recur," ",pParentName," ",pObjectName," ",
                                       pObjectFlags," ",pElementID," ",pParentXID
                                      ),CURRENT_TIME()
                             );
            END IF;

            IF pObjectFlags & 4 = 4     -- Object represents a Database Table.
               THEN SET pTableName = pObjectName;    -- Set the Table Name for recursive references.
            END IF;

      Cxml: WHILE TRUE DO                  -- For all elements at each recursion level ...
      
                  FETCH c_xml INTO pElementID, pElementName, pElementValue, pElementFlags;

                  /* Trace/Debug statement */
      
                  IF @Trace = TRUE THEN
                     INSERT INTO TRACE VALUES (0,CONCAT(@recur," ",pElementID," ",pElementName,
                                                        " ",pElementValue," Flags=",pElementFlags
                                                       ),CURRENT_TIME()
                                              );
                  END IF;

                  IF EOF OR pElementName = CONCAT("/",pObjectName)
                     THEN LEAVE Cxml;
                  END IF;

                 /* IF Element is a subordinate Object ... */
      
                  IF pElementFlags & 1 = 1 THEN

                     /* ... then push all variable values onto a stack and initialize them
                        for processing at the next recursion level. It is with conscious
                        intent that pTableName is not re-initialized. It will be set in the
                        next recursion level if the Object is a Table. Else, its value will
                        carry through to the next recursion level as all elements processed
                        there will be for the same table as this recursion level.
      
                        The Parent Name that is passed to the recursive iteration must be
                        a table. This is determined by testing Bit 4 of the Object Flags
                        in the call to this iteration. If it is not a table, but instead an
                        intermediate collection of elements whose values will be inserted upon
                        return to this recursion level, then the Parent (i.e. Table) Name that
                        was passed to this iteration must be passed on to the next.
                     */
      
                     INSERT INTO Stack (ParentName,ObjectName,ObjectFlags,ElementID,
                                        ElementName,ElementValue,ElementFlags,TableName,
                                        ParentTable,ParentFlags,ParentXID,PoolFlag,PoolName,
                                        ColNames,ColValues,LastStackID
                                       )
                            VALUES (pParentName,pObjectName,pObjectFlags,pElementID,
                                    pElementName,pElementValue,pElementFlags,pTableName,
                                    pParentTable,pParentFlags,pParentXID,@Pool,pPoolName,
                                    pColNames,pColValues,pLastStackID
                                   );

                     SET pLastStackID = pElementID;  /* Element ID of the next Stack record
                                                        to be popped is stored in each Stack
                                                        record.
                                                     */
 
                     IF pObjectFlags & 4 = 4 AND pObjectFlags & 512 = FALSE THEN

                         /* While technically, in the XML Schema, ConservationProject is the parent of
                            everything, for many reasons too complicated to explain here, in the database
                            it is the parent of nothing. Instead, in the database, ProjectSummary is the
                            parent of everything.
                         */

                         SET pParentName = pObjectName;
                         SET pParentFlags = pObjectFlags;
                         SET pParentXID = pXID;
                     END IF;
 
                     SET pObjectName = pElementName;
                     SET pObjectFlags = pElementFlags;
                     
                     /* Initialize pColNames and pColValues for this recursion. */
                     
                     CASE WHEN pElementFlags & (2048|4096) IN (2048,4096) THEN
                     
                               /* Save the XID of each row that may be the parent for (an) embedded
                                  child(ren) for retroactive insertion as a relational reference in 
                                  the child table during EOF processing.
                            
                                  Include the XID when initializing pColNames and pColValues.
                                  
                                  Flag 2048 = ElementValue contains this Object's XID 
                
                                  Flag 4096 = Object is a Factor that doesn't have its own XID and requires
                                  the assignment of one. (E.g. ThreatRating.)
                        
                                  Note that pColValues is anchored with "^" to avoid possible corruption
                                  while the value list is being constructed.
                               */

                               IF pElementFlags & 4096 = 4096 THEN

                                   /* Flag 4096 = Object is a Factor that doesn't have its own XID and requires
                                      the assignment of one. (E.g. ThreatRating.)
                                   */
                        
                                   SET pXID = pNewXID;
                                   SET pNewXID = pNewXID + 1;
                              
                               ELSE SET pXID = pElementValue;
                          
                               END IF;
                     
                               SET pColNames = " (ID,XID";
                     
                               IF pObjectFlags & 8 = 8 THEN /* Object Flag 8 = Multi-valued sets. */
            
                                   /* Close out the previous set and open a new set in the series of multi-valued sets. */
               
                                   SET pColValues = CONCAT("),(^0,",pXID);
                          
                               ELSE SET pColValues = CONCAT("(^0,",pXID);
                               
                               END IF;
                               
                          ELSE /* Object header does not contain or require an XID */
                          
                               SET pColNames = " (ID";
                                      
                               IF pObjectFlags & 8 = 8 THEN /* Object Flag 8 = Multi-valued sets. */
            
                                    /* Close out the previous set and open a new set in the series of multi-valued sets. */
               
                                    SET pColValues = "),(^0";
                           
                               ELSE SET pColValues = "(^0";

                               END IF;

                     END CASE;
                     
                     SET pElementName = "";
                     SET pElementValue = "";
                     SET pElementFlags = 0;
                     SET pParentTable = "";

                     SET @ColNames = "";    -- Initialize the global set of column names
                     SET @ColValues = "";   -- and values that transition among recursions.

                     IF pObjectFlags & 2 = 2 THEN
                         
                         /* Element is a Pool Header */
                         
                         SET @Pool = TRUE;
                         SET pPoolName = pObjectName;
                         SET pPoolFlags = pObjectFlags;
                         SET pParentName = "";
                     END IF;

                     SET @recur=@recur + 1;   -- Increment recursion level.
  
                     ITERATE Recur;
                  END IF;
      
                  /* Flag 8 = the element is the second or later in a series of multiple values within an 
                              Object. Append succesive values to the value list (pColValues). 
                     
                     Flag 16 = The Object forms a M:N relationship with its parent.
                     
                     Flag 32 = The Object forms a 1:N relationship with its parent.
                     
                     Flag 128 = the Object forms a recursive reference to a parent row in its own Table.
                     
                     Flag 64 = Object contains a compound reference factor in a multi-valued list
                               or set. Both Element Name and Element Value become distinct column 
                               values.
                  */
                  
                  IF (pObjectFlags & (16|32) IN (16,32)) THEN 
                  
                      /* Elements are in a 1/M:N relationship to their parent. */
                      
                       IF pObjectFlags & 128 = 128  
                       
                           /* Elements form a recursive reference to a parent in its own Table, 
                              e.g. Task to SubTask, and are named "Ref" .
                           */
                           
                           THEN SET pElementName = REPLACE(pElementName,"Id","Ref");
                           ELSE SET pElementName = REPLACE(pElementName,"Id","XID");
                       END IF;

                  END IF;

                  IF 8 IN (pElementFlags & 8, pObjectFlags & 8) THEN

                       /* Element is the 2nd or succeeding value in a multi-valued list
                          OR an element of a multi-valued set. 
                       */
 
                       IF pObjectFlags & 64 = 64 THEN /* Flag = 8 AND Flag = 64 */
                       
                            /* Element is a compound reference factor in a multi-valued list
                               or set. Both Element Name and Element Value are distinct column 
                               values. This is the case in diagram factor references and to 
                               the factors to which diagram links connect. They are normalized 
                               for insert into the table. The "Id" suffix is truncated so as to 
                               reflect the Object factor name.
                            */
                            
                            SET pColValues = CONCAT(pColValues, ",\"",
                                                    TRIM(TRAILING "Id" FROM pElementName)
                                                    ,"\",",pElementValue
                                                   );
                       ELSE /* Flag = 8 AND Flag != 64 */
                       
                            IF pElementFlags & 8 = 8 THEN
                            
                                /* ElementFlag = 8; ObjectFlag != 8.
                                
                                   Element is one of a multi-valued list, but not
                                   one in a multi-valued set (ObjectFlag = 8).
                                   Don't close off a multi-valued set
                                   (ObjectFlag = 8) until we reach the end of 
                                   the set of values.
                                   
                                   ColValues is anchored with "^" to avoid possible corruption
                                   during constuction of the value list.
                                */
                                
                                SET pColValues = CONCAT(pColValues,"),(^0");
                            END IF;
                            
                       END IF;
                       
                  ELSE /* (Flag != 8) */
                  
                       IF pObjectFlags & 64 = 64 THEN /* Flag != 8 AND Flag = 64 */

                            /* Element is a compound reference factor. Both Element Name and
                               Element Value are distinct column values. This is the case in
                               diagram factor references and to the factors to which diagram
                               links connect. They are normalized for insert into the table. The
                               "Id" suffix is truncated so as to reflect the Object factor name.
                            */

                            SET pColNames = CONCAT(pColNames, ",", pObjectName, ",", pObjectName, "XID");
                            SET pColValues = CONCAT(pColValues, ",\"",
                                                    TRIM(TRAILING "Id" FROM pElementName)
                                                    ,"\",",pElementValue
                                                   );
                       ELSE /* Flag != 8 AND Flag != 64 */

                            IF TRIM(LEADING pObjectName FROM pElementName) = "Id" THEN

                                  /* Miradi's convention is to name the user-assigned Id for
                                     each instance of an Object Factor 'ObjectId.' To differentiate
                                     the user-assigned ID from the database's convention of naming
                                     the primary key of each table 'ID' (and, thus, the foreign
                                     keys that reference the primary key 'TablenameID,'
                                     user-assigned IDs are given an underscore, and named 'Object_Id.'
                                  */
       
                                  SET pColNames =
                                         CONCAT(pColNames,",",REPLACE(pElementName,"Id","_Id")
                                              );
                             ELSE SET pColNames =
                                        CONCAT(pColNames, ",",
                                               CASE WHEN LOCATE(pObjectName,pElementName) = 1

                                                    /* What we're actually doing here is removing the
                                                       leading ObjectName from the Element Name. However,
                                                       because some instances of Element Name are identical
                                                       to their Object Name (e.g. ProjectLocationProjectLocation)
                                                       ... and TRIM() or REPLACE() removes/replaces /all/
                                                       occurrences of the trim/replace string, we can't use 
                                                       TRIM() or REPLACE() to perform this operation. Thus, 
                                                       it becomes unnecessarily complicated.
                                                    */

                                                    THEN SUBSTR(pElementName,LENGTH(pObjectName)+1)
                                                    ELSE pElementName
                                                END
                                              );
                             END IF;
                       END IF;
                  END IF;

                  IF pObjectFlags & 64 = FALSE THEN
                     SET pColValues = CONCAT(pColValues,",\"",pElementValue,"\"");
                  END IF;

            END WHILE Cxml;
      
            IF pObjectFlags & 4 = 4 THEN         -- Object represents a Database Table
            
                /* Insert a row into the table represented by the XML Object. */
            
                IF pObjectFlags & (16|32) IN (16,32) THEN     /* Object is the child of a  M:N or 1:N 
                                                                 association.
                                                              */
                   IF  @Pool = TRUE 
                   AND pObjectFlags & 256 = FALSE THEN        /* Children of tables in a pool must
                                                                 reference their Parent XID.
                                                              */
                       SET pColNames =
                              REPLACE(pColNames,"(ID",CONCAT("(ID,",pParentName,"XID"));
                              
                       /* ColValues is anchored with "^" to avoid possible corruption during manipulation. */

                       SET pColValues = REPLACE(pColValues,"(^0",CONCAT("(^0,",pParentXID));
                   END IF;
               END IF;
      
               /* ProjectSummaryID is inserted into every project-specific table in the database. 
                  It is the common relational association among all rows in all tables for each
                  project.

                  Because we don't yet know the ProjectSummaryID for Objects subordinate to
                  ProjectSummary whose values are embedded in the ProjectSummary Object
                  in the XML data stream, ProjectSummaryID will be saved when the ProjectSummary
                  row is inserted below, and backfilled into tables whose elements were embedded
                  as subordinates to ProjectSummary during EOF processing.
               */

               IF NOT (1024 IN (pObjectFlags & 1024, pParentFlags & 1024)) THEN
               
                  /* Flag 1024 = ProjectSummary Table.
                  
                     If we're writing the ProjectSummary record (pObjectFlag = 1024),
                     we will be creating ProjectSummaryID, which is an auto-increment column 
                     in the ProjectSummary Table.
                     
                     If this table is an embedded child of ProjectSummary (pParentFlag = 1024), 
                     then we don't yet know the ProjectSummaryID. In that case, the ID of this
                     child record will be inserted into ChildRefs so ProjectSummaryID can be 
                     retroactively into it during EOF processing.
                     
                  */
                  
                  SET pColNames = REPLACE(pColNames,"(ID","(ID,ProjectSummaryID");
                              
                  /* ColValues is anchored with "^" to avoid possible corruption while constructing
                     column value list.
                  */

                  SET pColValues = REPLACE(pColValues,"(^0",CONCAT("(^0,", @ProjectSummaryID));
               END IF;

               IF pObjectFlags & 256 = 256 THEN

                  /* Tag rows of Factor Types that share a common table. 
                     Undifferentiate TargetXID in ThreatRating Table
                  */
               
                  CASE WHEN pTableName IN ("DateUnitWorkUnits","DateUnitExpense",
                                           "CalculatedWorkUnits","CalculatedExpense",
                                           "CalculatedWho"
                                          ) THEN
                            SET pColNames = REPLACE(pcolNames,"(ID",
                                                    CONCAT("(ID,Factor,FactorXID")
                                                   );
                              
                            /* ColValues is anchored with "^" to avoid possible corruption while constructing
                               column value list.
                            */

                            SET pColValues = REPLACE(pColValues,"(^0",
                                                     CONCAT("(^0,\"", pParentName, "\",",
                                                            pParentXID
                                                           )
                                                     );
                                                   
                       WHEN pTableName = "IntermediateResult" THEN
                            SET pColNames = CONCAT(pColNames,",FactorType");
                            SET pColValues = CONCAT(pColValues,",\"IR\"");
                            
                       WHEN pTableName = "ThreatReductionResult" THEN
                            SET pColNames = CONCAT(pColNames,",FactorType");
                            SET pColValues = CONCAT(pColValues,",\"TR\"");

                       WHEN pTableName = "BiodiversityTarget" THEN
                            SET pColNames = CONCAT(pColNames,",FactorType");
                            SET pColValues = CONCAT(pColValues,",\"BD\"");
                            
                       WHEN pTableName = "HumanWelfareTarget" THEN
                            SET pColNames = CONCAT(pColNames,",FactorType");
                            SET pColValues = CONCAT(pColValues,",\"HW\"");
                                                    
                       WHEN pTableName = "ThreatRating" THEN
                            SET pColNames = 
                                   REPLACE(pColNames,"BiodiversityTargetXID","TargetXID");
                            
                       ELSE SET EOF = EOF;

                  END CASE;
                  
               END IF;

               IF pObjectFlags & 8192 = 8192 THEN
               
                  /* Factor's attribute name is contained in its object header's
                     ElementValue, which is located in the record pointed to by
                     the Stack Pointer.
                  */

                  SET pColValues = CONCAT(pColValues, ",\"", 
                                          (SELECT ElementValue FROM Stack 
                                            WHERE ElementID = pLastStackID
                                          ),"\""
                                         );
                  CASE pTableName 
                       WHEN "StatusEntry" THEN
                            SET pColNames = CONCAT(pColNames, ",StatusKey");
                                         
                       WHEN "ExtraDataSection" THEN
                            SET pColNames = CONCAT(pColNames, ",Owner");
                                         
                       WHEN "ExtraDataItem" THEN
                            SET pColNames = CONCAT(pColNames, ",Name");
                                         
                       WHEN "ConservationProject" THEN
                       
                            /* Conservation Project Table also contains the timestamp of this import. */
                            
                            SET pColNames = CONCAT(pColNames, ",xmlns,DatabaseImportDtm");
                            SET pColValues = CONCAT(pColValues,",\"", 
                                                    CURRENT_TIMESTAMP(),"\""
                                                   );
                                         
                       ELSE SET EOF = EOF;

                  END CASE;
                  
               END IF;
                  
               /* Prepare and execute the insert of elements into their table.
                              
                  Anchor character "^" is removed from ColValues.
               */
 
               SET @SQLStmt = CONCAT("INSERT INTO ",pTableName, pColNames, ") VALUES ",
                                     REPLACE(pColValues,"(^0","(0"), ")"
                                    );
                                    
               /* Trace/Debug statement */

               IF @Trace = TRUE THEN
                  INSERT INTO TRACE VALUES (0,@SQLStmt,CURRENT_TIME());
               END IF;

               PREPARE SQLStmt FROM @SQLStmt;
               EXECUTE SQLStmt;
               DEALLOCATE PREPARE SQLStmt;
               
               /******************************************************************************
               
                The next two statements select the primary key of the row just inserted
                using the function LAST_INSERT_ID(). No other INSERT can come before them.

               /* If this iteration has just written the ProjectSummary record, set the
                  global variable @ProjectSummaryID to be inserted into all subsequent
                  database tables that reference it ... and to be backfilled into tables
                  directly subordinate to ProjectSummary (before ProjectSummaryID was known)
                  during EOF processing.
               */

               IF pObjectName = "ProjectSummary"
                  THEN SET @ProjectSummaryID = LAST_INSERT_ID();
               END IF;

              /* Tables for subordinate Objects that are embedded within their parent Object
                  (e.g. ProjectResourceRoleCodes) are populated prior to knowing their
                  correpsonding Parent Object ID. We need to capture their IDs in the temporary
                  table ChildRefs so they can be backfilled with the reference to their Parent's ID
                  at the end of this iterative process for the entire Project. See code below
                  executed at EOF (when @recur = 0).
               */

               IF pParentName != ""
                  THEN INSERT INTO ChildRefs (ID,ProjectSummaryID,ParentName,ParentFlags,
                                              TableName,ChildID
                                             )
                              SELECT 0,@ProjectSummaryID,pParentName,
                                     CASE WHEN @Pool = TRUE
                                          THEN pObjectFlags + 2
                                          ELSE pObjectFlags
                                      END,pTableName,LAST_INSERT_ID();
               END IF;

               /******************************************************************************/
               
               SET @ColNames = "";
               SET @ColValues = "";
 
          ELSE /* If the Object just processed is not, itself, a Table, then its elements form
                  a 1:1 relationship with, and become columns of, the Table being processed by
                  a higher-level recursion. Pass its set of column names and values back to that
                  higher-level recursion.

                  If the Object forms a 1:N or M:N reletionship with its Parent, then
                  write a ChildID record so the Parent's ID (which is not yet known)
                  can be backfilled during EOF processing.
               */

               SET @ColNames = TRIM(LEADING " (ID" FROM pColNames);
               SET @ColValues = TRIM(LEADING "(^0" FROM pColValues);

               IF  pObjectFlags & (16|32) IN (16,32)
               AND @ColNames != "" THEN
                   INSERT INTO ChildRefs (ID,ProjectSummaryID,ParentName,ParentFlags,
                                          TableName
                                         )
                          SELECT 0,@ProjectSummaryID,
                                 TRIM(LEADING pTableName FROM
                                         TRIM(TRAILING "Id" FROM pObjectName)
                                      ),
                                 CASE WHEN @Pool = TRUE
                                      THEN pObjectFlags + 2
                                      ELSE pObjectFlags
                                  END,pTableName;
               END IF;
            END IF;
      
            IF pElementName LIKE "/%Pool"
               THEN SET @Pool = FALSE;
                    SET pPoolName = NULL;
            END IF;

            /* Pop the variable values from the previous recursion from the Stack */

            SET pXID = pParentXID;

            SELECT ParentName,ObjectName,ObjectFlags,ElementID,ElementName,ElementValue,
                   ElementFlags,TableName,ParentTable,ParentFlags,ParentXID,PoolFlag,PoolName,
                   CONCAT(ColNames,@ColNames),CONCAT(ColValues,@ColValues),LastStackID
              INTO pParentName,pObjectName,pObjectFlags,pElementID,pElementName,pElementValue,
                   pElementFlags,pTableName,pParentTable,pParentFlags,pParentXID,@Pool,pPoolName,
                   pColNames,pColValues,pLastStackID
              FROM Stack
             WHERE ElementID = pLastStackID;

            SET @recur = @recur - 1;        -- Decrement recursion level.

      END WHILE Recur;
      CLOSE c_xml;


      /* ANALYZE TABLEs. */

      /* Trace/Debug Statement */

      IF @Trace = TRUE THEN
         INSERT INTO TRACE VALUES (0,"Analyze Tables", CURRENT_TIME());
      END IF;

      SET EOF = FALSE;
      OPEN c_analyze;

Anlyz:
      WHILE NOT EOF DO
            FETCH c_analyze INTO pTableName;

            IF NOT EOF THEN
               SET @SQLStmt = CONCAT("ANALYZE LOCAL TABLE ",pTableName);

               /* Trace/Debug Statement */

               IF @Trace = TRUE THEN
                  INSERT INTO TRACE VALUES (0,@SQLStmt, CURRENT_TIME());
               END IF;

               PREPARE SQLStmt FROM @SQLStmt;
               EXECUTE SQLStmt;
               DEALLOCATE PREPARE SQLStmt;
            END IF;

      END WHILE Anlyz;
      CLOSE c_analyze;

      /* Trace/Debug Statement */

      IF @Trace = TRUE THEN
         INSERT INTO TRACE VALUES (0,"End Analyze Tables", CURRENT_TIME());
      END IF;


      /* Begin EOF processing. */

      /* Differentiate the Factor Type for Methods, Activities, and Tasks and their 
         subordinates based on their references. (Miradi stores all three of these
         factors in the single Object Class "Task.") This must be performed prior to backfilling 
         Parent IDs into Child Tables because Methods, Activities, and Tasks share the same 
         table (TaskActivityMethod) and their respective Views are dependent on their Factor.

         CalculatedWho, CalculatedWorkUnits, and CalculatedExpense records for those Factors also 
         need to be updated based on their Factor associations.
      */

      UPDATE TaskActivityMethod Task,
             IndicatorMethod IM
             
             /* Rows in TaskActivityMethod that are linked to Indicators are Methods. */
             
                LEFT JOIN CalculatedWho Who
                       ON Who.ProjectSummaryID = IM.ProjectSummaryID
                      AND Who.Factor = "Task"
                      AND Who.FactorXID = IM.MethodXID
                      
                LEFT JOIN CalculatedWorkUnits CalcWork
                       ON CalcWork.ProjectSummaryID = IM.ProjectSummaryID
                      AND CalcWork.Factor = "Task"
                      AND CalcWork.FactorXID = IM.MethodXID

                LEFT JOIN CalculatedExpense CalcExp
                       ON CalcExp.ProjectSummaryID = IM.ProjectSummaryID
                      AND CalcExp.Factor = "Task"
                      AND CalcExp.FactorXID = IM.MethodXID

         SET Task.Factor = "Method",
             Who.Factor = "Method",
             CalcWork.Factor = "Method",
             CalcExp.Factor = "Method"
       WHERE IM.ProjectSummaryID = Task.ProjectSummaryID
         AND IM.MethodXID = Task.XID
         AND Task.ProjectSummaryID = @ProjectSummaryID;

      UPDATE TaskActivityMethod Task,
             StrategyActivity SA
             
             /* Rows in TaskActivityMethod that are linked to Strategies are Activities. */
             
                LEFT JOIN CalculatedWho Who
                       ON Who.ProjectSummaryID = SA.ProjectSummaryID
                      AND Who.Factor = "Task"
                      AND Who.FactorXID = SA.ActivityXID
                      
                LEFT JOIN CalculatedWorkUnits CalcWork
                       ON CalcWork.ProjectSummaryID = SA.ProjectSummaryID
                      AND CalcWork.Factor = "Task"
                      AND CalcWork.FactorXID = SA.ActivityXID
                          
                LEFT JOIN CalculatedExpense CalcExp
                       ON CalcExp.ProjectSummaryID = SA.ProjectSummaryID
                      AND CalcExp.Factor = "Task"
                      AND CalcExp.FactorXID = SA.ActivityXID
                          
         SET Task.Factor = "Activity",
             Who.Factor = "Activity",
             CalcWork.Factor = "Activity",
             CalcExp.Factor = "Activity"
       WHERE SA.ProjectSummaryID = Task.ProjectSummaryID
         AND SA.ActivityXID = Task.XID
         AND Task.ProjectSummaryID = @ProjectSummaryID;

      UPDATE TaskActivityMethod Task,
             SubTask
             
             /* Rows in TaskActivityMethod that are linked to SubTasks are Tasks. */
             
                LEFT JOIN CalculatedWho Who
                       ON Who.ProjectSummaryID = SubTask.ProjectSummaryID
                      AND Who.Factor = "Task"
                      AND Who.FactorXID = SubTask.SubtaskRef
                      
                LEFT JOIN CalculatedWorkUnits CalcWork
                       ON CalcWork.ProjectSummaryID = SubTask.ProjectSummaryID
                      AND CalcWork.Factor = "Task"
                      AND CalcWork.FactorXID = SubTask.SubtaskRef
                          
                LEFT JOIN CalculatedExpense CalcExp
                       ON CalcExp.ProjectSummaryID = SubTask.ProjectSummaryID
                      AND CalcExp.Factor = "Task"
                      AND CalcExp.FactorXID = SubTask.SubtaskRef
                          
         SET Task.Factor = "Task",
             Who.Factor = "Task",
             CalcWork.Factor = "Task",
             CalcExp.Factor = "Task"
       WHERE SubTask.ProjectSummaryID = Task.ProjectSummaryID
         AND SubTask.SubtaskRef = Task.XID
         AND Task.ProjectSummaryID = @ProjectSummaryID;
         
      /* Now differentiate ParentName and TableName in the ChildRefs Table to correspond 
         to the updated Factors in the above tables.
      */
      
      UPDATE ChildRefs Child
                LEFT JOIN CalculatedWorkUnits CalcWork
                       ON CalcWork.ID = Child.ChildID
                      AND Child.TableName = "CalculatedWorkUnits" 
                      
                LEFT JOIN CalculatedExpense CalcExp
                       ON CalcExp.ID = Child.ChildID
                      AND Child.TableName = "CalculatedExpense" 
                      
                LEFT JOIN CalculatedWho Who
                       ON Who.ID = Child.ChildID
                      AND Child.TableName = "CalculatedWho" 
                      
                LEFT JOIN (TaskActivityMethodAssignment Asgn, TaskActivityMethod Task1)
                       ON (    Task1.ProjectSummaryID = Asgn.ProjectSummaryID
                           AND Task1.XID = Asgn.TaskActivityMethodXID
                           AND Asgn.ID = Child.ChildID
                           AND Child.TableName = "TaskAssignment"
                          )
                      
                LEFT JOIN (TaskActivityMethodExpense Exp, TaskActivityMethod Task2)
                       ON (    Task2.ProjectSummaryID = Exp.ProjectSummaryID
                           AND Task2.XID = Exp.TaskActivityMethodXID
                           AND Exp.ID = Child.ChildID
                           AND Child.TableName = "TaskExpense"
                          )
                      
                LEFT JOIN (TaskActivityMethodProgressReport Rpt, TaskActivityMethod Task3)
                       ON (    Task3.ProjectSummaryID = Rpt.ProjectSummaryID
                           AND Task3.XID = Rpt.TaskActivityMethodXID
                           AND Rpt.ID = Child.ChildID
                           AND Child.TableName = "TaskProgressReport"
                          )
                          
                LEFT JOIN (SubTask, TaskActivityMethod Task4)
                       ON (    Task4.ProjectSummaryID = SubTask.ProjectSummaryID
                           AND Task4.XID = SubTask.TaskXID
                           AND SubTask.ID = Child.ChildID
                           AND Child.TableName = "TaskSubTask"
                          ) 
                      
         SET Child.ParentName = CASE WHEN CalcWork.ID IS NOT NULL
                                          THEN CalcWork.Factor
                                     WHEN CalcExp.ID IS NOT NULL
                                          THEN CalcExp.Factor
                                     WHEN Who.ID IS NOT NULL
                                          THEN Who.Factor
                                     WHEN Asgn.ID IS NOT NULL
                                          THEN Task1.Factor
                                     WHEN Exp.ID IS NOT NULL
                                          THEN Task2.Factor
                                     WHEN Rpt.ID IS NOT NULL
                                          THEN Task3.Factor
                                     WHEN SubTask.ID IS NOT NULL
                                          THEN Task4.Factor
                                     ELSE Child.ParentName
                                 END,
             Child.TableName = CASE WHEN Asgn.ID IS NOT NULL
                                         THEN REPLACE(Child.TableName,"Task",Task1.Factor)
                                    WHEN Exp.ID IS NOT NULL
                                         THEN REPLACE(Child.TableName,"Task",Task2.Factor)
                                    WHEN Rpt.ID IS NOT NULL
                                         THEN REPLACE(Child.TableName,"Task",Task3.Factor)
                                    WHEN SubTask.ID IS NOT NULL
                                         THEN CASE Task4.Factor 
                                                   WHEN "Activity"
                                                        THEN "ActivityTask"
                                                   WHEN "Method"
                                                        THEN "MethodTask"
                                                   ELSE "TaskSubTask"
                                               END
                                    ELSE Child.TableName
                                 END
       WHERE Child.ProjectSummaryID = @ProjectSummaryID
         AND Child.TableName IN ("CalculatedWorkUnits","CalculatedExpense",
                                 "CalculatedWho","TaskAssignment","TaskExpense",
                                 "TaskProgressReport","TaskSubTask"
                                )
         AND Child.ParentName = "Task";


      /* Next, backfill Parent ID references in Child tables whose contents
         were embedded in Parent objects in the XML data stream and thus inserted
         into the database before their Parent IDs were known.
      */

      ANALYZE TABLE ChildRefs;

      SET EOF = FALSE;
      OPEN c_child1;

Child1:
      WHILE NOT EOF DO
            FETCH c_child1 INTO pParentTable, pObjectFlags, pTableName;

            IF NOT EOF THEN

            /* Trace/Debug Statement */

               IF @Trace = TRUE THEN
                  INSERT INTO TRACE VALUES(0,CONCAT(pParentTable,", Flags = ",
                                                    pObjectFlags,", ", pTableName
                                                   ),CURRENT_TIME()
                                          );
               END IF;

               SET @SQLStmt =
                      CONCAT("UPDATE ",pTableName," AS Child, ",
                             pParentTable," AS Parent",
                             " SET Child.",
                             CASE WHEN pObjectFlags & 256 = 256
                                  THEN "Factor"
                                  ELSE pParentTable
                              END,"ID = Parent.ID",
                             " WHERE Parent.ProjectSummaryID = Child.ProjectSummaryID",
                             " AND Parent.XID = Child.",
                             CASE WHEN pObjectFlags & 256 = 256
                                  THEN CONCAT("FactorXID AND Child.Factor = \"",pParentTable,"\"")
                                  ELSE CONCAT(pParentTable,"XID")
                              END,
                             " AND Child.ProjectSummaryID = ",@ProjectSummaryID
                            );

               /* Trace/Debug Statement */

               IF @Trace = TRUE THEN
                  INSERT INTO TRACE VALUES (0,@SQLStmt, CURRENT_TIME());
               END IF;

               PREPARE SQLStmt FROM @SQLStmt;
               EXECUTE SQLStmt;
               DEALLOCATE PREPARE SQLStmt;

               IF pObjectFlags & 16 = 16 AND pObjectFlags & 128 = FALSE THEN
                  SET pCoParent =
                         CASE TRIM(LEADING pParentTable FROM pTableName)
                              WHEN "Assignment" THEN "ResourceAssignment"
                              WHEN "Expense" THEN "ExpenseAssignment"
                              WHEN "CalculatedWho" THEN "ProjectResource"
                              WHEN "RelevantActivity" THEN "Activity"
                              WHEN "RelevantIndicator" THEN "Indicator"
                              WHEN "RelevantStrategy" THEN "Strategy"
                              WHEN "StressBasedThreatRating" THEN "Stress"
                              ELSE TRIM(LEADING pParentTable FROM pTableName)
                          END;
                  SET @SQLStmt =
                         CONCAT("UPDATE ",pTableName," AS Child, ",
                                pCoParent," AS Parent",
                                " SET Child.",pCoParent,"ID = Parent.ID",
                                " WHERE Parent.ProjectSummaryID =",
                                " Child.ProjectSummaryID",
                                " AND Parent.XID = Child.",pCoParent,"XID",
                                " AND Child.ProjectSummaryID = ",@ProjectSummaryID
                               );

                  /* Trace/Debug Statement */

                  IF @Trace = TRUE THEN
                     INSERT INTO TRACE VALUES (0,@SQLStmt, CURRENT_TIME());
                  END IF;

                  PREPARE SQLStmt FROM @SQLStmt;
                  EXECUTE SQLStmt;
                  DEALLOCATE PREPARE SQLStmt;
               END IF;

            END IF;

      END WHILE Child1;
      CLOSE c_child1;


      /* If the Parent Object is not in a Pool, there is no XID. The Parent:Child
         relationship is 1:1.
      */

      SET EOF = FALSE;
      OPEN c_child2;

Child2:  
      WHILE NOT EOF DO
            FETCH c_child2 INTO pParentTable, pObjectFlags, pTableName, pChildID;

            IF NOT EOF THEN
               /* Trace/Debug Statement */

               IF @Trace = TRUE THEN
                  INSERT INTO TRACE VALUES(0,CONCAT(pParentTable,", Flags = ",
                                                    pObjectFlags," ", pTableName
                                                   ),CURRENT_TIME()
                                          );
               END IF;

               SET @SQLStmt =
                      CONCAT("UPDATE ",pTableName," AS Child, ",
                             pParentTable," AS Parent",
                             " SET Child.",pParentTable,"ID = Parent.ID",
                             " WHERE CASE WHEN \"",pParentTable,
                             "\" != \"ProjectSummary\" ",
                             " THEN Child.ProjectSummaryID = Parent.",
                             TRIM(LEADING pParentTable FROM "ProjectSummaryID"),
                             " ELSE Child.ID = ",pChildID," END AND Parent.",
                             TRIM(LEADING pParentTable FROM "ProjectSummaryID"),
                             " = ",@ProjectSummaryID
                            );

               /* Trace/Debug Statement */

               IF @Trace = TRUE THEN
                  INSERT INTO TRACE VALUES (0,@SQLStmt, CURRENT_TIME());
               END IF;

               PREPARE SQLStmt FROM @SQLStmt;
               EXECUTE SQLStmt;
               DEALLOCATE PREPARE SQLStmt;

               SET @SQLStmt = CONCAT("ANALYZE TABLE ",pTableName);
               PREPARE SQLStmt FROM @SQLStmt;
               EXECUTE SQLStmt;
               DEALLOCATE PREPARE SQLStmt;

               /* If the ConPro Project ID was imported from the XML data stream
                  then we don't have to create one.
               */

               IF pTableName = "ExternalProjectId" THEN
                  SET ProjectIdFlag = TRUE;
               END IF;

            END IF;

      END WHILE Child2;
      CLOSE c_child2;
      
      
      /* If ConPro Project ID was not imported from the XML data stream, create it. */

      IF ProjectIdFlag = FALSE THEN
         INSERT INTO ExternalProjectId
                SELECT 0, @ProjectSummaryID, "ConPro", ProjectID FROM ProjectID;
         UPDATE ProjectID SET ProjectID = ProjectID + 1;
         ANALYZE TABLE ExternalProjectId;
      END IF;


      /* Transform Target.ViabilityMode from "","TNC" to "Simple","KEA", respectively. */

      UPDATE Target
         SET ViabilityMode = CASE WHEN ViabilityMode IS NULL THEN "Simple"
                                  WHEN ViabilityMode = "TNC" THEN "KEA"
                              END
       WHERE ProjectSummaryID = @ProjectSummaryID;
       
       
      /* Set Indicator.IsActive to be compatible with Target.ViabilityMode and Strategy.Status.
      
         If Indicators were created under both Simple and KEA Viability Modes, then inactivate
         the Indicator created under the mode not selected when the project was exported.
         
         Similarly, if a Strategy is flagged by the user as a Draft Strategy, Indicators
         created for that Strategy will be flagged as inactive.
      */

      UPDATE Indicator Ind
                LEFT JOIN (TargetIndicator TgtInd, Target Tgt1)
                       ON (    Tgt1.ID = TgtInd.TargetID
                           AND TgtInd.IndicatorID = Ind.ID
                          )
                LEFT JOIN (v_KEAIndicator KEAInd, v_TargetKEA TgtKEA, Target Tgt2)
                       ON (    Tgt2.ID = TgtKEA.TargetID
                           AND TgtKEA.KEAID = KEAInd.KEAID
                           AND KEAInd.IndicatorID = Ind.ID
                          )
                LEFT JOIN (StrategyIndicator StrInd, Strategy Str)
                       ON (    Str.ID = StrInd.StrategyID
                           AND StrInd.IndicatorID = Ind.ID
                          ) 
         SET IsActive = CASE WHEN Tgt1.ViabilityMode = "KEA" THEN FALSE
                             WHEN Tgt2.ViabilityMode = "Simple" THEN FALSE
                             WHEN Str.Status = "Draft" THEN FALSE
                             ELSE TRUE
                         END
       WHERE Ind.ProjectSummaryID = @ProjectSummaryID;


      /* Update Sequence of StrategyActivity, SubTask, IndicatorMethod */

      /* IMPORTANT NOTE: The desired sequence to retrieve rows from these intersections is
         the physical sequence their associations were exported in the XML. While that sequence
         can be robustly assured with SELECT ... ORDER BY TableName.ID, a Sequence field
         is introduced for clarity in assuring the rows are sequenced when retrieved.
      */

      UPDATE StrategyActivity SA,
             (SELECT ProjectSummaryID, MIN(ID) AS MinID
                FROM StrategyActivity
               WHERE ProjectSummaryID = @ProjectSummaryID
               GROUP BY 1
             ) AS T1
         SET SA.Sequence = SA.ID - T1.MinID + 1
       WHERE SA.ProjectSummaryID = T1.ProjectSummaryID;

      UPDATE SubTask,
             (SELECT ProjectSummaryID, MIN(ID) AS MinID
                FROM SubTask
               WHERE ProjectSummaryID = @ProjectSummaryID
               GROUP BY 1
             ) AS T1
         SET SubTask.Sequence = SubTask.ID - T1.MinID + 1
       WHERE SubTask.ProjectSummaryID = T1.ProjectSummaryID;

      UPDATE IndicatorMethod IM,
             (SELECT ProjectSummaryID, MIN(ID) AS MinID
                FROM IndicatorMethod
               WHERE ProjectSummaryID = @ProjectSummaryID
               GROUP BY 1
             ) AS T1
         SET IM.Sequence = IM.ID - T1.MinID + 1
       WHERE IM.ProjectSummaryID = T1.ProjectSummaryID;


      /* Create the components of Work Plan and Expense durations from their text elements. */

      UPDATE DateUnitWorkUnits
         SET StartYear =
             CASE WHEN WorkUnitsDateUnit IN ("Month","Quarter","Year")
                  THEN SUBSTRING_INDEX(SUBSTRING_INDEX(WorkUnitsDate,
                                                      '"',2
                                                      ),'"',-1
                                      )
              END,
             StartMonth =
             CASE WHEN WorkUnitsDateUnit IN ("Month","Quarter","Year")
                  THEN SUBSTRING_INDEX(SUBSTRING_INDEX(WorkUnitsDate,
                                                       '"',4
                                                      ),'"',-1
                                      )
              END
       WHERE ProjectSummaryID = @ProjectSummaryID;

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
       WHERE Plan.ProjectSummaryID = DateUnitWorkUnits.ProjectSummaryID
         AND DateUnitWorkUnits.ProjectSummaryID = @ProjectSummaryID;


      UPDATE DateUnitExpense
         SET StartYear =
             CASE WHEN ExpensesDateUnit IN ("Month","Quarter","Year")
                  THEN SUBSTRING_INDEX(SUBSTRING_INDEX(ExpensesDate,
                                                       '"',2
                                                      ),'"',-1
                                      )
              END,
             StartMonth =
             CASE WHEN ExpensesDateUnit IN ("Month","Quarter","Year")
                  THEN SUBSTRING_INDEX(SUBSTRING_INDEX(ExpensesDate,
                                                       '"',4
                                                      ),'"',-1
                                      )
              END
       WHERE ProjectSummaryID = @ProjectSummaryID;

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
       WHERE Plan.ProjectSummaryID = DateUnitExpense.ProjectSummaryID
         AND DateUnitExpense.ProjectSummaryID = @ProjectSummaryID;


      /* Populate Stress.StressRating (not yet populated by Miradi) */

      UPDATE Stress Str, StressBasedThreatRating Sthr
         SET Str.StressRating = Sthr.StressRating
       WHERE Sthr.StressID = Str.ID
         AND Str.ProjectSummaryID = @ProjectSummaryID;


      /* Trace/Debug Statement. */

      IF  @Trace = TRUE THEN
          INSERT INTO TRACE VALUES (0,"End sp_Iterate_XML()",CURRENT_TIME());
      END IF;

END $$

DELIMITER ;

-- END