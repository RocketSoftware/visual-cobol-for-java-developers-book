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
      
       program-id. Program1. 
      *> No DATA DIVISION header required in Micro Focus COBOL
       working-storage section. 
       01 anInteger               pic x(4) comp-5. 
       01 aDifferentInteger       pic x(4) comp-x. 
       01 aString                 pic x(100). 

       procedure division.
         move 99 to anInteger
         move anInteger to aDifferentInteger
         move "Hello there" to aString

         display anInteger space aDifferentInteger space aString
           stop run
