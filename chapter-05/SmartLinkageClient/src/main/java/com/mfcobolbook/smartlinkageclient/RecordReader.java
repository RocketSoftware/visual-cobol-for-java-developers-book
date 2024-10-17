/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 
package com.mfcobolbook.smartlinkageclient;

import com.mfcobolbook.businessrules.AccountStorageAccess;
import com.mfcobolbook.businessrules.CustomerRecord;
import com.mfcobolbook.businessrules.Status;

public class RecordReader
{
    public static void main(String[] args)
    {
        AccountStorageAccess access = new AccountStorageAccess();
        Status s = new Status();
        
        access.OPEN_CUSTOMER_FILE("R", s);
        if (s.getStatus().equals("00"))
        {
            CustomerRecord record = new CustomerRecord();
            record.setCustomerId(0);
            access.READ_CUSTOMER_RECORD("S", record, s); 
            while (s.getStatus().equals("00"))
            {
                access.READ_CUSTOMER_RECORD("N", record, s);
                if (s.getStatus().equals("00"))
                {
                    System.out.println(
                            String.format("Customer Record %d %s %s", 
                                    record.getCustomerId(), 
                                    record.getFirstName(), 
                                    record.getLastName()));
                }
            }
            access.OPEN_CUSTOMER_FILE("C",s);
        }
        else
        {
            System.out.println(
            		String.format("Could not open file, %s",
                                              s.getStatus())); 
        }
    }
}
