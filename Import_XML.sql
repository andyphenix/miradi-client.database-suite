/*
   Import XML_v18.sql

   Import a Miradi project from an XMPZ XML data stream into the Miradi Database.

   Compatible with XMPZ XML data model http://xml.miradi.org/schema/ConservationProject/73.

   Developed by David Berg for The Nature Conservancy.

   Revision History:
   Version 18 - 2011-09-06 - Insert a Begin XML Load record into Trace.
   Version 17 - 2011-08-24 - Add new Element Flags 2048, 4096, and 8192.
                           - Don't retrieve first row from XMLData to seed the call to
                             sp_Iterate_XML. Since that procedure has long ceased being
                             truly recursively called, it can fetch its own first row.
   Version 16 - 2011-05-18 - Added AutoIncrement ID field to Trace Table.
   Version 15 - 2011-05-02 - Amend the line delimiter when reading in the raw XML file to include
                             the '<' from the tag following each element of text (i.e. '>\r\n<').
                             because the first character of a user-entered text string may be a newline.
                             Restore the >< XML delimiters when writing to ProjectXML.
   Version 14 - 2011-04-20 - Add Pool Flags and Pool Name to Stack Table.
   Version 13 - 2011-04-11 - Make the Debug/Trace an optional feature on call.
   Version 12 - 2011-03-18 - Change data types for XML_Line and ElementValue to MEDIUMTEXT
                             to accommodate ExtraDataItemValue.
   Version 11 - 2011-03-08 - Added LastStackID to Stack Table.
   Version 10 - 2011-02-28 - Added "FIELDS TERMINATED BY x'00' to LOAD statement because the
                             default field terminator is a TAB (\t) ... and comment/detail
                             fields are subject to containing TABs.
   Version 09 - 2011-02-21 - ChildIDs table doesn't need ChildID. Simplify by removing ChildID
                             and renaming the table ChildRefs.
                           - Add call to sp_StrategyThreat();
   Version 08 - 2011-02-09 - Revise to use a stack table instead of recursive calls to
                             sp_iterate_xml() to perform recursion due to performance
                             issues with recursive calls. Some vestiges of recursive calls,
                             e.g. global variables, remain throughout.
   Version 07 - 2011-01-31 - Flag diagram bend points.
                           - Other revisions following successful run of Version 6.
   Version 06 - 2011-01-18 - Add Element Falg 64. Set @Pool = FALSE.
   Version 05 - 2011-01-17 - Restructure Element Flags
                           - Eliminate table XMLObjects; use Element Flag instead.
   Version 04 - 2011-01-14 - Remove columns table.
   Version 03 - 2011-01-12 - Improve generalizations as they apply to like situations.
   Version 02 - 2010-12-31 - Added ElementFlags to XMLData.
   Version 01 - 2010-12-27 - Initial Version plus several enhnacements.
*/

/* Note that using InnoDB when populating XMLData and XMLObjects and Stack resulted in unexplained
   (by me) severe performance issues. Thus, the tables are created as MyISAM tables.
*/

USE Miradi;

START TRANSACTION;

/* Create a temporary table for tracing and debugging purposes. 
   Depending on the product and version of the client query tool, you may need to make
   this a permanent table and then drop it when you're done.
*/

DROP TABLE IF EXISTS Trace;
CREATE TEMPORARY TABLE Trace
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 Trace MEDIUMTEXT,
 Tmstmp TIME
)
ENGINE=MyISAM DEFAULT CHARSET=utf8;


/* Note that if you set @Trace = TRUE, you also need to comment out the COMMIT statement 
   at the end of this procedure to avoid dropping the temporary table Trace before you 
   can view it.
*/

SET @Trace = TRUE;                      -- When TRUE, called scrips populate the Trace/Debug table.

DROP TABLE IF EXISTS ProjectXML;
CREATE TEMPORARY TABLE ProjectXML                  -- Contains raw XML file contents.
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 XML_Line MEDIUMTEXT
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

# TRUNCATE TABLE ProjectXML;
# TRUNCATE TABLE Trace;

/* Load raw XML data into ProjectXML */

INSERT INTO Trace VALUES (0,"Begin XML Load",CURRENT_TIME());

LOAD DATA LOCAL INFILE 'c:\\_data\\Miradi\\Eastern Bay\\project.xml'  # Microsoft format.
# LOAD DATA LOCAL INFILE '/home/dberg/Miradi/Data/project.xml'          # UNIX format.
     INTO TABLE ProjectXML FIELDS TERMINATED BY x'00'    /* Required because there are embedded
                                                            newlines in the data that would be
                                                            otherwise interpreted as field terminators.
                                                         */

                           ESCAPED BY x'00'              /* Required because there are embedded
                                                            escape characters ('\') in the data
                                                            that would be otherwise interpreted as
                                                            escape characters themselves.
                                                         */

                           /* Uncomment the appropriate line below depending on whether the XML file
                              you wish to import was created under a Microsoft operating system or a
                              UNIX operating system. Microsoft uses x'0d0a' (\r\n) to delimit newlines;
                              UNIX uses just x'0a' (\n).
                           */

                           LINES TERMINATED BY '>\r\n<'   # For XML files exported with Microsoft OS.
