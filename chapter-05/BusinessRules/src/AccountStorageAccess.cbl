       program-id. ACCOUNT-STORAGE-ACCESS as "AccountStorageAccess".  
       file-control.
           select Account-File assign to external accountFile
               file status is file-status
               organization is indexed 
               access mode is dynamic
               record key is FILE-ACCOUNT-ID of FILE-ACCOUNT
               alternate record key is FILE-CUSTOMER-ID of FILE-ACCOUNT
                                                        with duplicates 
               .
           select Customer-File assign to external customerFile
               file status is file-status
               organization is indexed 
               access mode is dynamic
               record key is FILE-CUSTOMER-ID OF FILE-CUSTOMER-RECORD
               alternate record key is FILE-LAST-NAME with duplicates
               .
           select Transaction-File assign to external transactionFile
               file status is file-status
               organization is indexed 
               access mode is dynamic 
               record key is FILE-TRANSACTION-ID
               alternate record key is FILE-ACCOUNT-ID
                                    of FILE-TRANSACTION-RECORD
                                    with duplicates                              
               alternate record key is FILE-TRANS-DATE with duplicates
               .


       data division.
       file section.
       fd Account-File. 
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==FILE==.
       fd Customer-File.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==FILE==.
       fd Transaction-File. 
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==FILE==. 
       working-storage section.
       01 displayable          pic x(255). 
       78 MAX-ID               value 2147483648.
       
       01 file-status.
        03 file-status-1 pic x.
        03 file-status-2 pic x.
       
       01 library-status-code  pic xx comp-5. 
       copy "PROCEDURE-NAMES.cpy".

       linkage section. 
       01 LNK-STATUS.
        03 LNK-FILE-STATUS-1               PIC X.
        03 LNK-FILE-STATUS-2               PIC X.
       copy "FUNCTION-CODES.cpy".  
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==. 
       
       procedure division.
           perform display-file-names
           goback.

       
       ENTRY OPEN-CUSTOMER-FILE using by VALUE LNK-FUNCTION
                                  by reference LNK-STATUS
           evaluate LNK-FUNCTION
               when OPEN-READ
                   open input Customer-File 
               when OPEN-WRITE
                   open i-o Customer-File  
               when OPEN-I-O
                   open i-o Customer-File
               when CLOSE-FILE
                   close Customer-File
           end-evaluate
           move file-status to LNK-STATUS
           goback.
           
       ENTRY WRITE-CUSTOMER-RECORD using by value LNK-FUNCTION
                                     by reference LNK-CUSTOMER-RECORD 
                                                  LNK-STATUS.
           move LNK-CUSTOMER-RECORD to FILE-CUSTOMER-RECORD
           evaluate LNK-FUNCTION
           when WRITE-RECORD
               write FILE-CUSTOMER-RECORD
           when UPDATE-RECORD
               rewrite FILE-CUSTOMER-RECORD
           when other 
               move "88" to file-status
           end-evaluate
           move file-status to LNK-STATUS 
           goback.
       
       ENTRY DELETE-CUSTOMER-RECORD using by reference LNK-CUSTOMER-RECORD
                                                       LNK-STATUS. 
           move LNK-CUSTOMER-RECORD to FILE-CUSTOMER-RECORD
           delete Customer-File record
           move file-status to lnk-status
           display file-status
           goback.

      * find account by customer last name
       ENTRY FIND-CUSTOMER-NAME using BY value LNK-FUNCTION 
                                  by reference LNK-CUSTOMER-RECORD 
                                               LNK-STATUS.
           move "00" to LNK-STATUS
           evaluate LNK-FUNCTION
               when START-READ
                   move LNK-CUSTOMER-RECORD TO FILE-CUSTOMER-RECORD
                   start Customer-File key is equal FILE-LAST-NAME
               when READ-NEXT
                   read Customer-File next
                   move FILE-CUSTOMER-RECORD to LNK-CUSTOMER-RECORD
           end-evaluate
           move file-status to LNK-STATUS
           goback. 

      * find account by customer ID
       ENTRY FIND-CUSTOMER-ID using BY value LNK-FUNCTION 
                                by reference LNK-CUSTOMER-RECORD 
                                             LNK-STATUS.
           move "00" to LNK-STATUS
           move LNK-CUSTOMER-RECORD to FILE-CUSTOMER-RECORD
           read Customer-File key is FILE-CUSTOMER-ID 
                                  of FILE-CUSTOMER-RECORD
           move FILE-CUSTOMER-RECORD to LNK-CUSTOMER-RECORD
           
           move file-status to LNK-STATUS
           goback. 
           
       ENTRY READ-CUSTOMER-RECORD using by value LNK-FUNCTION
                                       reference LNK-CUSTOMER-RECORD 
                                                 LNK-STATUS

           evaluate LNK-FUNCTION
               when START-READ
                   move LNK-CUSTOMER-RECORD TO FILE-CUSTOMER-RECORD
                   start CUSTOMER-File key >= FILE-CUSTOMER-ID 
                                          of FILE-CUSTOMER-RECORD
               when READ-NEXT
                   read CUSTOMER-FILE next
           end-evaluate
           move FILE-CUSTOMER-RECORD to LNK-CUSTOMER-RECORD
           move file-status to LNK-STATUS
           goback
           .      
       
       ENTRY READ-LAST-CUSTOMER-RECORD using 
                                by reference LNK-CUSTOMER-RECORD 
                                             LNK-STATUS
           move MAX-ID to FILE-CUSTOMER-ID of FILE-CUSTOMER-RECORD
           start Customer-File key 
                               < FILE-CUSTOMER-ID OF FILE-CUSTOMER-RECORD

           read Customer-File previous  
           move FILE-CUSTOMER-RECORD to LNK-CUSTOMER-RECORD 
           move file-status to LNK-STATUS
           goback.

       ENTRY OPEN-ACCOUNT-FILE using by VALUE LNK-FUNCTION
                                 by reference LNK-STATUS
           evaluate LNK-FUNCTION
               when OPEN-READ
                   open input Account-File
               when OPEN-I-O
                   open i-o Account-File
               when OPEN-WRITE
                   open output Account-File
               when CLOSE-FILE
                   close Account-File
           end-evaluate
           move file-status to LNK-STATUS
           
           goback. 
           
       ENTRY WRITE-ACCOUNT-RECORD using by value LNK-FUNCTION 
                                    by reference LNK-ACCOUNT 
                                                 LNK-STATUS.
           move LNK-ACCOUNT to FILE-ACCOUNT
           
           evaluate LNK-FUNCTION
               when WRITE-RECORD
                   write FILE-ACCOUNT
               when UPDATE-RECORD
                   rewrite FILE-ACCOUNT
               when other 
                   move "88" to file-status
           end-evaluate
           move file-status to LNK-STATUS
           goback.

       ENTRY READ-ACCOUNT-RECORD using by value LNK-FUNCTION
                               by reference LNK-ACCOUNT LNK-STATUS

           evaluate LNK-FUNCTION
               when START-READ
                   move LNK-ACCOUNT TO FILE-ACCOUNT
                   start ACCOUNT-File key >= FILE-ACCOUNT-ID 
                                          of FILE-ACCOUNT
               when READ-NEXT
                   read ACCOUNT-File next
           end-evaluate
           move FILE-ACCOUNT to LNK-ACCOUNT
           move file-status to LNK-STATUS
           goback
           . 
           
       ENTRY DELETE-ACCOUNT-RECORD using by reference LNK-ACCOUNT
                                                       LNK-STATUS. 
           move LNK-ACCOUNT to FILE-ACCOUNT
           delete Account-File record
           move file-status to lnk-status
           display file-status
           goback.



       ENTRY READ-LAST-ACCOUNT-RECORD using by reference LNK-ACCOUNT 
                                                         LNK-STATUS.
           move MAX-ID to FILE-ACCOUNT-ID of FILE-ACCOUNT
           start Account-File key < FILE-ACCOUNT-ID of FILE-ACCOUNT 

           read Account-File previous  
           move FILE-ACCOUNT to LNK-ACCOUNT
           move file-status to LNK-STATUS
           goback.

       ENTRY OPEN-TRANSACTION-FILE using by VALUE LNK-FUNCTION
                                     by reference LNK-STATUS
           evaluate LNK-FUNCTION
               when OPEN-READ
                   open input Transaction-File 
               when OPEN-WRITE
                   open output Transaction-File
               when OPEN-I-O
                   open i-o Transaction-File
               when CLOSE-FILE
                   close Transaction-File
           end-evaluate
           move file-status to LNK-STATUS
           goback.

       ENTRY WRITE-TRANSACTION-RECORD using by value LNK-FUNCTION 
                                   by reference LNK-TRANSACTION-RECORD
                                                LNK-STATUS.
           move LNK-TRANSACTION-RECORD to FILE-TRANSACTION-RECORD
           evaluate LNK-FUNCTION
               when WRITE-RECORD
                   write FILE-TRANSACTION-RECORD
               when UPDATE-RECORD
                   rewrite FILE-TRANSACTION-RECORD
               when other 
           end-evaluate           
           move file-status to LNK-STATUS 
           goback.
           
       ENTRY READ-TRANSACTION-RECORD using by value LNK-FUNCTION
                               by reference LNK-TRANSACTION-RECORD 
                                            LNK-STATUS

           evaluate LNK-FUNCTION
               when START-READ
                   move LNK-TRANSACTION-RECORD TO FILE-TRANSACTION-RECORD
                   start TRANSACTION-FILE key >= FILE-TRANSACTION-ID 
               when READ-NEXT
                   read TRANSACTION-FILE next
           end-evaluate
           move FILE-TRANSACTION-RECORD to LNK-TRANSACTION-RECORD
           move file-status to LNK-STATUS
           goback
           . 

       ENTRY FIND-TRANSACTION-BY-ACCOUNT using by value LNK-FUNCTION
                                           by reference LNK-TRANSACTION-RECORD 
                                                        LNK-STATUS
           move LNK-TRANSACTION-RECORD to FILE-TRANSACTION-RECORD
           evaluate LNK-FUNCTION
               when START-READ
                   start Transaction-File key = FILE-ACCOUNT-ID 
                                                of FILE-TRANSACTION-RECORD
               when READ-NEXT
                   read Transaction-File next 
           end-evaluate
           move file-status to LNK-STATUS
           move FILE-TRANSACTION-RECORD to LNK-TRANSACTION-RECORD
           goback. 

       ENTRY INITIALIZE-DATA-SYSTEM using by reference LNK-STATUS.
           move "00" to LNK-STATUS
           goback. 
       
       
       ENTRY DELETE-ALL-DATA. 
           display "dd_CUSTOMERFILE" upon environment-name
           perform delete-file
           
           display "dd_ACCOUNTFILE" upon environment-name
           perform delete-file
           
           display "dd_TRANSACTIONFILE" upon environment-name
           perform delete-file     
           goback.
       
       delete-file section. 
           move spaces to displayable
           accept displayable from environment-value
           call "CBL_DELETE_FILE" using displayable 
                              returning library-status-code
           if library-status-code <> 0 
               display "Status when deleting " displayable library-status-code
           end-if
           exit section
           .
           
       ENTRY DELETE-TRANSACTION-RECORD using by reference 
                                    LNK-TRANSACTION-RECORD
                                    LNK-STATUS. 
           move LNK-TRANSACTION-RECORD to FILE-TRANSACTION-RECORD    
           delete TRANSACTION-FILE record 
           move FILE-STATUS to LNK-STATUS
           goback. 
       
       ENTRY READ-LAST-TRANSACTION-RECORD using by reference
                                 LNK-TRANSACTION-RECORD
                                 LNK-STATUS     
           move MAX-ID to FILE-TRANSACTION-ID
           start Transaction-File key < FILE-TRANSACTION-ID 

           read Transaction-File previous  
           move FILE-TRANSACTION-RECORD to LNK-TRANSACTION-RECORD
           move file-status to LNK-STATUS
           goback.

       display-file-names section.
           display "dd_CUSTOMERFILE" upon environment-name
           accept displayable from environment-value
           display "Customer    file = " displayable
           move spaces to displayable

           display "dd_ACCOUNTFILE" upon environment-name
           accept displayable from environment-value
           display "Account     file = " displayable
           move spaces to displayable

           display "dd_TRANSACTIONFILE" upon environment-name
           accept displayable from environment-value
           display "Transaction file = " displayable
       
       
