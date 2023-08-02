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
