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
import com.mfcobolbook.businessinterop.CustomerDataAccess;
import com.mfcobolbook.businessinterop.CustomerDto;
import com.mfcobolbook.creditservice.forms.CustomerForm;
import com.microfocus.cobol.runtimeservices.generic.RunUnit;

@RestController
@RequestMapping("/service/customer")
public class CustomerController {
    

    
    
    
    @GetMapping
    public ArrayWrapper<CustomerForm> customers() {
        List<CustomerForm> customerList = new ArrayList<>();
        try (RunUnit<CustomerDataAccess> ru = new RunUnit<>(
                CustomerDataAccess.class)) {
            try (CustomerDataAccess accessor = (CustomerDataAccess) ru
                    .GetInstance(CustomerDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.read);
                for (CustomerDto next : accessor.getCustomers()) {
                    customerList.add(new CustomerForm(next));
                }
            }
        }
        return new ArrayWrapper<>(customerList);
    }

    @GetMapping(value = "/{id}")
    public CustomerForm getCustomer(@PathVariable("id") int id)
            throws ResourceNotFoundException {
        try (RunUnit<CustomerDataAccess> ru = new RunUnit<>(
                CustomerDataAccess.class)) {
            try (CustomerDataAccess accessor = (CustomerDataAccess) ru
                    .GetInstance(CustomerDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.read);
                CustomerDto dto = accessor.getCustomer(id);
                if (dto != null) {
                    return new CustomerForm(dto);
                } else {
                    throw new ResourceNotFoundException(
                            String.format("Could not find record %d", id));
                }
            }
        }
    }

    @PostMapping
    public ResponseEntity<CustomerForm> addCustomer(
            @RequestBody CustomerForm customer) {
        if (customer.getFirstName() == null || customer.getLastName() ==null)
            return ResponseEntity.badRequest().build(); 
        
        try (RunUnit<CustomerDataAccess> ru = new RunUnit<>(
                CustomerDataAccess.class)) {
            try (CustomerDataAccess accessor = (CustomerDataAccess) ru
                    .GetInstance(CustomerDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.rw);
                CustomerDto dto = customer.createCustomerDto();
                int id = accessor.addCustomer(dto);
                customer.setId(id);
                return ResponseEntity.ok(customer);
            }
        }
    }

    @DeleteMapping(value = "/{id}")
    public ResponseEntity<?> deleteCustomer(@PathVariable("id") int id)
            throws ResourceNotFoundException {
        HttpStatus status = null;
        try (RunUnit<CustomerDataAccess> ru = new RunUnit<>(
                CustomerDataAccess.class)) {
            try (CustomerDataAccess accessor = (CustomerDataAccess) ru
                    .GetInstance(CustomerDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.write);
                status = accessor.deleteCustomer(id)
                        ? HttpStatus.NO_CONTENT
                        : HttpStatus.NOT_FOUND;
            }
        }
        return new ResponseEntity<String>(status);
    }

    @PutMapping
    public ResponseEntity<String> updateCustomer(
            @RequestBody CustomerForm customer) {
        try (RunUnit<CustomerDataAccess> ru = new RunUnit<>(
                CustomerDataAccess.class)) {
            try (CustomerDataAccess accessor = 
                    (CustomerDataAccess) ru.GetInstance(
                            CustomerDataAccess.class, true)) {
                accessor.open(AbstractBusinessAccess .OpenMode.rw);
                CustomerDto dto = customer.createCustomerDto();
                HttpStatus status = accessor.updateCustomer(dto)
                        ? HttpStatus.NO_CONTENT
                        : HttpStatus.NOT_FOUND;
                return new ResponseEntity<>(status);
            }
        }
    }

}
