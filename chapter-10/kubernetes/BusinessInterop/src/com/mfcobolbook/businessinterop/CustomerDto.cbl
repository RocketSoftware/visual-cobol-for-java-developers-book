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
