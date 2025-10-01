"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { useAuth } from "@/hooks/use-auth"
import { storeEvent } from "@/utils/api"
import {
    Calendar,
    CheckCircle,
    AlertTriangle,
    Save,
    ChevronDown
} from "lucide-react"

export default function AddEventPage() {
    const { role, isAuthenticated, isLoading } = useAuth()
    const router = useRouter()

    // Form state
    const [formData, setFormData] = useState({
        start_date: "",
        start_time: "",
        end_date: "",
        end_time: "",
        title: "",
        description: "",
        is_market_place: 0
    })

    // UI state
    const [isSubmitting, setIsSubmitting] = useState(false)
    const [submitStatus, setSubmitStatus] = useState(null) // 'success', 'error', null
    const [submitMessage, setSubmitMessage] = useState("")
    const [validationErrors, setValidationErrors] = useState({})

    // Check if user has admin access
    if (isLoading) {
        return (
            <div className="flex flex-col min-h-screen">
                <DashboardHeader />
                <div className="flex-1 container py-8 flex items-center justify-center">
                    <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary"></div>
                </div>
            </div>
        )
    }

    if (!isAuthenticated || role !== 2) {
        router.push("/dashboard")
        return null
    }

    // Helper function to handle time input changes
    const handleTimeChange = (e) => {
        const { name, value } = e.target
        setFormData(prev => ({ ...prev, [name]: value }))

        // Clear validation error when user changes time
        if (validationErrors[name.replace('_time', '_date')]) {
            setValidationErrors(prev => ({
                ...prev,
                [name.replace('_time', '_date')]: ""
            }))
        }
    }

    // Helper function to add 2 minutes to a time string (HH:MM format)
    const addMinutesToTime = (timeString) => {
        const [hours, minutes] = timeString.split(':').map(Number)
        const totalMinutes = hours * 60 + minutes + 2
        const newHours = Math.floor(totalMinutes / 60) % 24
        const newMinutes = totalMinutes % 60
        return newHours.toString().padStart(2, '0') + ':' + newMinutes.toString().padStart(2, '0')
    }

    // Handle form input changes
    const handleInputChange = (e) => {
        const { name, value, type } = e.target

        setFormData(prev => {
            const newData = {
                ...prev,
                [name]: type === 'radio' ? parseInt(value) : value
            }

            // Reset time when date changes
            if (name === 'start_date' && value !== prev.start_date) {
                newData.start_time = ""
            }
            if (name === 'end_date' && value !== prev.end_date) {
                newData.end_time = ""
            }

            return newData
        })

        // Clear validation error when user starts typing
        if (validationErrors[name]) {
            setValidationErrors(prev => ({
                ...prev,
                [name]: ""
            }))
        }
    }



    // Validate form data
    const validateForm = () => {
        const errors = {}

        // Title validation
        if (!formData.title.trim()) {
            errors.title = "Title is required"
        } else if (formData.title.trim().length < 3) {
            errors.title = "Title must be at least 3 characters"
        } else if (formData.title.trim().length > 255) {
            errors.title = "Title must not exceed 255 characters"
        }

        // Start date and time validation
        if (!formData.start_date || !formData.start_time) {
            errors.start_date = "Start date and time is required"
        }

        // End date and time validation
        if (!formData.end_date || !formData.end_time) {
            errors.end_date = "End date and time is required"
        } else if (formData.start_date && formData.start_time && formData.end_date && formData.end_time) {
            const startDateTime = new Date(`${formData.start_date} ${formData.start_time}:00`)
            const endDateTime = new Date(`${formData.end_date} ${formData.end_time}:00`)

            if (endDateTime <= startDateTime) {
                errors.end_date = "End date and time must be after start date and time"
            }
        }

        // Description validation (optional but has max length)
        if (formData.description && formData.description.length > 5000) {
            errors.description = "Description must not exceed 5000 characters"
        }



        return errors
    }

    // Handle form submission
    const handleSubmit = async (e) => {
        e.preventDefault()

        // Validate form
        const errors = validateForm()
        if (Object.keys(errors).length > 0) {
            setValidationErrors(errors)
            setSubmitStatus('error')
            setSubmitMessage('Please fix the validation errors below')
            return
        }

        setIsSubmitting(true)
        setSubmitStatus(null)
        setSubmitMessage("")
        setValidationErrors({})

        try {
            // Prepare event data for API
            const adjustedStartTime = addMinutesToTime(formData.start_time)
            const eventData = {
                start_date: `${formData.start_date} ${adjustedStartTime}:00`,
                end_date: `${formData.end_date} ${formData.end_time}:00`,
                title: formData.title.trim(),
                description: formData.description.trim() || null,
                is_market_place: formData.is_market_place
            }

            console.log('Creating event:', eventData)

            // Call the actual API endpoint
            const response = await storeEvent(eventData)

            console.log('Event created successfully:', response)

            // Handle successful response
            setSubmitStatus('success')
            setSubmitMessage('Event created successfully! Redirecting to admin dashboard...')

            // Reset form after successful submission
            setTimeout(() => {
                router.push('/admin')
            }, 2000)

        } catch (error) {
            console.error('Error creating event:', error)
            setSubmitStatus('error')

            // Handle API validation errors
            if (error.response && error.response.data && error.response.data.errors) {
                const apiErrors = error.response.data.errors
                const serverValidationErrors = {}

                // Map server errors to form fields
                Object.keys(apiErrors).forEach(field => {
                    if (Array.isArray(apiErrors[field])) {
                        serverValidationErrors[field] = apiErrors[field][0] // Take first error message
                    }
                })

                setValidationErrors(serverValidationErrors)
                setSubmitMessage(error.response.data.message || 'Please fix the validation errors below')
            } else if (error.message.includes('Validation Error')) {
                setSubmitMessage('Please check your input data and try again.')
            } else if (error.message.includes('Unauthorized')) {
                setSubmitMessage('Session expired. Please login again.')
            } else if (error.message.includes('Forbidden')) {
                setSubmitMessage('You do not have permission to create events.')
            } else {
                setSubmitMessage(error.message || 'Failed to create event. Please try again.')
            }
        } finally {
            setIsSubmitting(false)
        }
    }

    // Clear form
    const clearForm = () => {
        setFormData({
            start_date: "",
            start_time: "",
            end_date: "",
            end_time: "",
            title: "",
            description: "",
            is_market_place: 0
        })
        setValidationErrors({})
        setSubmitStatus(null)
        setSubmitMessage("")
    }

    return (
        <div className="flex flex-col min-h-screen bg-gray-50">
            <DashboardHeader />

            <main className="flex-1 container py-8 max-w-4xl mx-auto">
                {/* Header Section */}
                <div className="mb-8">
                    <div className="flex items-center gap-3 mb-4">
                        <div className="w-10 h-10 bg-[#1E3C90] rounded-lg flex items-center justify-center">
                            <Calendar className="h-5 w-5 text-white" />
                        </div>
                        <div>
                            <h1 className="text-2xl font-bold text-gray-900">Create New Event</h1>
                            <p className="text-gray-600">Add a new event to the DHA MarketPlace</p>
                        </div>
                    </div>
                </div>

                {/* Status Messages */}
                {submitStatus === 'success' && (
                    <div className="mb-6 animate-in slide-in-from-top-2 duration-300">
                        <Alert className="bg-green-50 border-green-200 border-l-4 border-l-green-500">
                            <CheckCircle className="h-5 w-5 text-green-600" />
                            <AlertDescription className="text-green-800">
                                <div className="flex items-start justify-between">
                                    <div>
                                        <h4 className="font-semibold mb-1">Event Created Successfully</h4>
                                        <p className="text-sm">{submitMessage}</p>
                                    </div>
                                    <CheckCircle className="h-6 w-6 text-green-500 flex-shrink-0" />
                                </div>
                            </AlertDescription>
                        </Alert>
                    </div>
                )}

                {submitStatus === 'error' && (
                    <div className="mb-6 animate-in slide-in-from-top-2 duration-500">
                        <Alert className="bg-red-50 border-red-200 border-l-4 border-l-red-500">
                            <AlertTriangle className="h-5 w-5 text-red-600" />
                            <AlertDescription className="text-red-800">
                                <div className="flex items-start justify-between">
                                    <div>
                                        <h4 className="font-semibold mb-1">Error Creating Event</h4>
                                        <p className="text-sm">{submitMessage}</p>
                                    </div>
                                    <AlertTriangle className="h-6 w-6 text-red-500 flex-shrink-0" />
                                </div>
                            </AlertDescription>
                        </Alert>
                    </div>
                )}

                {/* Event Form */}
                <form onSubmit={handleSubmit} className="space-y-6">
                    {/* Event Information */}
                    <Card className="shadow-sm border">
                        <CardHeader className="border-b bg-gray-50">
                            <CardTitle className="text-lg flex items-center gap-2">
                                <Calendar className="h-5 w-5" />
                                Event Information
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="p-6 space-y-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                {/* Title */}
                                <div className="md:col-span-2">
                                    <Label htmlFor="title">
                                        Event Title <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        id="title"
                                        name="title"
                                        value={formData.title}
                                        onChange={handleInputChange}
                                        placeholder="Enter event title (3-255 characters)"
                                        className={validationErrors.title ? "border-red-500" : ""}
                                        maxLength={255}
                                    />
                                    {validationErrors.title && (
                                        <p className="text-sm text-red-600 mt-1">{validationErrors.title}</p>
                                    )}
                                    <p className="text-xs text-gray-500 mt-1">
                                        {formData.title.length}/255 characters
                                    </p>
                                </div>

                                {/* Start Date and Time */}
                                <div>
                                    <Label htmlFor="start_date">
                                        Start Date & Time <span className="text-red-500">*</span>
                                    </Label>
                                    <div className="flex gap-2">
                                        <Input
                                            id="start_date"
                                            name="start_date"
                                            type="date"
                                            value={formData.start_date}
                                            onChange={handleInputChange}
                                            className={validationErrors.start_date ? "border-red-500" : "flex-1"}
                                            min={new Date().toISOString().split('T')[0]}
                                        />
                                        <Input
                                            id="start_time"
                                            name="start_time"
                                            type="time"
                                            value={formData.start_time}
                                            onChange={handleTimeChange}
                                            className={validationErrors.start_date ? "border-red-500" : "flex-1"}
                                            disabled={!formData.start_date}
                                        />
                                    </div>
                                    {validationErrors.start_date && (
                                        <p className="text-sm text-red-600 mt-1">{validationErrors.start_date}</p>
                                    )}
                                    <p className="text-xs text-gray-500 mt-1">
                                        Select date and time (24-hour format, Pakistani time). Start time will be automatically adjusted +2 minutes when submitted.
                                    </p>
                                </div>

                                {/* End Date and Time */}
                                <div>
                                    <Label htmlFor="end_date">
                                        End Date & Time <span className="text-red-500">*</span>
                                    </Label>
                                    <div className="flex gap-2">
                                        <Input
                                            id="end_date"
                                            name="end_date"
                                            type="date"
                                            value={formData.end_date}
                                            onChange={handleInputChange}
                                            className={validationErrors.end_date ? "border-red-500" : "flex-1"}
                                            min={formData.start_date || new Date().toISOString().split('T')[0]}
                                        />
                                        <Input
                                            id="end_time"
                                            name="end_time"
                                            type="time"
                                            value={formData.end_time}
                                            onChange={handleTimeChange}
                                            className={validationErrors.end_date ? "border-red-500" : "flex-1"}
                                            disabled={!formData.end_date}
                                        />
                                    </div>
                                    {validationErrors.end_date && (
                                        <p className="text-sm text-red-600 mt-1">{validationErrors.end_date}</p>
                                    )}
                                    <p className="text-xs text-gray-500 mt-1">
                                        Select date and time (24-hour format, Pakistani time). End time remains as selected.
                                    </p>
                                </div>

                                {/* Description */}
                                <div className="md:col-span-2">
                                    <Label htmlFor="description">
                                        Description <span className="text-gray-500">(Optional)</span>
                                    </Label>
                                    <Textarea
                                        id="description"
                                        name="description"
                                        value={formData.description}
                                        onChange={handleInputChange}
                                        placeholder="Enter event description (max 5000 characters)"
                                        rows={4}
                                        className={validationErrors.description ? "border-red-500" : ""}
                                        maxLength={5000}
                                    />
                                    {validationErrors.description && (
                                        <p className="text-sm text-red-600 mt-1">{validationErrors.description}</p>
                                    )}
                                    <p className="text-xs text-gray-500 mt-1">
                                        {formData.description.length}/5000 characters
                                    </p>
                                </div>

                                {/* Inventory Management */}
                                <div className="md:col-span-2">
                                    <Label className="text-base font-medium">
                                        Post-Event Inventory Management <span className="text-red-500">*</span>
                                    </Label>
                                    <p className="text-sm text-gray-600 mb-3">
                                        Choose what happens to the inventory after the event ends
                                    </p>
                                    <div className="space-y-3">
                                        <div className="flex items-start space-x-3">
                                            <input
                                                type="radio"
                                                id="delete_inventory"
                                                name="is_market_place"
                                                value={0}
                                                checked={formData.is_market_place === 0}
                                                onChange={handleInputChange}
                                                className="mt-1 h-4 w-4 text-[#1E3C90] focus:ring-[#1E3C90] border-gray-300"
                                            />
                                            <div className="flex-1">
                                                <Label htmlFor="delete_inventory" className="font-medium text-gray-900 cursor-pointer">
                                                    Delete Inventory After Event
                                                </Label>
                                                <p className="text-sm text-gray-600 mt-1">
                                                    All inventory items will be permanently removed once the event concludes
                                                </p>
                                            </div>
                                        </div>
                                        <div className="flex items-start space-x-3">
                                            <input
                                                type="radio"
                                                id="convert_marketplace"
                                                name="is_market_place"
                                                value={1}
                                                checked={formData.is_market_place === 1}
                                                onChange={handleInputChange}
                                                className="mt-1 h-4 w-4 text-[#1E3C90] focus:ring-[#1E3C90] border-gray-300"
                                            />
                                            <div className="flex-1">
                                                <Label htmlFor="convert_marketplace" className="font-medium text-gray-900 cursor-pointer">
                                                    Convert Inventory to MarketPlace
                                                </Label>
                                                <p className="text-sm text-gray-600 mt-1">
                                                    Inventory items will be moved to the general marketplace for continued sale
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </CardContent>
                    </Card>

                    {/* Action Buttons */}
                    <div className="flex flex-col sm:flex-row gap-4 justify-end">
                        <Button
                            type="button"
                            onClick={clearForm}
                            variant="outline"
                            disabled={isSubmitting}
                        >
                            Clear Form
                        </Button>
                        <Button
                            type="submit"
                            disabled={isSubmitting}
                            className="bg-[#1E3C90] hover:bg-[#1a3480] text-white"
                        >
                            {isSubmitting ? (
                                <>
                                    <div className="animate-spin rounded-full h-4 w-4 border-t-2 border-b-2 border-white mr-2"></div>
                                    Creating Event...
                                </>
                            ) : (
                                <>
                                    <Save className="h-4 w-4 mr-2" />
                                    Create Event
                                </>
                            )}
                        </Button>
                    </div>
                </form>
            </main>
        </div>
    )
}