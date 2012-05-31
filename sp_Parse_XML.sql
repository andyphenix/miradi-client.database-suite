/*
   sp_Parse_XML_v50e.sql

   Parses raw XMLZ XML Data contained in the ProjectXML Table into distinct rows
   of element names and values. 
   
   Compatible with XMPZ XML data model http://xml.miradi.org/schema/ConservationProject/73.
   
   Developed by David Berg for The Nature Conservancy 
        and the Greater Conservation Community.

   Note that most conditional tests in this procedure must occur in the order presented, as the
   first condition in a CASE statement that tests TRUE exits the CASE statement. Changes to
   that order must be tested thoroughly before implementing them.

   Revision History: 
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
                           - Fix a bug where an Object that had an attribute (Id or other element)
                             but no other elements was discarded as a consequence of changes
                             implemented in Version 49(?).
   Version 49 - 2011-08-24 - Much streamlining and rework to improve performance as well as
                             consistency, clarity, and comprehension. 
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
   Version 46 - 2011-07-15 - Create independent element for xmlns.
                           - Assign Flag to object ConservationProject.
                           - Flag ConservationProject = 512 and ProjectSummary = 1024.
                           - Add DatabaseImportDtm to ConservationProject.
   Version 45 - 2011-06-30 - Rename Task and associated Tables to TaskActivityMethod
   Version 44 - 2011-06-27 - Change FactorName to FactorType for all occurrences.
   Version 43 - 2011-05-25 - Make compound elements Flag 64 instead of their object headers.
   Version 42 - 2011-05-18 - Add ID field to Trace.
   Version 41 - 2011-05-09 - Add FactorName to CalculatedYears and WorkUnits/ExpenseEntry
   Version 40 - 2011-05-01 - Replace the '<' that is removed from the front of every line when
                             reading the raw XML file into Import_XML.sql. (See explanation below
                             and in Import_XML.sql.)
   Version 39 - 2011-04-26 - Changes corresponding to XML Schema Version 73.
                           - Add code to process .
   Version 38a- 2011-04-24 - Replace all RLIKE operators for performance sensitivity.
   Version 38 - 2011-04-24 - Revisions to database structure to simplify parsing logic.
   Version 37 - 2011-04-22 - Revisions to Version 36 to make it more robust.
   Version 36 - 2011-04-18 - Some serious additions required to support Calculated Costs.
   Version 35 - 2011-04-15 - Additional normalization of the database to remove custom parsing
                             for Diagram features.
                             - Remove Flag 256 processing from ScopeBoxes and Diagram Links to
                               correspond to database schema updates.
                             - Remove special processing for Tagged Object Sets to correspond to
                               the addition of WrappedByDiagramFactor as its own table.
                           - Reformat IF/CASE statements for better space utilization.
   Version 34 - 2011-04-11 - Make the Debug/Trace an optional feature on call.
   Version 33 - 2011-04-08 - Additional revisions from Version 32. Version 32 stripped
                             "Biodiversity","HumanWelfare","Intermediate", and "ThreatReduction"
                             from /all/ occurrences, inclduing diagram factor references. Those,
                             in particular, need to be kept intact. So I used Flag 256 to mark
                             the elements to be stripped within Target, Result, and ThreatRating
                             Pools.
   Version 32 - 2011-03-26 - Revise the handling of Factor Types that share a common table:
                             Biodiversity & Human Welfare Targets; Intermediate & Threat
                             Reduction Results. Goal and Objective each becomes its own table.
   Version 31 - 2011-03-23 - Revise the paradigm of storing Expense and Work Unit Time
                             schedules.
   Version 30 - 2011-03-17 - Add processing for the new Object set in Schema Version 66, "ExtraData".
                           - Change data type of ElementValue to MEDIUMTEXT to accommodate
                             ExtraDataItemValue.
                           - Add additional transformations for embedded special characters in the data.
   Version 29 - 2011-03-10 - Go back to using a temporary table to identify Object Header Tags.
                             It adds <= 1 second to performance, but is more robust than
                             trusting that all elements with an empty value are Object Headers.
   Version 28 - 2011-03-07 - Additional changes for Dashboard Status Entries.
                           - Allow ProjectSummaryScope to be renamed ProjectScope.
                           - Add KeyEcologicalAttribute and ScopeBox to 256 flags.
                           - Replaced inadvertent deletion of
                             REPLACE(ElementName,"FactorLink","Link").
   Version 27 - 2011-03-03 - Changes in accordance with XML Schema Version 63.
   Version 26 - 2011-02-28 - Expense Assignment timelines are exported on the same XML Line
                             as are Object IDs. Thus, parsing of the embedded quotes in each
                             of those specifications became confused. I moved the code to
                             parse those specifications out of the SELECT statement and into
                             the body of the parsing code.
                           - This also enabled me to rewrite the determination of an Object
                             Header and get rid of the need to create an extra temporary table.
                           - Make MiradiTables a permanent table in the database schema script.
                           - Move ThreatRatingXID back into the parse script so @ParentXID gets
                             properly set when the iterate script is processing StressThreatRating.
                           - (03/02) Fix parsing of Expense & WorkPlan Time assignments.
   Version 25 - 2011-02-25 - Move more stuff around to try to improve performance.
   Version 24 - 2011-02-19 - Move deletion of empty elements back into XLine loop
                             to improve performance.
   Version 23 - 2011-02-16 - Simplify flagging Pool header tags.
   Version 22 - 2011-02-15 - Move all ElementName and ElementValue alterations to EOF updates
                             rather than during line-by-line processing for performance reasons.
   Version 21 - 2011-02-13 - Changes to reflect updated XML Schema Version 58.
   Version 20 - 2011-02-07 - Move flag settings into UPDATE statements at the end of the parse process.
                           - More thorough annotations.
   Version 19 - 2011-02-02 - Streamline and edit object and element name/value adjustments.
                           - Other adjustments and minor bug fixes.
   Version 18 - 2010-01-31 - Simplify Table Names.
                           - Tag DiagramLinkBendPoints and Indicator Thresholds.
                           - Other revisions following successful run of Version 17.
   Version 17 - 2010-01-28 - Accommodate revisions to TNC Project Data in revised XML Schema.
                           - Incorporate delimiters for work plan timespans into a single statement.
   Version 16 - 2010-01-25 - Reverse Version 07 WRT differentiation of Scope, Planning, Location.
   Version 15 - 2010-01-24 - Add code to parse work plan and expense date assignments.
   Version 14 - 2010-01-18 - Restructure how Containers & Ids work.
   Version 13 - 2010-01-17 - Restructure Element Flags
                           - Eliminate table XMLObjects; use Element Flag instead.
   Version 12 - 2011-01-15 - Remove special processing for ExternalProjectId. (Now in XML Schema.)
   Version 11 - 2011-01-13 - Further code improvements.
                           - Set Bit 8 in ElementFlags if Element is a WrappedByDiagramFactor.
   Version 10 - 2011-01-12 - Improve generalizations as they apply to like situations.
   Version 09 - 2011-01-10 - Revise handling of ExternalProjectID.
   Version 08 - 2011-01-07 - Streamline and generalize table-specific code.
   Version 07 - 2011-01-03 - Accomodate XML_Data as a temporary table.
                           - Resequence Project Summary Objects in XMLData so they are consecutive.
                           - Remove the tags that delimit ProjectSummaryScope, ProjectSummaryLocation,
                             and ProjectSummaryPlanning objects, that they may be inserted into the
                             ProjectSummary Table.
   Version 06 - 2011-01-01 - Split Object ID onto separate line and name it XID.
   Version 05 - 2010-12-29 - Replace Id with XID in the XML Stream.
   Version 03 - 2010-12-xx - Added handler for naming convention exceptions, e.g. External Project ID.
   Version 02 - 2010-12-xx - Added population of XMLObjects Table.
   Version 01 - 2010-12-xx - Initial Version.
*/

