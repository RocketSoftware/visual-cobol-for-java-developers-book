      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
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
