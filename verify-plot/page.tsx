'use client';

import { useEffect, useState, useRef, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import Image from 'next/image';
import { CheckCircle2, AlertCircle, Download, Printer, Share2, Shield, Calendar, MapPin } from 'lucide-react';
import './verify-plot.css';
import { useReactToPrint } from 'react-to-print';

interface VerificationData {
  name: string;
  cnic: string;
  plot_no: string;
  size: string;
  category: string;
}

function VerifyPlotContent() {
  const searchParams = useSearchParams();
  const qrCode = searchParams.get('qr');
  const bookingId = searchParams.get('booking_id'); // Support legacy booking_id parameter

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [verificationData, setVerificationData] = useState<VerificationData | null>(null);
  const [showShareOptions, setShowShareOptions] = useState(false);
  const certificateRef = useRef<HTMLDivElement>(null);

  // For PDF/Print functionality
  const handlePrint = useReactToPrint({
    documentTitle: `Plot_Verification_${verificationData?.plot_no || 'Certificate'}`,
    // @ts-ignore - The type definitions are incorrect, content is a valid prop
    content: () => certificateRef.current,
  });

  // For sharing functionality
  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Plot Verification Certificate',
          text: `Plot ${verificationData?.plot_no} verification for ${verificationData?.name}`,
          url: window.location.href,
        });
      } catch (error) {
        setShowShareOptions(!showShareOptions);
      }
    } else {
      setShowShareOptions(!showShareOptions);
    }
  };

  // Copy URL to clipboard
  const copyToClipboard = () => {
    navigator.clipboard.writeText(window.location.href);
    alert('Link copied to clipboard!');
    setShowShareOptions(false);
  };

  useEffect(() => {
    const verifyQrCode = async () => {
      if (!qrCode && !bookingId) {
        setError('No QR code or booking ID provided');
        setLoading(false);
        return;
      }

      try {
        let response;
        
        if (qrCode) {
          // Check if QR code is our custom format (BOOKING_ID_TIMESTAMP)
          if (qrCode.startsWith('BOOKING_')) {
            const bookingIdFromQr = qrCode.split('_')[1];
            response = await fetch(`/api/customer-booking-info?reserve_booking_id=${bookingIdFromQr}`, {
              headers: {
                'Authorization': `Bearer ${localStorage.getItem('token') || ''}`
              }
            });
          } else {
            // Use QR code verification (preferred method for encrypted tokens)
            try {
              response = await fetch(`/api/verify-plot-confirmation-letter?qr=${encodeURIComponent(qrCode)}`);
            } catch (verifyError) {
              console.warn('QR verification failed, trying fallback method:', verifyError);
              // Fallback: try to extract booking ID if it's a simple format
              const bookingMatch = qrCode.match(/booking_id=(\d+)/i);
              if (bookingMatch) {
                const bookingIdFromQr = bookingMatch[1];
                response = await fetch(`/api/customer-booking-info?reserve_booking_id=${bookingIdFromQr}`, {
                  headers: {
                    'Authorization': `Bearer ${localStorage.getItem('token') || ''}`
                  }
                });
              } else {
                throw verifyError;
              }
            }
          }
        } else if (bookingId) {
          // Fallback: use booking ID to get customer booking info
          response = await fetch(`/api/customer-booking-info?reserve_booking_id=${bookingId}`, {
            headers: {
              'Authorization': `Bearer ${localStorage.getItem('token') || ''}`
            }
          });
        }

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.message || 'Failed to verify plot information');
        }

        // Handle different response formats
        if (data.data) {
          if (qrCode) {
            // QR verification response format
            setVerificationData(data.data);
          } else {
            // Customer booking info response format - transform to verification format
            const bookingData = data.data;
            setVerificationData({
              name: bookingData.user?.name || 'N/A',
              cnic: bookingData.user?.cnic || 'N/A',
              plot_no: bookingData.plot?.plot_no || 'N/A',
              size: bookingData.plot?.size || 'N/A',
              category: bookingData.plot?.category || 'N/A'
            });
          }
        } else {
          throw new Error('Invalid response format');
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred during verification');
      } finally {
        setLoading(false);
      }
    };

    verifyQrCode();
  }, [qrCode, bookingId]);

  // Format date for certificate
  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('en-US', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    }).format(date);
  };

  // Generate certificate number
  const certificateNumber = `VER-${Math.floor(Math.random() * 10000).toString().padStart(4, '0')}-${new Date().getFullYear()}`;

  return (
    <div className="verification-container">
      <div className="max-w-4xl mx-auto">
        {/* Header with actions */}
        <div className="verification-header-actions">
          <div className="logo-container">
            <Image
              src="images/logo.png"
              alt="DHA Marketplace Logo"
              width={180}
              height={60}
              className="logo-image"
              priority
            />
          </div>

          {/* Title */}
          <div className="text-center">
            <h1 className="verification-title">
              Plot Verification Certificate
            </h1>
            <p className="verification-subtitle">
              Official Plot Ownership Verification
            </p>
          </div>

          {!loading && !error && verificationData && (
            <div className="action-buttons">
              <button
                onClick={handlePrint}
                className="action-button print-button"
                aria-label="Download as PDF"
              >
                <Download size={18} />
                <span>Download</span>
              </button>

              <button
                onClick={() => window.print()}
                className="action-button"
                aria-label="Print certificate"
              >
                <Printer size={18} />
                <span>Print</span>
              </button>

              <div className="relative">
                <button
                  onClick={handleShare}
                  className="action-button"
                  aria-label="Share certificate"
                >
                  <Share2 size={18} />
                  <span>Share</span>
                </button>

                {showShareOptions && (
                  <div className="share-dropdown">
                    <button onClick={copyToClipboard} className="share-option">
                      Copy Link
                    </button>
                    <a
                      href={`mailto:?subject=Plot Verification Certificate&body=Please check this plot verification: ${window.location.href}`}
                      className="share-option"
                    >
                      Email
                    </a>
                    <a
                      href={`https://wa.me/?text=${encodeURIComponent(`Plot Verification Certificate: ${window.location.href}`)}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="share-option"
                    >
                      WhatsApp
                    </a>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Certificate Card */}
        <div className="verification-card" ref={certificateRef}>
          {loading ? (
            <div className="verification-loading">
              <div className="loading-spinner"></div>
              <p className="loading-text">Verifying plot details...</p>
            </div>
          ) : error ? (
            <div className="verification-error">
              <AlertCircle className="error-icon" />
              <h3 className="error-title">Verification Failed</h3>
              <p className="error-message">{error}</p>
              <p className="error-help">
                Please ensure you are using a valid QR code or contact support for assistance.
              </p>
            </div>
          ) : (
            <div className="certificate-container">
              {/* Certificate Header */}
              <div className="certificate-header">
                <div className="certificate-seal">
                  <Shield className="seal-icon" />
                </div>
                <div className="certificate-title-container">
                  <h2 className="certificate-title">Official Plot Verification</h2>
                  <p className="certificate-subtitle">This document certifies the ownership details of the plot</p>
                </div>
              </div>

              {/* Watermark */}
              <div className="certificate-watermark">VERIFIED</div>

              {/* Verification Status */}
              <div className="verification-status">
                <CheckCircle2 className="status-icon" />
                <h2 className="status-text">
                  Plot Confirmation Verified
                </h2>
              </div>

              {/* Certificate Number and Date */}
              <div className="certificate-meta">
                <div className="certificate-meta-item">
                  <span className="meta-label">Certificate No:</span>
                  <span className="meta-value">{certificateNumber}</span>
                </div>
                <div className="certificate-meta-item">
                  <span className="meta-label">Verification Date:</span>
                  <span className="meta-value">{formatDate(new Date())}</span>
                </div>
              </div>

              {/* Plot Details Section */}
              <div className="certificate-section">
                <div className="section-header">
                  <MapPin className="section-icon" />
                  <h3 className="section-title">Plot Details</h3>
                </div>
                <div className="section-content">
                  <div className="detail-grid">
                    <div className="detail-item">
                      <div className="detail-label">Plot Number</div>
                      <div className="detail-value highlight">{verificationData?.plot_no}</div>
                    </div>
                    <div className="detail-item">
                      <div className="detail-label">Category</div>
                      <div className="detail-value">{verificationData?.category}</div>
                    </div>
                    <div className="detail-item">
                      <div className="detail-label">Size</div>
                      <div className="detail-value">{verificationData?.size} sq. ft.</div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Owner Information Section */}
              <div className="certificate-section">
                <div className="section-header">
                  <Calendar className="section-icon" />
                  <h3 className="section-title">Owner Information</h3>
                </div>
                <div className="section-content">
                  <div className="detail-grid">
                    <div className="detail-item">
                      <div className="detail-label">Name</div>
                      <div className="detail-value">{verificationData?.name}</div>
                    </div>
                    <div className="detail-item">
                      <div className="detail-label">CNIC</div>
                      <div className="detail-value">{verificationData?.cnic}</div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Official Verification Seal */}
              <div className="verification-seal-section">
                <div className="official-seal">
                  <div className="seal-border">
                    <div className="seal-content">
                      <Shield className="seal-icon-large" />
                      <div className="seal-text">
                        <div className="seal-title">OFFICIALLY VERIFIED</div>
                        <div className="seal-subtitle">DHA MARKETPLACE</div>
                        <div className="seal-date">{formatDate(new Date())}</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Certificate Footer */}
              <div className="certificate-footer-enhanced">
                <div className="footer-content">
                  <div className="footer-logo-section">
                    <Image
                      src="images/logo.png"
                      alt="DHA Marketplace Logo"
                      width={140}
                      height={50}
                      className="footer-logo-image"
                    />
                    <div className="footer-authority">
                      <h4>Defence Housing Authority</h4>
                      <p>Official Plot Verification System</p>
                    </div>
                  </div>
                  
                  <div className="footer-verification-info">
                    <div className="verification-details">
                      <div className="verification-item">
                        <span className="verification-label">Certificate No:</span>
                        <span className="verification-value">{certificateNumber}</span>
                      </div>
                      <div className="verification-item">
                        <span className="verification-label">Verification Date:</span>
                        <span className="verification-value">{formatDate(new Date())}</span>
                      </div>
                      <div className="verification-item">
                        <span className="verification-label">Status:</span>
                        <span className="verification-value verified">VERIFIED ✓</span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <div className="footer-disclaimer">
                  <p className="disclaimer-text">
                    This is an official verification document generated from DHA Marketplace records. 
                    The information displayed has been verified and authenticated. This document serves as 
                    proof of plot ownership verification at the time of generation.
                  </p>
                  <p className="copyright-text">
                    © {new Date().getFullYear()} DHA Marketplace. All rights reserved. 
                    Unauthorized reproduction or distribution is prohibited.
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Support Information */}
        {!loading && !error && verificationData && (
          <div className="verification-support">
            <p>For any inquiries regarding this verification, please contact our support team.</p>
            <p>Email: support@dhamarketplace.com | Phone: +92-XXX-XXXXXXX</p>
          </div>
        )}
      </div>
    </div>
  );
}

// Loading fallback component
function VerifyPlotLoading() {
  return (
    <div className="verification-container">
      <div className="max-w-4xl mx-auto">
        <div className="verification-card">
          <div className="verification-loading">
            <div className="loading-spinner"></div>
            <p className="loading-text">Loading verification page...</p>
          </div>
        </div>
      </div>
    </div>
  );
}

// Main component with Suspense boundary
export default function VerifyPlotPage() {
  return (
    <Suspense fallback={<VerifyPlotLoading />}>
      <VerifyPlotContent />
    </Suspense>
  );
}