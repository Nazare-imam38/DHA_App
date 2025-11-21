# Property Update API - Critical Fix Required

## 🔴 Issue
Property update endpoint is returning 500 error: `Method validateSometimesIf does not exist`

## 📍 What's Wrong
The validation rules use `sometimes_if` which **is not a valid Laravel validation rule**.

## ✅ Quick Fix

### Find the file:
```bash
cd /var/www/html/dha-marketplace-backend
grep -rn "sometimes_if" app/
```

### Replace this pattern:
```php
// ❌ WRONG
'rent_price' => 'sometimes_if:purpose,Rent|required'

// ✅ CORRECT
'rent_price' => 'required_if:purpose,Rent|nullable|numeric|min:0'
```

### Common replacements needed:
```php
// For Rent vs Sell
'price' => 'required_if:purpose,Sell|nullable|numeric|min:0',
'rent_price' => 'required_if:purpose,Rent|nullable|numeric|min:0',
'property_duration' => 'required_if:purpose,Rent|nullable|string',

// For on_behalf fields
'cnic' => 'required_if:on_behalf,1|nullable|string|max:20',
'name' => 'required_if:on_behalf,1|nullable|string|max:255',
'phone' => 'required_if:on_behalf,1|nullable|string',
'address' => 'required_if:on_behalf,1|nullable|string|max:1000',
```

### After fixing:
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

## 📄 Reference Files
- `BACKEND_FIX_REQUIRED.md` - Detailed explanation
- `UpdatePropertyRequest_FIXED_EXAMPLE.php` - Complete working example
- `backend_fix_commands.sh` - Helper commands

## ⏱️ Priority
**CRITICAL** - Blocking property updates in production

## 📞 Questions?
Check Laravel docs: https://laravel.com/docs/validation#rule-required-if
