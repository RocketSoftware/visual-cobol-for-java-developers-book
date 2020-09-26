/****************************************************************************
 *
 *   Copyright (C) Micro Focus IP Development Limited  2012. 
 *   All rights reserved.
 *
 *   The software and information contained herein are proprietary to, and
 *   comprise valuable trade secrets of, Micro Focus IP Development Limited, 
 *   which intends to preserve as trade secrets such software and 
 *   information. This software is an unpublished copyright of Micro Focus  
 *   and may not be used, copied, transmitted, or stored in any manner.  
 *   This software and information or any other copies thereof may not be
 *   provided or otherwise made available to any other person.
 *   
 *   $Id: mf.cloud.codetemplates.xml 485282 2012-04-05 08:06:58Z pk $
 ****************************************************************************/

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
