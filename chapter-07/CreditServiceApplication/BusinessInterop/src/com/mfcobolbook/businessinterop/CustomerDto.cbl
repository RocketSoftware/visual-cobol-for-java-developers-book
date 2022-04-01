      *****************************************************************
      *                                                               *
      * Copyright (C) 2020-2022 Micro Focus.  All Rights Reserved.    *
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
      
       class-id com.mfcobolbook.businessinterop.CustomerDto. 
                
       01 customerId                   binary-long property. 
       01 firstName                    string property. 
       01 lastName                     string property. 
       
       
       method-id new (customerId as binary-long, firstName as string, 
                      lastname as string).
           set self::customerId to customerId 
           set self::firstName to firstName::trim
           set self::lastName to lastName::trim 
       end method. 

       method-id getAsCustomerRecord.
       linkage section. 
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by LNK.
       procedure division using by reference lnk-customer-record.
           move customerid to LNK-CUSTOMER-ID
           move firstname to LNK-FIRST-NAME
           move lastName to LNK-LAST-NAME
       end method. 
       
       method-id toString() returning aString as string override.
           set aString to type String::format
                       ("id %d, %s %s", 
                         customerId, firstName, lastName)
       end method.       
       end class.
