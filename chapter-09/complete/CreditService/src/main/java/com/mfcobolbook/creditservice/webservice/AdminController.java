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
 
package com.mfcobolbook.creditservice.webservice;

import java.io.IOException;
import java.io.InputStream;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mfcobolbook.database.DatabaseInitializerWrapper;

@RestController
@RequestMapping("/admin")
public class AdminController {

    @GetMapping("/initialize-db")
    public ResponseEntity<String> createTables()
            throws IOException {
        initSchema();
        populateTables(); 
        return ResponseEntity.ok("All tables initialized");
    }

    protected void initSchema() throws IOException {
        DatabaseInitializerWrapper databaseInitializerWrapper 
            = new DatabaseInitializerWrapper();
        databaseInitializerWrapper.dropAndCreateTables();

    }

    private void populateTables() throws IOException {
        DatabaseInitializerWrapper databaseInitializerWrapper 
            = new DatabaseInitializerWrapper();
        InputStream csvFile = getCsvStream("data/customer.csv");
        databaseInitializerWrapper.loadCustomerData(csvFile);
        csvFile = getCsvStream("data/account.csv");
        databaseInitializerWrapper.loadAccountData(csvFile);
        csvFile = getCsvStream("data/transaction.csv");
        databaseInitializerWrapper.loadTransactionData(csvFile);
    }

    private InputStream getCsvStream(String source) throws IOException {
        return AdminController.class.getClassLoader()
                .getResourceAsStream(source);
    }

}
