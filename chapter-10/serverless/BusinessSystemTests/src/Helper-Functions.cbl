       copy "mfunit_prototypes.cpy".
       copy "cblproto.cpy".
       program-id. Helper-Functions.

       data division.
       working-storage section.
       copy "PROCEDURE-NAMES.cpy".
       copy "FUNCTION-CODES.cpy".
              
       01 VERIFICATION-RECORD PIC X(200).
       01 file-status.
         03 file-status-1                      pic x.
         03 file-status-2                      pic x.
       01 record-length                        pic x(4) comp-5.
       01 open-ppointer                        procedure-pointer.
       01 write-ppointer                       procedure-pointer.
       01 read-one-record-ppointer             procedure-pointer.
       01 read-last-ppointer                   procedure-pointer.
       01 read-records-ppointer                procedure-pointer.
       01 function-code                        pic x.
       01 file-details                         cblt-fileexist-buf.
       01 ws-filename                          pic x(1000).
       01 msg                                  pic x(200).
       01 ws-file-status                       pic xx. 

       copy "HELPER-FUNCTIONS.cpy".

       linkage section.
       01 lnk-function-status pic 9.
      *> The actual size of LNK-RECORD doesn't matter as the
      *> data is allocated by the caller. But having a size
      *> equal or larger than the largest record makes it
      *? possible to see the value in the debugger.
       01 LNK-RECORD pic                       x(200).
       01 LNK-EXPECTED-RECORD                  pic x(200).
       01 LNK-FUNCTION-CODE                    pic x. 
       procedure division.
           call "ACCOUNT-STORAGE-ACCESS"
           goback
           .

       ENTRY INIT-CUSTOMER-TEST using by reference lnk-function-status.
           perform init-helper
           set open-ppointer to entry OPEN-CUSTOMER-FILE
           set write-ppointer to entry WRITE-CUSTOMER-RECORD
           set read-one-record-ppointer to entry FIND-CUSTOMER-ID
           set read-last-ppointer to entry READ-LAST-CUSTOMER-RECORD
           set read-records-ppointer to entry READ-CUSTOMER-RECORD 
           display "dd_CUSTOMERFILE" upon environment-name
           perform setup-test-data
           goback.

       ENTRY INIT-ACCOUNT-TEST using by reference lnk-function-status.
           perform init-helper
           set open-ppointer to entry OPEN-ACCOUNT-FILE
           set write-ppointer to entry WRITE-ACCOUNT-RECORD
           set read-one-record-ppointer to entry FIND-ACCOUNT-ID
           set read-last-ppointer to entry READ-LAST-ACCOUNT-RECORD
           set read-records-ppointer to entry READ-ACCOUNT-RECORD
           display "dd_ACCOUNTFILE" upon environment-name
           perform setup-test-data
           goback.
       
       ENTRY INIT-TRANSACTION-TEST using by reference lnk-function-status
           perform init-helper
           set open-ppointer to entry OPEN-TRANSACTION-FILE
           set write-ppointer to entry WRITE-TRANSACTION-RECORD
           set read-one-record-ppointer to entry FIND-TRANSACTION-BY-ID
           set read-last-ppointer to entry READ-LAST-TRANSACTION-RECORD
           set read-records-ppointer to entry READ-TRANSACTION-RECORD 
           display "dd_TRANSACTIONFILE" upon environment-name
           perform setup-test-data
           goback. 
                                                      
       
       setup-test-data section. 
      $if OESQL-TEST = 0    
           move spaces to ws-filename
           accept ws-filename from environment-value
           if ws-filename equals spaces
               move z"Environment variable not set" to msg
               call MFU-ASSERT-FAIL-Z using msg
               goback
           end-if
           call CBL-CHECK-FILE-EXIST using ws-filename
                                           file-details
           if return-code = 0
      *>       delete the file before running the test
               display "Deleting file"
               call CBL-DELETE-FILE using ws-filename
           end-if
      $end
           set succeeded to true
           move function-status to lnk-function-status
           exit section. 
    
       ENTRY OPEN-TEST-FILE using by value LNK-FUNCTION
                              by reference lnk-function-status.
           perform init-helper
           call open-ppointer using by value LNK-FUNCTION
                                    by reference file-status
           if file-status <> "05"
             and file-status <> "00" *> file not found/file ok
               move "Status returned from file open is "
                 & file-status & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
               goback
           end-if
           set succeeded to true
           move function-status to lnk-function-status
           goback
           .

       ENTRY CLOSE-TEST-FILE using by reference lnk-function-status.
           perform init-helper

           move CLOSE-FILE to function-code
           call open-ppointer using by value function-code
                                    by reference file-status
           if file-status <> "00"
               move "Status returned from file close is " 
                     & file-status & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
               set failed to true
               move function-status to lnk-function-status
               goback
           end-if
           set succeeded to true
           move function-status to lnk-function-status
           goback
           .

       ENTRY WRITE-TEST-RECORD using by value LNK-FUNCTION
                                     by reference LNK-RECORD
                                                  lnk-function-status.
           perform init-helper
           call write-ppointer using by value lnk-function
                                     by reference LNK-RECORD
                                                  file-status
           if file-status <> "00" and file-status <> "02"
               move "Status returned from file write is "
                 & file-status & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
               goback
           end-if
           set succeeded to true
           move function-status to lnk-function-status
           goback
           .

       ENTRY READ-TEST-RECORDS using by value lnk-function-code
                                     by reference LNK-RECORD
                                                  lnk-function-status.
           perform init-helper
           call read-records-ppointer using by value lnk-function-code
                                            by reference LNK-RECORD
                                                         file-status
           if file-status <> "00"
             and file-status <> "02"
             and file-status <> "23"
             and file-status <> "10"
               move "Status returned from file read is " & file-status & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
               set failed to true
               move function-status to lnk-function-status
               goback
           end-if
           if file-status = "23" or file-status = "10"
               set no-more-records to true
           else
               set succeeded to true
           end-if
           move function-status to lnk-function-status
           goback
           .


       ENTRY COMPARE-RECORDS using by value record-length
                                   by reference LNK-RECORD
                                                LNK-EXPECTED-RECORD
                                                lnk-function-status.
           perform init-helper
           move OPEN-READ to function-code
           call open-ppointer using by value function-code
                                    by reference file-status
           if file-status <> "05"
             and file-status <> "00" *> file not found/file ok
               move "Status returned from file open is "
                 & file-status & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
               goback
           end-if
           call read-one-record-ppointer using by value function-code
                                    by reference LNK-RECORD
                                                 file-status
           if file-status <> "00" and file-status <> "02"
               move "Status returned from file read is "
                 & file-status & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           else
               set succeeded to true
           end-if
           move CLOSE-FILE to function-code
           call open-ppointer using by value function-code
                                    by reference file-status
           if file-status <> "00" or failed
               set failed to true
               move function-status to lnk-function-status
               goback
           end-if

           if LNK-RECORD(1:record-length)
             <> LNK-EXPECTED-RECORD(1:record-length)
               move "Records do not match" to msg
               set failed to true
               call MFU-ASSERT-FAIL-Z using msg
               display "Expected"
               display LNK-EXPECTED-RECORD(1:record-length)
               display "actual "
               display LNK-RECORD(1:record-length)
               set failed to true
               move function-status to lnk-function-status
               goback
           end-if
           set succeeded to true
           move function-status to lnk-function-status
           goback
           .
      $if OESQL-TEST = 1
       ENTRY ADD-CUSTOMER using by reference lnk-function-status
                                             LNK-RECORD.
           move OPEN-WRITE to function-code
           call OPEN-CUSTOMER-FILE using by value function-code
                                         by reference file-status
           if file-status <> "00"
               set failed to true
               move function-status to lnk-function-status
               goback
           end-if
           move WRITE-RECORD to function-code
           call WRITE-CUSTOMER-RECORD using by value function-code
                                            by reference LNK-RECORD
                                                         file-status
           if file-status <> "00"
               set failed to true
               move function-status to lnk-function-status
               goback
           end-if
           move CLOSE-FILE to function-code
           call OPEN-CUSTOMER-FILE using by value function-code
                                         by reference file-status
           if file-status <> "00"
               set failed to true
           end-if
           goback. 
       
       ENTRY ADD-ACCOUNT using by reference lnk-function-status
                                            LNK-RECORD.
           move OPEN-WRITE to function-code
           call OPEN-ACCOUNT-FILE using by value function-code
                                         by reference file-status 
           if file-status <> "00"
               set failed to true
               move function-status to lnk-function-status
               goback
           end-if
           move WRITE-RECORD to function-code
           call WRITE-ACCOUNT-RECORD using by value function-code
                                           by reference LNK-RECORD
                                                        file-status
           if file-status <> "00"
               set failed to true
               move function-status to lnk-function-status
               goback
           end-if
           move CLOSE-FILE to function-code
           call OPEN-ACCOUNT-FILE using by value function-code
                                        by reference file-status
           if file-status <> "00"
               set failed to true
           end-if
           goback. 
      $end

       init-helper section.
           move 0 to lnk-function-status
           move spaces to VERIFICATION-RECORD
           exit section
           .
           
           
       end program Helper-Functions.