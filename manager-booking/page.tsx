"use client"

import { useState, useEffect, useRef } from "react"
import { useRouter } from "next/navigation"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Filter, FileText, Loader2, Calendar, Building2 } from "lucide-react"
import { useAuth } from "@/hooks/use-auth"
import ManagerBookingForm from "@/components/manager/manager-booking-form"
import PlotSelectionList from "@/components/manager/plot-selection-list"
import { PLOT_ENDPOINTS, ADMIN_ENDPOINTS } from "@/config/api-config"
import { MARKETING_ENDPOINTS } from "../../config/api-config"

// Add category state
const CATEGORY_OPTIONS = ["Residential", "Commercial"];

export default function ManagerBookingPage() {
  const { isAuthenticated, isLoading: authLoading } = useAuth()
  const router = useRouter()
  const [isLoading, setIsLoading] = useState(true)
  const [isFilterLoading, setIsFilterLoading] = useState(false)
  const [isLoadingEvents, setIsLoadingEvents] = useState(true)
  const [events, setEvents] = useState([])
  const [selectedEvent, setSelectedEvent] = useState("")
  const [plots, setPlots] = useState([])
  const [filteredPlots, setFilteredPlots] = useState([])
  const [selectedPlot, setSelectedPlot] = useState(null)
  const [selectedPhase, setSelectedPhase] = useState("")
  const [selectedSize, setSelectedSize] = useState("")
  const [availableSizes, setAvailableSizes] = useState({})
  const [formData, setFormData] = useState({
    name: "",
    father_name: "",
    cnic: "",
    passportNo: "",
    mailingAddress: "",
    officePhone: "",
    residencePhone: "",
    phone: "",
    email: "",
    paymentPlan: "lumpSum", // lumpSum or installment
    installmentYears: "1",
    processingFee: true,
    totalAmount: "",
    tokenReceived: "",
    balanceDownPayment: "",
    totalBalancePayment: "",
    date: "",
    bank_name: "",
    cheque_no: "",
    cheque_date: "",
    heardFrom: "sms",
    is_filler: "1",
    plot_id: "",
  })
  const [formErrors, setFormErrors] = useState({})
  const [formSuccess, setFormSuccess] = useState("")
  const [activeTab, setActiveTab] = useState("filter")
  const printFormRef = useRef(null)
  const [apiError, setApiError] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("Residential")
  const [isInfluencerBooking, setIsInfluencerBooking] = useState(false)

  // Get auth token
  const getAuthToken = () => {
    if (typeof window !== "undefined") {
      return localStorage.getItem("token")
    }
    return null
  }

  // Load events from API
  const loadEvents = async () => {
    try {
      setIsLoadingEvents(true)
      setApiError("")

      const token = getAuthToken()
      if (!token) {
        throw new Error("Authentication token not found")
      }

      const response = await fetch(ADMIN_ENDPOINTS.LIST_EVENTS, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (!response.ok) {
        throw new Error("Failed to fetch events")
      }

      const data = await response.json()

      if (data.status === "success") {
        // Filter out expired events - only show active events
        const activeEvents = (data.events || []).filter(event =>
          event.status !== "Expired" && event.status !== "expired"
        )
        setEvents(activeEvents)
      } else {
        setApiError("Failed to load events")
      }
    } catch (error) {
      setApiError(error.message || "Failed to load events")
    } finally {
      setIsLoadingEvents(false)
    }
  }

  // Handle event selection
  const handleEventSelect = (eventId) => {
    setSelectedEvent(eventId)
    setSelectedPlot(null)
    setSelectedPhase("")
    setSelectedSize("")
    setFilteredPlots([])
    setAvailableSizes({})
  }

  // Load plots data based on phase
  const loadPlotsByPhase = async (phase) => {
    try {
      setIsFilterLoading(true)
      setApiError("")
      setSelectedSize(""); // Reset size when phase changes
      setFilteredPlots([]) // Clear plots when phase changes

      const token = getAuthToken()
      if (!token) {
        throw new Error("Authentication token not found")
      }

      // Build URL with event_id parameter if event is selected
      let url = `${PLOT_ENDPOINTS.FILTERED_PLOTS}?phase=${phase}&category=${selectedCategory}`
      if (selectedEvent && selectedEvent !== "dha-marketplace") {
        url += `&event_id=${selectedEvent}`
      }

      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (!response.ok) {
        throw new Error("Failed to fetch plots")
      }

      const data = await response.json()

      if (data.success) {
        // Store available sizes
        setAvailableSizes(data.data.counts.sizes || {})

        // If there are plots, set them
        if (data.data.plots && data.data.plots.length > 0) {
          setFilteredPlots(data.data.plots)
        } else {
          setFilteredPlots([])
        }
      } else {
        setApiError(data.message || "Failed to fetch plots")
        setFilteredPlots([])
        setAvailableSizes({})
      }
    } catch (error) {
      setApiError(error.message || "Failed to fetch plots")
      setFilteredPlots([])
      setAvailableSizes({})
    } finally {
      setIsFilterLoading(false)
      setIsLoading(false)
    }
  }

  // Load plots data based on phase and size
  const loadPlotsByPhaseAndSize = async (phase, size) => {
    try {
      setIsFilterLoading(true)
      setApiError("")

      const token = getAuthToken()
      if (!token) {
        throw new Error("Authentication token not found")
      }

      const encodedSize = encodeURIComponent(size)
      // Build URL with event_id parameter if event is selected
      let url = `${PLOT_ENDPOINTS.FILTERED_PLOTS}?size=${encodedSize}&category=${selectedCategory}&phase=${phase}`
      if (selectedEvent && selectedEvent !== "dha-marketplace") {
        url += `&event_id=${selectedEvent}`
      }

      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (!response.ok) {
        throw new Error("Failed to fetch plots")
      }

      const data = await response.json()

      if (data.success) {
        // If there are plots, set them
        if (data.data.plots && data.data.plots.length > 0) {
          setFilteredPlots(data.data.plots)
        } else {
          setFilteredPlots([])
        }
      } else {
        setApiError(data.message || "Failed to fetch plots")
        setFilteredPlots([])
      }
    } catch (error) {
      setApiError(error.message || "Failed to fetch plots")
      setFilteredPlots([])
    } finally {
      setIsFilterLoading(false)
    }
  }

  // Load events on component mount
  useEffect(() => {
    if (isAuthenticated) {
      loadEvents()
    }
  }, [isAuthenticated])

  // Redirect to login if not authenticated
  useEffect(() => {
    if (!authLoading && !isAuthenticated) {
      router.push("/login")
    } else if (isAuthenticated) {
      setIsLoading(false)
    }
  }, [authLoading, isAuthenticated, router])

  // Reload plots when category changes and phase is selected
  useEffect(() => {
    if (selectedPhase) {
      loadPlotsByPhase(selectedPhase);
    } else {
      setFilteredPlots([]);
      setAvailableSizes({});
      setSelectedPlot(null);
    }
  }, [selectedCategory]);

  // Reset influencer booking when plots change and no vlogger pricing is available
  useEffect(() => {
    if (filteredPlots.length > 0 && !hasVloggerPricing() && isInfluencerBooking) {
      setIsInfluencerBooking(false);
    }
  }, [filteredPlots]);

  // Handle phase selection
  const handlePhaseSelect = (phase) => {
    setSelectedPhase(phase);
    setSelectedSize("");
    loadPlotsByPhase(phase);
  }

  // Handle size selection
  const handleSizeSelect = (size) => {
    setSelectedSize(size);
    if (selectedPhase) {
      loadPlotsByPhaseAndSize(selectedPhase, size);
    }
  }

  // Handle plot selection
  const handlePlotSelect = async (plot) => {
    try {
      const token = getAuthToken()
      if (!token) {
        throw new Error("Authentication token not found")
      }

      const response = await fetch(`${MARKETING_ENDPOINTS.HOLD_PLOT}?plot_id=${plot.id}`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.message || "Failed to hold plot")
      }

      setSelectedPlot(plot)
      // Update the plot_id in formData
      setFormData((prev) => ({
        ...prev,
        plot_id: plot.id,
      }))
      setActiveTab("booking")
    } catch (error) {
      setApiError(error.message || "Failed to hold plot")
    }
  }

  // Handle back to selection
  const handleBackToSelection = () => {
    setActiveTab("filter")
  }

  // Check if vlogger pricing is available for any of the filtered plots
  const hasVloggerPricing = () => {
    return filteredPlots.some(plot => {
      const vloggerBase = parseFloat(plot.vlogger_base_price || "0")
      const vloggerOneYr = parseFloat(plot.vlogger_one_yr_plan || "0")
      const vloggerTwoYr = parseFloat(plot.vlogger_two_yrs_plan || "0")

      return vloggerBase > 0 || vloggerOneYr > 0 || vloggerTwoYr > 0
    })
  }

  if (authLoading || isLoading) {
    return (
      <div className="flex flex-col min-h-screen">
        <DashboardHeader />
        <div className="flex-1 container py-8 flex items-center justify-center">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="flex flex-col min-h-screen">
      <DashboardHeader />

      <main className="flex-1 container py-6">
        <div className="mb-6">
          <h1 className="text-2xl md:text-3xl font-bold">Manager Booking Form</h1>
          <p className="text-muted-foreground mt-1">
            Help users book plots and place bids without using the map interface
          </p>
        </div>

        {/* Error Display */}
        {apiError && (
          <Alert className="mb-6 bg-red-50 border-red-200 text-red-800">
            <AlertDescription>{apiError}</AlertDescription>
          </Alert>
        )}

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="filter" className="flex items-center gap-2">
              <Filter className="h-4 w-4" />
              <span>Filter Plots</span>
            </TabsTrigger>
            <TabsTrigger value="booking" className="flex items-center gap-2" disabled={!selectedPlot}>
              <FileText className="h-4 w-4" />
              <span>Booking Form</span>
            </TabsTrigger>
          </TabsList>

          <TabsContent value="filter" className="mt-6">
            {/* Event Selection Section */}
            <div className="mb-6">
              <div className="mb-4">
                <h2 className="text-xl font-semibold mb-2">Select Inventory Source</h2>
                <p className="text-muted-foreground text-sm">Choose which inventory to load plots from</p>
              </div>

              {isLoadingEvents ? (
                <Card>
                  <CardContent className="flex items-center justify-center py-8">
                    <Loader2 className="h-6 w-6 animate-spin mr-2" />
                    <span>Loading inventory options...</span>
                  </CardContent>
                </Card>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {/* DHA MarketPlace Inventory Card */}
                  <Card
                    className={`cursor-pointer transition-all duration-200 hover:shadow-md ${selectedEvent === "dha-marketplace"
                      ? "ring-2 ring-primary bg-primary/5 border-primary"
                      : "hover:border-primary/50"
                      }`}
                    onClick={() => handleEventSelect("dha-marketplace")}
                  >
                    <CardContent className="p-6">
                      <div className="flex items-start space-x-4">
                        <div className={`p-3 rounded-lg ${selectedEvent === "dha-marketplace"
                          ? "bg-primary text-primary-foreground"
                          : "bg-muted"
                          }`}>
                          <Building2 className="h-6 w-6" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="font-semibold text-lg mb-1">DHA MarketPlace</h3>
                          <p className="text-sm text-muted-foreground mb-2">General inventory</p>
                          <div className="flex items-center text-xs text-muted-foreground">
                            <span className="inline-block w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                            Always Available
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>

                  {/* Event Cards */}
                  {events.map((event: any) => (
                    <Card
                      key={event.id}
                      className={`cursor-pointer transition-all duration-200 hover:shadow-md ${selectedEvent === event.id.toString()
                        ? "ring-2 ring-primary bg-primary/5 border-primary"
                        : "hover:border-primary/50"
                        }`}
                      onClick={() => handleEventSelect(event.id.toString())}
                    >
                      <CardContent className="p-6">
                        <div className="flex items-start space-x-4">
                          <div className={`p-3 rounded-lg ${selectedEvent === event.id.toString()
                            ? "bg-primary text-primary-foreground"
                            : "bg-muted"
                            }`}>
                            <Calendar className="h-6 w-6" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <h3 className="font-semibold text-lg mb-1 truncate">{event.title}</h3>
                            <p className="text-sm text-muted-foreground mb-2">Special Event</p>
                            <div className="flex items-center text-xs text-muted-foreground">
                              <span className={`inline-block w-2 h-2 rounded-full mr-2 ${event.status === 'Active' ? 'bg-green-500' : 'bg-yellow-500'
                                }`}></span>
                              {event.status || 'Active'}
                            </div>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}

              {/* Selected Inventory Info */}
              {selectedEvent && (
                <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                  <div className="flex items-center space-x-2">
                    <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                    <span className="text-sm font-medium text-blue-900">
                      Currently showing: {
                        selectedEvent === "dha-marketplace"
                          ? "DHA MarketPlace General Inventory"
                          : `${events.find((e: any) => e.id.toString() === selectedEvent)?.title} Event Inventory`
                      }
                    </span>
                  </div>
                </div>
              )}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <Card className="lg:col-span-1">
                <CardHeader>
                  <CardTitle className="text-lg">Filter Available Plots</CardTitle>
                  <CardDescription>Select phase and size to find available plots</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-6">
                    {/* Phase Selection */}
                    <div>
                      <label className="block text-sm font-medium mb-2">Select Phase</label>
                      {!selectedEvent ? (
                        <div className="text-center py-4 text-muted-foreground text-sm">
                          Please select an event first
                        </div>
                      ) : (
                        <div className="grid grid-cols-2 gap-2">
                          {[1, 2, 3, 4, 5, 6, 7].map((phase) => (
                            <Button
                              key={phase}
                              variant={selectedPhase === phase.toString() ? "default" : "outline"}
                              onClick={() => handlePhaseSelect(phase.toString())}
                              className="w-full"
                            >
                              Phase {phase}
                            </Button>
                          ))}
                        </div>
                      )}
                    </div>

                    {/* Size Selection - Only show if phase is selected and sizes are available */}
                    {selectedPhase && Object.keys(availableSizes).length > 0 && (
                      <div>
                        <label className="block text-sm font-medium mb-2">Select Size</label>
                        <div className="grid grid-cols-1 gap-2">
                          {Object.entries(availableSizes).map(([size, count]) => (
                            <Button
                              key={size}
                              variant={selectedSize === size ? "default" : "outline"}
                              onClick={() => handleSizeSelect(size)}
                              className="w-full justify-between"
                            >
                              <span>{size}</span>
                              <span className="bg-primary-foreground text-primary rounded-full px-2 py-0.5 text-xs">
                                {count}
                              </span>
                            </Button>
                          ))}
                        </div>
                      </div>
                    )}

                    {/* Show message if no sizes available */}
                    {selectedPhase && Object.keys(availableSizes).length === 0 && !isFilterLoading && (
                      <Alert>
                        <AlertDescription>No plots available in Phase {selectedPhase}</AlertDescription>
                      </Alert>
                    )}
                  </div>
                </CardContent>
              </Card>

              <Card className="lg:col-span-2">
                <CardHeader className="flex flex-row items-center justify-between">
                  <div>
                    <CardTitle className="text-lg">Available Plots</CardTitle>
                    <CardDescription>{filteredPlots.length} plots found</CardDescription>
                  </div>
                </CardHeader>
                <CardContent>
                  {/* Category Tabs inside Available Plots card */}
                  <div className="mb-4">
                    <div className="flex space-x-2 mb-3">
                      {CATEGORY_OPTIONS.map((cat) => (
                        <Button
                          key={cat}
                          variant={selectedCategory === cat ? "default" : "outline"}
                          onClick={() => {
                            setSelectedCategory(cat);
                            // Do not reset phase/size, just reload for this category
                          }}
                        >
                          {cat}
                        </Button>
                      ))}
                    </div>

                    {/* Influencer/Vlogger Discount Toggle - Only show if vlogger pricing is available */}
                    {hasVloggerPricing() && (
                      <div className="flex items-center space-x-3 p-3 bg-gradient-to-r from-purple-50 to-pink-50 border border-purple-200 rounded-lg">
                        <div className="flex items-center space-x-2">
                          <input
                            type="checkbox"
                            id="influencerBooking"
                            checked={isInfluencerBooking}
                            onChange={(e) => setIsInfluencerBooking(e.target.checked)}
                            className="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded"
                          />
                          <label htmlFor="influencerBooking" className="text-sm font-medium text-purple-800">
                            Social Media Influencer/Vlogger Booking
                          </label>
                        </div>
                        {isInfluencerBooking && (
                          <div className="flex items-center space-x-1 text-xs text-purple-600 bg-purple-100 px-2 py-1 rounded-full">
                            <span>✨</span>
                            <span>Special Discount Applied</span>
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                  {isFilterLoading ? (
                    <div className="flex items-center justify-center py-8">
                      <Loader2 className="h-8 w-8 animate-spin text-primary" />
                    </div>
                  ) : apiError ? (
                    <Alert className="bg-red-50 border-red-200 text-red-800">
                      <AlertDescription>{apiError}</AlertDescription>
                    </Alert>
                  ) : filteredPlots.length === 0 ? (
                    <div className="text-center py-8 text-muted-foreground">
                      {selectedPhase ? (
                        selectedSize ? (
                          <p>No plots available for the selected criteria</p>
                        ) : (
                          <p>Please select a size to view available plots</p>
                        )
                      ) : (
                        <p>Please select a phase to begin</p>
                      )}
                    </div>
                  ) : (
                    <PlotSelectionList
                      plots={filteredPlots}
                      onPlotSelect={handlePlotSelect}
                      selectedPlot={selectedPlot}
                    />
                  )}
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          <TabsContent value="booking" className="mt-6">
            {selectedPlot ? (
              <ManagerBookingForm
                plot={selectedPlot}
                onBackToSelection={handleBackToSelection}
                isInfluencerBooking={isInfluencerBooking}
              />
            ) : (
              <Card>
                <CardContent className="py-10 text-center">
                  <p className="text-muted-foreground">Please select a plot first from the Filter Plots tab</p>
                  <Button variant="outline" className="mt-4" onClick={() => setActiveTab("filter")}>
                    Go to Plot Selection
                  </Button>
                </CardContent>
              </Card>
            )}
          </TabsContent>
        </Tabs>
      </main>
    </div>
  )
}
