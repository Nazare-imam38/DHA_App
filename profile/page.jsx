"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { fetchUserProfile, updateBidAmount, fetchCustomerBookingInfo } from "@/utils/api"
import SimpleConfirmationLetter from "@/components/confirmation/simple-confirmation-letter"
import { useAuth } from "@/hooks/use-auth"
import DashboardLoading from "@/components/loading/dashboard-loading"
import { AlertCircle, Clock, User, TrendingUp, CheckCircle, Copy, Download, Loader2, Info, Gavel, Timer, CreditCard, Trophy } from "lucide-react"
import { Alert, AlertDescription } from "@/components/ui/alert"
import BidRankIndicator from "@/components/bidding/bid-rank-indicator"
import { MARKETING_ENDPOINTS } from "@/config/api-config";
import { PLOT_ENDPOINTS } from "@/utils/endpoints";


// Helper component for countdown timer
const CountdownTimer = ({ expiryTime, onExpire }) => {
  const [timeLeft, setTimeLeft] = useState("");
  const [isExpired, setIsExpired] = useState(false);

  useEffect(() => {
    if (!expiryTime) return;

    const updateCountdown = () => {
      const now = new Date().getTime();
      const expiry = new Date(expiryTime).getTime();
      const difference = expiry - now;

      if (difference <= 0) {
        setTimeLeft("Expired");
        setIsExpired(true);
        if (onExpire) onExpire();
        return;
      }

      const minutes = Math.floor(difference / (1000 * 60));
      const seconds = Math.floor((difference % (1000 * 60)) / 1000);
      setTimeLeft(`${minutes}:${seconds.toString().padStart(2, '0')}`);
    };

    updateCountdown();
    const interval = setInterval(updateCountdown, 1000);

    return () => clearInterval(interval);
  }, [expiryTime, onExpire]);

  if (!expiryTime) return null;

  return (
    <div className={`flex items-center gap-2 text-sm font-medium ${isExpired ? 'text-red-600' : 'text-orange-600'}`}>
      <Timer className="h-4 w-4" />
      <span>{isExpired ? "Payment Expired" : `Time Left: ${timeLeft}`}</span>
    </div>
  );
};

