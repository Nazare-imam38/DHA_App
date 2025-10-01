"use client";

import { motion } from "framer-motion";
import { useRouter } from "next/navigation";

export default function NotFound() {
  const router = useRouter();

  return (
    <div className="min-h-screen bg-white flex flex-col items-center justify-center p-4 overflow-hidden relative">
      {/* Background elements matching the design system */}
      <div className="absolute inset-0 pointer-events-none select-none">
        <div className="absolute -top-10 -left-10 w-40 h-40 sm:w-60 sm:h-60 rounded-2xl rotate-12 opacity-20" style={{ background: '#B2F1E7' }}></div>
        <div className="absolute -bottom-16 -right-16 w-56 h-56 sm:w-80 sm:h-80 rounded-2xl rotate-12 opacity-10" style={{ background: '#E6FAF8' }}></div>
      </div>

      <motion.div 
        className="text-center relative z-10 w-full max-w-xl px-4"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        {/* DHA Logo */}
        <div className="flex justify-center mb-6">
          <img src="/images/logo.png" alt="DHA Logo" className="h-14 w-auto max-w-[120px]" style={{objectFit: 'contain'}} />
        </div>
        <div className="bg-white/80 backdrop-blur-lg rounded-2xl sm:rounded-3xl p-6 sm:p-8 border border-[#12AE9E]/30 shadow-xl">
          {/* Animated 404 icon */}
          <motion.div
            animate={{
              scale: [1, 1.05, 1],
              rotate: [0, 3, -3, 0],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              repeatType: "reverse",
            }}
            className="mb-6"
          >
            <div className="relative mx-auto w-24 h-24">
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="text-5xl font-bold text-[#1E3C90]">4</div>
              </div>
              <svg
                className="w-24 h-24 absolute inset-0 text-[#12AE9E]"
                viewBox="0 0 100 100"
              >
                <circle
                  cx="50"
                  cy="50"
                  r="45"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="4"
                  strokeDasharray="283"
                  strokeDashoffset="75"
                />
              </svg>
              <div className="absolute inset-0 flex items-center justify-center rotate-180">
                <div className="text-5xl font-bold text-[#1E3C90]">4</div>
              </div>
            </div>
          </motion.div>

          <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold mb-3 leading-tight" style={{ color: '#1E3C90' }}>
            Page <span className="text-[#12AE9E]">Not Found</span>
          </h1>
          
          <p className="text-base sm:text-lg mb-6" style={{ color: '#1E3C90' }}>
            The page you're looking for doesn't exist or has been moved.
            <br className="hidden sm:block" />
            Let's get you back on track.
          </p>

          <div className="flex flex-col sm:flex-row justify-center gap-4">
            <motion.button
              className="bg-gradient-to-r from-[#12AE9E] to-[#12AD9D] hover:from-[#0E9C8D] hover:to-[#0E8C7D] text-white font-semibold py-3 px-6 rounded-full shadow-md hover:shadow-lg transition-all"
              whileHover={{ y: -2 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => router.push('/')}
            >
              Return Home
            </motion.button>
            
            <motion.button
              className="bg-white text-[#1E3C90] font-semibold py-3 px-6 rounded-full border border-[#1E3C90]/30 shadow-md hover:shadow-lg transition-all"
              whileHover={{ y: -2 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => window.history.back()}
            >
              Go Back
            </motion.button>
          </div>

          <div className="mt-6 text-sm text-[#1E3C90]/70">
            Need help? Contact our support team.
          </div>
        </div>
      </motion.div>
    </div>
  );
}