//
//  BookCurrencyUnit.swift
//  apple-playground
//
//  Created by Hiroshi Kimura on 2026/07/24.
//
import Playgrounds
import Foundation

#Playground {
  let price = 1234.56

  _ = price.formatted(.currency(code: "JPY"))
  
  _ = price.formatted(
    .currency(code: "JPY")
    .presentation(.narrow)
  )
  
  _ = price.formatted(
    .currency(code: "JPY")
    .presentation(.fullName)
  )
  
  _ = price.formatted(
    .currency(code: "JPY")
    .presentation(.standard)
  )
  
  _ = price.formatted(
    .currency(code: "JPY")
    .presentation(.isoCode)
  )
      
  let attributed = price.formatted(
    .currency(code: "JPY")
      .attributed
  )
      
}
