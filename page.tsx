'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import DashboardHeader from "@/components/dashboard/dashboard-header";
import DiscountBanner from "@/components/marketing/discount-banner";
import MarketingPopup from "@/components/marketing/marketing-popup";
import Link from 'next/link';
import { PLOT_ENDPOINTS } from "@/utils/endpoints";
import { HorizontalBanner, SplashAd, EventAd } from "@/components/ads/AdBanner";
import { Calendar, MapPin as MapPinIcon, Users, ChevronLeft, ChevronRight } from "lucide-react";
import {
  FaHome,
  FaBuilding,
  FaStar,
  FaShieldAlt,
  FaMobile,
  FaChartLine,
  FaSearch,
  FaComments,
  FaCheckCircle,
  FaMapPin,
  FaLock,
  FaGem,
  FaPlay,
  FaChevronLeft,
  FaChevronRight
} from "react-icons/fa";

// Professional DHA Video Gallery Component
const DHAVideoGallery = () => {
  const [activeVideo, setActiveVideo] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [hasAutoPlayed, setHasAutoPlayed] = useState(false);
  const videoRef = React.useRef(null);

  const videos = [
    {
      id: 'MfEKjf9Yaw4',
      title: 'DHA Phase 1',
      description: 'Explore the premium residential and commercial areas of DHA Phase 1',
      phase: 'Phase 1'
    },
    {
      id: 'lpLshvlI6_k',
      title: 'DHA Phase 2',
      description: 'Discover the modern infrastructure and facilities of DHA Phase 2',
      phase: 'Phase 2'
    },
    {
      id: 's7SohXfiqN4',
      title: 'DHA Phase 3',
      description: 'Experience the luxury living standards of DHA Phase 3',
      phase: 'Phase 3'
    },
    {
      id: '-fUfdug0k4g',
      title: 'DHA Phase 4',
      description: 'Tour the well-planned community of DHA Phase 4',
      phase: 'Phase 4'
    },
    {
      id: 'xDt5K_PnoHA',
      title: 'DHA Phase 5',
      description: 'Witness the contemporary development of DHA Phase 5',
      phase: 'Phase 5'
    },
    {
      id: 'cQltJO5DU28',
      title: 'DHA Phase 6 & 7',
      description: 'Explore the latest developments in DHA Phase 6 and 7',
      phase: 'Phase 6 & 7'
    }
  ];

  const nextVideo = () => {
    setActiveVideo((prev) => (prev + 1) % videos.length);
    setIsPlaying(false);
  };

  const prevVideo = () => {
    setActiveVideo((prev) => (prev - 1 + videos.length) % videos.length);
    setIsPlaying(false);
  };

  const selectVideo = (index: number) => {
    setActiveVideo(index);
    setIsPlaying(false);
  };

  // Autoplay when video comes into viewport
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !hasAutoPlayed) {
            setTimeout(() => {
              setIsPlaying(true);
              setHasAutoPlayed(true);
            }, 1500); // Delay to let the animation complete
          }
        });
      },
      {
        threshold: 0.5, // Trigger when 50% of the video is visible
        rootMargin: '0px 0px -100px 0px' // Trigger a bit before it's fully visible
      }
    );

    if (videoRef.current) {
      observer.observe(videoRef.current);
    }

    return () => {
      if (videoRef.current) {
        observer.unobserve(videoRef.current);
      }
    };
  }, [hasAutoPlayed]);

  return (
    <div className="max-w-6xl mx-auto">
      {/* Main Video Player */}
      <motion.div
        ref={videoRef}
        className="relative mb-8"
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6 }}
      >
        <div className="relative aspect-video rounded-2xl overflow-hidden shadow-2xl bg-black max-w-4xl mx-auto">
          {!isPlaying ? (
            <div className="relative w-full h-full group cursor-pointer" onClick={() => setIsPlaying(true)}>
              <img
                src={`https://img.youtube.com/vi/${videos[activeVideo].id}/maxresdefault.jpg`}
                alt={videos[activeVideo].title}
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-black/30 group-hover:bg-black/20 transition-all duration-300" />
              <div className="absolute inset-0 flex items-center justify-center">
                <motion.div
                  className="w-20 h-20 bg-white/90 rounded-full flex items-center justify-center shadow-2xl group-hover:bg-white group-hover:scale-110 transition-all duration-300"
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <FaPlay className="text-[#1E3C90] text-2xl ml-1" />
                </motion.div>
              </div>
              <div className="absolute bottom-6 left-6 text-white">
                <h3 className="text-2xl font-bold mb-2">{videos[activeVideo].title}</h3>
                <p className="text-white/90">{videos[activeVideo].description}</p>
              </div>
            </div>
          ) : (
            <iframe
              src={`https://www.youtube.com/embed/${videos[activeVideo].id}?autoplay=1&rel=0&modestbranding=1`}
              title={videos[activeVideo].title}
              className="w-full h-full"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          )}

          {/* Navigation Arrows */}
          <button
            onClick={prevVideo}
            className="absolute left-4 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/10 backdrop-blur-md rounded-full flex items-center justify-center text-white hover:bg-white/20 transition-all duration-300 z-10"
          >
            <FaChevronLeft className="text-lg" />
          </button>
          <button
            onClick={nextVideo}
            className="absolute right-4 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/10 backdrop-blur-md rounded-full flex items-center justify-center text-white hover:bg-white/20 transition-all duration-300 z-10"
          >
            <FaChevronRight className="text-lg" />
          </button>
        </div>
      </motion.div>

      {/* Video Thumbnails Grid */}
      <motion.div
        className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4"
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6, delay: 0.2 }}
      >
        {videos.map((video, index) => (
          <motion.div
            key={video.id}
            className={`relative cursor-pointer group ${activeVideo === index ? 'ring-4 ring-[#12AD9D]' : ''
              }`}
            onClick={() => selectVideo(index)}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <div className="aspect-video rounded-xl overflow-hidden shadow-lg">
              <img
                src={`https://img.youtube.com/vi/${video.id}/mqdefault.jpg`}
                alt={video.title}
                className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
              />
              <div className="absolute inset-0 bg-black/20 group-hover:bg-black/10 transition-all duration-300" />
              <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                <div className="w-8 h-8 bg-white/90 rounded-full flex items-center justify-center">
                  <FaPlay className="text-[#1E3C90] text-sm ml-0.5" />
                </div>
              </div>
            </div>
            <div className="mt-3 text-center">
              <h4 className="font-bold text-[#1E3C90] text-sm">{video.phase}</h4>
              <p className="text-xs text-gray-600 mt-1 line-clamp-2">{video.description}</p>
            </div>
          </motion.div>
        ))}
      </motion.div>

      {/* Phase Statistics */}
      <motion.div
        className="mt-12 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4"
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6, delay: 0.4 }}
      >

      </motion.div>
    </div>
  );
};

