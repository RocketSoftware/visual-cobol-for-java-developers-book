       program-id MainProgram. 

       working-storage section. 
       01 aNumber         pic s9(9) comp-5. 
       01 answer          pic s9(9) comp-5.    
       01 aString         pic x(60). 
       procedure division.
      *    Load the other program
           call "Program2"

           move 32 to aNumber
           call "EntryOne" using by value aNumber
                              returning answer
         display answer
           move "Hello world" to aString
           call "EntryTwo" using by reference aString
         display aString *> String value has been changed

         move 99 to aNumber
         call "EntryThree" using by content aNumber
         display aNumber *> aNumber unchanged because it was passed 
                         *> by content 
         display return-code 
           display aString
           
