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
      
       program-id MainProgram as "entryPoints.MainProgram".

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
           
