# 🚨 URGENT: Backend Fix Required for Property Update API

## Issue Summary
The property update API (`POST /api/update/property/{id}`) is returning a 500 error due to an invalid Laravel validation rule.

**IMPORTANT**: The API works perfectly on web/Postman but fails in the mobile app. This is NOT an app issue - it's a backend validation bug that needs to be fixed on the server.

## Error Details
```
Method Illuminate\Validation\Validator::validateSometimesIf does not exist.
BadMethodCallException
```

**Location**: `/var/www/html/dha-marketplace-backend/vendor/laravel/framework/src/Illuminate/Validation/Validator.php:1681`

## Root Cause
The backend is using `sometimes_if` validation rule which **does not exist in Laravel**. This is causing the validation to fail before the update logic even runs.

## Required Fix (Backend Team Action)

### Step 1: Locate the Validation File
Find the file that contains validation rules for property updates:
```bash
cd /var/www/html/dha-marketplace-backend
grep -r "sometimes_if" app/
```

Likely location: `app/Http/Requests/UpdatePropertyRequest.php`

### Step 2: Replace Invalid Validation Rules

**BEFORE (Wrong):**
```php
'rent_price' => 'sometimes_if:purpose,Rent|required|numeric',
'price' => 'sometimes_if:purpose,Sell|required|numeric',
'cnic' => 'sometimes_if:on_behalf,1|required|string',
```

**AFTER (Correct):**
```php
'rent_price' => 'required_if:purpose,Rent|nullable|numeric|min:0',
'price' => 'required_if:purpose,Sell|nullable|numeric|min:0',
'property_duration' => 'required_if:purpose,Rent|nullable|string',
'cnic' => 'required_if:on_behalf,1|nullable|string|max:20',
'name' => 'required_if:on_behalf,1|nullable|string|max:255',
'phone' => 'required_if:on_behalf,1|nullable|string',
'address' => 'required_if:on_behalf,1|nullable|string|max:1000',
```

### Step 3: Alternative Approach (Dynamic Rules)

If you need more complex conditional logic, use the `rules()` method:

```php
public function rules()
{
    $rules = [
        'purpose' => 'required|in:Sell,Rent',
        'property_type_id' => 'required|integer|exists:property_types,id',
        'title' => 'required|string|max:255',
        'description' => 'nullable|string',
        'category' => 'required|string',
        'unit_no' => 'nullable|string|max:50',
        'latitude' => 'required|numeric',
        'longitude' => 'required|numeric',
        'location' => 'required|string|max:500',
        'sector' => 'nullable|string|max:100',
        'phase' => 'nullable|string|max:100',
        'payment_method' => 'nullable|string',
    ];

    // Conditional rules based on purpose
    if ($this->input('purpose') === 'Rent') {
        $rules['rent_price'] = 'required|numeric|min:0';
        $rules['property_duration'] = 'required|string';
        $rules['price'] = 'nullable|numeric';
    } else {
        $rules['price'] = 'required|numeric|min:0';
        $rules['rent_price'] = 'nullable|numeric';
        $rules['property_duration'] = 'nullable|string';
    }

    // Conditional rules based on on_behalf
    if ($this->input('on_behalf') == 1) {
        $rules['cnic'] = 'required|string|max:20';
        $rules['name'] = 'required|string|max:255';
        $rules['phone'] = 'required|string';
        $rules['address'] = 'required|string|max:1000';
    } else {
        $rules['cnic'] = 'nullable|string|max:20';
        $rules['name'] = 'nullable|string|max:255';
        $rules['phone'] = 'nullable|string';
        $rules['address'] = 'nullable|string|max:1000';
    }

    return $rules;
}
```

### Step 4: Test the Fix

After making changes, test with this payload:

```bash
curl -X POST https://marketplace-testingbackend.dhamarketplace.com/api/update/property/8 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "purpose=Rent" \
  -F "property_type_id=6" \
  -F "title=371 Phase 5" \
  -F "description=Corner Plot" \
  -F "category=Residential" \
  -F "unit_no=371" \
  -F "price=0" \
  -F "rent_price=25000000" \
  -F "latitude=33.53326" \
  -F "longitude=73.21193" \
  -F "location=371, Street 10" \
  -F "sector=5" \
  -F "phase=Phase 5" \
  -F "payment_method=KuickPay" \
  -F "property_duration=30 days" \
  -F "on_behalf=0" \
  -F "name=Shaf Haider" \
  -F "phone=+923136509721" \
  -F "amenities[6][1]=1" \
  -F "amenities[6][2]=2" \
  -F "amenities[6][3]=3"
```

## Valid Laravel Validation Rules

Use these instead of `sometimes_if`:
- `required_if:field,value` - Required if another field equals a value
- `required_unless:field,value` - Required unless another field equals a value
- `required_with:field` - Required if another field is present
- `required_without:field` - Required if another field is not present
- `sometimes` - Only validate if field is present
- `nullable` - Allow null values

## Reference
- Laravel Validation Docs: https://laravel.com/docs/10.x/validation#available-validation-rules
- Conditional Rules: https://laravel.com/docs/10.x/validation#conditionally-adding-rules

## Priority
**HIGH** - This is blocking property updates in production

## Status
- [ ] Backend team notified
- [ ] Validation rules fixed
- [ ] Tested on staging
- [ ] Deployed to production
- [ ] Frontend team notified of fix

---
**Created**: November 14, 2025
**Reported by**: Frontend Team
**Affects**: Property Update API (POST /api/update/property/{id})
