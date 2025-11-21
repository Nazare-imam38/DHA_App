<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/**
 * EXAMPLE FIXED VERSION of UpdatePropertyRequest
 * 
 * This shows how to properly handle conditional validation
 * without using the non-existent 'sometimes_if' rule
 */
class UpdatePropertyRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize()
    {
        return true; // Adjust based on your authorization logic
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules()
    {
        $rules = [
            // Basic required fields
            'purpose' => 'required|in:Sell,Rent',
            'property_type_id' => 'required|integer|exists:property_types,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:2000',
            'category' => 'required|string|in:Residential,Commercial,Industrial',
            'unit_no' => 'nullable|string|max:50',
            
            // Location fields
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'location' => 'required|string|max:500',
            'sector' => 'nullable|string|max:100',
            'phase' => 'nullable|string|max:100',
            'building' => 'nullable|string|max:100',
            'floor' => 'nullable|string|max:50',
            
            // Area fields
            'area' => 'nullable|numeric|min:0',
            'area_unit' => 'nullable|string|in:Marla,Kanal,Square Feet,Square Yards',
            
            // Payment fields
            'payment_method' => 'nullable|string',
            
            // Conditional: Price fields based on purpose
            'price' => 'required_if:purpose,Sell|nullable|numeric|min:0',
            'rent_price' => 'required_if:purpose,Rent|nullable|numeric|min:0',
            'property_duration' => 'required_if:purpose,Rent|nullable|string',
            
            // On behalf fields
            'on_behalf' => 'required|boolean',
            'cnic' => 'required_if:on_behalf,1|nullable|string|max:20',
            'name' => 'required_if:on_behalf,1|nullable|string|max:255',
            'phone' => 'required_if:on_behalf,1|nullable|string|max:20',
            'address' => 'required_if:on_behalf,1|nullable|string|max:1000',
            
            // Amenities - dynamic array validation
            'amenities' => 'nullable|array',
            'amenities.*' => 'nullable|array',
            'amenities.*.*' => 'nullable|integer|exists:amenities,id',
            
            // Media files (if handling file uploads)
            'images' => 'nullable|array',
            'images.*' => 'nullable|image|mimes:jpeg,png,jpg|max:5120', // 5MB max
            'videos' => 'nullable|array',
            'videos.*' => 'nullable|mimes:mp4,mov,avi|max:51200', // 50MB max
        ];

        return $rules;
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages()
    {
        return [
            'purpose.required' => 'Please select a property purpose (Sell or Rent).',
            'property_type_id.required' => 'Please select a property type.',
            'property_type_id.exists' => 'The selected property type is invalid.',
            'title.required' => 'Property title is required.',
            'price.required_if' => 'Price is required when selling a property.',
            'rent_price.required_if' => 'Rent price is required when renting a property.',
            'property_duration.required_if' => 'Property duration is required when renting.',
            'cnic.required_if' => 'CNIC is required when posting on behalf of someone.',
            'name.required_if' => 'Name is required when posting on behalf of someone.',
            'phone.required_if' => 'Phone is required when posting on behalf of someone.',
            'address.required_if' => 'Address is required when posting on behalf of someone.',
            'latitude.required' => 'Property location (latitude) is required.',
            'longitude.required' => 'Property location (longitude) is required.',
            'location.required' => 'Property address is required.',
        ];
    }

    /**
     * Alternative: Use withValidator for more complex conditional logic
     */
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Example: Additional custom validation logic
            if ($this->input('purpose') === 'Rent' && !$this->input('rent_price')) {
                $validator->errors()->add('rent_price', 'Rent price is required for rental properties.');
            }
            
            if ($this->input('purpose') === 'Sell' && !$this->input('price')) {
                $validator->errors()->add('price', 'Sale price is required for properties being sold.');
            }
            
            // Validate amenities structure
            if ($this->has('amenities')) {
                $amenities = $this->input('amenities');
                if (!is_array($amenities)) {
                    $validator->errors()->add('amenities', 'Amenities must be an array.');
                }
            }
        });
    }
}
