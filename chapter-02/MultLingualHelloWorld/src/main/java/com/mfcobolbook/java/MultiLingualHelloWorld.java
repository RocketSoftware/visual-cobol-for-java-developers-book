/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 

package com.mfcobolbook.java;

import com.mfcobolbook.examples.SalutationStore;

public class MultiLingualHelloWorld
{
	public static void main(String[] args)
	{
		SalutationStore store = new SalutationStore(); 
		System.out.println(store.fetchGreeting("English"));
		System.out.println(store.fetchGreeting("French"));
		System.out.println(store.fetchGreeting("German"));
		System.out.println(store.fetchGreeting("Italian"));
	}
}
