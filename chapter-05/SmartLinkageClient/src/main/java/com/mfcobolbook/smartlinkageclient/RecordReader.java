/*****************************************************************
 *                                                               *
 * Copyright 2020-2023 Open Text. All Rights Reserved.           *
 * This software may be used, modified, and distributed          *
 * (provided this notice is included without modification)       *
 * solely for demonstration purposes with other                  *
 * Micro Focus software, and is otherwise subject to the EULA at *
 * https://www.microfocus.com/en-us/legal/software-licensing.    *
 *                                                               *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ALL IMPLIED             *
 * WARRANTIES, INCLUDING THE IMPLIED WARRANTIES OF               *
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,         *
 * SHALL NOT APPLY.                                              *
 * TO THE EXTENT PERMITTED BY LAW, IN NO EVENT WILL              *
 * MICRO FOCUS HAVE ANY LIABILITY WHATSOEVER IN CONNECTION       *
 * WITH THIS SOFTWARE.                                           *
 *                                                               *
 *****************************************************************/
 
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
