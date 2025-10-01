import { NextResponse } from "next/server"
import { MARKETING_ENDPOINTS } from "../../../config/api-config"

export async function POST(request) {
  try {
    const formData = await request.formData()
    const token = request.headers.get("Authorization")

    if (!token) {
      return NextResponse.json({ success: false, message: "Authentication token not found" }, { status: 401 })
    }

    // Use the endpoint from the API config
    const response = await fetch(MARKETING_ENDPOINTS.SALE_RESERVE_BOOKING, {
      method: "POST",
      headers: {
        Authorization: token,
      },
      body: formData,
    })

    const responseData = await response.json()

    if (!response.ok) {
      return NextResponse.json(
        {
          success: false,
          message: responseData.message || "Failed to submit booking",
          errors: responseData.errors,
        },
        { status: response.status },
      )
    }

    return NextResponse.json(responseData)
  } catch (error) {
    return NextResponse.json({ success: false, message: "Internal server error" }, { status: 500 })
  }
}