#                           LINES TERMINATED BY '>\n<'     # For XML Files exported with UNIX OS.

                                                         /* Because there are embedded newlines in the
                                                            data that would be otherwise interpreted as line
                                                            delimiters - AND - because it is also possible,
                                                            albeit infrequent, that the first character of a
                                                            user-entered text string is a newline. the trailing
                                                            XML Tag Delimiter (>) from the previous element and
                                                            the leading XML Tag Delimiter (<) from the next
                                                            element that surround each newline are included in
                                                            the line delimiter character string. The tag
                                                            delimiters are restored below in the SET command.
                                                         */
                           IGNORE 1 LINES
                (XML_Line)
            SET XML_Line = CONCAT("<",XML_Line,">");     /* Restore the "<>" XML delimiters removed as components
                                                            of line delimiters in LINES TERMINATED BY.
                                                         */

ANALYZE TABLE ProjectXML;

DROP TABLE IF EXISTS XMLData;
CREATE TEMPORARY TABLE XMLData             -- Contains parsed XML Data in distinct records.
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ElementName VARCHAR(255),
 ElementValue MEDIUMTEXT,
 ElementFlags INTEGER DEFAULT 0            /* A seried of bitwise flags to direct special processing
                                              in called procedures ...

                                                  1 = Element is an Object header tag.
                                                  2 = Element is the Object header of a Pool of
                                                      multiple like Objects.
                                                  4 = Element is an Object for which exists a Table.
                                                  8 = Element is the second or later element in a
                                                      List Container, e.g. IDs or Codes.
                                                 16 = Element is the Object header of a list of
                                                      Many-to-One-or-Many elements.
                                                 32 = Element is the Object header of a list of
                                                      One-to-Many elements.
                                                 64 = Elements are compound elements.
                                                      The element name is a Factor Name;
                                                      the element value is the Factor's XID.
                                                128 = Element is the Object header of a list of
                                                      recursive references.
                                                256 = Element is the Object header of a set of
                                                      Diagram Bend Points or Indicator Thresholds.
                                                512 = Element is the Object header for 
                                                      ConservationProject.
                                               1024 = Element is the Object header for 
                                                      ProjectSummary.
                                               2048 = ElementValue contains the current Object's 
                                                      XID Value.
                                               4096 = Factor requires that an XID be created for it.
                                               8192 = ElementValue contains the current Factor's 
                                                      Attribute Value.
                                            */
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

# TRUNCATE TABLE XMLData;

INSERT INTO Trace VALUES (0,"Begin Parse",CURRENT_TIME());

CALL sp_parse_xml();                     -- Parses raw XML contenst using "><" delimiters.

/* Recursion in sp_iterate_xml() is accomplished by pushing and popping variable values
   onto and from a stack table.
*/

DROP TABLE IF EXISTS Stack;
CREATE TEMPORARY TABLE Stack
(ParentName VARCHAR(255),
 ObjectName VARCHAR(255),
 ObjectFlags INTEGER,
 ElementID INTEGER PRIMARY KEY,
 ElementName VARCHAR(255),
 ElementValue TEXT,
 ElementFlags INTEGER,
 TableName VARCHAR(255),
 ParentTable VARCHAR(255),
 ParentFlags INTEGER,
 ParentXID INTEGER,
 PoolFlag BOOLEAN DEFAULT FALSE,
 PoolName VARCHAR(255),
 ColNames TEXT,
 ColValues TEXT,
 LastStackID INTEGER
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/* Hierarchical forward references to Child tables are embedded within the Parent Object in
   the XML; they are thus processed and populated before the Parent Obejct's ID is known.
   The temporary table ChildIDs stores IDs of objects subordinate to whichever parent is being
   processed so their parent references can be updated after the Parent row is inserted.
*/

DROP TABLE IF EXISTS ChildRefs;
CREATE TEMPORARY TABLE ChildRefs
(ID INTEGER AUTO_INCREMENT PRIMARY KEY,
 ProjectSummaryID INTEGER,
 ParentName VARCHAR(255),
 ParentFlags INTEGER,
 TableName VARCHAR(255),
 ChildID INTEGER,
 INDEX (ParentFlags)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

# TRUNCATE TABLE Stack;
# TRUNCATE TABLE ChildRefs;

/* Iterate through the XML data stream to populate the database, seeded with Record 1. */

SET @Pool = FALSE;          -- Indicator that Objects are members of a Pool of Objects.
SET @recur = 0;             -- Recursion Level.
SET @ProjectSummaryID = -1; -- Initialize ProjectSummaryID (to other than zero).

INSERT INTO Trace VALUES (0,"Begin Iterate",CURRENT_TIME());

CALL sp_Iterate_XML();

/* Associate Strategies/Objectives/Threats with the Threats/Targets they address */

INSERT INTO Trace VALUES (0,"Begin StrategyThreat",CURRENT_TIME());

CALL sp_StrategyThreat(@ProjectSummaryID);

/*
DROP TABLE ProjectXML;
DROP TABLE XMLData;
DROP TABLE Stack;
DROP TABLE ChildRefs;
DROP TABLE Trace;
COMMIT;

-- END