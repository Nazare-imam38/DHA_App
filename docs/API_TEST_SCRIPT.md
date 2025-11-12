# API Test Script

## Test API Endpoint
**URL**: `https://testingbackend.dhamarketplace.com/api/create/property`
**Method**: POST (Multipart)
**Token**: `eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMmExZC0xMjEyLTczZGYtODE5OS1iMmM5MGM1NmE4NDIiLCJqdGkiOiI4YTA5Y2U4ODQxNWM4NGI3YjEyOTUwMTY2Y2UzOTU2NzFhMzc0ZWY3NTQ5ZmUzYWFmNjZkZTA2MzIzYWI4YzNiM2VlMmU5ZGE4NTBhYTdmOSIsImlhdCI6MTc2MTc2MzgxMi45ODY3NzgsIm5iZiI6MTc2MTc2MzgxMi45ODY3ODIsImV4cCI6MTc5MzI5OTgxMi45NzY2NjEsInN1YiI6IjE5Iiwic2NvcGVzIjpbXX0.D6quu21hk5sEe17frN6um0a30i7VLZMQmE6BERb_dxkRw5aCNSx33ek5uY7pF0eMnUE2owk__-LwCR7O1A1ezVIq68LF81t_04iKj5ZES4LPT1t8SRqhk1bqfZYpT1_WqpPcavoALGOw1UZyxLn3U8iRgcI7cNZgJmtH0vOjX8k4airq__BcI9UvLjVXW4p44LzYuBjNL0GfLpR0s81TkncYltpDK7TWYCqM7q5bb9fxDjk1zu9UHPBXoYYN74k0WeqCHUKCr9fQhABIcvZzmOW7R8BQvBf-XDVm_tYu8YOxUz_HaFSN6f_JuhduqpRUaIRXZAS1G37ZOa5g-Uwz41azYkjgMw3vdEfiu5JwrSpfAiVBXo7DDyzfTflfltF77y6-JOT2vfb44bKY7UF655NTx7-YltrIgZVkKU9LIg3dtCi1TCT8s3e0N6AmRs444DS6z_lPEl4OJw7lVDFMTQy5IGEAuVF44A5Ce87Pr68UIJNvwqkWL2yGMVLyoocC7XGYBEBfH9QIPu2gprlRJ8Yb4A4qXpcW2oRApCRQzM71DvEx4uF-IFCZZCSVAu7p3v3c8hehq8hG__Mc1vPAuGghAVsIeqoViOogB1BmkplYLsWQB6rb73ECpHADf8ti5ThV3n1KPgkvCNjGJVbYjPaHwtC2XMnXoSuPUysFlno`

## Required Fields for Owner Details (on_behalf = 1)
```json
{
  "on_behalf": "1",
  "cnic": "3840392735407",
  "name": "John Doe", 
  "phone": "+923035523964",
  "address": "123 Main Street, Karachi",
  "email": "john@example.com"
}
```

## Complete API Payload Structure
```json
{
  "title": "Beautiful House",
  "description": "A beautiful house with modern amenities",
  "purpose": "Sell",
  "category": "Residential", 
  "property_type_id": "1",
  "property_subtype_id": "1",
  "property_duration": "30 Days",
  "price": "5000000",
  "is_rent": "0",
  "location": "House 123, Street 5, Sector A, Phase 2, DHA Karachi",
  "latitude": "24.8607",
  "longitude": "67.0011",
  "building": "Building A",
  "floor": "Ground Floor", 
  "apartment_number": "A-101",
  "area": "5",
  "area_unit": "Marla",
  "phase": "Phase 2",
  "sector": "Sector A", 
  "street_number": "Street 5",
  "unit_no": "A-101",
  "payment_method": "Cash",
  "amenities": ["1", "2", "3"],
  "on_behalf": "1",
  "cnic": "3840392735407",
  "name": "John Doe",
  "phone": "+923035523964", 
  "address": "123 Main Street, Karachi",
  "email": "john@example.com",
  "images[]": [file1, file2],
  "videos[]": [video1]
}
```