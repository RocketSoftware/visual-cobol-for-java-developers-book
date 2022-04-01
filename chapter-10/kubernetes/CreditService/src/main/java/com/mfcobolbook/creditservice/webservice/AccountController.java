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
import com.mfcobolbook.businessinterop.AccountDataAccess;
import com.mfcobolbook.businessinterop.AccountDto;
import com.mfcobolbook.creditservice.forms.AccountForm;
import com.microfocus.cobol.runtimeservices.generic.RunUnit;

@RestController
@RequestMapping("/service/account")
public class AccountController {
    @GetMapping
    public ArrayWrapper<AccountForm> accounts() {
        List<AccountForm> accountList = new ArrayList<>();
        try (RunUnit<AccountDataAccess> ru = new RunUnit<>(
                AccountDataAccess.class)) {
            try (AccountDataAccess accessor = (AccountDataAccess) ru
                    .GetInstance(AccountDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.read);
                for (AccountDto next : accessor.getAccounts()) {
                    accountList.add(new AccountForm(next));
                }
            }
        }
        return new ArrayWrapper<>(accountList);
    }

    @GetMapping(value = "/{id}")
    public AccountForm getAccount(@PathVariable("id") int id)
            throws ResourceNotFoundException {
        try (RunUnit<AccountDataAccess> ru = new RunUnit<>(
                AccountDataAccess.class)) {
            try (AccountDataAccess accessor = (AccountDataAccess) ru
                    .GetInstance(AccountDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.read);
                AccountDto dto = accessor.getAccount(id);
                if (dto != null) {
                    return new AccountForm(dto);
                } else {
                    throw new ResourceNotFoundException(
                     String.format("Could not find record %d", id));
                }
            }
        }
    }

    @PostMapping
    public ResponseEntity<AccountForm> addAccount(
            @RequestBody AccountForm account) {
        try (RunUnit<AccountDataAccess> ru = new RunUnit<>(
                AccountDataAccess.class)) {
            try (AccountDataAccess accessor = (AccountDataAccess) ru
                    .GetInstance(AccountDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.rw);
                AccountDto dto = account.createAccountDto();
                int id = accessor.addAccount(dto);
                account.setId(id);
                return ResponseEntity.ok(account);
            }
        }
    }

    @DeleteMapping(value = "/{id}")
    public ResponseEntity<?> deleteAccount(@PathVariable("id") 
                                            int id)
            throws ResourceNotFoundException {
        HttpStatus status = null;
        try (RunUnit<AccountDataAccess> ru = new RunUnit<>(
                AccountDataAccess.class)) {
            try (AccountDataAccess accessor = (AccountDataAccess) ru
                    .GetInstance(AccountDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.rw);
                status = accessor.deleteAccount(id)
                        ? HttpStatus.NO_CONTENT
                        : HttpStatus.NOT_FOUND;
            }
        }
        return new ResponseEntity<String>(status);
    }

    @PutMapping
    public ResponseEntity<String> updateAccount(
            @RequestBody AccountForm account) {
        try (RunUnit<AccountDataAccess> ru = new RunUnit<>(
                AccountDataAccess.class)) {
            try (AccountDataAccess accessor = 
                    (AccountDataAccess) ru.GetInstance(
                            AccountDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.rw);
                AccountDto dto = account.createAccountDto();
                HttpStatus status = accessor.updateAccount(dto)
                        ? HttpStatus.NO_CONTENT
                        : HttpStatus.NOT_FOUND;
                return new ResponseEntity<>(status);
            }
        }
    }
}
