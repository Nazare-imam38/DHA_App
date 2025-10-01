"use client"

import { useState, useRef, useEffect } from "react"
import { useRouter } from "next/navigation"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { useAuth } from "@/hooks/use-auth"
import { Upload, FileSpreadsheet, CheckCircle, AlertTriangle, Download, Trash2, Eye, Sparkles, Star, Zap, Calendar } from "lucide-react"
import { importPlots } from "@/utils/api"
import { fetchEvents } from "@/utils/api";

export default function AddPlotPage() {
  const { role, isAuthenticated, isLoading } = useAuth()
  const router = useRouter()
  const fileInputRef = useRef(null)

  // CSV Upload state
  const [csvData, setCsvData] = useState([])
  const [csvFile, setCsvFile] = useState(null)
  const [isProcessing, setIsProcessing] = useState(false)
  const [uploadStatus, setUploadStatus] = useState(null) // 'success', 'error', null
  const [uploadMessage, setUploadMessage] = useState("")
  const [validationErrors, setValidationErrors] = useState([])
  const [previewMode, setPreviewMode] = useState(false)

  // Expected CSV headers - Updated to match new API requirements
  const expectedHeaders = [
    'gid', 'phase', 'sector', 'plot_no', 'category', 'street_no', 'type', 'subtype',
    'size', 'st_code', 'uid', 'far', 'zone', 'block', 'cat_area', 'dimension',
    'base_price', '1yr_plan', '2yrs_plan', '2_5yrs_pla', '3yrs_plan', 'l_sum_ep',
    '1yr_ep', '2yrs_ep', '2_5yrs_ep', '3yrs_ep', 'tokenprice', 'is_bidding', 'dis_yt', '1yr_dis_yt', '2yr_dis_yt', 'geom'
  ]

  const [events, setEvents] = useState([]);
  const [eventsLoading, setEventsLoading] = useState(true);
  const [eventsError, setEventsError] = useState("");
  const [selectedEventId, setSelectedEventId] = useState(null);
  const [importStats, setImportStats] = useState(null);

  useEffect(() => {
    async function loadEvents() {
      setEventsLoading(true);
      setEventsError("");
      try {
        const res = await fetchEvents();
        // Adjust if API response structure is different
        setEvents(res.data || res.events || []);
      } catch (e) {
        setEventsError(e.message || "Failed to fetch events");
      }
      setEventsLoading(false);
    }
    loadEvents();
  }, []);

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

  // Parse CSV file
  const parseCSV = (text) => {
    const lines = text.split('\n').filter(line => line.trim())
    if (lines.length === 0) return []

    const headers = lines[0].split(',').map(h => h.trim().replace(/"/g, ''))
    const rows = []

    for (let i = 1; i < lines.length; i++) {
      const values = lines[i].split(',').map(v => v.trim().replace(/"/g, ''))
      if (values.length === headers.length) {
        const row = {}
        headers.forEach((header, index) => {
          row[header] = values[index]
        })
        rows.push(row)
      }
    }

    return { headers, rows }
  }

  // Handle file upload
  const handleFileUpload = (event) => {
    const file = event.target.files[0]
    if (!file) return

    if (!file.name.endsWith('.csv')) {
      setUploadStatus('error')
      setUploadMessage('Please upload a CSV file only')
      return
    }

    setCsvFile(file)
    setIsProcessing(true)
    setUploadStatus(null)
    setUploadMessage("")
    setValidationErrors([])

    const reader = new FileReader()
    reader.onload = (e) => {
      try {
        const text = e.target.result
        const { headers, rows } = parseCSV(text)

        // Validate headers
        const missingHeaders = expectedHeaders.filter(h => !headers.includes(h))
        const extraHeaders = headers.filter(h => !expectedHeaders.includes(h))

        if (missingHeaders.length > 0) {
          setValidationErrors([`Missing required columns: ${missingHeaders.join(', ')}`])
          setUploadStatus('error')
          setUploadMessage('CSV format validation failed')
        } else {
          setCsvData(rows)
          setUploadStatus(null) // Don't show success for file parsing
          setUploadMessage("")
          setPreviewMode(true)
        }
      } catch (error) {
        setUploadStatus('error')
        setUploadMessage('Error parsing CSV file')
        setValidationErrors([error.message])
      } finally {
        setIsProcessing(false)
      }
    }

    reader.readAsText(file)
  }

  // Handle bulk upload to API
  const handleBulkUpload = async () => {
    if (csvData.length === 0 || !csvFile) return

    // Validate that an event is selected (null is valid for DHA MarketPlace inventory)
    if (selectedEventId === undefined) {
      setUploadStatus('error')
      setUploadMessage('Please select an event or DHA MarketPlace inventory before uploading plots')
      setValidationErrors(['You must select either an event or DHA MarketPlace inventory to associate with these plots'])
      return
    }

    setIsProcessing(true)
    setUploadStatus(null)
    setUploadMessage("")

    try {
      console.log('Starting bulk upload of CSV file:', csvFile.name)
      console.log('CSV contains', csvData.length, 'plots')
      console.log('Selected event ID:', selectedEventId)

      // Call the import plots API with the actual CSV file and event ID
      const response = await importPlots(csvFile, selectedEventId)

      console.log('Upload response:', response)

      // Handle successful response
      if (response.success === true || response.success === 'true') {
        setUploadStatus('success')

        // Create detailed success message using the new response structure
        let successMessage = response.message || 'Import completed successfully!'

        // Store detailed statistics for display
        const importStats = {
          total: csvData.length,
          imported: response.data?.imported || 0,
          failed: response.data?.failed || 0,
          failedRows: response.data?.failed_rows || [],
          importId: response.data?.import_id || null
        }

        // Set the message and stats for display
        setUploadMessage(successMessage)
        setImportStats(importStats)
      } else {
        // Handle case where response doesn't indicate success
        throw new Error(response.message || 'Upload completed but success status unclear')
      }

      // Scroll to top to show success message
      window.scrollTo({ top: 0, behavior: 'smooth' })

      // Don't auto-reset - let user choose their next action

    } catch (error) {
      console.error('Upload error:', error)
      setUploadStatus('error')
      setUploadMessage(error.message || 'Failed to upload plots. Please try again.')

      // If it's a validation error, try to extract specific errors
      if (error.message.includes('Validation Error')) {
        try {
          const errorObj = JSON.parse(error.message.replace('Validation Error: ', ''))
          if (typeof errorObj === 'object') {
            const errorMessages = Object.values(errorObj).flat()
            setValidationErrors(errorMessages)
          }
        } catch (parseError) {
          setValidationErrors([error.message])
        }
      }

      // Scroll to top to show error message
      window.scrollTo({ top: 0, behavior: 'smooth' })
    } finally {
      setIsProcessing(false)
    }
  }

  // Download sample CSV template
  const downloadTemplate = () => {
    const csvContent = expectedHeaders.join(',') + '\n' +
      'GID001,1,A,101,Residential,Street 1,Standard,Premium,5 Marla,ST001,UID001,2.5,Zone A,Block 1,125,25x50,5000000,5500000,6000000,6500000,7000000,4500000,4800000,5200000,5600000,6000000,1200000,500000,0,0,0,{}\n' +
      'GID002,2,B,102,Commercial,Street 2,Commercial,Standard,10 Marla,ST002,UID002,3.0,Zone B,Block 2,250,50x50,10000000,11000000,12000000,13000000,14000000,9000000,9500000,10500000,11500000,12500000,2500000,1000000,1,1,1,{}'

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    const url = URL.createObjectURL(blob)
    link.setAttribute('href', url)
    link.setAttribute('download', 'plot_template.csv')
    link.style.visibility = 'hidden'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  // Clear uploaded data
  const clearData = () => {
    setCsvData([])
    setCsvFile(null)
    setPreviewMode(false)
    setUploadStatus(null)
    setUploadMessage("")
    setValidationErrors([])
    setImportStats(null)
    if (fileInputRef.current) {
      fileInputRef.current.value = ""
    }
  }

  return (
    <div className="flex flex-col min-h-screen bg-gray-50">
      <DashboardHeader />

      <main className="flex-1 container py-8 max-w-6xl mx-auto">
        {/* Events List Section */}
        <div className="mb-8">
          <Card className="shadow-sm border">
            <CardHeader className="border-b bg-gray-50">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-[#12AE9E] rounded-lg flex items-center justify-center">
                  <Calendar className="h-4 w-4 text-white" />
                </div>
                <div>
                  <CardTitle className="text-lg">Select Event or Inventory Type</CardTitle>
                  <p className="text-sm text-gray-600">Choose an event or select DHA MarketPlace inventory</p>
                </div>
              </div>
            </CardHeader>
            <CardContent className="p-6">
              {/* DHA MarketPlace Inventory Option - Always Present */}
              <div className="mb-6 p-4 bg-gradient-to-r from-green-50 to-emerald-50 border-2 border-green-200 rounded-lg">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-gradient-to-r from-green-500 to-emerald-500 rounded-lg flex items-center justify-center">
                      <Star className="h-5 w-5 text-white" />
                    </div>
                    <div>
                      <h3 className="font-semibold text-green-800 flex items-center gap-2">
                        DHA MarketPlace Inventory
                        <Badge className="bg-green-100 text-green-800 text-xs">Default</Badge>
                      </h3>
                      <p className="text-sm text-green-600">General inventory not tied to any specific event</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {selectedEventId === null && (
                      <Badge className="bg-green-100 text-green-800 text-xs">Selected</Badge>
                    )}
                    <Button
                      onClick={() => setSelectedEventId(selectedEventId === null ? undefined : null)}
                      variant={selectedEventId === null ? "default" : "outline"}
                      size="sm"
                      className={selectedEventId === null ? "bg-green-600 hover:bg-green-700" : "border-green-300 text-green-700 hover:bg-green-50"}
                    >
                      {selectedEventId === null ? "Unselect" : "Select"}
                    </Button>
                  </div>
                </div>
              </div>

              {/* Events List */}
              {eventsLoading ? (
                <div className="text-gray-500">Loading events...</div>
              ) : eventsError ? (
                <div className="text-red-600">{eventsError}</div>
              ) : events.length === 0 ? (
                <div className="text-gray-500">No events found.</div>
              ) : (
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow className="bg-gray-50">
                        <TableHead className="w-12">#</TableHead>
                        <TableHead>Title</TableHead>
                        <TableHead>Start Date</TableHead>
                        <TableHead>End Date</TableHead>
                        <TableHead>Tag</TableHead>
                        <TableHead className="w-32">Action</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {events.map((event, idx) => (
                        <TableRow
                          key={event.id || idx}
                          className={`hover:bg-gray-50 ${selectedEventId === event.id ? 'bg-blue-50 border-l-4 border-l-blue-500' : ''}`}
                        >
                          <TableCell className="font-medium text-gray-500">{idx + 1}</TableCell>
                          <TableCell>
                            <div className="flex items-center gap-2">
                              {event.title}
                              {selectedEventId === event.id && (
                                <Badge className="bg-blue-100 text-blue-800 text-xs">Selected</Badge>
                              )}
                            </div>
                          </TableCell>
                          <TableCell>{event.start_date}</TableCell>
                          <TableCell>{event.end_date}</TableCell>
                          <TableCell>{event.tag}</TableCell>
                          <TableCell>
                            <Button
                              onClick={() => setSelectedEventId(selectedEventId === event.id ? undefined : event.id)}
                              variant={selectedEventId === event.id ? "default" : "outline"}
                              size="sm"
                              className={selectedEventId === event.id ? "bg-blue-600 hover:bg-blue-700" : ""}
                            >
                              {selectedEventId === event.id ? "Unselect" : "Select"}
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
        {/* Header Section */}
        <div className="mb-8">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 bg-[#1E3C90] rounded-lg flex items-center justify-center">
              <FileSpreadsheet className="h-5 w-5 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Bulk Plot Upload</h1>
              <p className="text-gray-600">Upload multiple plots using CSV file format</p>
            </div>
          </div>
        </div>

        {/* Status Messages */}
        {uploadStatus === 'success' && (
          <div className="mb-6 animate-in slide-in-from-top-2 duration-300">
            <div className="relative overflow-hidden bg-gradient-to-r from-green-50 via-emerald-50 to-teal-50 border-2 border-green-200 rounded-xl p-6 shadow-lg">
              {/* Animated background pattern */}
              <div className="absolute inset-0 bg-gradient-to-r from-green-100/20 via-emerald-100/20 to-teal-100/20 animate-pulse"></div>

              {/* Success content */}
              <div className="relative z-10">
                <div className="flex items-start gap-4">
                  {/* Animated success icon */}
                  <div className="flex-shrink-0">
                    <div className="w-12 h-12 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full flex items-center justify-center animate-pulse">
                      <CheckCircle className="h-6 w-6 text-white animate-bounce" />
                    </div>
                  </div>

                  {/* Success message content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-2">
                      <h3 className="text-lg font-bold text-green-800 flex items-center gap-2">
                        ✅ Import Completed!
                        <CheckCircle className="h-5 w-5 text-green-500 animate-pulse" />
                      </h3>
                    </div>

                    <p className="text-green-700 font-medium mb-3">
                      {uploadMessage}
                    </p>

                    {/* Import Statistics */}
                    {importStats && (
                      <div className="bg-white/60 rounded-lg p-4 border border-green-200 mb-3">
                        <h4 className="text-sm font-semibold text-green-800 mb-3 flex items-center gap-2">
                          <CheckCircle className="h-4 w-4" />
                          Import Statistics:
                        </h4>

                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-3">
                          <div className="text-center">
                            <div className="text-2xl font-bold text-blue-600">{importStats.total}</div>
                            <div className="text-xs text-gray-600">Total Rows</div>
                          </div>
                          <div className="text-center">
                            <div className="text-2xl font-bold text-green-600">{importStats.imported}</div>
                            <div className="text-xs text-gray-600">Imported</div>
                          </div>
                          <div className="text-center">
                            <div className="text-2xl font-bold text-red-600">{importStats.failed}</div>
                            <div className="text-xs text-gray-600">Failed</div>
                          </div>
                          <div className="text-center">
                            <div className="text-2xl font-bold text-purple-600">#{importStats.importId}</div>
                            <div className="text-xs text-gray-600">Import ID</div>
                          </div>
                        </div>

                        {/* Progress bar */}
                        <div className="w-full bg-gray-200 rounded-full h-2 mb-2">
                          <div
                            className="bg-green-500 h-2 rounded-full transition-all duration-500"
                            style={{ width: `${(importStats.imported / importStats.total) * 100}%` }}
                          ></div>
                        </div>
                        <div className="text-xs text-gray-600 text-center">
                          Success Rate: {((importStats.imported / importStats.total) * 100).toFixed(1)}%
                        </div>

                        {/* Failed rows details */}
                        {importStats.failed > 0 && importStats.failedRows.length > 0 && (
                          <div className="mt-3 p-3 bg-red-50 rounded-lg border border-red-200">
                            <h5 className="text-sm font-semibold text-red-800 mb-2">Failed Rows:</h5>
                            <div className="max-h-32 overflow-y-auto">
                              {importStats.failedRows.slice(0, 5).map((failedRow, index) => (
                                <div key={index} className="text-xs text-red-700 mb-1">
                                  Row {failedRow.row_number}: {failedRow.error || 'Unknown error'}
                                </div>
                              ))}
                              {importStats.failedRows.length > 5 && (
                                <div className="text-xs text-red-600 font-medium">
                                  ... and {importStats.failedRows.length - 5} more failed rows
                                </div>
                              )}
                            </div>
                          </div>
                        )}
                      </div>
                    )}

                    {/* Success stats */}
                    <div className="flex flex-wrap gap-3 mb-4">
                      <div className="flex items-center gap-2 bg-white/60 rounded-lg px-3 py-1.5 border border-green-200">
                        <CheckCircle className="h-4 w-4 text-green-500" />
                        <span className="text-sm font-medium text-green-800">
                          Import Complete
                        </span>
                      </div>

                      {csvFile && (
                        <div className="flex items-center gap-2 bg-white/60 rounded-lg px-3 py-1.5 border border-green-200">
                          <FileSpreadsheet className="h-4 w-4 text-blue-500" />
                          <span className="text-sm font-medium text-green-800">
                            File: {csvFile.name}
                          </span>
                        </div>
                      )}

                      {selectedEventId && (
                        <div className="flex items-center gap-2 bg-white/60 rounded-lg px-3 py-1.5 border border-green-200">
                          <Calendar className="h-4 w-4 text-purple-500" />
                          <span className="text-sm font-medium text-green-800">
                            Event: {events.find(e => e.id === selectedEventId)?.title || 'Selected'}
                          </span>
                        </div>
                      )}
                    </div>

                    {/* Action buttons */}
                    <div className="bg-white/80 rounded-lg p-4 border border-green-200">
                      <h5 className="text-sm font-semibold text-green-800 mb-3">What would you like to do next?</h5>
                      <div className="flex flex-col sm:flex-row gap-3">
                        <Button
                          onClick={clearData}
                          className="bg-blue-600 hover:bg-blue-700 text-white flex-1"
                        >
                          <Upload className="h-4 w-4 mr-2" />
                          Upload New Inventory
                        </Button>
                        <Button
                          onClick={() => window.location.reload()}
                          variant="outline"
                          className="border-green-300 text-green-700 hover:bg-green-50 flex-1"
                        >
                          <Zap className="h-4 w-4 mr-2" />
                          Refresh Page
                        </Button>
                        <Button
                          onClick={() => router.push('/dashboard')}
                          variant="outline"
                          className="border-gray-300 text-gray-700 hover:bg-gray-50 flex-1"
                        >
                          <Eye className="h-4 w-4 mr-2" />
                          Go to Dashboard
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Success elements */}
                <div className="absolute top-2 right-2 text-2xl animate-bounce">
                  ✅
                </div>
                <div className="absolute bottom-2 right-8 text-xl animate-pulse">
                  🎉
                </div>
              </div>
            </div>
          </div>
        )}

        {uploadStatus === 'error' && (
          <div className="mb-6 animate-in slide-in-from-top-2 duration-500">
            <div className="relative overflow-hidden bg-gradient-to-r from-red-50 via-rose-50 to-pink-50 border-2 border-red-200 rounded-xl p-6 shadow-lg">
              {/* Animated background pattern */}
              <div className="absolute inset-0 bg-gradient-to-r from-red-100/20 via-rose-100/20 to-pink-100/20 animate-pulse"></div>

              {/* Error content */}
              <div className="relative z-10">
                <div className="flex items-start gap-4">
                  {/* Animated error icon */}
                  <div className="flex-shrink-0">
                    <div className="w-12 h-12 bg-gradient-to-r from-red-500 to-rose-500 rounded-full flex items-center justify-center animate-pulse">
                      <AlertTriangle className="h-6 w-6 text-white animate-bounce" />
                    </div>
                  </div>

                  {/* Error message content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-2">
                      <h3 className="text-lg font-bold text-red-800 flex items-center gap-2">
                        ⚠️ Upload Failed!
                        <AlertTriangle className="h-5 w-5 text-red-500 animate-pulse" />
                      </h3>
                    </div>

                    <p className="text-red-700 font-medium mb-3">
                      {uploadMessage}
                    </p>

                    {/* Error details */}
                    {validationErrors.length > 0 && (
                      <div className="bg-white/60 rounded-lg p-4 border border-red-200 mb-3">
                        <h4 className="text-sm font-semibold text-red-800 mb-2 flex items-center gap-2">
                          <AlertTriangle className="h-4 w-4" />
                          Error Details:
                        </h4>
                        <ul className="space-y-1">
                          {validationErrors.map((error, index) => (
                            <li key={index} className="text-sm text-red-700 flex items-start gap-2">
                              <span className="text-red-500 mt-0.5">•</span>
                              <span>{error}</span>
                            </li>
                          ))}
                        </ul>
                      </div>
                    )}

                    {/* Error stats */}
                    <div className="flex flex-wrap gap-3">
                      <div className="flex items-center gap-2 bg-white/60 rounded-lg px-3 py-1.5 border border-red-200">
                        <AlertTriangle className="h-4 w-4 text-red-500" />
                        <span className="text-sm font-medium text-red-800">
                          Upload Failed
                        </span>
                      </div>

                      {csvFile && (
                        <div className="flex items-center gap-2 bg-white/60 rounded-lg px-3 py-1.5 border border-red-200">
                          <FileSpreadsheet className="h-4 w-4 text-blue-500" />
                          <span className="text-sm font-medium text-red-800">
                            File: {csvFile.name}
                          </span>
                        </div>
                      )}

                      <div className="flex items-center gap-2 bg-white/60 rounded-lg px-3 py-1.5 border border-red-200">
                        <Download className="h-4 w-4 text-green-500" />
                        <span className="text-sm font-medium text-red-800">
                          Try Template
                        </span>
                      </div>
                    </div>

                    {/* Action buttons */}
                    <div className="mt-4 flex flex-wrap gap-2">
                      <Button
                        onClick={downloadTemplate}
                        variant="outline"
                        size="sm"
                        className="border-red-300 text-red-700 hover:bg-red-50"
                      >
                        <Download className="h-4 w-4 mr-2" />
                        Download Template
                      </Button>
                      <Button
                        onClick={clearData}
                        variant="outline"
                        size="sm"
                        className="border-red-300 text-red-700 hover:bg-red-50"
                      >
                        <Trash2 className="h-4 w-4 mr-2" />
                        Clear & Retry
                      </Button>
                    </div>
                  </div>
                </div>

                {/* Warning elements */}
                <div className="absolute top-2 right-2 text-2xl animate-bounce">
                  ⚠️
                </div>
                <div className="absolute bottom-2 right-8 text-xl animate-pulse">
                  🔄
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Upload Section */}
        <div className="mb-8">
          <Card className="shadow-sm border">
            <CardHeader className="border-b bg-gray-50">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 bg-[#1E3C90] rounded-lg flex items-center justify-center">
                    <Upload className="h-4 w-4 text-white" />
                  </div>
                  <div>
                    <CardTitle className="text-lg">Upload CSV File</CardTitle>
                    <p className="text-sm text-gray-600">Select your plot data file</p>
                  </div>
                </div>
                <Button
                  onClick={downloadTemplate}
                  variant="outline"
                  size="sm"
                  className="hidden sm:flex"
                >
                  <Download className="h-4 w-4 mr-2" />
                  Download Template
                </Button>
              </div>
            </CardHeader>
            <CardContent className="p-6">
              <div className="space-y-4">
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-[#1E3C90] transition-colors">
                  <FileSpreadsheet className="h-16 w-16 text-gray-400 mx-auto mb-4" />
                  <p className="font-medium text-gray-700 mb-2">Drop your CSV file here</p>
                  <p className="text-sm text-gray-500 mb-6">or click to browse</p>
                  <input
                    ref={fileInputRef}
                    type="file"
                    accept=".csv"
                    onChange={handleFileUpload}
                    className="hidden"
                  />
                  <div className="flex flex-col sm:flex-row gap-3 justify-center items-center">
                    <Button
                      onClick={() => fileInputRef.current?.click()}
                      disabled={isProcessing}
                      className="bg-[#1E3C90] hover:bg-[#1a3480] text-white"
                    >
                      {isProcessing ? (
                        <>
                          <div className="animate-spin rounded-full h-4 w-4 border-t-2 border-b-2 border-white mr-2"></div>
                          Processing...
                        </>
                      ) : (
                        <>
                          <Upload className="h-4 w-4 mr-2" />
                          Choose CSV File
                        </>
                      )}
                    </Button>
                    <Button
                      onClick={downloadTemplate}
                      variant="outline"
                      className="sm:hidden"
                    >
                      <Download className="h-4 w-4 mr-2" />
                      Download Template
                    </Button>
                  </div>
                </div>

                {csvFile && (
                  <div className="bg-blue-50 rounded-lg p-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <FileSpreadsheet className="h-6 w-6 text-blue-600" />
                        <div>
                          <p className="font-medium text-blue-800">{csvFile.name}</p>
                          <p className="text-sm text-blue-600">{(csvFile.size / 1024).toFixed(2)} KB</p>
                        </div>
                      </div>
                      <Button
                        onClick={clearData}
                        variant="ghost"
                        size="sm"
                        className="text-red-600 hover:text-red-800"
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Data Preview Section */}
        {previewMode && csvData.length > 0 && (
          <div className="mb-8">
            <Card className="shadow-sm border">
              <CardHeader className="border-b bg-gray-50">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-[#12AE9E] rounded-lg flex items-center justify-center">
                      <Eye className="h-4 w-4 text-white" />
                    </div>
                    <div>
                      <CardTitle className="text-lg">Data Preview</CardTitle>
                      <p className="text-sm text-gray-600">{csvData.length} plots ready for upload</p>
                    </div>
                  </div>
                  <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3">
                    <div className="flex items-center gap-3">
                      <Badge className="bg-blue-100 text-blue-800">
                        {csvData.length} Entries
                      </Badge>
                      {selectedEventId && (
                        <Badge className="bg-green-100 text-green-800">
                          Event: {events.find(e => e.id === selectedEventId)?.title || 'Selected'}
                        </Badge>
                      )}
                    </div>
                    <Button
                      onClick={handleBulkUpload}

                      className={`${!selectedEventId ? 'bg-gray-400 ' : 'bg-[#12AE9E] hover:bg-[#0e9b8a]'} text-white`}
                    >
                      {isProcessing ? (
                        <>
                          <div className="animate-spin rounded-full h-4 w-4 border-t-2 border-b-2 border-white mr-2"></div>
                          Uploading...
                        </>
                      ) : (
                        <>
                          <Upload className="h-4 w-4 mr-2" />
                          Upload All Plots
                        </>
                      )}
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="p-0">
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow className="bg-gray-50">
                        <TableHead className="w-12">#</TableHead>
                        {expectedHeaders.map((header, index) => (
                          <TableHead key={index} className="min-w-[100px] text-xs font-semibold">
                            {header.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
                          </TableHead>
                        ))}
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {csvData.map((row, index) => (
                        <TableRow key={index} className="hover:bg-gray-50">
                          <TableCell className="font-medium text-gray-500">{index + 1}</TableCell>
                          {expectedHeaders.map((header, headerIndex) => (
                            <TableCell key={headerIndex} className="text-sm min-w-[100px]">
                              {header === 'category' ? (
                                <Badge
                                  variant="secondary"
                                  className={row[header] === 'Residential' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'}
                                >
                                  {row[header] || 'N/A'}
                                </Badge>
                              ) : header === 'status' ? (
                                <Badge
                                  variant="secondary"
                                  className={
                                    row[header] === 'available' ? 'bg-green-100 text-green-800' :
                                      row[header] === 'sold' ? 'bg-red-100 text-red-800' :
                                        'bg-yellow-100 text-yellow-800'
                                  }
                                >
                                  {row[header] || 'N/A'}
                                </Badge>
                              ) : header === 'phase' ? (
                                <Badge variant="outline" className="text-xs">
                                  Phase {row[header] || 'N/A'}
                                </Badge>
                              ) : header === 'base_price' || header === 'token_amoun' ? (
                                <span className="font-mono text-xs">
                                  {row[header] ? `PKR ${Number(row[header]).toLocaleString()}` : 'N/A'}
                                </span>
                              ) : header === 'geom' ? (
                                <span className="text-xs text-gray-500 max-w-[100px] truncate block">
                                  {row[header] ? 'GeoJSON Data' : 'N/A'}
                                </span>
                              ) : header === 'created_at' || header === 'updated_at' || header === 'expire_time' ? (
                                <span className="text-xs">
                                  {row[header] ? new Date(row[header]).toLocaleDateString() : 'N/A'}
                                </span>
                              ) : (
                                <span className={header === 'plot_no' ? 'font-medium' : ''}>
                                  {row[header] || 'N/A'}
                                </span>
                              )}
                            </TableCell>
                          ))}
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>

                </div>
              </CardContent>
            </Card>
          </div>
        )}


      </main>
    </div>
  )
}