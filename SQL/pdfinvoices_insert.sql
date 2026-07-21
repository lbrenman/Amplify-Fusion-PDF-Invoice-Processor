INSERT INTO public.pdfinvoices (
    invoice_number
  , invoice_type
  , purchase_order_number
  , issue_date
  , due_date
  , currency
  , seller_name
  , seller_tax_id
  , seller_email
  , seller_phone
  , seller_city
  , seller_state
  , seller_postal_code
  , seller_country_code
  , buyer_name
  , buyer_tax_id
  , buyer_email
  , buyer_city
  , buyer_state
  , buyer_postal_code
  , buyer_country_code
  , subtotal
  , total_charges
  , total_tax
  , grand_total
  , prior_balance
  , amount_paid
  , total_due
  , line_items
  , charges
  , raw_json
  , raw_text
  , source_filename
  , model
) VALUES (
    NULLIF(:invoiceNumber, '')
  , COALESCE(NULLIF(:invoiceType, ''), 'invoice')
  , NULLIF(:purchaseOrderNumber, '')
  , CAST(NULLIF(:issueDate, '') AS date)
  , CAST(NULLIF(:dueDate, '') AS date)
  , NULLIF(:currency, '')
  , NULLIF(:sellerName, '')
  , NULLIF(:sellerTaxId, '')
  , NULLIF(:sellerEmail, '')
  , NULLIF(:sellerPhone, '')
  , NULLIF(:sellerCity, '')
  , NULLIF(:sellerState, '')
  , NULLIF(:sellerPostalCode, '')
  , NULLIF(:sellerCountryCode, '')
  , NULLIF(:buyerName, '')
  , NULLIF(:buyerTaxId, '')
  , NULLIF(:buyerEmail, '')
  , NULLIF(:buyerCity, '')
  , NULLIF(:buyerState, '')
  , NULLIF(:buyerPostalCode, '')
  , NULLIF(:buyerCountryCode, '')
  , CAST(:subtotal     AS numeric)
  , CAST(:totalCharges AS numeric)
  , CAST(:totalTax     AS numeric)
  , CAST(:grandTotal   AS numeric)
  , CAST(:priorBalance AS numeric)
  , CAST(:amountPaid   AS numeric)
  , CAST(:totalDue     AS numeric)
  , COALESCE(CAST(:rawJson AS jsonb) -> 'lineItems', CAST('[]' AS jsonb))
  , COALESCE(CAST(:rawJson AS jsonb) -> 'charges',   CAST('[]' AS jsonb))
  , CAST(:rawJson AS jsonb)
  , NULLIF(:rawText, '')
  , NULLIF(:sourceFilename, '')
  , NULLIF(:model, '')
);