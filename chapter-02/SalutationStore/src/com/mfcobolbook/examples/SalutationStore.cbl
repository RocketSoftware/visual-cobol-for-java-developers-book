       class-id com.mfcobolbook.examples.SalutationStore public.

       01 greetingsDictionary          dictionary[string, string]. 
       
       method-id new.
           invoke initData() 
       end method. 
       
       method-id initData.
           create greetingsDictionary 
           write greetingsDictionary from "Hello World" key "english"
           write greetingsDictionary from "Bonjour le monde" key "french"
           write greetingsDictionary from "Hallo Welt" key "german"
       end method.
       
       method-id fetchGreeting(language as string) returning result as string.
           set language to language::toLowerCase()
           read greetingsDictionary into result key language
               invalid key
                   set result to "I don't speak this language" 
                   
                   
           end-read 
       end method. 
       
       end class.