USE Miradi;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_Parse_XML $$
CREATE PROCEDURE sp_Parse_XML()

Parse:
BEGIN

      DECLARE XML_Line_In MEDIUMTEXT;             -- Raw XML Imput
      DECLARE XML_Line_Out MEDIUMTEXT;            -- Parsed XML Output
      DECLARE pElementName VARCHAR(255);
      DECLARE pElementValue MEDIUMTEXT;
      DECLARE pElementFlags INTEGER DEFAULT 0;  /* A seried of bitwise flags to direct special
                                                   processing in called procedures ...

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
                                                  256 = Element is a table that shares 
                                                        multiple factors.
                                                  512 = Element is the Object header for ConservationProject.
                                                 1024 = Element is the Object header for ProjectSummary.
                                                 2048 = ElementValue contains the current Object's 
                                                        XID Value.
                                                 4096 = Factor requires that an XID be created for it.
                                                 8192 = ElementValue contains the current Factor's 
                                                        Attribute Value.
                                                */
      DECLARE PrevElementID INTEGER DEFAULT 0;
      DECLARE PrevElementName TEXT DEFAULT "";
      DECLARE i SMALLINT DEFAULT 0;               -- Iterator for delimited segments.
      DECLARE EOF BOOLEAN DEFAULT FALSE;

      /* Cursor to parse the XML lines into distinct records.

        A line delimiter ("^") is appended to each row as it is read in to recognize EOL
        while traversing line segments.
      */

      DECLARE c_xml CURSOR FOR
              SELECT CONCAT(XML_Line,"^")
                FROM ProjectXML ORDER BY ID;

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET EOF = TRUE;

      /* Trace/Debug Statement. This particular statement is executed unconditionally to
         timestamp entry into the import process.
      */

      INSERT INTO Trace VALUES (0,"Begin Parse",CURRENT_TIME());

      OPEN c_xml;

      /* For every row in the XML Data stream ... */

      Xrow:
      WHILE NOT EOF DO

            FETCH c_xml INTO XML_Line_In;

            IF NOT EOF THEN
               SET i = 0;

               /* Iterate through the delimited segments on each line, delimited by
                  the junction of two tags, '><'.
               */

               XLine:
               WHILE LOCATE("^",SUBSTRING_INDEX(SUBSTRING_INDEX(XML_Line_In,"><",i
                                                               ),"><",-1
                                               )
                           ) = 0 DO

                     SET pElementFlags = 0;
                     
                     /* Segment each XML Line into distinct records as delimited by "><". */

                     SET i = i+1;
                     SET XML_Line_Out =
                            CONCAT(CASE WHEN i > 1 THEN "<" ELSE "" END,
                                   TRIM(TRAILING "^" FROM
                                        SUBSTRING_INDEX(
                                           SUBSTRING_INDEX(XML_Line_In,"><",i
                                                          ),"><",-1
                                                       )
                                       ),">"
                                  );

                     CASE WHEN XML_Line_Out LIKE "% Id=%" THEN

                               /* Element is an Object Header within a Pool.

                                  Internal Object IDs are specified using the notation:
                                  'ObjectClassHeader Id="xx"'. The Id is separated
                                  From the Object Class Header and becomes its 
                                  ElementValue. It will become the XID value when
                                  inserted into its respective Table in Iterate_XML.
                               */

                               SET XML_Line_Out = 
                                      REPLACE(REPLACE(XML_Line_Out," Id=\"",">"
                                                     ),"\">",""
                                             );
                               SET pElementFlags = pElementFlags + 2048;
                               
                          WHEN XML_Line_Out LIKE "<StatusEntry Key=%" THEN
                          
                               /* Dashboard Status Entries are like any object within
                                  a pool, except they are subordinate to objects within
                                  a pool and are not a pool in and of themselves. Their
                                  instance attribute, rather than being an ID, is, instead
                                  a textual "Key." The Key is separated from the ElementName
                                  and becomes its ElmentValue.
                               */
                               
                               SET XML_Line_Out =
                                   REPLACE(REPLACE(XML_Line_Out," Key=\"",">"
                                                  ),"\">",""
                                          );
                               SET pElementFlags = pElementFlags + 8192;
                                
                          /* Extra Data Sections and Extra Data Items each contain a non-key
                             attribute value in their Object Header.
                          */
                          
                          WHEN XML_Line_Out LIKE "<ExtraDataSection owner=%" THEN
                               SET XML_Line_Out = 
                                   REPLACE(REPLACE(XML_Line_Out," owner=\"",">"
                                                  ),"\">",""
                                          );
                               SET pElementFlags = pElementFlags + 8192;
                                                         
                          WHEN XML_Line_Out LIKE "<ExtraDataItem ExtraDataItemName=%" THEN
                               SET XML_Line_Out = 
                                   REPLACE(REPLACE(XML_Line_Out," ExtraDataItemName=\"",">"
                                                  ),"\">",""
                                          );
                               SET pElementFlags = pElementFlags + 8192;
                                                         
                          WHEN XML_Line_Out LIKE "<ConservationProject xmlns=%" THEN
                          
                               /* Conservation Project contains the XMLNS specification as
                                  its attribute value.
                               */
                               
                               SET XML_Line_Out = 
                                   REPLACE(REPLACE(XML_Line_Out," xmlns=",">"
                                                  ),"\">","\""
                                          );
                               SET pElementFlags = pElementFlags + 512 + 8192;
                                                         
                          ELSE SET i = i;
                      END CASE;

                     /* Separate each record into its Element Name and Value.
                        First Element Name ...
                     */

                     SET pElementName = TRIM(LEADING "<" FROM
                                             SUBSTRING_INDEX(XML_Line_Out,">",1)
                                            );

                     CASE WHEN TRIM(LEADING "/" FROM pElementName) 
                                  IN ("ExpensesDateUnit","WorkUnitsDateUnit",

                               /* Element is a Work Plan/Expense Assignment time specification.
                                  Separate the time specification from the Element Header Tag,
                                  rename the field to WorkUnitsDate/ExpensesDate, and lose
                                  the header and trailer tags.
                               */
                                      "LinkableFactorId"
                                     ) THEN
                                     
                               /* LinkableFactorId is a structural element, required in the XML Schema,
                                  that actually gets in the way of the iterator when its lead-in Object
                                  is tagged with Flag 64 because its child element is a compound element
                                  and its lead-in's Object Name is used to form its child's column names.

                                  For the  present, at least, it will be removed from the XML data stream,
                                  as it has no usable function in it and would require custom code to
                                  deal with its presence.
                               */

                               SET PrevElementName = pElementName;
                               ITERATE XLine; 
                               
                          WHEN PrevElementName IN ("ExpensesDateUnit","WorkUnitsDateUnit") THEN
                          
                               /* Insert the WorkUnit/Expense time period object header. */
                               
                               INSERT INTO XMLData (ID, ElementName, ElementValue, ElementFlags)
                                      VALUES (0, SUBSTRING_INDEX(pElementName," ",1), "", pElementFlags);
                                      
                               /* Separate the time period unit from the time period specification.
                                  Insert the time period unit and stage the time period specification
                                  and rename the field to WorkUnitsDate/ExpensesDate.
                               */
                                      
                               INSERT INTO XMLData (ID, ElementName, ElementValue, ElementFlags)
                                      VALUES (0, PrevElementName,
                                              TRIM(LEADING "WorkUnits" FROM
                                                      TRIM(LEADING "Expenses" FROM 
                                                              SUBSTRING_INDEX(pElementName," ",1)
                                                          )
                                                  ), pElementFlags
                                             );

                               SET pElementName = CASE WHEN LEFT(pElementName,3) = "Exp"
                                                       THEN "ExpensesDate"
                                                       ELSE "WorkUnitsDate"
                                                   END;

                          WHEN pElementName IN ("ExtraData","/ExtraData")

                               /* ExtraData contains users' view specifications in "Sections"
                                  and will be treated like a Pool. Instances of the
                                  ExtraDataPool are ExtraDataSections whose attribute is
                                  an "owner." Sections don't carry their own XID, so one will
                                  be provided for them. Each ExtraDataSection contains A series
                                  of Names (presented as attributes rather than elements(??))
                                  and corresponding Values.
                               */
                          
                               THEN SET pElementName = CONCAT(pElementName,"Pool");
                               
                          ELSE SET i = i;
                     END CASE;


                     /* Remove empty Objects (where the Object trailer tag immediately
                        follows the Object header tag without any element value) so the
                        iterator doesn't waste performance time by creating an unnecessary
                        recursion loop for them.
                     */

                     IF pElementName = CONCAT("/",PrevElementName) THEN
                        DELETE FROM XMLData WHERE ID = PrevElementID;
                        ITERATE XLine;
                        
                     END IF;

                     /* ... then Element Value */

                     SET pElementValue =
                         CASE WHEN pElementName IN ("WorkUnitsDate","ExpensesDate") THEN
                                   TRIM(TRAILING ">" FROM
                                        SUBSTRING_INDEX(XML_Line_Out," ",
                                                        CASE WHEN XML_Line_Out LIKE "%Full%"
                                                               OR XML_Line_Out LIKE "%Day%"
                                                             THEN -1 ELSE -2
                                                         END
                                                       )
                                        )
                              ELSE
                                   REPLACE(SUBSTRING_INDEX(
                                              SUBSTRING_INDEX(XML_Line_Out,"</",1),">",-1
                                                          ),CONCAT("^",x'0d'),""
                                          )
                          END;

                    /* Insert parsed XML Data into its table for importing into the database. */

                     INSERT INTO XMLData (ID, ElementName, ElementValue, ElementFlags)
                            VALUES (0, pElementName, pElementValue,

                                    /* Flag 8 = Second and subsequent consecutive elements
                                                that form a multi-valued list OR second
                                                and subsequent element sets that form a
                                                multi-valued set.
                                    */

                                    CASE WHEN pElementName = PrevElementName
                                           OR (    pElementName IN ("WrappedByDiagramFactorId",
                                                                    "DiagramPoint"
                                                                   )
                                               AND PrevElementName IN ("/WrappedByDiagramFactorId",
                                                                       "/DiagramPoint"
                                                                      )
                                              )
                                         THEN pElementFlags + 8
                                              
                                         ELSE pElementFlags
                                     END
                                   );

                     SET PrevElementID = LAST_INSERT_ID();
                     
                     IF pElementFlags & (2048|8192) = FALSE THEN

                        /* Don't allow Objects with attribute values but no other element
                           present to be inadvertently discarded. (This possibility was
                           introduced with Version 49(?)  and corrected in Version 50).
                        */
                        
                        SET PrevELementName = pElementName;
                     END IF;

               END WHILE XLine;
            END IF;
      END WHILE XRow;
      CLOSE c_xml;
      
      /* Begin EOF Processing. */

      /* Trace/Debug Statement */

      IF @Trace = TRUE THEN
         INSERT INTO Trace VALUES (0,"Begin Update Flags",CURRENT_TIME());
      END IF;

      /* Flag 1 = Element is an Object Header Tag. */

      CREATE INDEX ElmntNm ON XMLData (ElementName);
      ANALYZE TABLE XMLData;

      DROP TABLE IF EXISTS XMLObjects;
      CREATE TEMPORARY TABLE XMLObjects
             SELECT DISTINCT TRIM(LEADING "/" FROM ElementName) AS ObjectName
               FROM XMLData
              WHERE LEFT(ElementName,1) = "/";

      UPDATE XMLData Dat, XMLObjects Obj
         SET Dat.ElementFlags = Dat.ElementFlags + 1
       WHERE Dat.ElementName = Obj.ObjectName;

      DROP TABLE XMLObjects;

      /* Trace/Debug Statement */

      IF @Trace = TRUE THEN
         INSERT INTO Trace VALUES (0,"End Object Flags",CURRENT_TIME());
      END IF;

      UPDATE XMLData
         SET ElementName =

                CASE /* Object/Element Names for these selected Objects are altered (shortened
                        for the most part, clarified in others) to be consistent with their Database
                        Table/Column Names. They do not necessarily reflect exceptions to their naming
                        in the XML Schema (which has its own requisite naming consistency rules), but
                        are just rendered consistent for meaningful cognition in the Database and ERD.

                        While it may seem counter-intuitive, the best performance for this step is
                        actually acheived by performing a single UPDATE that sequentially read the
                        entire table without a filter to select affected rows rather than in-line
                        processing during parsing.

                        The WHEN statements are listed in order of their likely occurrence for
                        performance considerations because a condition that tests TRUE will exit
                        the CASE statement. However, for exactly that reason, some conditions are
                        consciously tested ahead of others that might occur with higher frequency
                        because they test a condition that might be eliminated by a previous TRUE result.

                        Therefore, please use care and test thorouhly if thinking about changing their order.
                     */

                     WHEN TRIM(LEADING "/" FROM ElementName) IN ("WrappedByDiagramFactorId",
                                                                 "DiagramLinkFromDiagramFactorId",
                                                                 "DiagramLinktoDiagramFactorId",
                                                                 "DiagramLinkBendPoints",
                                                                 "TaggedObjectSetFactorIds"
                                                                ) THEN
                                                                
                          /* Database naming convention consistency */
                          
                          TRIM(TRAILING "Id" FROM TRIM(TRAILING "s" FROM ElementName))
                          
                     WHEN TRIM(LEADING "/" FROM ElementName) = "DiagramFactorGroupBoxChildrenIds"

                          /* Rename object DiagramFactorGroupBoxChildren to GroupBoxChildren.
                             This is case where the XML name follows the XML naming convention,
                             but whose prefix doesn't add value to its cognition in the database.
                          */

                          THEN REPLACE(ElementName,"DiagramFactor","")

                     WHEN TRIM(LEADING "/" FROM ElementName) = "DiagramLinkGroupedDiagramLinkIds"

                          /* Rename object DiagramLinkGroupedDiagramLink to GroupedDiagramLink.
                             This is case where the XML name follows the XML naming convention,
                             but whose prefix doesn't add value to its cognition in the database.
                          */

                          THEN REPLACE(ElementName,"DiagramLinkG","G")

                     WHEN TRIM(LEADING "/" FROM ElementName) LIKE "WorkUnitsEntry%"

                          /* - Rename object WorkUnitsEntry to CalculatedWorkUnits.
                             - Rename element ResourceId to ProjectResourceId.
                               (Note: the ResourceId transformation is made here because the test for
                                ResourceId below would never be reached when this condition tests TRUE.
                          */

                          THEN REPLACE(REPLACE(ElementName,"WorkUnitsEntry","CalculatedWorkUnits"),
                                       "ResourceId","ProjectResourceId"
                                      )

                     WHEN TRIM(LEADING "/" FROM ElementName) LIKE "ExpenseEntry%"

                          /* Rename object ExpenseEntry to CalculatedExpense. */

                          THEN REPLACE(ElementName,"ExpenseEntry","CalculatedExpense")

                     WHEN ElementName LIKE "%ResourceId"

                          /* Rename element ResourceId to ProjectResourceId. */

                          THEN REPLACE(ElementName,"ResourceId","ProjectResourceId")

                     WHEN ElementName LIKE "%Sorted%"

                          /* Remove "Sorted" from Object Names. */

                          THEN REPLACE(ElementName,"Sorted","")

                     WHEN TRIM(LEADING "/" FROM ElementName) = "ProjectSummaryLocationCountriesContainer"

                          /* Rename object ProjectSummaryLocationCountries to ProjectCountries. */

                          THEN REPLACE(ElementName,"SummaryLocation","")

                     WHEN TRIM(LEADING "/" FROM ElementName) = "ProjectSummaryScopeProtectedAreaCategoriesContainer"

                          /* Rename object ProjectSummaryScopeProtectedAreaCategories to ProtectedAreaCategories. */

                          THEN REPLACE(ElementName,"ProjectSummaryScope","")

                     WHEN TRIM(LEADING "/" FROM ElementName) LIKE "ProjectSummaryLocation%"
                       OR TRIM(LEADING "/" FROM ElementName) LIKE "ProjectSummaryPlanning%"
                       OR TRIM(LEADING "/" FROM ElementName) LIKE "ProjectSummaryScope%"

                          /* Remove "Summary" from Location, Planning, and Scope object names. */

                          THEN REPLACE(ElementName,"Summary","")

                     WHEN ElementName LIKE "%SelectedTagged%"

                          /* Rename objects conatining "SelectedTaggedObjectSet" to TaggedObjectSet. */

                          THEN REPLACE(ElementName,"Selected","")

                     WHEN TRIM(LEADING "/" FROM ElementName) LIKE "TncProjectData_%"

                          /* Remove the string "TncProjectData" from container names containing it.
                             While it follows the XML Naming Convention, it is superfluous here.
                          */

                          THEN REPLACE(ElementName,"TncProjectData","")

                     WHEN TRIM(LEADING "/" FROM ElementName) LIKE "Tnc%"

                          /* Standardize case. */

                          THEN REPLACE (ElementName,"Tnc","TNC")

                     WHEN TRIM(LEADING "/" FROM ElementName) LIKE "%WwfProjectData_%"

                          /* Remove the string "WWFProjectData" from container names containing it.
                             While it follows the XML Naming Convention, it is superfluous here.

                             Also standardize case.
                          */

                           THEN REPLACE(ElementName,"WwfProjectData","WWF")

                     WHEN TRIM(LEADING "/" FROM ElementName) LIKE "Wwf%"

                          /* Standardize case. */

                           THEN REPLACE (ElementName,"Wwf","WWF")

                     WHEN ElementName LIKE "ProjectResourceCustom.%"

                          /* Remove the string "Custom." from ProjectResource elements. */

                          THEN REPLACE(ElementName,"Custom.","")

                     ELSE ElementName
                 END,

             ElementValue =

                /* Embedded special characters are transformed to encoded strings when
                   exported to XML and must be transformed back for insertion into the
                   database.
                */

                REPLACE(
                   REPLACE(
                      REPLACE(
                         REPLACE(
                            REPLACE(
                               REPLACE(
                                  REPLACE(ElementValue,"&lt;","<"),"&gt;",">"
                                      ),"&amp;","&"
                                   ),"\\","\\\\"
                                ),"&#39;","\'"
                             ),"\"","\\\""
                          ),"&quot;","\\\""
                       ),

             ElementFlags = /* Flag 2 = Element is a Pool Header Tag. 
 
                               Flag 64 = Elements are compound elements.
                                         The element name is a Factor Name;
                                         the element value is the Factor's XID.
                                         
                               Flag 256 = Table stores rows from multiple factors and requires
                                          factor differentiation in Iterate_XML.
                
                               Flag 1024 = ProjectSummary header.
                
                               Flag 4096 = Threat Ratings, WorkUnits/Expense/Status Entries and
                                           ExtraDataSection have no attribute ID in Miradi. 
                                           One will be created in Iterate_XML.

                            */
             
                            CASE WHEN RIGHT(ElementName,4) = "Pool"
                                      THEN ElementFlags + 2
                                      
                                 WHEN ElementName IN ("WrappedByDiagramFactor",
                                                      "DiagramLinkFromDiagramFactor",
                                                      "DiagramLinktoDiagramFactor"
                                                     )
                                      THEN ElementFlags + 64
                                      
                                 WHEN ElementName IN ("DateUnitWorkUnits",
                                                      "DateUnitExpense",
                                                      "BiodiversityTarget",
                                                      "HumanWelfareTarget",
                                                      "IntermediateResult",
                                                      "ThreatReductionResult",
                                                      "CalculatedWho"
                                                     )
                                      THEN ElementFlags + 256
                                      
                                 WHEN ElementName IN ("ThreatRating",
                                                      "CalculatedWorkUnits",
                                                      "CalculatedExpense"
                                                     )
                                      THEN ElementFlags + 256 + 4096
                                       
                                 WHEN ElementName = "ProjectSummary"
                                      THEN ElementFlags + 1024
 
                                 WHEN ElementName IN ("StatusEntry",
                                                      "ExtraDataSection"
                                                     )
                                      THEN ElementFlags + 4096
                                      
                                 ELSE ElementFlags
                             END;

      /* Trace/Debug Statement */

      IF @Trace = TRUE THEN
         INSERT INTO Trace VALUES (0,"End Full-Pass Update",CURRENT_TIME());
      END IF;

      /* Set Element Flags to designate special processing while importing elements
         into the database.

         Flag 16 = Element Name is the Object Header Tag for a M:N intersection.
         Flag 128 = Element Name is the Object Header Tag for a list of recursive references.
      */

      UPDATE XMLData
         SET ElementFlags = ElementFlags + 16,
             ElementName = TRIM(TRAILING "Ids" FROM ElementName),
             ElementFlags = CASE WHEN ElementName
                                      IN ("GroupBoxChildren",
                                          "GroupedDiagramLink",
                                          "TaskSubTask"
                                         )
                                 THEN ElementFlags + 128
                                 ELSE ElementFlags
                             END
       WHERE RIGHT(ElementName,3) = "Ids"
          OR ElementName = "CalculatedWho";

      /* Trace/Debug Statement */

      IF @Trace = TRUE THEN
         INSERT INTO Trace VALUES (0,"End 16 Flags",CURRENT_TIME());
      END IF;

      /*
         Flag 32 = Element Name is the Object Tag for a 1:N reference.
      */

      UPDATE XMLData
         SET ElementFlags = ElementFlags + 32,
             ElementName = TRIM(TRAILING "Container" FROM ElementName)
       WHERE ElementName LIKE "%Container"
          OR ElementName LIKE "ResourceAssignment_%Id"
          OR ElementName LIKE "ExpenseAssignment_%Id"
          OR ElementName LIKE "CalculatedWorkUnits%"
          OR ElementName LIKE "CalculatedExpense%"
          OR ElementName IN ("StressBasedThreatRatingStressId","ThreatReductionResultThreatId",
                             "ThreatRatingThreatId","ThreatRatingTargetId",
                             "IndicatorThreshold","SimpleThreatRating",
                             "StressBasedThreatRating","StatusEntry","ExtraDataItem",
                             "DiagramLinkBendPoint","TaggedObjectSetFactor"
                            );

      /* Trace/Debug Statement */

      IF @Trace = TRUE THEN
         INSERT INTO Trace VALUES (0,"End 32 Flags",CURRENT_TIME());
      END IF;

      /* Flag 4 = Element is an Object Tag that corresponds to a database table. */

      UPDATE XMLData
         SET ElementFlags = ElementFlags + 4
       WHERE ElementName IN (SELECT TableName FROM MiradiTables)
         AND ElementFlags & 1 = 1;

      /* Trace/Debug Statement */

      IF @Trace = TRUE THEN
         INSERT INTO Trace VALUES (0,"End Update Flags",CURRENT_TIME());
      END IF;


END Parse $$

DELIMITER ;

-- END