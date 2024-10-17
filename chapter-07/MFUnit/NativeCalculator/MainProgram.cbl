      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       program-id. MainProgram.

       data division.
       working-storage section.
       linkage section. 
       01 operand1                 pic s9(15)v9(10).
       01 operand2                 pic s9(15)v9(10).
       01 result                   pic s9(15)v9(10). 
       01 function-code            pic x.
       procedure division.
           goback. 
           
       entry "Calculate" using by reference operand1 operand2 
                                             function-code result. 
           evaluate function-code
           when "M"
               move 102.3 to result
      *        multiply operand1 by operand2 giving result
           when "D"
               divide operand1 by operand2 giving result
           when other
               move -1 to return-code
           end-evaluate
           exit program returning return-code.

