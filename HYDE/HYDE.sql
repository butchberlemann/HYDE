--
-- HYDE  (Package) 
--
--  Dependencies: 
--   STANDARD (Package)
--   GISAPPSDBM ()
--   HYDE_HYDRANT (Table)
--   HYDE_PERMIT (Table)
--
CREATE OR REPLACE PACKAGE GISAPPSDBM.Hyde IS
   TYPE HYDE_CURSOR IS REF CURSOR;

   FUNCTION GET_PERMITS_CUST_NAME (IN_CUST_NAME IN GISAPPSDBM.Hyde_permit.PERMIT_CUST_NAME%TYPE)
      RETURN HYDE_CURSOR;

   FUNCTION GET_PERMITS_BY_PERM_NUM (IN_PERM_NUM IN GISAPPSDBM.HYDE_PERMIT.PERMIT_NUMBER%TYPE)
      RETURN HYDE_CURSOR;

   FUNCTION GET_PERMIT_DETAIL_BY_PERM_NUM (IN_PERM_NUMBER IN GISAPPSDBM.HYDE_PERMIT.PERMIT_NUMBER%TYPE)
      RETURN HYDE_CURSOR;

   FUNCTION GET_PERMIT_DETAIL_BY_CUST_NAME (IN_CUSTOMER_NAME IN GISAPPSDBM.Hyde_permit.PERMIT_CUST_NAME%TYPE)
      RETURN HYDE_CURSOR;

   PROCEDURE ADD_HYD_TO_PERMIT (
      PERM_NUM   IN GISAPPSDBM.Hyde_hydrant.PERMIT_NUMBER%TYPE,
      GM_LID        IN GISAPPSDBM.Hyde_hydrant.LID%TYPE
   );

   PROCEDURE UPDATES_FROM_CCB;

   PROCEDURE DEACTIVATE_HYDE_FROM_PERMIT (
      PPERM_NUM   IN GISAPPSDBM.Hyde_hydrant.PERMIT_NUMBER%TYPE,
      PLID        IN GISAPPSDBM.Hyde_hydrant.LID%TYPE
   );
END Hyde;
/


GRANT EXECUTE ON GISAPPSDBM.HYDE TO ARCIMS;
--
-- HYDE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY GISAPPSDBM.Hyde IS
   /*
       GET_PERMITS_CUST_NAME
       Returns a ref cursor that contains customer information like the cust_name provided
       Hermnan Berlemann
       4/29/2009
   */
   FUNCTION GET_PERMITS_CUST_NAME (IN_CUST_NAME IN GISAPPSDBM.HYDE_PERMIT.PERMIT_CUST_NAME%TYPE)
      RETURN HYDE_CURSOR IS
      PERMCURSOR   HYDE_CURSOR;
      CUSTNAME     GISAPPSDBM.HYDE_PERMIT.PERMIT_CUST_NAME%TYPE;
     
   BEGIN
      CUSTNAME := UPPER (TRIM(IN_CUST_NAME)) || '%';
        
      OPEN PERMCURSOR FOR
      
         SELECT  DISTINCT(PERMIT_CUST_NAME) PERMIT_CUST_NAME
             FROM   GISAPPSDBM.HYDE_PERMIT
            WHERE   UPPER (PERMIT_CUST_NAME) LIKE (CUSTNAME)
         AND PERMIT_STATUS != 'NOT'
         ORDER BY PERMIT_CUST_NAME;

      RETURN PERMCURSOR;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN PERMCURSOR;
      WHEN OTHERS THEN
        Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                DBMS_UTILITY.Format_error_stack
                               );
         RETURN PERMCURSOR;
   END GET_PERMITS_CUST_NAME;

   /*
       GET_PERMITS_BY_PERM_NUM
       Returns a ref cursor that contains customer information like the permit number provided
       Hermnan Berlemann
       4/29/2009
   */
   FUNCTION GET_PERMITS_BY_PERM_NUM (IN_PERM_NUM GISAPPSDBM.HYDE_PERMIT.PERMIT_NUMBER%TYPE)
      RETURN HYDE_CURSOR IS
      PERMCURSOR   HYDE_CURSOR;
      PERM         NUMBER;
      PERMNUM     GISAPPSDBM.HYDE_PERMIT.PERMIT_NUMBER%TYPE;
   BEGIN
   
   PERMNUM := UPPER (TRIM(IN_PERM_NUM)) || '%';   
   
   --DB_LOGGER.LOG_MESSAGE(USER,NULL,'SELECT * FROM (SELECT   PERMIT_NUMBER FROM   GISAPPSDBM.HYDE_PERMIT WHERE   PERMIT_NUMBER  LIKE ('|| PERMNUM ||')AND PERMIT_STATUS != NOT ORDER BY   PERMIT_NUMBER) WHERE ROWNUM < 10;');
   
      OPEN PERMCURSOR FOR
                 SELECT * FROM (SELECT   PERMIT_NUMBER
             FROM   GISAPPSDBM.HYDE_PERMIT
            WHERE   PERMIT_NUMBER  LIKE (PERMNUM)
            AND     PERMIT_STATUS != 'NOT'
         ORDER BY   PERMIT_NUMBER)
         WHERE ROWNUM < 10;
    
    
    --SELECT * FROM LOGGED_MESSAGES ORDER BY MSGDATE desc;