// Events Slider Component
const EventsSlider = () => {
  const [currentSlide, setCurrentSlide] = useState(0);

  // Events data
  const events = [
    {
      id: 1,
      title: "DHA Phase 6 Launch Event",
      date: "March 15, 2024",
      time: "2:00 PM - 6:00 PM",
      location: "DHA Islamabad Head Office",
      description: "Exclusive launch event for new residential plots in Phase 6. Meet with property experts and get early access to premium locations.",
      image: "/images/event-ad-test.png",
      category: "Property Launch",
      attendees: "150+",
      price: "Free Entry"
    },
    {
      id: 2,
      title: "Investment Seminar 2024",
      date: "March 22, 2024",
      time: "10:00 AM - 4:00 PM",
      location: "DHA Commercial Center",
      description: "Learn about DHA property investment strategies, market trends, and legal aspects from industry experts.",
      image: "/images/event-ad-test.png",
      category: "Educational",
      attendees: "200+",
      price: "PKR 2,000"
    },
    {
      id: 3,
      title: "DHA Property Expo",
      date: "April 5, 2024",
      time: "11:00 AM - 8:00 PM",
      location: "DHA Exhibition Hall",
      description: "Annual property exhibition showcasing all DHA phases, amenities, and investment opportunities.",
      image: "/images/event-ad-test.png",
      category: "Exhibition",
      attendees: "500+",
      price: "PKR 500"
    },
    {
      id: 4,
      title: "Legal Documentation Workshop",
      date: "April 12, 2024",
      time: "3:00 PM - 5:00 PM",
      location: "DHA Legal Department",
      description: "Understanding property documentation, legal requirements, and compliance procedures for DHA properties.",
      image: "/images/event-ad-test.png",
      category: "Workshop",
      attendees: "80+",
      price: "PKR 1,500"
    },
    {
      id: 5,
      title: "DHA Phase 7 Preview",
      date: "April 20, 2024",
      time: "1:00 PM - 5:00 PM",
      location: "DHA Phase 7 Site",
      description: "Exclusive preview of upcoming DHA Phase 7 development with site tour and investment opportunities.",
      image: "/images/event-ad-test.png",
      category: "Preview",
      attendees: "100+",
      price: "PKR 3,000"
    },
    {
      id: 6,
      title: "DHA Investment Summit",
      date: "May 10, 2024",
      time: "9:00 AM - 6:00 PM",
      location: "DHA Conference Center",
      description: "Annual investment summit bringing together property experts, investors, and DHA officials for networking and insights.",
      image: "/images/event-ad-test.png",
      category: "Summit",
      attendees: "300+",
      price: "PKR 5,000"
    }
  ];

  const totalSlides = Math.ceil(events.length / 3);
  
  const nextSlide = () => {
    setCurrentSlide((prev) => (prev + 1) % totalSlides);
  };

  const prevSlide = () => {
    setCurrentSlide((prev) => (prev - 1 + totalSlides) % totalSlides);
  };

  const getCurrentEvents = () => {
    const startIndex = currentSlide * 3;
    return events.slice(startIndex, startIndex + 3);
  };

  return (
    <div className="max-w-7xl mx-auto relative">
      {/* Navigation Arrows */}
      <button
        onClick={prevSlide}
        className="absolute left-4 top-1/2 -translate-y-1/2 z-10 w-12 h-12 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center text-gray-700 hover:bg-white shadow-lg border border-gray-200 transition-all duration-300 hover:scale-110"
      >
        <ChevronLeft className="h-6 w-6" />
      </button>
      
      <button
        onClick={nextSlide}
        className="absolute right-4 top-1/2 -translate-y-1/2 z-10 w-12 h-12 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center text-gray-700 hover:bg-white shadow-lg border border-gray-200 transition-all duration-300 hover:scale-110"
      >
        <ChevronRight className="h-6 w-6" />
      </button>

      {/* Events Grid */}
      <div className="relative overflow-hidden rounded-2xl">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentSlide}
            initial={{ opacity: 0, x: 100 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -100 }}
            transition={{ duration: 0.5, ease: "easeInOut" }}
            className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
          >
            {getCurrentEvents().map((event, index) => (
              <motion.div
                key={event.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                className="bg-white rounded-2xl shadow-xl overflow-hidden hover:shadow-2xl transition-all duration-300 hover:scale-105"
              >
                {/* Event Image */}
                <div className="relative h-48 overflow-hidden">
                  <img
                    src={event.image}
                    alt={event.title}
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute inset-0 bg-black/20"></div>
                  
                  {/* Event Badge */}
                  <div className="absolute top-4 left-4">
                    <span className="bg-white/90 backdrop-blur-sm text-[#1E3C90] px-3 py-1 rounded-full text-xs font-semibold">
                      {event.category}
                    </span>
                  </div>
                  
                  {/* Event Price */}
                  <div className="absolute top-4 right-4">
                    <span className="bg-[#12AD9D] text-white px-3 py-1 rounded-full text-xs font-semibold">
                      {event.price}
                    </span>
                  </div>
                </div>

                {/* Event Details */}
                <div className="p-6">
                  <div className="space-y-4">
                    <div>
                      <h3 className="text-xl font-bold text-gray-800 mb-2 line-clamp-2">
                        {event.title}
                      </h3>
                      <p className="text-gray-600 text-sm leading-relaxed line-clamp-3">
                        {event.description}
                      </p>
                    </div>

                    <div className="space-y-3">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                          <Calendar className="h-4 w-4 text-[#1E3C90]" />
                        </div>
                        <div>
                          <p className="font-semibold text-gray-800 text-sm">{event.date}</p>
                          <p className="text-xs text-gray-600">{event.time}</p>
                        </div>
                      </div>

                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                          <MapPinIcon className="h-4 w-4 text-green-600" />
                        </div>
                        <div>
                          <p className="font-semibold text-gray-800 text-sm">Location</p>
                          <p className="text-xs text-gray-600">{event.location}</p>
                        </div>
                      </div>

                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                          <Users className="h-4 w-4 text-purple-600" />
                        </div>
                        <div>
                          <p className="font-semibold text-gray-800 text-sm">Attendees</p>
                          <p className="text-xs text-gray-600">{event.attendees}</p>
                        </div>
                      </div>
                    </div>

                    <div className="pt-2">
                      <button className="w-full bg-gradient-to-r from-[#1E3C90] to-[#12AD9D] text-white py-2 px-4 rounded-lg font-semibold hover:shadow-lg transition-all duration-300 hover:scale-105 text-sm">
                        Register for Event
                      </button>
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Slide Indicators */}
      <div className="flex justify-center mt-8 gap-2">
        {Array.from({ length: totalSlides }, (_, index) => (
          <button
            key={index}
            onClick={() => setCurrentSlide(index)}
            className={`w-3 h-3 rounded-full transition-all duration-300 ${
              index === currentSlide
                ? 'bg-[#1E3C90] scale-125'
                : 'bg-gray-300 hover:bg-gray-400'
            }`}
          />
        ))}
      </div>

      {/* Slide Counter */}
      <div className="text-center mt-4">
        <p className="text-sm text-gray-600">
          Page {currentSlide + 1} of {totalSlides}
        </p>
      </div>
    </div>
  );
};

const typewriterWords = [
  { text: 'MARKETPLACE', color: '#12AE9E' },
  { text: 'OFFICIAL PORTAL', color: '#1E3C90' },
  { text: 'TRUSTED PLATFORM', color: '#12AE9E' },
];

const DhaMarketplaceLanding = () => {
  const [typeIndex, setTypeIndex] = useState(0);
  const [displayed, setDisplayed] = useState('');
  const [typing, setTyping] = useState(true);
  const [showSplash, setShowSplash] = useState(true); // Show splash ad for testing

  // Add state for plot stats
  type PlotStatsType = {
    total_plots: number;
    plot_categories: {
      residential: number;
      commercial: number;
    };
  };
  const [plotStats, setPlotStats] = useState<PlotStatsType | null>(null);
  const [statsLoading, setStatsLoading] = useState(true);



  useEffect(() => {
    let timeout: NodeJS.Timeout;
    if (typing) {
      if (displayed.length < typewriterWords[typeIndex].text.length) {
        timeout = setTimeout(() => {
          setDisplayed(typewriterWords[typeIndex].text.slice(0, displayed.length + 1));
        }, 80);
      } else {
        timeout = setTimeout(() => setTyping(false), 1200);
      }
    } else {
      timeout = setTimeout(() => {
        setTyping(true);
        setDisplayed('');
        setTypeIndex((prev) => (prev + 1) % typewriterWords.length);
      }, 600);
    }
    return () => clearTimeout(timeout);
  }, [displayed, typing, typeIndex]);

  useEffect(() => {
    async function fetchStats() {
      setStatsLoading(true);
      try {
        const res = await fetch(PLOT_ENDPOINTS.DASHBOARD_PLOT_STATS);
        const data = await res.json();
        if (data.success) {
          setPlotStats(data.data);
        }
      } catch (e) {
        console.error("Failed to load stats:", e);
      }
      setStatsLoading(false);
    }
    fetchStats();
  }, []);

  return (
    <div className="min-h-screen bg-white overflow-x-hidden">
      <DashboardHeader />
      
      {/* Splash Ad - Show for testing */}
      {showSplash && (
        <SplashAd onClose={() => setShowSplash(false)} />
      )}
      
      {/* Horizontal Banner Ad - Top */}
      <div className="w-full mb-8">
        <HorizontalBanner className="mb-0" />
      </div>
      
      {/* DHA MarketPlace Coming Soon Hero Section */}
      <section className="relative overflow-hidden bg-white min-h-[calc(100vh-80px)] flex items-center justify-center pt-4">
        {/* Animated Background Elements */}
        <div className="absolute inset-0 overflow-hidden">
          <motion.div
            className="absolute top-10 left-10 w-60 h-60 rounded-full bg-[#12AD9D]/10 backdrop-blur-sm"
            animate={{
              rotate: 360,
              scale: [1, 1.1, 1]
            }}
            transition={{
              duration: 20,
              repeat: Infinity,
              ease: "linear"
            }}
          />
          <motion.div
            className="absolute bottom-10 right-10 w-72 h-72 rounded-full bg-[#1E3C90]/5 backdrop-blur-sm"
            animate={{
              rotate: -360,
              scale: [1.1, 1, 1.1]
            }}
            transition={{
              duration: 25,
              repeat: Infinity,
              ease: "linear"
            }}
          />
          <motion.div
            className="absolute top-1/2 left-1/3 w-24 h-24 rounded-full bg-[#12AD9D]/15 backdrop-blur-sm"
            animate={{
              y: [-15, 15, -15],
              x: [-8, 8, -8]
            }}
            transition={{
              duration: 8,
              repeat: Infinity,
              ease: "easeInOut"
            }}
          />
        </div>

        <div className="container mx-auto px-4 py-8 relative z-10">
          <div className="grid lg:grid-cols-2 gap-12 items-center">

            {/* Left Content */}
            <motion.div
              className="text-center lg:text-left"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
            >
              {/* DHA Logo */}
              <motion.div
                className="mb-8 flex justify-center lg:justify-start"
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.2, duration: 0.6 }}
              >
                <div className="text-6xl md:text-8xl font-bold text-[#1E3C90] drop-shadow-lg">
                  DHA
                </div>
              </motion.div>

              {/* Animated Title */}
              <motion.h1
                className="text-4xl md:text-6xl lg:text-7xl font-bold mb-6 leading-tight"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.4 }}
              >
                <span className="block mb-2" style={{ color: typewriterWords[typeIndex].color }}>
                  {displayed}
                  <motion.span
                    className="ml-2"
                    animate={{ opacity: [1, 0, 1] }}
                    transition={{ duration: 1, repeat: Infinity }}
                    style={{ color: typewriterWords[typeIndex].color }}
                  >
                    |
                  </motion.span>
                </span>
              </motion.h1>

              {/* Official Badge */}
              <motion.div
                className="bg-gradient-to-r from-[#12AD9D]/10 to-[#1E3C90]/10 backdrop-blur-md rounded-2xl p-6 mb-8 border border-[#12AD9D]/30 text-center"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.6 }}
              >
                {statsLoading ? (
                  <motion.div
                    className="inline-flex items-center gap-3 text-[#1E3C90]"
                    animate={{
                      scale: [1, 1.05, 1],
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "easeInOut"
                    }}
                  >
                    <div className="w-3 h-3 bg-[#12AD9D] rounded-full animate-pulse"></div>
                    <p className="text-lg font-bold">LOADING PLOTS...</p>
                    <div className="w-3 h-3 bg-[#12AD9D] rounded-full animate-pulse"></div>
                  </motion.div>
                ) : (
                  <motion.div
                    className="flex flex-col sm:flex-row items-center justify-center gap-3 sm:gap-6 text-[#1E3C90] px-2"
                    animate={{
                      scale: [1, 1.05, 1],
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "easeInOut"
                    }}
                  >
                    <div className="hidden sm:block w-3 h-3 bg-[#12AD9D] rounded-full animate-pulse"></div>

                    <div className="flex items-center gap-2">
                      <FaHome className="text-[#12AD9D] text-sm" />
                      <span className="text-base md:text-lg font-bold text-[#12AD9D]">
                        {plotStats?.plot_categories?.residential?.toLocaleString() ?? '0'}
                      </span>
                      <span className="text-xs md:text-sm font-medium text-gray-600">Residential</span>
                    </div>

                    <div className="w-1 h-1 bg-gray-400 rounded-full"></div>

                    <div className="flex items-center gap-2">
                      <FaBuilding className="text-[#1E3C90] text-sm" />
                      <span className="text-base md:text-lg font-bold text-[#1E3C90]">
                        {plotStats?.plot_categories?.commercial?.toLocaleString() ?? '0'}
                      </span>
                      <span className="text-xs md:text-sm font-medium text-gray-600">Commercial</span>
                    </div>

                    <div className="hidden sm:block w-3 h-3 bg-[#12AD9D] rounded-full animate-pulse"></div>
                  </motion.div>
                )}

              </motion.div>

              {/* Description */}
              <motion.p
                className="text-lg md:text-xl text-gray-600 mb-8 leading-relaxed"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.8 }}
              >
                Pakistan's premier DHA property marketplace. Discover verified DHA properties, connect with trusted buyers and sellers, and experience seamless, secure property transactions across all DHA phases.
              </motion.p>

              {/* CTA Buttons */}
              <motion.div
                className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 1 }}
              >
                <Link href="/dashboard">
                  <motion.button
                    className="bg-gradient-to-r from-[#12AD9D] to-[#1E3C90] text-white font-bold py-4 px-8 rounded-full text-lg shadow-xl hover:shadow-2xl transition-all duration-300"
                    whileHover={{ scale: 1.05, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    Explore Plots
                  </motion.button>
                </Link>
                <Link href="/profile">
                  <motion.button
                    className="bg-transparent border-2 border-[#1E3C90] text-[#1E3C90] font-bold py-4 px-8 rounded-full text-lg hover:bg-[#1E3C90] hover:text-white transition-all duration-300"
                    whileHover={{ scale: 1.05, y: -2 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    See Bookings
                  </motion.button>
                </Link>
              </motion.div>
            </motion.div>

            {/* Right Content - DHA MarketPlace Preview */}
            <motion.div
              className="relative"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.3 }}
            >
              <div className="relative">
                {/* Floating Animation Container */}
                <motion.div
                  animate={{
                    y: [-10, 10, -10],
                    rotate: [0, 2, -2, 0]
                  }}
                  transition={{
                    duration: 6,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                >
                  <img
                    src="/images/1080x1080.jpg"
                    alt="DHA MarketPlace Properties"
                    className="w-full max-w-lg mx-auto rounded-3xl shadow-2xl border-4 border-white/20"
                  />
                </motion.div>

                {/* Decorative Elements */}
                <motion.div
                  className="absolute top-4 right-4 w-10 h-10 bg-[#12AD9D] rounded-full flex items-center justify-center shadow-lg"
                  animate={{
                    scale: [1, 1.1, 1],
                    rotate: [0, 180, 360]
                  }}
                  transition={{
                    duration: 4,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                >
                  <FaStar className="text-white text-sm" />
                </motion.div>

                <motion.div
                  className="absolute bottom-4 left-4 w-12 h-12 bg-[#1E3C90]/20 backdrop-blur-sm rounded-full border border-[#1E3C90]/30"
                  animate={{
                    scale: [1, 1.05, 1],
                    opacity: [0.7, 1, 0.7]
                  }}
                  transition={{
                    duration: 3,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                />
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* DHA Phases Video Gallery Section */}
      <section className="py-20 bg-gradient-to-b from-gray-50 to-white">
        <div className="container mx-auto px-4">
          <motion.div
            className="text-center mb-16"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
          >
            <motion.div
              className="inline-block mb-6"
              animate={{
                scale: [1, 1.05, 1],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            >
              <div className="bg-[#12AD9D]/10 text-[#12AD9D] text-sm font-bold py-2 px-6 rounded-full border border-[#12AD9D]/30">
                EXPLORE DHA PHASES
              </div>
            </motion.div>
            <h2 className="text-4xl md:text-5xl font-bold text-[#1E3C90] mb-6">
              Discover <span className="text-[#12AD9D]">DHA Islamabad-Rawalpindi</span>
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Take a virtual tour of all DHA phases and explore the premium lifestyle and world-class infrastructure
            </p>
          </motion.div>

          <DHAVideoGallery />
        </div>
      </section>

      {/* Events Section with Detailed Slider */}
      <section className="py-20 bg-gradient-to-br from-gray-50 to-blue-50">
        <div className="container mx-auto px-4">
          <motion.div
            className="text-center mb-16"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
          >
            <motion.div
              className="inline-block mb-6"
              animate={{
                scale: [1, 1.05, 1],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut"
              }}
            >
              <div className="bg-[#1E3C90]/10 text-[#1E3C90] text-sm font-bold py-2 px-6 rounded-full border border-[#1E3C90]/30">
                UPCOMING EVENTS
              </div>
            </motion.div>
            <h2 className="text-4xl md:text-5xl font-bold text-[#1E3C90] mb-6">
              Join Our <span className="text-[#12AD9D]">Exclusive Events</span>
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Stay updated with the latest DHA property opportunities and investment seminars
            </p>
          </motion.div>

          <EventsSlider />
        </div>
      </section>

       {/* Official Footer */}
       <footer className="bg-white">
         <div className="container mx-auto px-4 py-16">
           <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-12">
             
             {/* DHA MarketPlace Information */}
             <div className="space-y-4">
               {/* Logo */}
               <div className="flex items-center gap-3 mb-4">
                 <div className="w-12 h-12 bg-[#1E3C90] rounded-full flex items-center justify-center">
                   <span className="text-white font-bold text-lg">D</span>
                 </div>
                 <div>
                   <div className="text-[#1E3C90] font-bold text-lg">DHA MARKETPLACE</div>
                   <div className="text-[#12AD9D] font-semibold text-sm">DIGITAL PROPERTY PORTAL</div>
                 </div>
               </div>
               
               {/* Title */}
               <h3 className="text-2xl font-bold text-[#1E3C90]">DHA MarketPlace</h3>
               
               {/* Description */}
               <p className="text-gray-600 text-sm leading-relaxed">
                 Pakistan's premier DHA property marketplace. Discover verified DHA properties, connect with trusted buyers and sellers, and experience seamless, secure property transactions across all DHA phases.
               </p>
               
               {/* Social Media Icons */}
               <div className="flex gap-3 mt-4">
                 <div className="w-8 h-8 bg-[#1E3C90] rounded-full flex items-center justify-center">
                   <span className="text-white text-sm font-bold">f</span>
                 </div>
                 <div className="w-8 h-8 bg-[#1E3C90] rounded-full flex items-center justify-center">
                   <span className="text-white text-sm">▶</span>
                 </div>
                 <div className="w-8 h-8 bg-[#1E3C90] rounded-full flex items-center justify-center">
                   <span className="text-white text-sm">📷</span>
                 </div>
               </div>
             </div>

             {/* Quick Links */}
             <div className="space-y-4">
               <h3 className="text-lg font-bold text-[#1E3C90]">Quick Links</h3>
               <div className="space-y-2">
                 {[
                   { name: "View Properties", href: "/dashboard" },
                   { name: "Register", href: "/register" },
                   { name: "Login", href: "/login" },
                   { name: "My Profile", href: "/profile" }
                 ].map((link, index) => (
                   <Link key={index} href={link.href}>
                     <div className="text-gray-600 hover:text-[#1E3C90] transition-colors duration-300 text-sm">
                       {link.name}
                     </div>
                   </Link>
                 ))}
               </div>
             </div>

             {/* Services */}
             <div className="space-y-4">
               <h3 className="text-lg font-bold text-[#1E3C90]">Services</h3>
               <div className="space-y-2">
                 {[
                   { name: "Digital Property Portal" },
                   { name: "Plot Booking" },
                   { name: "Payment Plans" },
                   { name: "Documentation" }
                 ].map((service, index) => (
                   <div key={index} className="text-gray-600 text-sm">
                     {service.name}
                   </div>
                 ))}
               </div>
             </div>

             {/* Contact Info */}
             <div className="space-y-4">
               <h3 className="text-lg font-bold text-[#1E3C90]">Contact Info</h3>
               <div className="space-y-3">
                 <div className="flex items-start gap-3">
                   <div className="w-4 h-4 bg-[#1E3C90] rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                     <span className="text-white text-xs">📍</span>
                   </div>
                   <div>
                     <p className="text-gray-600 text-sm leading-relaxed">
                       DHA Islamabad-Rawalpindi<br />
                       Phase 1, Commercial Area<br />
                       Islamabad, Pakistan
                     </p>
                   </div>
                 </div>
                 
                 <div className="flex items-start gap-3">
                   <div className="w-4 h-4 bg-[#1E3C90] rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                     <span className="text-white text-xs">📞</span>
                   </div>
                   <div>
                     <p className="text-gray-600 text-sm">
                       +92-51-1234567
                     </p>
                   </div>
                 </div>
                 
                 <div className="flex items-start gap-3">
                   <div className="w-4 h-4 bg-[#1E3C90] rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                     <span className="text-white text-xs">✉</span>
                   </div>
                   <div>
                     <p className="text-gray-600 text-sm">
                       info@dhamarketplace.com
                     </p>
                   </div>
                 </div>
               </div>
             </div>
           </div>

           {/* Footer Bottom */}
           <div className="border-t border-gray-200 mt-12 pt-8">
             <div className="text-left">
               <span className="text-gray-500 text-sm">
                 © 2025 DHA MarketPlace. All rights reserved.
               </span>
             </div>
           </div>
         </div>
       </footer>

      {/* Horizontal Banner Ad - Bottom */}
      <div className="w-full mb-8">
        <HorizontalBanner className="mb-0" />
      </div>
    </div>
  );
};

export default DhaMarketplaceLanding; 