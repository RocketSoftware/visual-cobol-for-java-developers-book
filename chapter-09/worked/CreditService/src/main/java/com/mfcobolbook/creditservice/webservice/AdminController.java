/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 
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