--    TRUNCATE table LOGGED_MESSAGES;
    
    RETURN PERMCURSOR;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN PERMCURSOR;
      WHEN OTHERS THEN
       Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                DBMS_UTILITY.Format_error_stack
                               );
      RETURN PERMCURSOR;
   END GET_PERMITS_BY_PERM_NUM;

   /*
       GET_PERMIT_DETAIL_BY_PERM_NUM
       Returns a ref cursor that contains permit details of the complete permit number provided
       Hermnan Berlemann
       4/29/2009
   */
   FUNCTION GET_PERMIT_DETAIL_BY_PERM_NUM (IN_PERM_NUMBER GISAPPSDBM.HYDE_PERMIT.PERMIT_NUMBER%TYPE)
      RETURN HYDE_CURSOR IS
      PERMCURSOR   HYDE_CURSOR;
   BEGIN
      OPEN PERMCURSOR FOR
           SELECT   B.PERMIT_NUMBER PERM_NUM,
                    B.PERMIT_CUST_NAME CUST_NAME
             FROM   
                       HYDE_PERMIT B
            WHERE   B.PERMIT_NUMBER = IN_PERM_NUMBER
            AND     B.PERMIT_STATUS != 'NOT'
         ORDER BY   B.PERMIT_CUST_NAME;

      RETURN PERMCURSOR;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN PERMCURSOR;
      WHEN OTHERS THEN
         Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                DBMS_UTILITY.Format_error_stack
                               );
   END GET_PERMIT_DETAIL_BY_PERM_NUM;

   /*
       GET_PERMIT_DETAIL_CUST_NAME
       Returns a ref cursor that contains permit details of the customer name provided
       Hermnan Berlemann
       4/29/2009
   */
   FUNCTION GET_PERMIT_DETAIL_BY_CUST_NAME (IN_CUSTOMER_NAME IN GISAPPSDBM.HYDE_PERMIT.PERMIT_CUST_NAME%TYPE)
      RETURN HYDE_CURSOR IS
      PERMCURSOR   HYDE_CURSOR;
   BEGIN
      OPEN PERMCURSOR FOR
           SELECT   NVL (A.LID, '') LID,
                    B.PERMIT_NUMBER PERM_NUM,
                    B.PERMIT_CUST_NAME CUST_NAME
             FROM      HYDE_PERMIT B
                    LEFT JOIN
                       (SELECT   PERMIT_NUMBER, LID
                          FROM   HYDE_HYDRANT
                         WHERE   ASSIGNED_STATUS = 1) A
                    ON (A.PERMIT_NUMBER = B.PERMIT_NUMBER)
            WHERE   UPPER (B.PERMIT_CUST_NAME) = UPPER (IN_CUSTOMER_NAME)
            AND     B.PERMIT_STATUS != 'NOT'
         ORDER BY   B.PERMIT_NUMBER;

      RETURN PERMCURSOR;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN PERMCURSOR;
      WHEN OTHERS THEN
         Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                DBMS_UTILITY.Format_error_stack
                               );
         RETURN PERMCURSOR;
   END GET_PERMIT_DETAIL_BY_CUST_NAME;
   /*
       Add_hyd_to_permit
       Adds hydrants to permits
       Hermnan Berlemann
       4/29/2009
   */
   PROCEDURE ADD_HYD_TO_PERMIT (
      PERM_NUM   IN GISAPPSDBM.HYDE_HYDRANT.PERMIT_NUMBER%TYPE,
      GM_LID        IN GISAPPSDBM.HYDE_HYDRANT.LID%TYPE
   ) IS
      VALIDPERMCHECK   NUMBER;
      VALIDLIDCHECK    NUMBER;
      INVALID_HYDRANT         EXCEPTION;
      INVALID_PERMIT         EXCEPTION;

   BEGIN
      SELECT   COUNT ( * ) INTO VALIDLIDCHECK FROM ARCFM.WHYDRANT WHERE ARCFM.WHYDRANT.LID = GM_LID;

      SELECT   COUNT ( * )
        INTO   VALIDPERMCHECK
        FROM   GISAPPSDBM.HYDE_PERMIT
       WHERE   PERMIT_NUMBER = PERM_NUM;

