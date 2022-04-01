/*****************************************************************
 *                                                               *
 * Copyright (C) 2020-2022 Micro Focus. All Rights Reserved.     *
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

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mfcobolbook.businessinterop.AbstractBusinessAccess ;
import com.mfcobolbook.businessinterop.TransactionDataAccess;
import com.mfcobolbook.businessinterop.TransactionDto;
import com.mfcobolbook.businessinterop.AbstractBusinessAccess .OpenMode;
import com.mfcobolbook.creditservice.forms.TransactionForm;
import com.microfocus.cobol.runtimeservices.generic.RunUnit;

@RestController
@RequestMapping("/service/transaction")
public class TransactionController {
   
    private Log log = LogFactory.getLog(TransactionController.class); 

   @GetMapping(value = "/account/{id}")
    public ResponseEntity<ArrayWrapper<TransactionForm>> 
           transactionsForAccount(@PathVariable("id") int id) {
        final List<TransactionForm> transactionList = new ArrayList<>();
        try (TransactionDataAccess tda = new TransactionDataAccess()) {
            tda.open(OpenMode.read);
            tda.getTransactionsByAccount(id).forEach( (TransactionDto dto) -> 
              transactionList.add(new TransactionForm(dto)) ) ;
            }
        ArrayWrapper<TransactionForm> wrapper = 
                new ArrayWrapper<>(transactionList) ; 
       
        if (transactionList.size() == 0) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(wrapper);
        }
        else {
            return ResponseEntity.ok(wrapper); 
        }
        
    }

    @GetMapping(value = "/{id}")
    public TransactionForm getTransaction(@PathVariable("id") int id)
            throws ResourceNotFoundException {
        try (RunUnit<TransactionDataAccess> ru = new RunUnit<>(
                TransactionDataAccess.class)) {
            try (TransactionDataAccess accessor = (TransactionDataAccess) ru
                    .GetInstance(TransactionDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.read);
                TransactionDto dto = accessor.getTransaction(id);
                if (dto != null) {
                    return new TransactionForm(dto);
                } else {
                    throw new ResourceNotFoundException(
                            String.format("Could not find record %d", id));
                }
            }
        }
    }

    @PostMapping
    public ResponseEntity<TransactionForm> addTransaction(
            @RequestBody TransactionForm account) {
        try (RunUnit<TransactionDataAccess> ru = new RunUnit<>(
                TransactionDataAccess.class)) {
            try (TransactionDataAccess accessor = (TransactionDataAccess) ru
                    .GetInstance(TransactionDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.rw);
                TransactionDto dto = account.createTransactionDto();
                int id = accessor.addTransaction(dto);
                account.setId(id);
                return ResponseEntity.ok(account);
            }
        }
    }

    @DeleteMapping(value = "/{id}")
    public ResponseEntity<?> deleteTransaction(@PathVariable("id") int id)
            throws ResourceNotFoundException {
        HttpStatus status = null;
        try (RunUnit<TransactionDataAccess> ru = new RunUnit<>(
                TransactionDataAccess.class)) {
            try (TransactionDataAccess accessor = (TransactionDataAccess) ru
                    .GetInstance(TransactionDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.rw);
                status = accessor.deleteTransaction(id)
                        ? HttpStatus.NO_CONTENT
                        : HttpStatus.NOT_FOUND;
            }
        }
        return new ResponseEntity<String>(status);
    }

    @PutMapping
    public ResponseEntity<String> updateTransaction(
            @RequestBody TransactionForm account) {
        log.info("PUT method");
        try (RunUnit<TransactionDataAccess> ru = new RunUnit<>(
                TransactionDataAccess.class)) {
            try (TransactionDataAccess accessor = 
                    (TransactionDataAccess) ru.GetInstance(
                            TransactionDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.rw);
                TransactionDto dto = account.createTransactionDto();
                HttpStatus status = accessor.updateTransaction(dto)
                        ? HttpStatus.NO_CONTENT
                        : HttpStatus.NOT_FOUND;
                return new ResponseEntity<>(status);
            }
        }
    }
}
