      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       class-id com.mfcobolbook.databuilder.TransactionsBuilder
        inherits AbstractBuilder.
       copy "PROCEDURE-NAMES.cpy". 
       copy "FUNCTION-CODES.cpy".

       78 DATA-LENGTH                      value 1000. 
       78 DATA-WIDTH                       value 4. 

       01 nextTransactionIndex             binary-long. 
       01 transactionInputData             string occurs DATA-LENGTH occurs DATA-WIDTH. 
       01 statementStartDate.
        03 year                            pic 9(4).
        03 month                           pic 9(2).
        03 #day                            pic 9(2). 

       method-id new (csvfile as string, statementDate as string).
           invoke super::new(csvfile)
           invoke validateDate(statementdate) 
           set statementStartDate to statementDate
       end method.

       method-id createRecords() returning result as condition-value override.
           invoke readRawTransactions(self::inputFile)
           set nextTransactionIndex to getTransactionEndIndex() 
           if nextTransactionIndex = 0 then
                   set nextTransactionIndex to 1
           end-if
           set result to iterateAccounts()
       end method. 

       method-id iterateAccounts returning result as condition-value. 
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
       01 fileStatus.
        03 status-byte-1               pic x.
        03 status-byte-2               pic x.
       01 functionCode                 pic x.
       
           set fileStatus to openFile(type FileType::account, OPEN-READ, "00")
           try
               if fileStatus <> "00"
                   raise new Exception("Couldn't open account file")
               end-if
               set functionCode to START-READ
               set LS-ACCOUNT-ID to 0 
               declare ids as list[binary-double]
               create ids 
               call READ-ACCOUNT-RECORD using by value functionCode 
                                          by reference LS-ACCOUNT fileStatus
               set functionCode to READ-NEXT
               perform until fileStatus <> "00"
                   call READ-ACCOUNT-RECORD using by value functionCode 
                                              by reference LS-ACCOUNT fileStatus
                   if fileStatus = "00"
                       write ids from LS-ACCOUNT-ID 
                   end-if
               end-perform
               
               perform varying nextId as binary-double through ids
                   move nextId to LS-ACCOUNT-ID

                   invoke addTransactions(LS-ACCOUNT-ID)
               end-perform
               
           finally
                invoke openFile(type FileType::account, CLOSE-FILE, "00")
          end-try
          set result to true 
       end method. 

       method-id addTransactions(accountId as binary-long).
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
       01 zeroPaddedDay                    pic 99. 
       01 numberTransactions               binary-long.
       01 inputDataIndex                   binary-long.
       01 daysInMonth                      binary-long.
       01 functionCode                     pic x. 
       01 fileStatus.
        03 status-byte-1               pic x.
        03 status-byte-2               pic x.

           display "Writing transactions for account " & accountId
           set numberTransactions to getRandom(0, 33)
           set daysInMonth to getMonthLength(month of statementStartDate)
           declare dates as binary-long occurs any
           set size of dates to (numberTransactions) 
           invoke fillDates(dates, daysInMonth)

           move year to LS-YEAR
           move month to LS-MONTH
           move WRITE-RECORD to functionCode

           try 
               invoke openFile(type FileType::transaction, OPEN-I-O, "05")

               perform varying i as binary-long  from 0 by 1 until i > numberTransactions
                   set inputDataIndex to getRandom(0, DATA-LENGTH - 1)
                   declare dataRow = transactionInputData[inputDataIndex]
                   move nextTransactionIndex to LS-TRANSACTION-ID
                   move accountId to LS-ACCOUNT-ID
                   move dates[i] to LS-DAY 
                   move stringToDecimal(dataRow[2]) to LS-AMOUNT
                   move dataRow[3] TO LS-DESCRIPTION 
                   call WRITE-TRANSACTION-RECORD using by value functionCode
                                                   by reference LS-TRANSACTION-RECORD fileStatus 
                   if fileStatus <> "00" and fileStatus <> "02"
                       raise new Exception("Transaction write failed with status " & fileStatus)
                   end-if
                   add 1 to nextTransactionIndex
               end-perform
           catch e as type Exception
               display e::getMessage()
           finally
              invoke openFile(type FileType::transaction, CLOSE-FILE, "00")
           end-try
       end method. 
       
       method-id validateDate(d as string).
       01 dateGroup.
         03 filler     pic 9(4). 
         03 m          pic 9(2). 
         03 filler     pic 9(2). 
           if size of d <> 8 
               raise new DataBuilderException("Date wrong length")
           end-if
               
           try 
               invoke type Integer::parseInt(d)
           catch e as type Exception
               raise new DataBuilderException ("Non numeric character in date")
           end-try
           move d to dateGroup
           if m < 1 or m > 12 
               raise new DataBuilderException("Month value out of range")
           end-if
       
       end method. 
        
           
           

       method-id getMonthLength(#month as binary-long) returning days as binary-long.
           if #month < 1 or #month > 12 
               raise new Exception("Invalid month")
           end-if
           evaluate #month
           when 1
           when 3
           when 5
           when 7
           when 8
           when 10
           when 12
               set days to 31
           when 2 
               set days to 28
           when other
               set days to 30
           end-evaluate
       end method. 

       method-id dayToString(dayDate as binary-long) returning result as string.
           if dayDate < 10 
               set result to "0" & dayDate
           else
               set result to dayDate
           end-if
       end method. 

       method-id getRandom(lowerBound as binary-long, upperBound as binary-long)
                                                       returning result as binary-long.
           compute result = (function random() * upperBound) + lowerBound.  

       end method. 

       method-id fillDates(dates as binary-long occurs any, daysInMonth as binary-long)
           perform varying i as binary-long from 0 by 1 until i = size of dates 
               set dates[i] to getRandom(1,daysInMonth)
           end-perform
           sort dates ascending
       end method. 

       method-id readRawTransactions(csvFilename as string). 
           declare dataIndex as binary-long = 0 
           perform using csvFile as type TextFieldParser = new TextFieldParser(csvFileName)
               perform until csvFile::endOfData() 
                   declare thisRow  = csvFile::next() 
                   if size of thisRow <> DATA-WIDTH 
                       raise new Exception("File does not contain " & DATA-WIDTH & " fields")
                   end-if
                   if thisRow[0] = "id" 
                       exit perform cycle                     
                   end-if
                   if dataIndex >= DATA-LENGTH 
                       exit perform
                   end-if
                   set transactionInputData[dataIndex] = thisRow
                   add 1 to dataIndex
                end-perform
           end-perform
       end method. 

       method-id getTransactionEndIndex() returning result as binary-long. 
       copy "FUNCTION-CODES.cpy". 

       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==LS==.
       01 lastIndex                    binary-long.
       01 fileStatus.
        03 status-byte-1                pic x.
        03 status-byte-2                pic x.

           set fileStatus to openFile(type FileType::transaction, OPEN-READ, "35")
           if fileStatus = "35" *> no file 
               set lastIndex to 0
           else
               call READ-LAST-TRANSACTION-RECORD using by reference LS-TRANSACTION-RECORD fileStatus
               if LS-YEAR = year of statementStartDate and LS-MONTH = month of statementStartDate 
                   raise new Exception("Transactions for this period already in file")
               end-if
               add 1 to LS-TRANSACTION-ID giving lastIndex 
               invoke openFile(type FileType::transaction, CLOSE-FILE, "35")
           end-if
           set result to lastIndex
       end method. 
       
        end class.
