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
