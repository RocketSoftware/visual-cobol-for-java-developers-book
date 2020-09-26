       class-id com.mfcobolbook.database.MainProgram public.
       COPY "DataMigrationEntryPoints.cpy". 

       method-id main(args as string occurs any) public static.
           if (size of (args) <> 1)
               display "Specify a destination folder"
           end-if
           call "DatabaseInitializer"
           
           call CREATE-TABLES 
           
           call BULK-COPY using "customer" "c:\temp\csvs\customer.csv"
           call BULK-COPY using "account"  "c:\temp\csvs\account.csv"
           call BULK-COPY using "transaction"  "c:\temp\csvs\transaction.csv"

       end method. 
       
       end class.
