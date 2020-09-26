       program-id. Program2.

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
