      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
      $set ilusing(java.io) ilusing(java.math) 
       class-id com.mfcobolbook.datamigration.DataWriter public.

       working-storage section.
       01 outputFolder                 string.
       
       copy "FUNCTION-CODES.cpy". 
       copy "PROCEDURE-NAMES.cpy". 
       
       method-id new (folder as string).
           call "AccountStorageAccess"
           set outputFolder to folder
       end method. 

       method-id writeCustomers().
       working-storage section.
           01 fileStatus. 
             03 status-byte-1          pic x.
             03 status-byte-2          pic x.    
           declare op as string
           try 
               move OPEN-READ to op
               call OPEN-CUSTOMER-FILE using by value op 
                                      by reference  fileStatus
               if fileStatus <> "00"
                   raise new Exception ("Could not open customer file")
               end-if
               invoke writeRecords("customer.csv",
                                   method self::readCustomerRecord,
                                    method self::customerFormatter)
           finally
               move CLOSE-FILE to op
                   call OPEN-CUSTOMER-FILE using by value op 
                                       by reference  fileStatus 
           end-try
       end method. 
                 
       method-id writeAccounts(). 
       working-storage section.
           01 fileStatus. 
             03 status-byte-1          pic x.
             03 status-byte-2          pic x.    
           declare op as string
           try 
               move OPEN-READ to op
               call OPEN-ACCOUNT-FILE using by value op 
                                      by reference  fileStatus
               if fileStatus <> "00"
                   raise new Exception ("Could not open customer file")
               end-if
               invoke writeRecords("account.csv",
                                   method self::readAccountRecord,
                                   method self::accountFormatter)
           finally
               move CLOSE-FILE to op
                   call OPEN-ACCOUNT-FILE using by value op 
                                       by reference  fileStatus 
           end-try
       end method. 
                 
       method-id writeTransactions(). 
       working-storage section.
           01 fileStatus. 
             03 status-byte-1          pic x.
             03 status-byte-2          pic x.    
           declare op as string
           try 
               move OPEN-READ to op
               call OPEN-TRANSACTION-FILE using by value op 
                                      by reference  fileStatus
               if fileStatus <> "00"
                   raise new Exception ("Could not open customer file")
               end-if
               invoke writeRecords("transaction.csv",
                                   method self::readTransactionRecord,
                                   method self::transactionFormatter)
           finally
               move CLOSE-FILE to op
                   call OPEN-TRANSACTION-FILE using by value op 
                                       by reference  fileStatus 
           end-try
       end method. 
       
       
       method-id writeRecords (outputFile as string
                               recordReader  as type RecordReader
                               formatter  as type CsvRecordFormatter,).
       
           declare fileStatus as byte occurs 2 
           declare op as string
      
           declare outputFileName = new File(outputFolder, outputFile)
           perform using writer as type PrintWriter = 
                       new PrintWriter(new FileWriter(outputFileName))
              move START-READ to op
              invoke recordReader::apply(op)
              
               move READ-NEXT to op 
               perform until false 
                   declare fileRecord = recordReader::apply(op) 
                   if size of fileRecord = 0 
                       exit perform 
                   end-if
                   declare outputLine = formatter::apply(fileRecord)
                   display outputLine
                   invoke writer::println(outputLine)
               end-perform
           end-perform
       end method. 
       
       method-id readCustomerRecord (op as string) 
                          returning result as byte occurs any.
       working-storage section. 
       01 fileStatus. 
         03 status-byte-1      pic x. 
         03 status-byte-2      pic x. 
           copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
           call READ-CUSTOMER-RECORD using by value OP 
                                      by reference LS-CUSTOMER-RECORD
                                                   fileStatus
           if fileStatus = "10"
               set size of result to 0 
           else if fileStatus <> "00"
               raise new Exception ("Could not read file. code: " & fileStatus )
           else
               set result to LS-CUSTOMER-RECORD
           end-if
       end method. 
       
       method-id customerFormatter (customerRecord as byte occurs any)
                                  returning csvRow as string. 
           copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
           set LS-CUSTOMER-RECORD to customerRecord 
           declare outputLine = 
           String::format("%d, %s, %s", LS-CUSTOMER-ID, 
                           LS-FIRST-NAME::trim(), 
                           LS-LAST-NAME::trim())
           set csvRow to outputLine
       end method. 

       method-id readAccountRecord (op as string) 
                          returning result as byte occurs any.
       working-storage section. 
       01 fileStatus. 
         03 status-byte-1      pic x. 
         03 status-byte-2      pic x. 
           copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
           call READ-ACCOUNT-RECORD using by value OP 
                                      by reference LS-ACCOUNT
                                                   fileStatus
           if fileStatus = "10"
               set size of result to 0 
           else if fileStatus <> "00"
               raise new Exception ("Could not read file. code: " & fileStatus )
           else
               set result to LS-ACCOUNT
           end-if
       end method. 
       
       method-id accountFormatter (accountRecord as byte occurs any)
                                  returning csvRow as string. 
           copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
           set LS-ACCOUNT to accountRecord 
           declare outputLine = 
           String::format("%d,%d,%s,%s,%s", 
                           LS-ACCOUNT-ID,
                           LS-CUSTOMER-ID,
                           convertDecimal(LS-BALANCE), 
                           LS-TYPE
                           convertDecimal(LS-CREDIT-LIMIT))
           set csvRow to outputLine
       end method.        

       method-id readTransactionRecord (op as string) 
                          returning result as byte occurs any.
       working-storage section. 
       01 fileStatus. 
         03 status-byte-1      pic x. 
         03 status-byte-2      pic x. 
           copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
           call READ-TRANSACTION-RECORD using by value OP 
                                      by reference LS-TRANSACTION-RECORD
                                                   fileStatus
           if fileStatus = "10"
               set size of result to 0 
           else if fileStatus <> "00"
               raise new Exception ("Could not read file. code: " & fileStatus )
           else
               set result to LS-TRANSACTION-RECORD
           end-if
       end method. 

       method-id transactionFormatter (transactionRecord as byte occurs any)
                                  returning csvRow as string. 
           copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
           set LS-TRANSACTION-RECORD to transactionRecord 
           declare outputLine = 
           String::format("%d,%d,%s,%s,%s", LS-TRANSACTION-ID, 
                           LS-ACCOUNT-ID
                           LS-TRANS-DATE, 
                           convertDecimal(LS-AMOUNT), 
                           LS-DESCRIPTION::trim)
           set csvRow to outputLine
       end method. 
       
       method-id convertDecimal(unformatted as type BigDecimal) 
                      returning formattedNumber as string.
           declare inValue = new BigDecimal(unformatted, type MathContext::DECIMAL32) 
           set formattedNumber to inValue::toString()
       end method. 
       

       delegate-id CsvRecordFormatter(fields as byte occurs any) 
                       returning result as string.
       end delegate. 
       
       delegate-id RecordReader(op as string) 
                   returning dataRecord as byte occurs any.
       end delegate. 
       
       end class.
