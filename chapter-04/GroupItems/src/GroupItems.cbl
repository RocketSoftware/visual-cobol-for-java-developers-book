       program-id GroupItems.
       Working-storage section. 
       01 cust-record. 
           03 cust-name                        pic x(80). 
           03 cust-address.
               05 address-line                 pic x(80) occurs 3.
               05 zip-code                     pic x(8).
               05 uk-post-code                 redefines zip-code.
                   07 outward-code             pic x(4).
                   07 inward-code              pic x(4). 
           03 age                              pic 9(4) comp-x.
         
       procedure division. 
           move "Director General" to cust-name
           move "BBC" to address-line(1) 
           move "W1A" to outward-code
           move "1AA" to inward-code.
