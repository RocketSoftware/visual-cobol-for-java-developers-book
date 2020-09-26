      $set ilusing(java.io) 
       class-id com.mfcobolbook.databuilder.AccountsBuilder inherits 
                                           type AbstractBuilder.

       working-storage section.
       copy "PROCEDURE-NAMES.cpy". 
       01 openAccountFile      procedure-pointer.
       01 openCustomerFile     procedure-pointer.
       01 openTransactionFile  procedure-pointer. 

       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LAST==.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==LAST==.
       COPY "FUNCTION-CODES.cpy". 
       
       01 nextCustomerIndex    binary-long.
       01 nextAccountIndex     binary-long. 

       78 CUSTOMER             value "CUSTOMER".
       78 ACCOUNT              value "ACCOUNT". 

       method-id new (inputFile as string) public.
           invoke super::new(inputFile)
           goback.
       end method.

       method-id createRecords()  returning success as condition-value override protected.
       copy "FUNCTION-CODES.cpy". 
           try
              invoke openFile (type FileType::customer, OPEN-WRITE, "05") 
              invoke openFile (type FileType::account, OPEN-WRITE, "05") 

               perform using csvFile as type TextFieldParser = new TextFieldParser(inputFile)
                   perform until csvFile::endOfData
                       declare thisRow  = csvFile::next()  
                       if size of thisRow < 8 
                           raise new Exception("no fields")
                       end-if
                       if thisRow[0] = "id" 
                           exit perform cycle                     
                       end-if
                       declare recordId    = stringToInt(thisRow[0])
                       declare firstName   = thisRow[2]
                       declare lastName  = thisRow[3]
                       declare creditLimit = stringToInt(thisRow[5]) * 1000
                       declare dateString  = convertDate(thisRow[6])
                       declare balance     = stringToDecimal(thisRow[7])
                       
                       invoke addCustomerRecord(firstName, lastName, recordId)
                       invoke addAccountRecord(recordId, balance, creditLimit)
                   end-perform

               end-perform
           catch e as type Exception 
               display e::getMessage()
               exit method 
           finally
              invoke openFile (type FileType::customer, CLOSE-FILE, "00") 
              invoke openFile (type FileType::account, CLOSE-FILE, "00") 
           end-try
           set success to true
       end method. 

       method-id convertDate(mockarooFmt as string) returning myFormat as string private.
           declare parts = mockarooFmt::split("-")
           if size of parts <> 3
               set parts to mockarooFmt::split("/")
               if size of parts <> 3
                   raise new Exception("date in unexpected format")
               end-if
           end-if
           set myFormat to parts[2] & parts[1] & parts[0]
       end method.


       method-id addCustomerRecord (firstName as string
                                    lastName as string, 
                                    recordId as binary-double) 
                                    private.
           01 #function                        pic x.
           copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==LS==. 
           01 file-status.
               03 status-byte-1                pic x.
               03 status-byte-2                pic x.

           set LS-FIRST-NAME to firstName
           set LS-LAST-NAME to lastName
           set LS-CUSTOMER-ID to recordId
           move WRITE-RECORD TO #function
      
           call WRITE-CUSTOMER-RECORD using by value #function 
                                        by reference LS-CUSTOMER-RECORD
                                                     file-status
           if file-status <> "00" and file-status <> "02"
               move LOW-VALUES to LAST-CUSTOMER-RECORD
               raise new Exception("Customer write failed with exception " & file-status & " id " & recordId)
           end-if
      *    set recordId to LS-CUSTOMER-ID
       end method. 

       method-id addAccountRecord (recordId as binary-double,
                                   balance as decimal, 
                                   creditLimit as binary-long)
                                   private.
           copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LS==. 
           01 file-status.
               03 status-byte-1                pic x.
               03 status-byte-2                pic x. 
           01 #function                        pic x. 
           set #function to WRITE-RECORD
           set LS-CUSTOMER-ID to recordId
           set LS-ACCOUNT-ID to recordId
           set LS-BALANCE to balance
           set LS-TYPE to "C"
           set LS-CREDIT-LIMIT to creditLimit
           
      
           call WRITE-ACCOUNT-RECORD using by value #function
                                        by reference LS-ACCOUNT
                                                     file-status
           if file-status <> "00" and file-status <> "02"
               move LOW-VALUES to LAST-CUSTOMER-RECORD
               raise new Exception("Account write failed with exception " & file-status & " id " & recordId)
           end-if
       end method.


       method-id getCustomerEndIndex() returning i as binary-long private.
           copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==LS==. 
           01 file-status.
               03 status-byte-1                pic x.
               03 status-byte-2                pic x. 

           call READ-LAST-CUSTOMER-RECORD using by reference LS-CUSTOMER-RECORD file-status
           add 1 to LS-CUSTOMER-ID giving i
       end method. 

       method-id getAccountEndIndex() returning i as binary-long private. 
           copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
           01 file-status.
               03 status-byte-1                pic x.
               03 status-byte-2                pic x. 
           call READ-LAST-ACCOUNT-RECORD using by reference LS-ACCOUNT file-status
           add 1 to LS-ACCOUNT-ID giving nextAccountIndex 
       end method. 

       end class.


