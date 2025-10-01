"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { useAuth } from "@/hooks/use-auth"
import DashboardLoading from "@/components/loading/dashboard-loading"
import { AlertCircle, User, Copy, FileText } from "lucide-react"
import { Alert, AlertDescription } from "@/components/ui/alert"

export default function MySalesPage() {
  const router = useRouter()
  const { isAuthenticated, isLoading: authLoading, user } = useAuth()

  const [salesData, setSalesData] = useState(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState("")

  // Function to copy text to clipboard
  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text).catch((err) => {})
  }

  // Format CNIC with dashes
  const formatCNIC = (cnic) => {
    if (!cnic) return ""
    const digits = cnic.replace(/\D/g, "")
    if (digits.length === 13) {
      return `${digits.slice(0, 5)}-${digits.slice(5, 12)}-${digits.slice(12, 13)}`
    }
    return cnic
  }

  // Redirect if not authenticated
  useEffect(() => {
    if (!authLoading && !isAuthenticated) {
      router.push("/login")
    }
  }, [authLoading, isAuthenticated, router])

  // Load user sales data
  const loadUserSales = async () => {
    if (!isAuthenticated) {
      return
    }

    try {
      setIsLoading(true)

      // Get auth token
      const token = localStorage.getItem("token")
      if (!token) {
        throw new Error("Authentication token not found")
      }

      const response = await fetch("https://backend-apis.dhamarketplace.com/api/user", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      if (!response.ok) {
        throw new Error("Failed to fetch sales data")
      }

      const data = await response.json()
      setSalesData(data.data)
    } catch (err) {
      setError("Failed to load sales data. Please try again later.")
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    loadUserSales()
  }, [isAuthenticated])

  if (authLoading || isLoading) {
    return <DashboardLoading />
  }

  return (
    <div className="flex flex-col min-h-screen">
      <DashboardHeader />

      <main className="flex-1 container py-6 md:py-10 px-4 md:px-6">
        <div className="max-w-5xl mx-auto">
          <h1 className="text-2xl md:text-3xl font-bold mb-4 md:mb-6">My Sales</h1>

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
                {salesData ? (
                  <div className="space-y-4">
                    <div>
                      <p className="text-sm text-muted-foreground">Name</p>
                      <p className="font-medium">{salesData.user.name}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Email</p>
                      <p className="font-medium break-words">{salesData.user.email}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">Phone</p>
                      <p className="font-medium">{salesData.user.phone}</p>
                    </div>
                    <div>
                      <p className="text-sm text-muted-foreground">CNIC</p>
                      <p className="font-medium">{formatCNIC(salesData.user.cnic)}</p>
                    </div>
                    <div className="pt-4">
                      <Button
                        className="w-full bg-blue-600 hover:bg-blue-700 text-white"
                        onClick={() => router.push("/manager-booking")}
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
                <CardTitle className="text-lg md:text-xl">My Sales & Bookings</CardTitle>
                <CardDescription>View all your plot sales and booking status</CardDescription>
              </CardHeader>
              <CardContent className="p-4 md:p-6 pt-0 md:pt-0">
                {salesData && salesData.reserve_bookings && salesData.reserve_bookings.length > 0 ? (
                  <Tabs defaultValue="all">
                    <TabsList className="mb-4 w-full">
                      <TabsTrigger value="all" className="flex-1">
                        All Sales
                      </TabsTrigger>
                      <TabsTrigger value="residential" className="flex-1">
                        Residential
                      </TabsTrigger>
                      <TabsTrigger value="commercial" className="flex-1">
                        Commercial
                      </TabsTrigger>
                    </TabsList>

                    <TabsContent value="all">
                      <div className="space-y-4">
                        {salesData.reserve_bookings.map((booking) => (
                          <SaleCard key={booking.id} booking={booking} />
                        ))}
                      </div>
                    </TabsContent>

                    <TabsContent value="residential">
                      <div className="space-y-4">
                        {salesData.reserve_bookings
                          .filter((booking) => booking.plot.category === "Residential")
                          .map((booking) => (
                            <SaleCard key={booking.id} booking={booking} />
                          ))}
                      </div>
                    </TabsContent>

                    <TabsContent value="commercial">
                      <div className="space-y-4">
                        {salesData.reserve_bookings
                          .filter((booking) => booking.plot.category === "Commercial")
                          .map((booking) => (
                            <SaleCard key={booking.id} booking={booking} />
                          ))}
                      </div>
                    </TabsContent>
                  </Tabs>
                ) : (
                  <div className="text-center py-8 md:py-12">
                    <FileText className="h-10 w-10 md:h-12 md:w-12 text-muted-foreground mx-auto mb-4" />
                    <h3 className="text-lg font-medium mb-2">No Sales Yet</h3>
                    <p className="text-muted-foreground mb-6 max-w-md mx-auto">
                      You haven't made any plot sales or bookings yet.
                    </p>
                    <Button onClick={() => router.push("/manager-booking")}>Create New Booking</Button>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </div>
      </main>
    </div>
  )
}

function SaleCard({ booking }) {
  const isCommercial = booking.plot.category === "Commercial"

  // Format number with commas
  const formatNumberWithCommas = (num) => {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  }

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text).catch((err) => {})
  }

  return (
    <Card className="overflow-hidden">
      <div className={`border-l-4 ${isCommercial ? "border-green-500" : "border-primary"}`}>
        <CardContent className="p-4">
          <div className="flex flex-col md:flex-row justify-between gap-4">
            <div className="flex-1">
              <div className="flex flex-wrap items-center gap-2 mb-2">
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
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-2 mb-4">
                {/* Plot Location Information */}
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

                {/* Plot Size Information */}
                <div>
                  <p className="text-sm text-muted-foreground">Size</p>
                  <p className="font-medium">{booking.plot.size ? `${booking.plot.size} sq ft` : "N/A"}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Dimensions</p>
                  <p className="font-medium">{booking.plot.dimension || "N/A"}</p>
                </div>

                {/* Booking Information */}
                <div>
                  <p className="text-sm text-muted-foreground">Booking Date</p>
                  <p className="font-medium">{new Date(booking.date).toLocaleDateString()}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Token Amount</p>
                  <p className="font-medium">PKR {Number.parseFloat(booking.token_amount).toLocaleString()}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">{isCommercial ? "Reserve Price" : "Lump Sum Price"}</p>
                  <p className="font-medium">PKR {Number.parseFloat(booking.plot.base_price).toLocaleString()}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground">Payment Method</p>
                  <p className="font-medium">{booking.payment_mode || booking.challan_type || "N/A"}</p>
                </div>
                {booking.bank_name && (
                  <div>
                    <p className="text-sm text-muted-foreground">Bank</p>
                    <p className="font-medium">{booking.bank_name}</p>
                  </div>
                )}
                {booking.cheque_no && (
                  <div>
                    <p className="text-sm text-muted-foreground">Cheque/Pay Order No</p>
                    <p className="font-medium">{booking.cheque_no}</p>
                  </div>
                )}
                {booking.cheque_date && (
                  <div>
                    <p className="text-sm text-muted-foreground">Cheque/Pay Order Date</p>
                    <p className="font-medium">{new Date(booking.cheque_date).toLocaleDateString()}</p>
                  </div>
                )}
                {booking.received_amount && (
                  <div>
                    <p className="text-sm text-muted-foreground">Received Amount</p>
                    <p className="font-medium">PKR {Number.parseFloat(booking.received_amount).toLocaleString()}</p>
                  </div>
                )}
              </div>

              {booking.challan_no && (
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
                </div>
              )}
            </div>
          </div>
        </CardContent>
      </div>
    </Card>
  )
}
