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
