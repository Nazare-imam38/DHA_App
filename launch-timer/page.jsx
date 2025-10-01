// dha-marketplace/app/launch-timer/page.jsx
'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import Confetti from 'react-confetti';
import { useWindowSize } from 'react-use';

// IMPORTANT: Set the launch date here and in middleware.ts to the SAME value!
// July 8th, 2025 at 4:25 PM Pakistani Time (UTC+5) = 11:25 AM UTC on July 8th
const LAUNCH_DATE_STRING = '2025-07-08T19:00:00Z';
// For testing, set to 1 minute from now:
// const LAUNCH_DATE_STRING = new Date(Date.now() + 60 * 1000).toISOString();

const LaunchCountdown = () => {
  const router = useRouter();
  // Use the same launch date as the middleware
  const launchDate = new Date(LAUNCH_DATE_STRING);

  const [timeLeft, setTimeLeft] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
    milliseconds: 0
  });
  const [isLaunchTime, setIsLaunchTime] = useState(false);

  useEffect(() => {
    const calculateTimeLeft = () => {
      const now = new Date();
      const difference = launchDate.getTime() - now.getTime();
      if (difference <= 0) {
        setIsLaunchTime(true);
        return;
      }
      setTimeLeft({
        days: Math.floor(difference / (1000 * 60 * 60 * 24)),
        hours: Math.floor((difference / (1000 * 60 * 60)) % 24),
        minutes: Math.floor((difference / 1000 / 60) % 60),
        seconds: Math.floor((difference / 1000) % 60),
        milliseconds: Math.floor((difference % 1000) / 10)
      });
    };
    const timer = setInterval(calculateTimeLeft, 10);
    calculateTimeLeft();
    return () => clearInterval(timer);
  }, [launchDate]);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        when: "beforeChildren",
        staggerChildren: 0.2
      }
    }
  };
  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: {
        duration: 0.5
      }
    }
  };
  const digitVariants = {
    pulse: {
      scale: [1, 1.05, 1],
      transition: {
        duration: 0.5,
        repeat: Infinity,
        repeatType: "reverse"
      }
    }
  };

  const { width, height } = typeof window !== 'undefined' ? useWindowSize() : { width: 0, height: 0 };

  return (
    <div className="min-h-screen bg-white flex flex-col items-center justify-center p-2 sm:p-4 overflow-hidden">
      {/* Confetti when site is live */}
      {isLaunchTime && (
        <Confetti width={width} height={height} numberOfPieces={350} recycle={false} gravity={0.25} />
      )}
      {/* Background elements */}
      {/* Decorative background shapes for subtle accent, matching landing page */}
      <div className="absolute inset-0 pointer-events-none select-none">
        <div className="absolute -top-10 -left-10 w-40 h-40 sm:w-60 sm:h-60 rounded-2xl rotate-12 opacity-20" style={{ background: '#B2F1E7' }}></div>
        <div className="absolute -bottom-16 -right-16 w-56 h-56 sm:w-80 sm:h-80 rounded-2xl rotate-12 opacity-10" style={{ background: '#E6FAF8' }}></div>
      </div>

      <AnimatePresence>
        {!isLaunchTime ? (
          <motion.div
            className="text-center relative z-10 w-full max-w-4xl px-2 sm:px-0"
            variants={containerVariants}
            initial="hidden"
            animate="visible"
          >
            <motion.div variants={itemVariants} className="mb-6 sm:mb-8">
              <h1 className="text-2xl xs:text-3xl sm:text-4xl md:text-6xl font-bold mb-2 sm:mb-4 leading-tight" style={{ color: '#1E3C90' }}>
                DHA <span className="text-[#12AE9E]">Marketplace</span>
              </h1>
              <p className="text-base xs:text-lg sm:text-xl font-semibold" style={{ color: '#12AE9E' }}>
                Official Launch Countdown
              </p>
            </motion.div>

            <motion.div variants={itemVariants} className="mb-8 sm:mb-12">
              <h2 className="text-lg xs:text-xl sm:text-2xl md:text-3xl font-semibold mb-1 sm:mb-2" style={{ color: '#1E3C90' }}>
                We are launching on
              </h2>
              <p className="text-[#12AE9E] font-medium text-xs xs:text-sm sm:text-base">
                {launchDate.toLocaleString('en-US', {
                  weekday: 'long',
                  month: 'long',
                  day: 'numeric',
                  year: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit',
                  hour12: true,
                  timeZone: 'Asia/Karachi'
                })} PKT
              </p>
            </motion.div>

            {/* Countdown Timer */}
            <motion.div
              variants={itemVariants}
              className="grid grid-cols-2 xs:grid-cols-3 sm:grid-cols-5 gap-2 sm:gap-4 mb-8 sm:mb-16 w-full max-w-2xl mx-auto"
            >
              {[
                { value: timeLeft.days, label: 'Days' },
                { value: timeLeft.hours, label: 'Hours' },
                { value: timeLeft.minutes, label: 'Minutes' },
                { value: timeLeft.seconds, label: 'Seconds' },
                { value: timeLeft.milliseconds, label: 'ms' }
              ].map((unit, index) => (
                <motion.div
                  key={unit.label}
                  className="bg-white/80 backdrop-blur-lg rounded-xl p-2 xs:p-3 sm:p-4 border border-[#12AE9E] shadow-md flex flex-col items-center min-w-[70px]"
                  whileHover={{ scale: 1.05 }}
                >
                  <motion.div
                    className="text-xl xs:text-2xl sm:text-3xl md:text-5xl font-extrabold mb-1 sm:mb-2"
                    style={{ color: '#1E3C90' }}
                    key={`${unit.value}-${index}`}
                    animate="pulse"
                    variants={digitVariants}
                  >
                    {unit.value.toString().padStart(2, '0')}
                  </motion.div>
                  <div className="text-xs xs:text-sm sm:text-base text-[#12AE9E] uppercase tracking-wider font-semibold">
                    {unit.label}
                  </div>
                </motion.div>
              ))}
            </motion.div>

            <motion.div variants={itemVariants} className="mb-8 sm:mb-12">
              <div className="relative h-2 bg-[#E6FAF8] rounded-full overflow-hidden w-full max-w-2xl mx-auto">
                <motion.div
                  className="absolute top-0 left-0 h-full bg-gradient-to-r from-[#12AD9D] to-[#12AE9E]"
                  initial={{ width: '0%' }}
                  animate={{
                    width: (
                      100 - (
                        (
                          timeLeft.days * 24 * 60 * 60 +
                          timeLeft.hours * 60 * 60 +
                          timeLeft.minutes * 60 +
                          timeLeft.seconds
                        ) /
                        (1 * 60 * 60)
                      ) * 100
                    ).toString() + '%'
                  }}
                  transition={{ duration: 0.5 }}
                />
              </div>
            </motion.div>

            <motion.div variants={itemVariants}>
              <h3 className="text-base xs:text-lg sm:text-xl font-semibold mb-4 sm:mb-6" style={{ color: '#1E3C90' }}>
                Get ready for a revolutionary property trading experience
              </h3>
              <div className="flex flex-wrap justify-center gap-2 xs:gap-3 sm:gap-4 mb-6 sm:mb-8">
                {[
                  '100% Online Transactions',
                  'Real-Time Plot Availability',
                  'Official DHA Islamabad Portal'
                ].map((feature) => (
                  <motion.div
                    key={feature}
                    className="flex items-center bg-[#E6FAF8] px-2 xs:px-3 sm:px-4 py-1 xs:py-2 rounded-full border border-[#12AE9E]/30"
                    whileHover={{ scale: 1.05 }}
                  >
                    <svg
                      className="w-4 h-4 xs:w-5 xs:h-5 text-[#12AE9E] mr-1 xs:mr-2"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth="2"
                        d="M5 13l4 4L19 7"
                      />
                    </svg>
                    <span className="text-[#1E3C90] font-medium text-xs xs:text-sm sm:text-base">{feature}</span>
                  </motion.div>
                ))}
              </div>
            </motion.div>

            {/* Buttons removed as per request */}
          </motion.div>
        ) : (
          <motion.div
            className="text-center relative z-10 w-full px-2 sm:px-0"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5 }}
          >
            <div className="bg-gradient-to-br from-blue-600/20 to-blue-800/20 backdrop-blur-md p-4 xs:p-6 sm:p-12 rounded-2xl sm:rounded-3xl border border-blue-700/30 shadow-2xl w-full max-w-xl mx-auto">
              <motion.div
                animate={{
                  scale: [1, 1.05, 1],
                  rotate: [0, 2, -2, 0],
                }}
                transition={{
                  duration: 2,
                  repeat: Infinity,
                  repeatType: "reverse",
                }}
                className="mb-6 sm:mb-8"
              >
                <svg
                  className="w-16 h-16 xs:w-20 xs:h-20 sm:w-24 sm:h-24 mx-auto text-green-400"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </motion.div>
              <h1 className="text-2xl xs:text-3xl sm:text-4xl md:text-6xl font-bold mb-4 sm:mb-6 leading-tight" style={{ color: '#1E3C90' }}>
                We're <span className="text-blue-400">Live!</span>
              </h1>
              <p className="text-base xs:text-lg sm:text-xl mb-6 sm:mb-8 max-w-2xl mx-auto" style={{ color: '#1E3C90' }}>
                The DHA Marketplace is now open. Start exploring premium plots and
                make your investment today!
              </p>
              <motion.button
                className="bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-bold py-3 xs:py-4 px-6 xs:px-8 rounded-full text-base xs:text-lg shadow-lg hover:shadow-xl transition-all"
                whileHover={{ y: -2 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => router.push('/')}
              >
                Enter Marketplace
              </motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default function LaunchTimerPage() {
  return <LaunchCountdown />;
} 