export default function ProfilePage() {
  const router = useRouter()
  const { isAuthenticated, isLoading: authLoading, user } = useAuth()

  // Add this function to copy text to clipboard
  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text).catch((err) => { })
  }

  // Add this function near the top of your component
  const formatCNIC = (cnic) => {
    if (!cnic) return ""

    // Remove any non-digit characters
    const digits = cnic.replace(/\D/g, "")

    // Format as 12345-1234567-1
    if (digits.length === 13) {
      return `${digits.slice(0, 5)}-${digits.slice(5, 12)}-${digits.slice(12, 13)}`
    }

    return cnic // Return original if not 13 digits
  }

  // Add a check at the beginning of the component to redirect non-customer users
  useEffect(() => {
    console.log({
      authLoading,
      isAuthenticated,
      userRole: user?.role,
      shouldRedirect: !authLoading && isAuthenticated && user && user.role !== undefined && user.role > 0,
    })

    // Only redirect if the user is definitely an admin (role > 0)
    if (!authLoading && isAuthenticated && user && user.role !== undefined && user.role > 0) {
      router.push("/admin")
    }
  }, [authLoading, isAuthenticated, user, router])

  const [profileData, setProfileData] = useState(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState("")
  const [bidAmounts, setBidAmounts] = useState({})
  const [bidErrors, setBidErrors] = useState({})
  const [bidSuccess, setBidSuccess] = useState({})
  const [isSubmitting, setIsSubmitting] = useState({})
  const [activeTab, setActiveTab] = useState("all");
  const [showConfirmationLetter, setShowConfirmationLetter] = useState(false)
  const [selectedBookingForLetter, setSelectedBookingForLetter] = useState(null)

  useEffect(() => {
    if (!authLoading && !isAuthenticated) {
      router.push("/login")
    }
  }, [authLoading, isAuthenticated, router])

  // Load user profile data
  const loadUserProfile = async () => {
    if (!isAuthenticated) {
      return
    }

    try {
      setIsLoading(true)
      const response = await fetchUserProfile()
      setProfileData(response.data)

      // Initialize bid amounts from current bid amounts
      if (response.data && response.data.reserve_bookings) {
        const initialBidAmounts = {}
        response.data.reserve_bookings.forEach((booking) => {
          initialBidAmounts[booking.id] = booking.bid_amount
        })
        setBidAmounts(initialBidAmounts)
      }
    } catch (err) {
      setError("Failed to load profile data. Please try again later.")
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    loadUserProfile()
  }, [isAuthenticated])

  // Handle bid amount change
  const handleBidAmountChange = (bookingId, value) => {
    // Remove any non-numeric characters
    const numericValue = value.replace(/[^0-9]/g, "")

    setBidAmounts((prev) => ({
      ...prev,
      [bookingId]: numericValue,
    }))

    // Clear any previous errors/success for this booking
    setBidErrors((prev) => ({
      ...prev,
      [bookingId]: null,
    }))
    setBidSuccess((prev) => ({
      ...prev,
      [bookingId]: null,
    }))
  }

  // Handle bid submission
  const handleUpdateBid = async (bookingId) => {
    const currentAmount = Number.parseFloat(bidAmounts[bookingId])
    const originalAmount = Number.parseFloat(profileData.reserve_bookings.find((b) => b.id === bookingId).bid_amount)

    // Validate bid amount
    if (!currentAmount || currentAmount <= originalAmount) {
      setBidErrors((prev) => ({
        ...prev,
        [bookingId]: "New bid amount must be higher than the current bid amount",
      }))
      return
    }

    // Check if bid amount is a multiple of 1 lac (100,000)
    if (currentAmount % 100000 !== 0) {
      setBidErrors((prev) => ({
        ...prev,
        [bookingId]: "Bid amount must be in multiples of 1 lac (100,000)",
      }))
      return
    }

    try {
      setIsSubmitting((prev) => ({
        ...prev,
        [bookingId]: true,
      }))

      await updateBidAmount(bookingId, currentAmount)

      setBidSuccess((prev) => ({
        ...prev,
        [bookingId]: "Bid updated successfully!",
      }))

      // Refresh profile data to get updated rank
      await loadUserProfile()
    } catch (err) {
      // Handle API validation errors
      if (err.errors && err.errors.bid_amount && err.errors.bid_amount.length > 0) {
        // Display the specific bid_amount error message from the API
        setBidErrors((prev) => ({
          ...prev,
          [bookingId]: err.errors.bid_amount[0],
        }))
      } else if (err.message) {
        // Display the general error message
        setBidErrors((prev) => ({
          ...prev,
          [bookingId]: err.message,
        }))
      } else {
        // Fallback to generic error
        setBidErrors((prev) => ({
          ...prev,
          [bookingId]: "Failed to update bid. Please try again.",
        }))
      }
    } finally {
      setIsSubmitting((prev) => ({
        ...prev,
        [bookingId]: false,
      }))
    }
  }

  if (authLoading || isLoading) {
    return <DashboardLoading />
  }

  return (
    <div className="flex flex-col min-h-screen">
      <DashboardHeader />

      <main className="flex-1 container py-6 md:py-10 px-4 md:px-6">
        <div className="max-w-5xl mx-auto">
          <h1 className="text-2xl md:text-3xl font-bold mb-4 md:mb-6">My Bookings</h1>

          {error && (
            <Alert variant="destructive" className="mb-6">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}

          <div className="grid gap-4 md:gap-6 grid-cols-1 md:grid-cols-3">
            <Card className="md:col-span-1">
              <CardHeader className="p-4 md:p-6">
                <CardTitle className="flex items-center gap-2 text-lg md:text-xl">
                  <User className="h-5 w-5" />
                  User Information
                </CardTitle>
              </CardHeader>
              <CardContent className="p-4 md:p-6 pt-0 md:pt-0">
                {profileData ? (
                  <div className="space-y-4">
                    <div>
                      <p className="text-sm text-muted-foreground">Name</p>
                      <p className="font-medium">{profileData.user.name}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Email</p>
                      <p className="font-medium break-words">{profileData.user.email}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Phone</p>
                      <p className="font-medium">{profileData.user.phone}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">CNIC</p>
                      <p className="font-medium">{formatCNIC(profileData.user.cnic)}</p>
                    </div>
                    <div className="pt-4">
                      <Button
                        className="w-full bg-blue-600 hover:bg-blue-700 text-white"
                        onClick={() => router.push("/dashboard")}
                      >
                        Back to Dashboard
                      </Button>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-4 text-muted-foreground">No user data available</div>
                )}
              </CardContent>
            </Card>

            <Card className="md:col-span-2">
              <CardHeader className="p-4 md:p-6">
                <CardTitle className="text-lg md:text-xl">My Bookings & Reservations</CardTitle>
                <CardDescription>View all your plot bookings and bid status</CardDescription>
              </CardHeader>
              <CardContent className="p-4 md:p-6 pt-0 md:pt-0">
                {profileData && profileData.reserve_bookings && profileData.reserve_bookings.length > 0 ? (
                  <Tabs value={activeTab} onValueChange={setActiveTab} defaultValue="all">
                    <TabsList className="mb-6 w-full flex flex-wrap gap-2 p-1 bg-gray-100/50 rounded-lg">
                      <TabsTrigger value="all" className="flex-1 min-w-0 text-xs sm:text-sm px-3 py-2.5 h-auto flex items-center justify-center gap-1.5 bg-white shadow-sm hover:bg-gray-50 data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-md rounded-md transition-all duration-200">
                        <span className="hidden sm:inline">All Bookings</span>
                        <span className="sm:hidden">All</span>
                        <Badge className="bg-gray-500 text-white text-xs px-1.5 py-0.5 min-w-[1.25rem] h-5 data-[state=active]:bg-white data-[state=active]:text-gray-500">
                          {profileData.reserve_bookings.length}
                        </Badge>
                      </TabsTrigger>
                      <TabsTrigger
                        value="bidding"
                        className={`flex-1 min-w-0 text-xs sm:text-sm px-3 py-2.5 h-auto flex items-center justify-center gap-1.5 bg-white shadow-sm hover:bg-gray-50 data-[state=active]:bg-gradient-to-r data-[state=active]:from-orange-500 data-[state=active]:to-red-500 data-[state=active]:text-white data-[state=active]:shadow-md rounded-md transition-all duration-200 ${profileData.reserve_bookings.filter(booking => booking.is_bidding === true).length > 0
                            ? 'hover:bg-orange-50'
                            : ''
                          }`}
                      >
                        <Gavel className="h-3 w-3" />
                        <span className="hidden sm:inline">Bidding Plots</span>
                        <span className="sm:hidden">Bidding</span>
                        {(() => {
                          const biddingCount = profileData.reserve_bookings.filter(booking => booking.is_bidding === true).length;
                          return biddingCount > 0 ? (
                            <Badge className="bg-orange-600 text-white text-xs px-1.5 py-0.5 min-w-[1.25rem] h-5 animate-pulse data-[state=active]:bg-white data-[state=active]:text-orange-600">
                              {biddingCount}
                            </Badge>
                          ) : null;
                        })()}
                      </TabsTrigger>
                      <TabsTrigger value="residential" className="flex-1 min-w-0 text-xs sm:text-sm px-3 py-2.5 h-auto flex items-center justify-center gap-1.5 bg-white shadow-sm hover:bg-gray-50 data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-md rounded-md transition-all duration-200">
                        <span className="hidden sm:inline">Residential</span>
                        <span className="sm:hidden">Res</span>
                        {(() => {
                          const residentialCount = profileData.reserve_bookings.filter(booking => booking.plot.category === "Residential").length;
                          return residentialCount > 0 ? (
                            <Badge className="bg-blue-500 text-white text-xs px-1.5 py-0.5 min-w-[1.25rem] h-5 data-[state=active]:bg-white data-[state=active]:text-blue-500">
                              {residentialCount}
                            </Badge>
                          ) : null;
                        })()}
                      </TabsTrigger>
                      <TabsTrigger value="commercial" className="flex-1 min-w-0 text-xs sm:text-sm px-3 py-2.5 h-auto flex items-center justify-center gap-1.5 bg-white shadow-sm hover:bg-gray-50 data-[state=active]:bg-green-600 data-[state=active]:text-white data-[state=active]:shadow-md rounded-md transition-all duration-200">
                        <span className="hidden sm:inline">Commercial</span>
                        <span className="sm:hidden">Comm</span>
                        {(() => {
                          const commercialCount = profileData.reserve_bookings.filter(booking => booking.plot.category === "Commercial").length;
                          return commercialCount > 0 ? (
                            <Badge className="bg-green-500 text-white text-xs px-1.5 py-0.5 min-w-[1.25rem] h-5 data-[state=active]:bg-white data-[state=active]:text-green-500">
                              {commercialCount}
                            </Badge>
                          ) : null;
                        })()}
                      </TabsTrigger>

                    </TabsList>

                    <TabsContent value="all">
                      <div className="space-y-4">
                        {profileData.reserve_bookings.map((booking) => (
                          <BookingCard
                            key={booking.id}
                            booking={booking}
                            bidAmount={bidAmounts[booking.id]}
                            onBidAmountChange={(value) => handleBidAmountChange(booking.id, value)}
                            onUpdateBid={() => handleUpdateBid(booking.id)}
                            error={bidErrors[booking.id]}
                            success={bidSuccess[booking.id]}
                            isSubmitting={isSubmitting[booking.id]}
                            setActiveTab={setActiveTab}
                            profileData={profileData}
                            onShowConfirmationLetter={(booking) => {
                              setSelectedBookingForLetter(booking)
                              setShowConfirmationLetter(true)
                            }}
                          />
                        ))}
                      </div>
                    </TabsContent>

                    <TabsContent value="bidding">
                      {/* Bidding Tab Info Section */}
                      <div className="mb-6 p-4 bg-gradient-to-r from-orange-50 to-red-50 border border-orange-200 rounded-lg">
                        <div className="flex items-start gap-3">
                          <div className="flex items-center justify-center w-10 h-10 bg-orange-100 rounded-full flex-shrink-0">
                            <Gavel className="h-5 w-5 text-orange-600" />
                          </div>
                          <div>
                            <h3 className="font-semibold text-orange-800 mb-1">Bidding Plots</h3>
                            <p className="text-sm text-orange-700 mb-2">
                              These are special auction plots where you can compete with other buyers by placing bids.
                            </p>
                            <ul className="text-xs text-orange-600 space-y-1">
                              <li>• Complete payment to unlock bidding features</li>
                              <li>• Place and update your bids to improve ranking</li>
                              <li>• Higher bids get better positions</li>
                              <li>• Monitor your ranking in real-time</li>
                            </ul>
                          </div>
                        </div>
                      </div>

                      <div className="space-y-4">
                        {(() => {
                          const biddingBookings = profileData.reserve_bookings.filter((booking) => booking.is_bidding === true);

                          if (biddingBookings.length === 0) {
                            return (
                              <div className="text-center py-8 text-muted-foreground">
                                <div className="flex flex-col items-center gap-3">
                                  <div className="flex items-center justify-center w-16 h-16 bg-orange-100 rounded-full">
                                    <Gavel className="h-8 w-8 text-orange-600" />
                                  </div>
                                  <div>
                                    <h3 className="font-semibold text-lg text-gray-700 mb-1">No Bidding Plots Found</h3>
                                    <p className="text-sm text-gray-500">You haven't booked any bidding plots yet.</p>
                                  </div>
                                </div>
                              </div>
                            );
                          }

                          return biddingBookings.map((booking) => (
                            <BookingCard
                              key={booking.id}
                              booking={booking}
                              bidAmount={bidAmounts[booking.id]}
                              onBidAmountChange={(value) => handleBidAmountChange(booking.id, value)}
                              onUpdateBid={() => handleUpdateBid(booking.id)}
                              error={bidErrors[booking.id]}
                              success={bidSuccess[booking.id]}
                              isSubmitting={isSubmitting[booking.id]}
                              setActiveTab={setActiveTab}
                              profileData={profileData}
                              onShowConfirmationLetter={(booking) => {
                                setSelectedBookingForLetter(booking)
                                setShowConfirmationLetter(true)
                              }}
                            />
                          ));
                        })()}
                      </div>
                    </TabsContent>

                    <TabsContent value="residential">
                      <div className="space-y-4">
                        {profileData.reserve_bookings
                          .filter((booking) => booking.plot.category === "Residential")
                          .map((booking) => (
                            <BookingCard
                              key={booking.id}
                              booking={booking}
                              bidAmount={bidAmounts[booking.id]}
                              onBidAmountChange={(value) => handleBidAmountChange(booking.id, value)}
                              onUpdateBid={() => handleUpdateBid(booking.id)}
                              error={bidErrors[booking.id]}
                              success={bidSuccess[booking.id]}
                              isSubmitting={isSubmitting[booking.id]}
                              setActiveTab={setActiveTab}
                              profileData={profileData}
                              onShowConfirmationLetter={(booking) => {
                                setSelectedBookingForLetter(booking)
                                setShowConfirmationLetter(true)
                              }}
                            />
                          ))}
                      </div>
                    </TabsContent>

                    <TabsContent value="commercial">
                      <div className="space-y-4">
                        {profileData.reserve_bookings
                          .filter((booking) => booking.plot.category === "Commercial")
                          .map((booking) => (
                            <BookingCard
                              key={booking.id}
                              booking={booking}
                              bidAmount={bidAmounts[booking.id]}
                              onBidAmountChange={(value) => handleBidAmountChange(booking.id, value)}
                              onUpdateBid={() => handleUpdateBid(booking.id)}
                              error={bidErrors[booking.id]}
                              success={bidSuccess[booking.id]}
                              isSubmitting={isSubmitting[booking.id]}
                              setActiveTab={setActiveTab}
                              profileData={profileData}
                              onShowConfirmationLetter={(booking) => {
                                setSelectedBookingForLetter(booking)
                                setShowConfirmationLetter(true)
                              }}
                            />
                          ))}
                      </div>
                    </TabsContent>


                  </Tabs>
                ) : (
                  <div className="text-center py-8 md:py-12">
                    <Clock className="h-10 w-10 md:h-12 md:w-12 text-muted-foreground mx-auto mb-4" />
                    <h3 className="text-lg font-medium mb-2">No Bookings Yet</h3>
                    <p className="text-muted-foreground mb-6 max-w-md mx-auto">
                      You haven't made any plot reservations or bids yet.
                    </p>
                    <Button onClick={() => router.push("/")}>Browse Available Plots</Button>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </div>
      </main>

      {/* Confirmation Letter Modal */}
      {showConfirmationLetter && selectedBookingForLetter && (
        <SimpleConfirmationLetter
          booking={selectedBookingForLetter}
          profileData={profileData}
          onClose={() => {
            setShowConfirmationLetter(false)
            setSelectedBookingForLetter(null)
          }}
        />
      )}
    </div>
  )
}

// The BookingCard component needs to be updated to show more plot details
// Replace the existing BookingCard component with this enhanced version

function BookingCard({ booking, bidAmount, onBidAmountChange, onUpdateBid, error, success, isSubmitting, setActiveTab, profileData, onShowConfirmationLetter }) {
  const router = useRouter()
  const isCommercial = booking.plot.category === "Commercial"
  const isBiddingPlot = booking.is_bidding === true

  // Helper function to get the selected payment plan price and name
  const getSelectedPaymentPlan = () => {
    const plot = booking.plot;
    const selectedPlan = booking.payment_plan; // This should contain the field name like "one_yr_plan"

    // If no payment plan is specified, default to base_price
    if (!selectedPlan || selectedPlan === 'base_price') {
      return {
        name: 'Reserved Price',
        price: Number.parseFloat(plot.base_price || 0),
        field: 'Reserved Price'
      };
    }

    // Map payment plan fields to their display names and prices
    const paymentPlanMap = {
      'one_yr_plan': {
        name: '1 Year Plan',
        price: Number.parseFloat(plot.one_yr_plan || 0),
        field: 'one_yr_plan'
      },
      'two_yrs_plan': {
        name: '2 Years Plan',
        price: Number.parseFloat(plot.two_yrs_plan || 0),
        field: 'two_yrs_plan'
      },
      'two_five_yrs_plan': {
        name: '2.5 Years Plan',
        price: Number.parseFloat(plot.two_five_yrs_plan || 0),
        field: 'two_five_yrs_plan'
      },
      'three_yrs_plan': {
        name: '3 Years Plan',
        price: Number.parseFloat(plot.three_yrs_plan || 0),
        field: 'three_yrs_plan'
      }
    };

    // Return the selected payment plan or fallback to base_price
    const planInfo = paymentPlanMap[selectedPlan];
    if (planInfo && planInfo.price > 0) {
      return planInfo;
    } else {
      return {
        name: 'Reserved Price',
        price: Number.parseFloat(plot.base_price || 0),
        field: 'Reserved Price'
      };
    }
  };

  const selectedPaymentPlan = getSelectedPaymentPlan();

  // Format number with commas
  const formatNumberWithCommas = (num) => {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  }

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text).catch((err) => { })
  }



  return (
    <Card className="overflow-hidden">
      <div className={`border-l-4 ${isCommercial ? "border-green-500" : "border-primary"}`}>
        <CardContent className="p-4">
          <div className="flex flex-col md:flex-row justify-between gap-4">
            <div className="flex-1">
              <div className="flex flex-wrap items-center justify-between gap-2 mb-2 relative">
                <div className="flex flex-wrap items-center gap-2">
                  <h3 className="font-semibold text-base">Plot {booking.plot.plot_no}</h3>
                  <Badge
                    className={
                      booking.plot.category === "Residential"
                        ? "bg-blue-100 text-blue-800"
                        : "bg-green-100 text-green-800"
                    }
                  >
                    {booking.plot.category}
                  </Badge>
                  <Badge
                    className={
                      booking.status === "Pending"
                        ? "bg-amber-100 text-amber-800"
                        : booking.status === "Completed" || booking.status === "Inprogress"
                          ? "bg-green-100 text-green-800"
                          : "bg-blue-100 text-blue-800"
                    }
                  >
                    {booking.status === "Inprogress" ? "Payment Done (Confirmation Awaited)" : booking.status}
                  </Badge>

                  {/* Special bidding badge */}
                  {isBiddingPlot && (
                    <Badge className="bg-gradient-to-r from-orange-100 to-red-100 text-orange-800 border border-orange-300 animate-pulse">
                      <Gavel className="h-3 w-3 mr-1" />
                      Bidding Plot
                    </Badge>
                  )}
                </div>

                {/* Download Button - Always Visible */}
                <Button
                  onClick={() => onShowConfirmationLetter(booking)}
                  size="sm"
                  className="bg-blue-600 hover:bg-blue-700 text-white flex items-center gap-1 px-3 py-1 h-8"
                >
                  <Download className="h-3 w-3" />
                  <span className="hidden sm:inline">Download</span>
                </Button>
              </div>

              {/* Enhanced plot details section */}
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-x-4 gap-y-2 mb-4 border-b pb-3">
                <div>
                  <p className="text-sm text-muted-foreground">Phase</p>
                  <p className="font-medium">{booking.plot.phase || "N/A"}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Sector</p>
                  <p className="font-medium">{booking.plot.sector || "N/A"}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Street</p>
                  <p className="font-medium">{booking.plot.street_no || "N/A"}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Block</p>
                  <p className="font-medium">
                    {booking.plot.block && booking.plot.block !== "NULL" ? booking.plot.block : "N/A"}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Size</p>
                  <p className="font-medium">{booking.plot.size} sq ft</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Dimensions</p>
                  <p className="font-medium">{booking.plot.dimension && booking.plot.dimension !== 'NULL' ? booking.plot.dimension : 'N/A'}</p>
                </div>
              </div>

              {/* Booking details section */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-2 mb-4">
                <div>
                  <p className="text-sm text-muted-foreground">Booking Date</p>
                  <p className="font-medium">{new Date(booking.date).toLocaleDateString()}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Token Amount</p>
                  <p className="font-medium">PKR {Number.parseFloat(booking.token_amount).toLocaleString()}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">{isCommercial ? "Reserve Price" : selectedPaymentPlan.name}</p>
                  <p className="font-medium">PKR {selectedPaymentPlan.price.toLocaleString()}</p>
                  {selectedPaymentPlan.field !== 'base_price' && (
                    <p className="text-xs text-muted-foreground">({selectedPaymentPlan.name})</p>
                  )}
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Payment Method</p>
                  <p className="font-medium">{booking.challan_type}</p>
                </div>
              </div>

              <div className="flex flex-col gap-1 text-sm text-muted-foreground">
                <div className="flex items-center gap-2">
                  <span className="truncate">PSID: {booking.challan_no}</span>
                  <button
                    onClick={(e) => {
                      e.stopPropagation()
                      copyToClipboard(booking.challan_no)
                    }}
                    className="p-1 hover:bg-gray-100 rounded-full"
                    title="Copy PSID"
                  >
                    <Copy className="h-3.5 w-3.5" />
                  </button>
                </div>
                {booking.challan_type === "KuickPay" && (
                  <span className="text-xs italic">(Go to your kuick pay app and enter PSID)</span>
                )}

                {/* Payment Expiry Countdown for all bookings */}
                {booking.challan_expiry_time && booking.status === "Pending" && (
                  <div className="mt-2 p-2 bg-amber-50 border border-amber-200 rounded-md">
                    <CountdownTimer
                      expiryTime={booking.challan_expiry_time}
                      onExpire={() => { }}
                    />
                  </div>
                )}
              </div>
            </div>

            {isBiddingPlot && booking.rank_no > 0 && (
              <div className="flex flex-row sm:flex-col items-center justify-center bg-orange-50 border border-orange-200 p-3 rounded-lg">
                <div className="flex items-center gap-2 mr-2 sm:mr-0 sm:mb-1">
                  <Gavel className="h-4 w-4 text-orange-600" />
                  <p className="text-xs font-semibold text-orange-800">Current Rank</p>
                </div>
                <div className="flex flex-col items-center">
                  <BidRankIndicator rank={booking.rank_no} size="sm" />
                  <p className="text-xs text-orange-600 mt-1 font-medium">Out of all bids</p>
                </div>
              </div>
            )}
          </div>

          {/* Enhanced Bidding section for plots with is_bidding = true */}
          {isBiddingPlot && (
            <div className="mt-4">
              {booking.status === "Pending" ? (
                /* Pending Status - Beautiful Waiting UI */
                <div className="border rounded-lg p-4 bg-gradient-to-r from-blue-50 to-indigo-50 border-blue-200">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="flex items-center justify-center w-10 h-10 bg-blue-100 rounded-full">
                      <CreditCard className="h-5 w-5 text-blue-600" />
                    </div>
                    <div>
                      <h4 className="font-semibold text-blue-800">Payment Confirmation Pending</h4>
                      <p className="text-sm text-blue-600">Complete your payment to unlock bidding</p>
                    </div>
                  </div>

                  {/* Payment Expiry Countdown */}
                  {booking.challan_expiry_time && (
                    <div className="bg-white/50 rounded-lg p-3 mb-4 border border-blue-200">
                      <div className="flex items-center justify-between">
                        <div className="text-sm text-blue-700">Payment Window</div>
                        <CountdownTimer
                          expiryTime={booking.challan_expiry_time}
                          onExpire={() => { }}
                        />
                      </div>
                    </div>
                  )}

                  {/* Preview of bidding features */}
                  <div className="bg-white/30 rounded-lg p-3 mb-3">
                    <div className="flex items-center gap-2 mb-2">
                      <Trophy className="h-4 w-4 text-blue-600" />
                      <span className="text-sm font-medium text-blue-800">What you'll get after payment confirmation:</span>
                    </div>
                    <ul className="text-xs text-blue-700 space-y-1 ml-6">
                      <li>• Place and update your bids</li>
                      <li>• View your real-time ranking</li>
                      <li>• Track competition with other bidders</li>
                      <li>• Receive instant bid notifications</li>
                    </ul>
                  </div>

                  <div className="flex items-center gap-2 text-xs text-blue-600">
                    <Info className="h-3 w-3" />
                    <span>Complete your payment using PSID: {booking.challan_no}</span>
                  </div>
                </div>
              ) : booking.status === "Inprogress" ? (
                /* Active Bidding Interface */
                <div className="border rounded-lg p-4 bg-gradient-to-r from-orange-50 to-red-50 border-orange-200">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="flex items-center justify-center w-10 h-10 bg-orange-100 rounded-full">
                      <Gavel className="h-5 w-5 text-orange-600" />
                    </div>
                    <div>
                      <h4 className="font-semibold text-orange-800">Live Bidding Active</h4>
                      <p className="text-sm text-orange-600">Update your bid to improve your ranking</p>
                    </div>
                  </div>

                  {/* Current Bid & Rank Status */}
                  <div className="grid grid-cols-2 gap-3 mb-4">
                    <div className="bg-white/50 rounded-lg p-3 border border-orange-200">
                      <div className="text-xs text-orange-600 mb-1">Current Bid</div>
                      <div className="font-semibold text-orange-800">PKR {formatNumberWithCommas(booking.bid_amount)}</div>
                    </div>
                    <div className="bg-white/50 rounded-lg p-3 border border-orange-200">
                      <div className="text-xs text-orange-600 mb-1">Your Rank</div>
                      <div className="flex items-center gap-2">
                        <BidRankIndicator rank={booking.rank_no} size="xs" />
                        <span className="font-semibold text-orange-800">#{booking.rank_no}</span>
                      </div>
                    </div>
                  </div>

                  {/* Bid Update Form */}
                  <div className="bg-white/30 rounded-lg p-3 mb-3">
                    <div className="flex items-end gap-2 mb-3">
                      <div className="flex-1">
                        <p className="text-xs text-orange-700 mb-1 font-medium">New Bid Amount (PKR)</p>
                        <Input
                          value={Number(bidAmount).toLocaleString()}
                          onChange={(e) => onBidAmountChange(e.target.value)}
                          placeholder="Enter new bid amount"
                          className="text-right border-orange-300 focus:border-orange-500 focus:ring-orange-500 bg-white"
                        />
                      </div>
                      <Button
                        size="sm"
                        onClick={onUpdateBid}
                        disabled={isSubmitting}
                        className="bg-orange-600 hover:bg-orange-700 text-white px-4 py-2"
                      >
                        {isSubmitting ? (
                          <><Loader2 className="h-3 w-3 animate-spin mr-1" />Updating...</>
                        ) : (
                          <><TrendingUp className="h-3 w-3 mr-1" />Update Bid</>
                        )}
                      </Button>
                    </div>

                    <div className="text-xs text-orange-600 mb-2">
                      • Bid amount must be in multiples of 1 lac (100,000)
                      {booking.rank_no > 1 && <span className="block">• Increase your bid to improve your rank</span>}
                    </div>
                  </div>

                  {/* Success/Error Messages */}
                  {success && (
                    <div className="bg-green-100 border border-green-300 rounded-lg p-2 mb-3">
                      <div className="flex items-center gap-2 text-green-700 text-sm">
                        <CheckCircle className="h-4 w-4" />
                        <span>{success}</span>
                      </div>
                    </div>
                  )}

                  {error && (
                    <div className="bg-red-100 border border-red-300 rounded-lg p-2 mb-3">
                      <div className="flex items-center gap-2 text-red-700 text-sm">
                        <AlertCircle className="h-4 w-4" />
                        <span>{error}</span>
                      </div>
                    </div>
                  )}

                  {/* Download Confirmation Letter Button for Bidding Plots */}
                  <div className="mt-4 pt-3 border-t border-orange-200">
                    <Button
                      onClick={() => onShowConfirmationLetter(booking)}
                      className="w-full bg-blue-600 hover:bg-blue-700 text-white"
                      size="sm"
                    >
                      <Download className="h-4 w-4 mr-2" />
                      Download Confirmation Letter
                    </Button>
                  </div>
                </div>
              ) : null}
            </div>
          )}

          {/* Enhanced UI for Non-Bidding plots */}
          {!isBiddingPlot && (
            <div className="mt-4">
              {booking.status === "Pending" ? (
                /* Pending Status - Beautiful Waiting UI for Non-Bidding */
                <div className="border rounded-lg p-4 bg-gradient-to-r from-green-50 to-emerald-50 border-green-200">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="flex items-center justify-center w-10 h-10 bg-green-100 rounded-full">
                      <CreditCard className="h-5 w-5 text-green-600" />
                    </div>
                    <div>
                      <h4 className="font-semibold text-green-800">Payment Confirmation Pending</h4>
                      <p className="text-sm text-green-600">Complete your payment to unlock all features</p>
                    </div>
                  </div>

                  {/* Payment Expiry Countdown */}
                  {booking.challan_expiry_time && (
                    <div className="bg-white/50 rounded-lg p-3 mb-4 border border-green-200">
                      <div className="flex items-center justify-between">
                        <div className="text-sm text-green-700">Payment Window</div>
                        <CountdownTimer
                          expiryTime={booking.challan_expiry_time}
                          onExpire={() => { }}
                        />
                      </div>
                    </div>
                  )}

                  {/* Preview of features after confirmation */}
                  <div className="bg-white/30 rounded-lg p-3 mb-3">
                    <div className="flex items-center gap-2 mb-2">
                      <CheckCircle className="h-4 w-4 text-green-600" />
                      <span className="text-sm font-medium text-green-800">What you'll get after payment confirmation:</span>
                    </div>
                    <ul className="text-xs text-green-700 space-y-1 ml-6">
                      <li>• Download your official confirmation letter</li>
                      <li>• Access to plot documentation</li>
                      <li>• Plot ownership verification</li>
                      <li>• Customer support for plot queries</li>
                    </ul>
                  </div>

                  <div className="flex items-center gap-2 text-xs text-green-600">
                    <Info className="h-3 w-3" />
                    <span>Complete your payment using PSID: {booking.challan_no}</span>
                  </div>
                </div>
              ) : (
                /* For all other statuses - show download button for testing */
                <div className="border rounded-lg p-4 bg-gradient-to-r from-blue-50 to-cyan-50 border-blue-200">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="flex items-center justify-center w-10 h-10 bg-blue-100 rounded-full">
                      <Download className="h-5 w-5 text-blue-600" />
                    </div>
                    <div>
                      <h4 className="font-semibold text-blue-800">Confirmation Letter</h4>
                      <p className="text-sm text-blue-600">Download your confirmation letter</p>
                    </div>
                  </div>

                  {/* Download Section */}
                  <div className="bg-white/30 rounded-lg p-3 mb-3">
                    <Button
                      onClick={() => onShowConfirmationLetter(booking)}
                      className="w-full bg-blue-600 hover:bg-blue-700 text-white mb-3"
                    >
                      <Download className="h-4 w-4 mr-2" />
                      Download Confirmation Letter
                    </Button>

                    <div className="text-xs text-blue-600 bg-blue-100/50 rounded p-2">
                      <Info className="h-3 w-3 inline mr-1" />
                      Generate and download your official confirmation letter with QR code verification.
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </div>
    </Card>
  )
}


