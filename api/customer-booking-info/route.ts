import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
    try {
        // Get the reserve_booking_id from the query parameters
        const { searchParams } = new URL(request.url);
        const reserveBookingId = searchParams.get('reserve_booking_id');

        if (!reserveBookingId) {
            return NextResponse.json(
                { message: 'Reserve booking ID is required' },
                { status: 400 }
            );
        }

        // Get the authorization header from the request
        const authHeader = request.headers.get('authorization');

        if (!authHeader) {
            return NextResponse.json(
                { message: 'Authorization header is required' },
                { status: 401 }
            );
        }

        // Forward the request to your backend API
        const response = await fetch(
            `https://backend-apis.dhamarketplace.com/api/customer-booking-info?reserve_booking_id=${reserveBookingId}`,
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': authHeader,
                },
            }
        );

        const data = await response.json();

        if (!response.ok) {
            return NextResponse.json(
                { message: data.message || 'Failed to fetch booking info' },
                { status: response.status }
            );
        }

        return NextResponse.json(data);
    } catch (error) {
        console.error('Error fetching customer booking info:', error);
        return NextResponse.json(
            { message: 'An error occurred while fetching booking info' },
            { status: 500 }
        );
    }
}