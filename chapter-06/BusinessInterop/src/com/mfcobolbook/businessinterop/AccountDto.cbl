      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
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
