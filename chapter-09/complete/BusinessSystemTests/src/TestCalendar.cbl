      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       copy "mfunit_prototypes.cpy".
       
       identification division.
       program-id. TestCalendar as "TestCalendar".

       environment division.
       configuration section.

       data division.
       working-storage section.
       copy "PROCEDURE-NAMES.cpy". 
       78 TEST-TestCalendar value "TestCalendar".
       copy "mfunit.cpy".
       copy "DATE.cpy" replacing ==(PREFIX)== by ==WS==.
       01 WS-RESULT                pic 99 comp-5. 
       procedure division.

       entry MFU-TC-PREFIX & TEST-TestCalendar.
           move "20180101" to WS-DATE
           call GET-DAYS-IN-MONTH using WS-DATE WS-RESULT 
           
           if WS-RESULT <> 31
               call MFU-ASSERT-FAIL-Z using z"Wrong number of days in January"
           end-if
           
           goback returning return-code
           .
           
       entry MFU-TC-PREFIX & TEST-TestCalendar & "_leap_year".
           move "20180201" to WS-DATE
           call GET-DAYS-IN-MONTH using WS-DATE WS-RESULT 
           display WS-RESULT
           if WS-RESULT <> 28
               call "MFU_ASSERT_FAIL_Z" using z"Wrong number of days in February"   
           end-if
           move "20160201" to WS-DATE
           call GET-DAYS-IN-MONTH using WS-DATE WS-RESULT 
           display WS-RESULT
           if WS-RESULT <> 29
               call "MFU_ASSERT_FAIL_Z" using z"Missing a leap day" 
           end-if
           
           move "19000201" to WS-DATE
           call GET-DAYS-IN-MONTH using WS-DATE WS-RESULT 
           display WS-RESULT
           if WS-RESULT <> 28
               call "MFU_ASSERT_FAIL_Z" using z"Added an erroneous leap day" 
           end-if
           
           move "20000201" to WS-DATE
           call GET-DAYS-IN-MONTH using WS-DATE WS-RESULT 
           display WS-RESULT
           if WS-RESULT <> 29
               call "MFU_ASSERT_FAIL_Z" using z"Missing leap day 2000" 
           end-if
           goback returning return-code
           .
           

      $region Test Configuration
       entry MFU-TC-SETUP-PREFIX & TEST-TestCalendar & "-leap-year".
           display "leap year set up" 
           call "Calendar" 
           goback returning 0.

       entry MFU-TC-SETUP-PREFIX & TEST-TestCalendar.
           display "standard setup" 
           call "Calendar" 
           goback returning 0.
      $end-region
