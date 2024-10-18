      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       program-id. Program1 as "procedureDivision.Program1".

       procedure division.
         perform thefirst
         perform thesecond
         goback
      *    You must terminate the previous sentence with a period before
      *    starting a new section. 
             .
         
       thefirst section.
         display "thefirst"
          perform onea
          exit section. 
          
      *    Paragraph onea
           onea.
           display "one A". 
       
       thesecond section. 
         display "thesecond" 
           exit section
        .
