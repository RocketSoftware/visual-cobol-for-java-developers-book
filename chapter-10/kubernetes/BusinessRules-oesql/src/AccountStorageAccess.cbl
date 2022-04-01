      *****************************************************************
      *                                                               *
      * Copyright (C) 2020-2022 Micro Focus.  All Rights Reserved.    *
      * This software may be used, modified, and distributed          *
      * (provided this notice is included without modification)       *
      * solely for demonstration purposes with other                  *
      * Micro Focus software, and is otherwise subject to the EULA at *
      * https://www.microfocus.com/en-us/legal/software-licensing.    *
      *                                                               *
      * THIS SOFTWARE IS PROVIDED "AS IS" AND ALL IMPLIED           *
      * WARRANTIES, INCLUDING THE IMPLIED WARRANTIES OF               *
      * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,         *
      * SHALL NOT APPLY.                                              *
      * TO THE EXTENT PERMITTED BY LAW, IN NO EVENT WILL              *
      * MICRO FOCUS HAVE ANY LIABILITY WHATSOEVER IN CONNECTION       *
      * WITH THIS SOFTWARE.                                           *
      *                                                               *
      *****************************************************************
      
       program-id. AccountStorageAccess.
      
       data division.
       working-storage section.
       01 WS-FUNCTION-CODE                 pic x. 
       78 POSTGRES-HOST value "POSTGRES_HOST".
       78 POSTGRES-DB value "POSTGRES_DB".
       78 POSTGRES-USER value "POSTGRES_USER".
       78 POSTGRES-PASSWORD value "POSTGRES_PASSWORD".
       01 pg-host pic x(20). 
       01 pg-db pic x(20).
       01 pg-user pic x(20).
       01 pg-password pic x(20).
       01 connection-string pic x(300) value spaces.
       01 FILLER pic x.
         88 NO-HOST value 'Y', false 'N'.
         88 NO-DB value 'Y', false 'N'.
         88 NO-USER value 'Y', false 'N'.
         88 NO-PASSWORD value 'Y', false 'N'.
       
       EXEC SQL INCLUDE SQLCA END-EXEC. 
           
       EXEC SQL BEGIN DECLARE SECTION END-EXEC. 
       01 WS-TEMP-ID                       pic x(4) comp-x.     
       01 WS-TEMP-ID-2                     pic x(4) comp-x.
       01 WS-TOTAL-TRANSACTIONS            pic x(4) comp-x. 
       01 WS-NUMBER-TRANSACTIONS           pic x(4) comp-x.

       EXEC SQL END DECLARE SECTION END-EXEC.
       01 date-characters                  pic x(8). 
       01 condition-class                  pic xx. 
       01 connection-opened                pic 99 comp-5 value 0. 

       copy "PROCEDURE-NAMES.cpy".

       linkage section. 
       01 LNK-CONNECTION-STRING            pic x(300). 
       01 LNK-STATUS.
        03 LNK-FILE-STATUS-1               PIC X.
        03 LNK-FILE-STATUS-2               PIC X.
       copy "FUNCTION-CODES.cpy".  
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==. 
       
       procedure division.
           goback.
       
       ENTRY SET-DB-CONNECTION-STRING using by reference LNK-CONNECTION-STRING. 
           move LNK-CONNECTION-STRING to connection-string
           goback.
       
       ENTRY OPEN-CUSTOMER-FILE using by VALUE LNK-FUNCTION
                                  by reference LNK-STATUS
           perform connect-to-database    
           goback.
           
       ENTRY WRITE-CUSTOMER-RECORD using by value LNK-FUNCTION
                                     by reference LNK-CUSTOMER-RECORD 
                                                  LNK-STATUS.
           move LNK-CUSTOMER-ID OF LNK-CUSTOMER-RECORD to WS-TEMP-ID
           evaluate LNK-FUNCTION
           when WRITE-RECORD
               exec sql 
                   insert into customer 
                       (id, firstName, lastName)
                       values
                       (:WS-TEMP-ID,
                        :LNK-FIRST-NAME,
                        :LNK-LAST-NAME);
                   commit
               end-exec
           when UPDATE-RECORD
               exec sql 
                   update customer
                   set firstName = :LNK-FIRST-NAME,
                       lastName = :LNK-LAST-NAME
                   where 
                       (id = :WS-TEMP-ID);
                   commit
               end-exec
           end-evaluate
           perform convert-sqlcode
           goback.
       
       ENTRY DELETE-CUSTOMER-RECORD using by reference LNK-CUSTOMER-RECORD
                                                       LNK-STATUS. 
           move LNK-CUSTOMER-ID of LNK-CUSTOMER-RECORD to WS-TEMP-ID
           exec sql
               delete from customer where 
                   id=:WS-TEMP-ID
           end-exec
           perform convert-sqlcode
           goback.

      * find account by customer last name
       ENTRY FIND-CUSTOMER-NAME using BY value LNK-FUNCTION 
                                  by reference LNK-CUSTOMER-RECORD 
                                               LNK-STATUS.
           evaluate LNK-FUNCTION
               when START-READ
                   exec sql 
                       declare wcurs cursor for 
                           select * from customer
                               where lastname = :LNK-LAST-NAME 
                   end-exec
                   exec sql
                       open wcurs
                   end-exec
               when READ-NEXT
                   exec sql
                       fetch wcurs into :LNK-CUSTOMER-RECORD
                   end-exec
           end-evaluate
           perform convert-sqlcode
           if sqlcode > 0
               exec sql
                   close wcurs
               end-exec
           end-if
           goback. 

      * find account by customer ID
       ENTRY FIND-CUSTOMER-ID using BY value LNK-FUNCTION 
                                by reference LNK-CUSTOMER-RECORD 
                                             LNK-STATUS.
           move LNK-CUSTOMER-ID of LNK-CUSTOMER-RECORD to WS-TEMP-ID 
           exec sql
               select * into :LNK-CUSTOMER-RECORD from customer 
                   where id = :WS-TEMP-ID
           end-exec
           perform convert-sqlcode
           goback.
           
       ENTRY READ-CUSTOMER-RECORD using by value LNK-FUNCTION
                                       reference LNK-CUSTOMER-RECORD 
                                                 LNK-STATUS
           move LNK-CUSTOMER-ID of LNK-CUSTOMER-RECORD to WS-TEMP-ID
           evaluate LNK-FUNCTION
               when START-READ
                   exec sql 
                       declare zcurs cursor for 
                           select * from customer
                              where id >= :WS-TEMP-ID 
                   end-exec
                   exec sql
                       open zcurs
                   end-exec
               when READ-NEXT
                   exec sql
                       fetch zcurs into :LNK-CUSTOMER-RECORD
                   end-exec
           end-evaluate
           perform convert-sqlcode
           goback
           .      
       
       ENTRY READ-LAST-CUSTOMER-RECORD using 
                                by reference LNK-CUSTOMER-RECORD 
                                             LNK-STATUS
           exec sql
               select * into :LNK-CUSTOMER-RECORD from customer 
                                       order by id desc limit 1
           end-exec
           perform convert-sqlcode
           goback.

       ENTRY OPEN-ACCOUNT-FILE using by VALUE LNK-FUNCTION
                                 by reference LNK-STATUS
           perform connect-to-database    
           goback.
           
       ENTRY WRITE-ACCOUNT-RECORD using by value LNK-FUNCTION 
                                    by reference LNK-ACCOUNT 
                                                 LNK-STATUS.
           move LNK-CUSTOMER-ID of LNK-ACCOUNT to WS-TEMP-ID
           move LNK-ACCOUNT-ID of LNK-ACCOUNT to WS-TEMP-ID-2
           evaluate LNK-FUNCTION
           when WRITE-RECORD
               exec sql
                   insert into account 
                       (id, customerid, balance, type, creditlimit)
                       values
                       (:WS-TEMP-ID-2,
                        :WS-TEMP-ID,
                        :LNK-BALANCE,
                        :LNK-TYPE, 
                        :LNK-CREDIT-LIMIT)
               end-exec
           when UPDATE-RECORD
               exec sql
                   update account 
                       set customerid=:WS-TEMP-ID, 
                           balance=:LNK-BALANCE,
                           type=:LNK-TYPE, 
                           creditlimit=:LNK-CREDIT-LIMIT
                       where id=:WS-TEMP-ID-2
               end-exec
           end-evaluate
           perform convert-sqlcode
           goback.

       ENTRY READ-ACCOUNT-RECORD using by value LNK-FUNCTION
                               by reference LNK-ACCOUNT LNK-STATUS
           move LNK-ACCOUNT-ID of LNK-ACCOUNT to WS-TEMP-ID
           move "00" to LNK-STATUS
           evaluate LNK-FUNCTION
               when START-READ
                   exec sql 
                       declare acurs cursor for 
                           select * from account
                              where id >= :WS-TEMP-ID
                   end-exec
                   exec sql
                       open acurs
                   end-exec
               when READ-NEXT
                   exec sql
                       fetch acurs into :LNK-ACCOUNT
                   end-exec
           end-evaluate
           perform convert-sqlcode
           if sqlcode <> 0
               exec sql
                   close acurs
               end-exec
           end-if

           goback.
       
      * find account by account ID
       ENTRY FIND-ACCOUNT-ID using BY value LNK-FUNCTION 
                                by reference LNK-ACCOUNT 
                                             LNK-STATUS.
           move LNK-ACCOUNT-ID of LNK-ACCOUNT to WS-TEMP-ID
           exec sql
             select * into :LNK-ACCOUNT from account where
                   id = :WS-TEMP-ID
           end-exec
           perform convert-sqlcode
           goback.
           
       ENTRY DELETE-ACCOUNT-RECORD using by reference LNK-ACCOUNT
                                                       LNK-STATUS. 
           move LNK-ACCOUNT-ID of LNK-ACCOUNT to WS-TEMP-ID
           exec sql
             delete from account where
                   id = :WS-TEMP-ID
           end-exec
           perform convert-sqlcode
           goback. 


       ENTRY READ-LAST-ACCOUNT-RECORD using by reference LNK-ACCOUNT 
                                                         LNK-STATUS.
           exec sql
               select * into :LNK-ACCOUNT from account order by id desc limit 1
           end-exec
           perform convert-sqlcode
           goback.

       ENTRY OPEN-TRANSACTION-FILE using by VALUE LNK-FUNCTION
                                     by reference LNK-STATUS
           perform connect-to-database    
           goback.

       ENTRY WRITE-TRANSACTION-RECORD using by value LNK-FUNCTION 
                                   by reference LNK-TRANSACTION-RECORD
                                                LNK-STATUS.
           move LNK-ACCOUNT-ID of LNK-TRANSACTION-RECORD to WS-TEMP-ID
           move LNK-TRANS-DATE to date-characters *> can't use group item 
                                                  *> inside sql statement 
                                                  *> for single field
           evaluate LNK-FUNCTION
               when WRITE-RECORD
                   exec sql
                       insert into transaction
                           (id, accountid, transdate, amount, description)
                           values
                           (:LNK-TRANSACTION-ID,
                            :WS-TEMP-ID,
                            :date-characters,
                            :LNK-AMOUNT, 
                            :LNK-DESCRIPTION);
                       commit;
                   end-exec
               when UPDATE-RECORD
                   exec sql
                       update transaction
                          set 
                           accountid=:WS-TEMP-ID,
                           transdate=:date-characters,
                           amount=:LNK-AMOUNT,
                           description=:LNK-DESCRIPTION
                        where id=:LNK-TRANSACTION-ID;
                       commit;
                   end-exec
           end-evaluate
           perform convert-sqlcode
           goback.
           
       ENTRY READ-TRANSACTION-RECORD using by value LNK-FUNCTION
                               by reference LNK-TRANSACTION-RECORD 
                                            LNK-STATUS

           evaluate LNK-FUNCTION
               when START-READ
                   exec sql 
                       declare tcurs cursor for 
                           select * from transaction
                              where id >= :LNK-TRANSACTION-ID;
                   end-exec
                   exec sql 
                       open tcurs
                   end-exec
               when READ-NEXT
                   exec sql 
                       fetch tcurs into 
                        :LNK-TRANSACTION-ID,
                        :WS-TEMP-ID,
                        :date-characters,
                        :LNK-AMOUNT, 
                        :LNK-DESCRIPTION            
                   end-exec
                   move date-characters to LNK-TRANS-DATE
                   move WS-TEMP-ID to  LNK-ACCOUNT-ID of LNK-TRANSACTION-RECORD
           end-evaluate
           perform convert-sqlcode
           goback
           . 
       
       ENTRY FIND-TRANSACTION-BY-ID using by value LNK-FUNCTION 
                                      by reference LNK-TRANSACTION-RECORD
                                                   LNK-STATUS.
           exec sql
               select * 
               into        
               :LNK-TRANSACTION-ID,
                    :WS-TEMP-ID,
                    :date-characters,
                    :LNK-AMOUNT, 
                    :LNK-DESCRIPTION
               from transaction
               where id = :LNK-TRANSACTION-ID
           end-exec
           move date-characters to LNK-TRANS-DATE
           move WS-TEMP-ID to LNK-ACCOUNT-ID of LNK-TRANSACTION-RECORD
           perform convert-sqlcode
           goback.

       ENTRY FIND-TRANSACTION-BY-ACCOUNT using by value LNK-FUNCTION
                                           by reference LNK-TRANSACTION-RECORD 
                                                        LNK-STATUS
           move LNK-ACCOUNT-ID of LNK-TRANSACTION-RECORD to WS-TEMP-ID
           evaluate LNK-FUNCTION
               when START-READ
                   exec sql
                      select count(*)  
                               into :WS-TOTAL-TRANSACTIONS
                               from transaction
                               where accountId = :WS-TEMP-ID
                   end-exec
                   move 0 to WS-NUMBER-TRANSACTIONS
                   exec sql 
                       declare tcurs2 cursor for 
                           select * from transaction
                               where accountid = :WS-TEMP-ID;
                   end-exec
                   exec sql 
                       open tcurs2
                   end-exec
               when READ-NEXT
                   add 1 to WS-NUMBER-TRANSACTIONS                                                         
                   exec sql
                       fetch tcurs2 into :LNK-TRANSACTION-ID, :WS-TEMP-ID, 
                                        :date-characters, :LNK-AMOUNT, 
                                        :LNK-DESCRIPTION
                       
                   end-exec
                   move date-characters to LNK-TRANS-DATE
                   move WS-TEMP-ID to LNK-ACCOUNT-ID of LNK-TRANSACTION-RECORD
           end-evaluate
           perform convert-sqlcode
           if sqlcode > 0
               exec sql
                   close tcurs2
               end-exec
           end-if
      *>   This code duplicates the behaviour of reading records
      *>   based on ISAM alternate key - file-status is "02" until 
      *>   there are no more records to read.
           if WS-NUMBER-TRANSACTIONS < WS-TOTAL-TRANSACTIONS 
              and WS-NUMBER-TRANSACTIONS <> 0 *> Don't change file status
                                              *> for START-READ.
              and LNK-STATUS <> "88"                                           
               move "02" to LNK-STATUS  *> more records to be read
           end-if
           goback. 
       		   	       
       ENTRY DELETE-TRANSACTION-RECORD using by reference 
                                    LNK-TRANSACTION-RECORD
                                    LNK-STATUS. 
           exec sql 
               delete from transaction where 
                   id=:LNK-TRANSACTION-ID
           end-exec
           perform convert-sqlcode
           goback. 
       
       ENTRY READ-LAST-TRANSACTION-RECORD using by reference
                                 LNK-TRANSACTION-RECORD
                                 LNK-STATUS.
           move LNK-TRANS-DATE to date-characters
           exec sql
               select id, accountid, transdate, amount, description 
                    into :LNK-TRANSACTION-ID, :WS-TEMP-ID, 
                         :date-characters, :LNK-AMOUNT, :LNK-DESCRIPTION
                    from transaction order by id desc limit 1
           end-exec
           move date-characters to LNK-TRANS-DATE
           move WS-TEMP-ID to LNK-ACCOUNT-ID of LNK-TRANSACTION-RECORD
           perform convert-sqlcode
           goback.
       
       convert-sqlcode section.
           move sqlstate(1:2) to condition-class
           
           evaluate condition-class
               when "00"
                   move "00" to LNK-STATUS 
               when "02" 
                   move "23" to LNK-STATUS
               when other
                   display "SQL state " sqlstate
                   display "sql msg " SQLERRM
                   move "88" to LNK-STATUS
           end-evaluate
           .
           
       connect-to-database section.
           evaluate LNK-FUNCTION
           when CLOSE-FILE
               if connection-opened = 1 
                   exec sql 
                       commit work release
                   end-exec
                   move 0 to connection-opened
               else 
                   move "00000" to sqlstate
               end-if
           when other
               if connection-opened = 0 
                   perform set-connection-string
                   exec sql
                       connect using :connection-string
                   end-exec
                   move 1 to connection-opened
               else 
                   move "00000" to sqlstate
               end-if
           end-evaluate
           perform convert-sqlcode
           .
           
       set-connection-string section.
           display POSTGRES-HOST upon environment-name 
           accept PG-HOST from environment-value
           display POSTGRES-DB upon environment-name 
           accept pg-db from environment-value
           display POSTGRES-USER upon environment-name 
           accept pg-user from environment-value
           display POSTGRES-PASSWORD upon environment-name 
           accept pg-password from environment-value
           
           display POSTGRES-HOST space with no advancing
           if pg-host = spaces
               set NO-HOST to true
               display "NOT SET" space with no advancing
           else
               display pg-host space with no advancing
           end-if
           display POSTGRES-DB space with no advancing
           if pg-db = spaces
               set NO-DB to true
               display "NOT SET" space with no advancing
           else
               display pg-db space with no advancing
           end-if
           display POSTGRES-USER space with no advancing
           if pg-user = spaces
               set NO-USER to true
               display "NOT SET" space with no advancing
           else
               display pg-user space with no advancing
           end-if
           display POSTGRES-PASSWORD space with no advancing
           if pg-password = spaces
               set NO-PASSWORD to true
               display "NOT SET"
           else
               display "****"
           end-if
           if NO-HOST or NO-DB or NO-USER or NO-PASSWORD
               goback
           end-if

           string "Driver=org.postgresql.Driver;URL=jdbc:postgresql://"
             pg-host delimited by space
             "/"
             pg-db delimited by space
             "?user="
             pg-user delimited by space
             "&password="
             pg-password delimited by space
             into connection-string
           .

             
