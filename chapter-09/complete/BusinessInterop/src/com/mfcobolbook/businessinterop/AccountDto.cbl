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
      
       class-id com.mfcobolbook.businessinterop.AccountDto public.

       working-storage section.
       01 accountId                            binary-long property. 
       01 customerId                           binary-long property. 
       01 balance                              decimal property.  
       01 #type                                binary-char property.  
       01 creditLimit                          decimal property.  
       
       
       method-id new (accountId as binary-long, customerId as binary-long, 
                      balance as decimal, #type as binary-char, creditLimit as decimal).
           set self::accountId to accountId 
           set self::customerId to customerid 
           set self::balance to balance
           set self::type to #type
           set self::creditLimit to creditLimit
           goback.
       end method.
       
       method-id getAsAccountRecord.
       linkage section. 
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by LNK.
       procedure division using by reference LNK-ACCOUNT.
           move accountId to LNK-ACCOUNT-ID
           move customerId to LNK-CUSTOMER-ID
           move balance to LNK-BALANCE
           move #type to LNK-TYPE
           move creditLimit to LNK-CREDIT-LIMIT
       end method. 

       method-id toString() returning aString as string override.
           set aString to type String::format
                       ("id %d, customerId %d, balance %s, limit %s", 
                         accountId, customerId, balance, creditLimit)
       end method.

       end class.
