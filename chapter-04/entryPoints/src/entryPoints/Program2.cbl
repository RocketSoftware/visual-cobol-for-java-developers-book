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
      
       program-id. Program2 as "entryPoints.Program2".

       working-storage section.
       01 result              pic s9(9) comp-5. 

       linkage section.
       01 paramByRef          pic x(60). 
       01 numberByRef         pic s9(9) comp-5. 
       01 paramByValue        pic s9(9) comp-5. 

       procedure division.
           display "Program loaded"
           goback.
       
       entry "EntryOne" using by value paramByValue.  
                             
           display "Entry one " paramByValue
           multiply 2 by paramByValue giving result 
         exit program returning result. 
       entry "EntryTwo" using by reference paramByRef. 
           display paramByRef
           move spaces to paramByRef
           move "goodbye world" to paramByRef
           exit program. 

       entry "EntryThree" using by reference numberByRef. 
         multiply numberByRef by 2 giving numberByRef 
         move numberByRef to return-code 
           exit program. 

       end program Program2.
