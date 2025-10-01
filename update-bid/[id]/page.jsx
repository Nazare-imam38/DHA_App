"use client"

import { useState, useEffect } from "react"
import { useRouter, useParams } from "next/navigation"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { fetchUserProfile, updateBidAmount } from "@/utils/api"
import { useAuth } from "@/hooks/use-auth"
import DashboardLoading from "@/components/loading/dashboard-loading"
import { AlertCircle, CheckCircle, ArrowLeft } from "lucide-react"
import { Alert, AlertDescription } from "@/components/ui/alert"

export default function UpdateBidPage() {
  const router = useRouter()
  const params = useParams()
  const { isAuthenticated, isLoading: authLoading } = useAuth()
  const [booking, setBooking] = useState(null)
  const [bidAmount, setBidAmount] = useState("")
  const [formattedBidAmount, setFormattedBidAmount] = useState("")
  const [isLoading, setIsLoading] = useState(true)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState("")
  const [success, setSuccess] = useState("")

  useEffect(() => {
    if (!authLoading && !isAuthenticated) {
      router.push("/login")
    }
  }, [authLoading, isAuthenticated, router])

  useEffect(() => {
    const loadBookingData = async () => {
      if (!isAuthenticated || !params.id) return

      try {
        setIsLoading(true)
        const response = await fetchUserProfile()

        if (!response.data || !response.data.reserve_bookings) {
          throw new Error("Failed to load booking data")
        }

        const foundBooking = response.data.reserve_bookings.find((b) => b.id.toString() === params.id)

        if (!foundBooking) {
          throw new Error("Booking not found")
        }

        setBooking(foundBooking)

        // Set initial bid amount
        const initialAmount = Number.parseFloat(foundBooking.bid_amount)
        setBidAmount(initialAmount.toString())
        setFormattedBidAmount(initialAmount.toLocaleString())
      } catch (err) {
        setError("Failed to load booking data. Please try again later.")
      } finally {
        setIsLoading(false)
      }
    }

    loadBookingData()
  }, [isAuthenticated, params.id])

  const handleBidAmountChange = (e) => {
    const value = e.target.value

    // Remove any non-numeric characters except commas
    const numericValue = value.replace(/[^0-9]/g, "")

    if (numericValue === "") {
      setBidAmount("")
      setFormattedBidAmount("")
      return
    }

    // Store the numeric value in state
    setBidAmount(numericValue)

    // Format with commas for display
    setFormattedBidAmount(Number(numericValue).toLocaleString())
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    if (!bidAmount) {
      setError("Please enter a bid amount")
      return
    }

    const numericBidAmount = Number(bidAmount)
    const currentBidAmount = Number.parseFloat(booking.bid_amount)

    if (numericBidAmount <= currentBidAmount) {
      setError("New bid amount must be higher than the current bid amount")
      return
    }

    try {
      setError("")
      setSuccess("")
      setIsSubmitting(true)

      await updateBidAmount(booking.id, numericBidAmount)

      setSuccess("Bid amount updated successfully!")

      // Redirect back to profile after a short delay
      setTimeout(() => {
        router.push("/profile")
      }, 2000)
    } catch (err) {
      setError(err.message || "Failed to update bid amount. Please try again.")
    } finally {
      setIsSubmitting(false)
    }
  }

  if (authLoading || isLoading) {
    return <DashboardLoading />
  }

  return (
    <div className="flex flex-col min-h-screen">
      <DashboardHeader />

      <main className="flex-1 container py-6 md:py-10 px-4 md:px-6">
        <div className="max-w-md mx-auto">
          <Button variant="ghost" className="mb-4 pl-0 flex items-center gap-1" onClick={() => router.push("/profile")}>
            <ArrowLeft className="h-4 w-4" />
            Back to Profile
          </Button>

          <Card>
            <CardHeader>
              <CardTitle className="text-xl">Update Bid Amount</CardTitle>
              <CardDescription>Increase your bid amount to improve your ranking</CardDescription>
            </CardHeader>
            <CardContent>
              {error && (
                <Alert variant="destructive" className="mb-4">
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}

              {success && (
                <Alert className="mb-4 bg-green-50 border-green-200 text-green-800">
                  <CheckCircle className="h-4 w-4 text-green-600" />
                  <AlertDescription>{success}</AlertDescription>
                </Alert>
              )}

              {booking && (
                <form onSubmit={handleSubmit}>
                  <div className="space-y-4">
                    <div className="bg-blue-50 p-4 rounded-md">
                      <h3 className="font-semibold mb-2">Booking Details</h3>
                      <div className="grid grid-cols-2 gap-2 text-sm">
                        <div>
                          <p className="text-gray-500">Plot Number</p>
                          <p className="font-medium">{booking.plot.plot_no}</p>
                        </div>
                        <div>
                          <p className="text-gray-500">Category</p>
                          <p className="font-medium">{booking.plot.category}</p>
                        </div>
                        <div>
                          <p className="text-gray-500">Current Bid</p>
                          <p className="font-medium">PKR {Number.parseFloat(booking.bid_amount).toLocaleString()}</p>
                        </div>
                        <div>
                          <p className="text-gray-500">Current Rank</p>
                          <p className="font-medium">#{booking.rank_no || "N/A"}</p>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="bidAmount">New Bid Amount (PKR)</Label>
                      <Input
                        id="bidAmount"
                        value={formattedBidAmount}
                        onChange={handleBidAmountChange}
                        placeholder="Enter new bid amount"
                        className="text-right"
                        required
                      />
                      <p className="text-xs text-muted-foreground">
                        Your new bid must be higher than your current bid amount.
                      </p>
                    </div>

                    <Button type="submit" className="w-full" disabled={isSubmitting || !!success}>
                      {isSubmitting ? "Updating..." : "Update Bid Amount"}
                    </Button>
                  </div>
                </form>
              )}
            </CardContent>
          </Card>
        </div>
      </main>
    </div>
  )
}
