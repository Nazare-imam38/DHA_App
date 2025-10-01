"use client";

import { useEffect } from "react";
import { motion } from "framer-motion";
import { useRouter } from "next/navigation";

export default function Error({ error, reset }) {
  const router = useRouter();
  
  useEffect(() => {
    // Optionally log error to an error reporting service
    // console.error(error);
  }, [error]);

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: '#f8fafc',
      color: '#1a202c',
      fontFamily: 'inherit',
      padding: '2rem'
    }}>
      <div style={{
        background: '#fff',
        borderRadius: '12px',
        boxShadow: '0 4px 24px rgba(0,0,0,0.08)',
        padding: '2rem 2.5rem',
        maxWidth: 400,
        textAlign: 'center'
      }}>
        {/* DHA Logo */}
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '1.5rem' }}>
          <img src="/images/logo.png" alt="DHA Logo" style={{ height: '56px', maxWidth: '120px', objectFit: 'contain' }} />
        </div>
        <h1 style={{ fontSize: '2rem', marginBottom: '0.5rem', color: '#004080' }}>Oops! Something went wrong.</h1>
        <p style={{ marginBottom: '1.5rem', color: '#555' }}>
          We apologize, but an unexpected error occurred.<br />
          Please try refreshing the page to continue.
        </p>
        <button
          onClick={() => reset()}
          style={{
            background: '#004080',
            color: '#fff',
            border: 'none',
            borderRadius: '6px',
            padding: '0.75rem 1.5rem',
            fontSize: '1rem',
            cursor: 'pointer',
            marginBottom: '0.5rem'
          }}
        >
          Refresh Page
        </button>
        <div style={{ fontSize: '0.85rem', color: '#888' }}>
          If the problem persists, please contact support.
        </div>
      </div>
    </div>
  );
}