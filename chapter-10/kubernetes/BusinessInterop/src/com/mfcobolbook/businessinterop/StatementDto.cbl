      $set ilusing(java.time) 
       class-id com.mfcobolbook.businessinterop.StatementDto public.

       01 minimumPayment                       decimal. 
       01 endingAmount                         decimal.
       01 interestAmount                       decimal. 
       01 accountId                            binary-long. 
       01 startDate                            type LocalDate. 
       
       
       method-id new (accountId as binary-long, startDate as type LocalDate, 
                      minimumPayment as decimal, endingAmount as decimal, 
                      interestAmount as decimal).
                      
          set self::minimumPayment to minimumPayment
          set self::endingAmount to endingAmount
          set self::interestAmount to interestAmount
          set self::accountId to accountId 
          set self::startDate to startDate
       end method. 
       
       method-id getMinimumPayment() returning result as decimal.
           set result to minimumPayment
       end method. 
       
       method-id getEndingAmount returning result as decimal.
           set result to endingAmount
       end method. 
       
       method-id getInterestAmount returning result as decimal.
           set result to interestAmount
       end method. 
       
       method-id getAccountId returning result as binary-long.
           set result to accountId
       end method. 
       
       method-id getStartDate returning result as type LocalDate.
           set result to startDate
       end method. 
       
       end class.
       