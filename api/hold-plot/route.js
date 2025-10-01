import { NextResponse } from "next/server"

export async function GET(request) {
  const plotId = request.nextUrl.searchParams.get("plot_id")

  if (!plotId) {
    return NextResponse.json({ success: false, message: "Plot ID is required" }, { status: 400 })
  }

  // Simulate holding the plot and setting an expiration time
  const expireTime = new Date(Date.now() + 15 * 60000).toISOString().replace("T", " ").substring(0, 19) // 15 minutes from now

  return NextResponse.json({
    success: true,
    expire_time: expireTime,
    message: "Plot hold successfully.",
  })
}
