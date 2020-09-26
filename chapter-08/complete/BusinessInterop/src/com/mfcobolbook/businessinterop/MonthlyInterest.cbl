      $set ilusing(java.time) 
      $set ilusing(com.microfocus.cobol.runtimeservices) 
       class-id com.mfcobolbook.businessinterop.MonthlyInterest public. 
       copy "PROCEDURE-NAMES.cpy".
       01 valuesCalculated                 condition-value.
       01 dayRate                          decimal.
       01 startingAmount                   decimal. 
       01 endingAmount                     decimal. 
       01 startDate                        type LocalDate. 
       01 accountId                        binary-long.
       01 minimumPayment                   decimal. 
       01 interest                         decimal. 
       01 initialized                      condition-value. 
       01 runUnit                          type RunUnit.
       
       method-id init (dayRate as decimal, startingAmount as decimal, 
                      startDate as type LocalDate, 
                      accountId as binary-long).
           set self::dayRate to dayRate
           set self::startingAmount to startingAmount
           set self::startDate to startDate
           set self::accountId to accountId
           set initialized to true
       end method. 
       
       method-id close. 
       end method. 
       
       method-id calculate() private.
       copy "DATE.cpy" replacing ==(PREFIX)== BY ==START==. 
       01 tempResult                       PIC S9(12)V99. 
       01 tempDayRate                      PIC 99v9(8) comp-3.
       01 tempInterestPayment              PIC S9(12)V99.
       01 tempMinimumPayment               PIC S9(12)V99.
       01 fileStatus. 
         03 statusByte1                    pic x.
         03 statusByte2                    pic x.
           if not initialized 
               raise new UninitialisedObjectException("No data provided")
           end-if
           if not valuesCalculated
               call "INTEREST-CALCULATOR"
               set START-YEAR of START-DATE to startDate::getYear()
               set START-MONTH of START-DATE  to startDate::getMonthValue() 
               set START-DAY of START-DATE  to startDate::getDayOfMonth()
               move startingAmount to tempResult
               move dayRate to tempDayRate
               call CALCULATE-INTEREST using by value START-DATE
                                                      accountid
                                         by reference tempDayRate 
                                                      tempResult 
                                                      tempInterestPayment
                                                      tempMinimumPayment 
                                                      fileStatus
               if fileStatus <> "00"
                   if fileStatus = "23"
                       raise new RecordNotFoundException(
                           "No transactions for account " & accountId)
                   else
                       raise new Exception("Could not calculate result")
                   end-if
               end-if
               set endingAmount to tempResult
               set interest to tempInterestPayment
               set minimumPayment to  tempMinimumPayment
               set valuesCalculated to true 
           end-if 
           
       end method. 
       
       method-id getMinimumPayment() returning result as decimal. 
           if not valuesCalculated
               invoke calculate()
           end-if
           set result to minimumPayment
       end method.
       
       method-id getEndingAmount() returning result as decimal. 
           if not valuesCalculated
               invoke calculate()
           end-if
           set result to endingAmount
       end method.
       
       method-id getInterestPayment() returning result as decimal.
           if not valuesCalculated
               invoke calculate()
           end-if
           set result to interest 
       end method.
       
       method-id getStatementDto() returning result as type StatementDto. 
           if not valuesCalculated
               invoke calculate()
           end-if
           set result to new StatementDto (accountId, startDate, 
                                           minimumPayment,
                                           endingAmount, interest) 
           
       end method. 
       
       end class.
