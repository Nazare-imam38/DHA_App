import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  try {
    // Get the qr parameter from the query parameters
    const { searchParams } = new URL(request.url);
    const qrCode = searchParams.get('qr');

    if (!qrCode) {
      return NextResponse.json(
        { message: 'QR code parameter is required' },
        { status: 400 }
      );
    }

    // Forward the request to your backend API
    const response = await fetch(
      `https://backend-apis.dhamarketplace.com/api/verify-plot-confirmation-letter?qr=${encodeURIComponent(qrCode)}`,
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    const data = await response.json();

    if (!response.ok) {
      return NextResponse.json(
        { message: data.message || 'QR code verification failed' },
        { status: response.status }
      );
    }

    return NextResponse.json(data);
  } catch (error) {
    console.error('Error verifying QR code:', error);
    return NextResponse.json(
      { message: 'An error occurred while verifying QR code' },
      { status: 500 }
    );
  }
}