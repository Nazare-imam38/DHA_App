"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { useAuth } from "@/hooks/use-auth"
import DashboardLoading from "@/components/loading/dashboard-loading"
import MarketingRouteGuard from "@/components/auth/marketing-route-guard"
import MarketingDashboard from "@/components/marketing/marketing-dashboard"

export default function MarketingPage() {
  const { isAuthenticated, isLoading, role } = useAuth()
  const router = useRouter()

  useEffect(() => {
    // If authentication check is complete
    if (!isLoading) {
      // If not authenticated, redirect to login
      if (!isAuthenticated) {
        router.push("/login")
      }
      // If authenticated but not a marketing user (role !== 5), redirect appropriately
      else if (role !== undefined && role !== 5) {
        if (role === 0) {
          router.push("/dashboard")
        } else {
          router.push("/admin")
        }
      }
    }
  }, [isLoading, isAuthenticated, role, router])

  // Show loading state while checking authentication
  if (isLoading) {
    return <DashboardLoading />
  }

  // If not authenticated or not a marketing user, don't render anything (will be redirected by useEffect)
  if (!isAuthenticated || (role !== undefined && role !== 5)) {
    return <DashboardLoading />
  }

  // Only render the dashboard if authenticated and is a marketing user
  return (
    <MarketingRouteGuard>
      <MarketingDashboard />
    </MarketingRouteGuard>
  )
}
