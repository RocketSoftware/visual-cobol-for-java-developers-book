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
 
package com.mfcobolbook.creditservice.forms;

import java.math.BigDecimal;

import com.mfcobolbook.businessinterop.AccountDto;

public class AccountForm {
    private int id ; 
    private int customerId ; 
    private BigDecimal balance ; 
    private byte type ; 
    private BigDecimal creditLimit ; 
    
    public AccountForm() {}
    public AccountForm(AccountDto accountDto) {
        id = accountDto.getAccountId();
        customerId = accountDto.getCustomerId();
        balance = accountDto.getBalance(); 
        type = accountDto.getType(); 
        creditLimit = accountDto.getCreditLimit();         
    }
    
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public int getCustomerId() {
        return customerId;
    }
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    public BigDecimal getBalance() {
        return balance;
    }
    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }
    public byte getType() {
        return type;
    }
    public void setType(byte type) {
        this.type = type;
    }
    public BigDecimal getCreditLimit() {
        return creditLimit;
    }
    public void setCreditLimit(BigDecimal creditLimit) {
        this.creditLimit = creditLimit;
    }
    
    public AccountDto createAccountDto() {
        return new AccountDto(id, customerId, balance, type, creditLimit) ; 
    }
}
