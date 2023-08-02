      *****************************************************************
      *                                                               *
      * Copyright 2020-2023 Open Text. All Rights Reserved.           *
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
      
      $set ilusing(java.time) ilusing(java.util)
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
       
       method-id asMap() returning result as type Map[String,String]. 
       end method. 
       
       end class.
       
