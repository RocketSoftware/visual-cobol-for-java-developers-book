      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
      $set sql(dbman=jdbc) 
       program-id. DatabaseInitializer.

       data division.
       working-storage section.
       COPY "DataMigrationEntryPoints.cpy". 
       78 DB-CONNECTION-STRING             value "DB_CONNECTION_STRING".
       01 WS-FUNCTION-CODE                 pic x. 
           

       EXEC SQL INCLUDE SQLCA END-EXEC. 
           
       EXEC SQL BEGIN DECLARE SECTION END-EXEC. 
       01 connection-string                pic x(300) value spaces.
       01 WS-TEMP-ID                       pic x(4) comp-x.     
       01 WS-TEMP-ID-2                     pic x(4) comp-x.
       01 WS-TOTAL-TRANSACTIONS            pic x(4) comp-x. 
       01 WS-NUMBER-TRANSACTIONS           pic x(4) comp-x.
       01 csvPath                          string.
       01 tableName                        string. 
       01 sqlCommand                       pic x(1000). 
       EXEC SQL END DECLARE SECTION END-EXEC.
       01 date-characters                  pic x(8). 
       01 condition-class                  pic xx. 
       01 connection-opened                pic 99 comp-5 value 0.       
       01 success-flag                     pic 9. 
       
       linkage section. 
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==. 
       01 lnkSuccess                       pic 9. 
       01 lnk-connection-string            pic x(300). 
           
       procedure division using by reference lnk-connection-string.
           move lnk-connection-string to connection-string
           goback. 
       
      *> Postgres SQL
       entry CREATE-TABLES.
           perform open-database-connection
           exec sql 
                  DROP TABLE if exists public.customer CASCADE;
                  DROP SEQUENCE if exists customer_id_seq;
                  CREATE SEQUENCE customer_id_seq;
                  CREATE TABLE public.customer
               (
                   id integer not null DEFAULT nextval('customer_id_seq'),
                   firstname character varying(60) COLLATE pg_catalog."default",
                   lastname character varying(60) COLLATE pg_catalog."default",
                   CONSTRAINT customer_pkey PRIMARY KEY (id)
               )
               
               TABLESPACE pg_default;
               
               ALTER TABLE public.customer
                   OWNER to postgres;
           end-exec
           perform convert-sqlcode
           perform close-database-connection
           perform open-database-connection 
           
           exec sql
                  DROP TABLE if exists public.account CASCADE;
                  DROP SEQUENCE if exists account_id_seq;
                  CREATE SEQUENCE account_id_seq;
               CREATE TABLE public.account
               (
                   id integer NOT NULL DEFAULT nextval('account_id_seq'),
                   customerid integer,
                   balance character(20) COLLATE pg_catalog."default",
                   type character(1) COLLATE pg_catalog."default",
                   creditlimit character(20) COLLATE pg_catalog."default",
                   CONSTRAINT account_pkey PRIMARY KEY (id),
                   CONSTRAINT account_customerid_fkey FOREIGN KEY (customerid)
                       REFERENCES public.customer (id) MATCH SIMPLE
                       ON UPDATE NO ACTION
                       ON DELETE NO ACTION
               )
               TABLESPACE pg_default;
                ALTER TABLE public.account
                   OWNER to postgres;
               commit;
           end-exec
           perform convert-sqlcode
           perform close-database-connection
           perform open-database-connection 
           
           exec sql
               DROP TABLE if exists public.transaction CASCADE ;
               DROP SEQUENCE if exists transaction_id_seq;
               CREATE SEQUENCE transaction_id_seq;
               CREATE TABLE public.transaction
               (
                   id integer NOT NULL DEFAULT nextval('transaction_id_seq'),
                   accountid integer,
                   transdate character(8) COLLATE pg_catalog."default",
                   amount character(20) COLLATE pg_catalog."default",
                   description character varying(255) COLLATE pg_catalog."default",
                   CONSTRAINT transaction_pkey PRIMARY KEY (id),
                   CONSTRAINT transaction_accountid_fkey FOREIGN KEY (accountid)
                       REFERENCES public.account (id) MATCH SIMPLE
                       ON UPDATE NO ACTION
                       ON DELETE NO ACTION
               )
               
               TABLESPACE pg_default;
               
               ALTER TABLE public.transaction
                   OWNER to postgres;
           end-exec
           perform convert-sqlcode
           
           perform close-database-connection
           goback.

       
       entry WRITE-CUSTOMER-ROW using by reference LNK-CUSTOMER-RECORD
                                                   lnkSuccess.
           move LNK-CUSTOMER-ID of LNK-CUSTOMER-RECORD to WS-TEMP-ID 
           exec sql
               insert into customer 
                   (id, firstName, lastName)
                   values
                   (:WS-TEMP-ID,
                    :LNK-FIRST-NAME,
                    :LNK-LAST-NAME);
           end-exec
           perform convert-sqlcode
           move success-flag to lnkSuccess 
           goback. 
      
       entry WRITE-ACCOUNT-ROW using by reference LNK-ACCOUNT
                                                  lnkSuccess.
           move LNK-ACCOUNT-ID of LNK-ACCOUNT to WS-TEMP-ID-2 
           move LNK-CUSTOMER-ID of LNK-ACCOUNT to WS-TEMP-ID 
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
           perform convert-sqlcode
           move success-flag to lnkSuccess 
           goback. 
       
       entry WRITE-TRANSACTION-ROW using by reference LNK-TRANSACTION-RECORD  
                                                  lnkSuccess.
           move LNK-ACCOUNT-ID of LNK-TRANSACTION-RECORD to WS-TEMP-ID 
           move LNK-TRANS-DATE to date-characters
           exec sql
               insert into transaction
                   (id, accountid, transdate, amount, description)
                   values
                   (:LNK-TRANSACTION-ID,
                    :WS-TEMP-ID,
                    :date-characters,
                    :LNK-AMOUNT, 
                    :LNK-DESCRIPTION);
           end-exec
           perform convert-sqlcode
           move success-flag to lnkSuccess 
           goback. 
       
       entry OPEN-DATABASE using by reference lnkSuccess.
           perform open-database-connection 
           perform convert-sqlcode 
           move success-flag to lnkSuccess
           goback. 

       entry CLOSE-DATABASE using by reference lnkSuccess.
           perform close-database-connection 
           perform convert-sqlcode 
           move success-flag to lnkSuccess
           goback. 

       convert-sqlcode section.
           move sqlstate(1:2) to condition-class
           
           evaluate condition-class
               when "00"
                   move 0 to success-flag 
               when "02" 
                   move 1 to success-flag
               when other
                   display "SQL state " sqlstate
                   display "sql msg " SQLERRM
                   move 9 to success-flag 
           end-evaluate
           .
           
       open-database-connection section.
           if not connection-opened = 1 then 
               perform set-connection-string
               exec sql
                    connect using :connection-string
               end-exec
               move 1 to connection-opened
           else 
               move "00000" to sqlstate
           end-if
           perform convert-sqlcode
           .
           
       close-database-connection section. 
           if connection-opened = 1 
               exec sql 
                   commit work release
               end-exec
               move 0 to connection-opened
           else 
               move "00000" to sqlstate
           end-if
           perform convert-sqlcode
           .
           
       set-connection-string section.
           .   
           
       
       
       
