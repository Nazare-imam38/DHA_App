'use client';

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import PlotDashboard from "@/components/dashboard/plot-dashboard"
import { useAuth } from "@/hooks/use-auth"
import DashboardLoading from "@/components/loading/dashboard-loading"

export default function DashboardPage() {
  // Optionally, you can show a loading state if needed, but do not block for auth
  // If you want to show a loading spinner while fetching plot data, handle it inside PlotDashboard
  return <PlotDashboard />
}