--TO_DO Add logic to check that three hydrants are not already assigned to a permit 

      IF (VALIDPERMCHECK > 0) THEN
         IF (VALIDLIDCHECK > 0) THEN
            INSERT INTO HYDE_HYDRANT (
                                      PERMIT_NUMBER, LID, ASSIGNED_STATUS
                                     )
              VALUES   (
                        PERM_NUM, GM_LID, 1
                       );
         ELSE
            RAISE INVALID_HYDRANT;
         END IF;
      ELSE 
        RAISE INVALID_PERMIT;
      END IF;
   EXCEPTION
      WHEN INVALID_PERMIT THEN
        Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                'INVALID_PERMIT '||DBMS_UTILITY.Format_error_stack
                               );
         RAISE INVALID_PERMIT;       
      WHEN INVALID_HYDRANT THEN
        Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                'INVALID_HYDRANT '||DBMS_UTILITY.Format_error_stack
                               );
         RAISE INVALID_HYDRANT;       
      WHEN OTHERS THEN
        Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                DBMS_UTILITY.Format_error_stack
                               );
         RAISE; 
   END ADD_HYD_TO_PERMIT;

   /*
       Deactivates hydrants from permits
       Hermnan Berlemann
       4/29/2009
   */   
   PROCEDURE DEACTIVATE_HYDE_FROM_PERMIT (
      PPERM_NUM   IN GISAPPSDBM.HYDE_HYDRANT.PERMIT_NUMBER%TYPE,
      PLID        IN GISAPPSDBM.HYDE_HYDRANT.LID%TYPE
   ) IS
   BEGIN
      UPDATE   HYDE_HYDRANT A
         SET   ASSIGNED_STATUS = 0
       WHERE   A.PERMIT_NUMBER = PPERM_NUM
               AND A.LID = PLID;
   EXCEPTION
      WHEN OTHERS THEN
                 Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                DBMS_UTILITY.Format_error_stack
                               );
   END DEACTIVATE_HYDE_FROM_PERMIT;
   /*
       Process updates from CCB
       Hermnan Berlemann
       4/29/2009
   */   
   PROCEDURE UPDATES_FROM_CCB IS
   BEGIN
      MERGE INTO   HYDE_PERMIT HYDE_PERM
           USING   (SELECT * FROM INTDBM.CM_HYDRANT_PERMITS_VW@L_GISAPPSDBM.CIS_PV_FIMS_USER) CCB_PERM
              ON   (HYDE_PERM.PERMIT_NUMBER = CCB_PERM.PERM_NUM)
      WHEN MATCHED THEN
         UPDATE SET HYDE_PERM.LAST_ACTIVE_DATE = TRUNC (SYSDATE)
      WHEN NOT MATCHED THEN
         INSERT              (
                              PERMIT_NUMBER,
                              PERMIT_STATUS,
                              PERMIT_DATE,
                              PERMIT_CUST_NAME,
                              LAST_ACTIVE_DATE
                             )
             VALUES   (
                       TRIM (CCB_PERM.PERM_NUM),
                       TRIM (CCB_PERM.STATUS),
                       TRUNC (CCB_PERM.START_DATE),
                       TRIM (CCB_PERM.NAME),
                       TRUNC(SYSDATE)
                      );

      --The Merge Statment updates all data tha is found in the interface. 
      --Therefor if the data is not updated it is not in the interface and 
      --no longer valid.

      UPDATE   HYDE_PERMIT
         SET   PERMIT_STATUS = 'NOT'
       WHERE   trunc(HYDE_PERMIT.LAST_ACTIVE_DATE) != trunc(sysdate);
       
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      --No Updates in the data to Sync
      WHEN OTHERS THEN
          Db_logger.LOG_MESSAGE (
                                USER,
                                DBMS_UTILITY.Format_error_backtrace,
                                DBMS_UTILITY.Format_error_stack
                               );
   END UPDATES_FROM_CCB;
END Hyde;
/


GRANT EXECUTE ON GISAPPSDBM.HYDE TO ARCIMS;
