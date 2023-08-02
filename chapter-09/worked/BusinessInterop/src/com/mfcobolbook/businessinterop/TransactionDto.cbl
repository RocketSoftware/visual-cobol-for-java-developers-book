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
      
      $set ilusing(java.time)  ilusing(java.time.format)
       class-id com.mfcobolbook.businessinterop.TransactionDto public.

       working-storage section.
       01 transactionId            binary-long property.
       01 accountId                binary-long property.
       01 transDate                type LocalDate property. 
       01 amount                   decimal property.
       01 description              string property. 
       01 isoFormatter             type DateTimeFormatter value 
                                       type DateTimeFormatter::BASIC_ISO_DATE
                                           static.
       
       method-id new(transactionId as binary-long, accountId as binary-long
                     transDate as type LocalDate, amount as decimal, 
                     description as string).
           set self::transactionId to transactionId
           set self::accountId to accountId
           set self::transDate to transDate
           set self::amount to amount
           set self::description to description::trim()
       end method. 

       method-id getAsTransactionRecord
       linkage section. 
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by LNK. 
       procedure division using by reference LNK-TRANSACTION-RECORD.
           move transactionId to LNK-TRANSACTION-ID
           move accountId to LNK-ACCOUNT-ID
           move transDate::getYear() to LNK-YEAR
           move transDate::getMonthValue() to LNK-MONTH
           move transDate::getDayOfMonth() to LNK-DAY
           move amount to LNK-AMOUNT
           move description to LNK-DESCRIPTION
       end method.
       
       method-id convertToLocalDate static.
       01 WS-ISO-DATE.  
         03 LNK-YEAR                   PIC 9(4).
         03 filler                     value '-'.
         03 LNK-MONTH                  PIC 9(2). 
         03 filler                     value '-'.
         03 LNK-DAY                    PIC 9(2). 

       linkage section.
       copy "DATE.cpy" replacing ==(PREFIX)== by ==LNK==.
       procedure division using by value LNK-DATE 
                      returning result as type LocalDate.
           move corresponding LNK-DATE to WS-ISO-DATE
           set result = type LocalDate::parse(WS-ISO-DATE)
       end method. 
       
       method-id getDateAsString returning #date as string.
           set #date to isoFormatter::format(transDate)
       end method. 
       
       method-id toString() returning displayString as string override.
           set displayString to type String::format("id %d, account %d, %s, %s %s", 
                       transactionId, accountId,
                       transDate::format(
                         type java.time.format.DateTimeFormatter::ISO_LOCAL_DATE)
                       amount, description)
       end method. 
       
       end class.
