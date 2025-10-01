"use client"

import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Card, CardContent } from "@/components/ui/card"
import { Mail, MapPin, Phone, Clock, Users, Award, Shield, ChevronLeft, ChevronRight, Calendar, MapPin as MapPinIcon } from "lucide-react"
import { useAuth } from "@/hooks/use-auth"
import { VerticalBanner, HorizontalBanner, EventAd } from "@/components/ads/AdBanner"
import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"

export default function ContactPage() {
  const { role } = useAuth()
  const [currentEventIndex, setCurrentEventIndex] = useState(0)

  // Events data
  const events = [
    {
      id: 1,
      title: "DHA Phase 6 Launch Event",
      date: "March 15, 2024",
      time: "2:00 PM - 6:00 PM",
      location: "DHA Islamabad Head Office",
      description: "Exclusive launch event for new residential plots in Phase 6. Meet with property experts and get early access to premium locations.",
      image: "/images/event-1.jpg",
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
      image: "/images/event-2.jpg",
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
      image: "/images/event-3.jpg",
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
      image: "/images/event-4.jpg",
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
      image: "/images/event-5.jpg",
      category: "Preview",
      attendees: "100+",
      price: "PKR 3,000"
    }
  ]

  const nextEvent = () => {
    setCurrentEventIndex((prev) => (prev + 1) % events.length)
  }

  const prevEvent = () => {
    setCurrentEventIndex((prev) => (prev - 1 + events.length) % events.length)
  }

  const goToEvent = (index) => {
    setCurrentEventIndex(index)
  }

  return (
    <div className="flex flex-col min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      <DashboardHeader />

      <main className="flex-1">
        {/* Hero Section */}
        <section className="relative bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] text-white py-20">
          <div className="absolute inset-0 bg-black/10"></div>
          <div className="relative container mx-auto px-4 text-center">
            <div className="flex justify-center mb-6">
              <img src="/images/dha-logo.png" alt="DHA Logo" className="h-20 w-20 rounded-full bg-white/10 p-2" />
            </div>
            <h1 className="text-4xl md:text-5xl font-bold mb-4">Get In Touch</h1>
            <p className="text-xl md:text-2xl text-blue-100 max-w-2xl mx-auto">
              Connect with DHA Marketplace - Your trusted partner in premium property investments
            </p>
          </div>
        </section>

                 {/* Contact Cards Section */}
         <section className="py-16 container mx-auto px-4">
           <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3 max-w-6xl mx-auto relative">
            
            {/* Office Location */}
            <Card className="group hover:shadow-xl transition-all duration-300 border-0 shadow-lg bg-white/80 backdrop-blur-sm">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                  <MapPin className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-xl font-bold text-gray-800 mb-4">Visit Our Office</h3>
                <div className="space-y-3 text-gray-600">
                  <p className="font-medium">DHA Islamabad Head Office</p>
                  <p>Defence Ave, Sector A DHA Phase 1, Islamabad</p>

                </div>
              </CardContent>
            </Card>

            {/* Phone Numbers */}
            <Card className="group hover:shadow-xl transition-all duration-300 border-0 shadow-lg bg-white/80 backdrop-blur-sm">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-r from-[#12AE9E] to-[#1E3C90] rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                  <Phone className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-xl font-bold text-gray-800 mb-4">Call Us</h3>
                <div className="space-y-4 text-gray-600">
                  <div className="p-3 bg-blue-50 rounded-lg">
                    <p className="font-semibold text-[#1E3C90]">Sales Department</p>
                    <p className="text-lg font-mono mb-2">+92-51-111-555-400</p>
                    <div className="text-sm">
                      <p className="font-medium text-gray-700 mb-1">Extensions:</p>
                      <div className="flex flex-wrap gap-2">
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1244</span>
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1258</span>
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1606</span>
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1381</span>
                      </div>
                    </div>
                  </div>
                  
                  <div className="p-3 bg-green-50 rounded-lg">
                    <p className="font-semibold text-green-700">Call Center</p>
                    <p className="text-lg font-mono mb-2">+92-51-111-555-400</p>
                    <div className="text-sm">
                      <p className="font-medium text-gray-700 mb-1">Extensions:</p>
                      <div className="flex flex-wrap gap-2">
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1301</span>
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1302</span>
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1303</span>
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1304</span>
                        <span className="bg-white px-2 py-1 rounded text-xs font-mono">1305</span>
                      </div>
                    </div>
                  </div>

                </div>
              </CardContent>
            </Card>

            {/* Email Addresses */}
            <Card className="group hover:shadow-xl transition-all duration-300 border-0 shadow-lg bg-white/80 backdrop-blur-sm md:col-span-2 lg:col-span-1">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-r from-[#1E3C90] via-[#12AE9E] to-[#1E3C90] rounded-full flex items-center justify-center mx-auto mb-6 group-hover:scale-110 transition-transform duration-300">
                  <Mail className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-xl font-bold text-gray-800 mb-4">Email Us</h3>
                <div className="space-y-3 text-gray-600">
                  <div className="p-3 bg-gray-50 rounded-lg">
                    <p className="font-semibold text-gray-700">Email Market Place</p>
                    <p className="text-sm text-blue-600">info@dhamarketplace.com</p>
                  </div>

                </div>
              </CardContent>
            </Card>
          </div>
        </section>

        {/* Google Maps Section */}
        <section className="py-16 bg-gray-50">
          <div className="container mx-auto px-4">
            <div className="text-center mb-12">
              <h2 className="text-3xl md:text-4xl font-bold text-gray-800 mb-4">Find Us on Map</h2>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto">
                Locate our DHA Islamabad Head Office easily with the interactive map below
              </p>
            </div>

            <div className="max-w-4xl mx-auto">
              <Card className="overflow-hidden shadow-xl border-0">
                <CardContent className="p-0">
                  <div className="relative w-full h-96 md:h-[500px]">
                    <iframe
                      src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3321.8!2d73.0479!3d33.6844!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x38dfbfd07891722f%3A0x6059515c2bce5b99!2sDefence%20Ave%2C%20DHA%20Phase%201%2C%20Islamabad%2C%20Islamabad%20Capital%20Territory%2C%20Pakistan!5e0!3m2!1sen!2s!4v1642678901234!5m2!1sen!2s"
                      width="100%"
                      height="100%"
                      style={{ border: 0 }}
                      allowFullScreen=""
                      loading="lazy"
                      referrerPolicy="no-referrer-when-downgrade"
                      title="DHA Islamabad Head Office Location"
                      className="absolute inset-0"
                    ></iframe>
                  </div>

                  {/* Map Info Overlay */}
                  <div className="p-6 bg-white border-t">
                    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] rounded-full flex items-center justify-center">
                          <MapPin className="h-5 w-5 text-white" />
                        </div>
                        <div>
                          <p className="font-semibold text-gray-800">DHA Islamabad Head Office</p>
                          <p className="text-sm text-gray-600">Defence Ave, Sector A DHA Phase 1, Islamabad</p>
                        </div>
                      </div>

                      <div className="flex gap-3">
                        <a
                          href="https://www.google.com/maps/dir//Defence+Ave,+DHA+Phase+1,+Islamabad,+Islamabad+Capital+Territory,+Pakistan"
                          target="_blank"
                          rel="noopener noreferrer"
                          className="bg-[#1E3C90] text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-[#1a3480] transition-colors duration-300"
                        >
                          Get Directions
                        </a>
                        <a
                          href="https://www.google.com/maps/place/Defence+Ave,+DHA+Phase+1,+Islamabad,+Islamabad+Capital+Territory,+Pakistan"
                          target="_blank"
                          rel="noopener noreferrer"
                          className="border border-[#1E3C90] text-[#1E3C90] px-4 py-2 rounded-lg text-sm font-medium hover:bg-[#1E3C90] hover:text-white transition-colors duration-300"
                        >
                          View Larger Map
                        </a>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </section>

        {/* Why Choose Us Section */}
        <section className="py-16 bg-white">
          <div className="container mx-auto px-4">
            <div className="text-center mb-12">
              <h2 className="text-3xl md:text-4xl font-bold text-gray-800 mb-4">Why Choose DHA Marketplace?</h2>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto">
                Your trusted partner for premium property investments in DHA Islamabad
              </p>
            </div>

            <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-4 max-w-6xl mx-auto">
              <div className="text-center group">
                <div className="w-16 h-16 bg-gradient-to-r from-blue-500 to-blue-600 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform duration-300">
                  <Shield className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-gray-800 mb-2">Secure Transactions</h3>
                <p className="text-gray-600 text-sm">100% secure and transparent property transactions</p>
              </div>

              <div className="text-center group">
                <div className="w-16 h-16 bg-gradient-to-r from-teal-500 to-teal-600 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform duration-300">
                  <Users className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-gray-800 mb-2">Expert Support</h3>
                <p className="text-gray-600 text-sm">Dedicated team of property investment experts</p>
              </div>

              <div className="text-center group">
                <div className="w-16 h-16 bg-gradient-to-r from-purple-500 to-purple-600 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform duration-300">
                  <Award className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-gray-800 mb-2">Premium Locations</h3>
                <p className="text-gray-600 text-sm">Exclusive access to prime DHA properties</p>
              </div>

              <div className="text-center group">
                <div className="w-16 h-16 bg-gradient-to-r from-green-500 to-green-600 rounded-full flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform duration-300">
                  <Clock className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-lg font-semibold text-gray-800 mb-2">Quick Processing</h3>
                <p className="text-gray-600 text-sm">Fast and efficient property booking process</p>
              </div>
            </div>
          </div>
        </section>

        {/* Events Slider Section */}
        <section className="py-20 bg-gradient-to-br from-gray-50 to-blue-50">
          <div className="container mx-auto px-4">
            <div className="text-center mb-16">
              <h2 className="text-3xl md:text-4xl font-bold text-gray-800 mb-4">Upcoming Events</h2>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto">
                Join our exclusive events and stay updated with the latest DHA property opportunities
              </p>
            </div>

            <div className="max-w-6xl mx-auto">
              {/* Main Event Slider */}
              <div className="relative">
                {/* Navigation Arrows */}
                <button
                  onClick={prevEvent}
                  className="absolute left-4 top-1/2 -translate-y-1/2 z-10 w-12 h-12 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center text-gray-700 hover:bg-white shadow-lg border border-gray-200 transition-all duration-300 hover:scale-110"
                >
                  <ChevronLeft className="h-6 w-6" />
                </button>
                
                <button
                  onClick={nextEvent}
                  className="absolute right-4 top-1/2 -translate-y-1/2 z-10 w-12 h-12 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center text-gray-700 hover:bg-white shadow-lg border border-gray-200 transition-all duration-300 hover:scale-110"
                >
                  <ChevronRight className="h-6 w-6" />
                </button>

                {/* Event Card */}
                <div className="relative overflow-hidden rounded-2xl shadow-2xl">
                  <AnimatePresence mode="wait">
                    <motion.div
                      key={currentEventIndex}
                      initial={{ opacity: 0, x: 100 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -100 }}
                      transition={{ duration: 0.5, ease: "easeInOut" }}
                      className="relative"
                    >
                      <div className="grid lg:grid-cols-2 gap-0">
                                                 {/* Event Image */}
                         <div className="relative h-80 lg:h-96 overflow-hidden">
                           <img
                             src="/images/event-ad-test.png"
                             alt={events[currentEventIndex].title}
                             className="w-full h-full object-cover"
                           />
                           <div className="absolute inset-0 bg-black/20"></div>
                          
                          {/* Event Badge */}
                          <div className="absolute top-6 left-6">
                            <span className="bg-white/90 backdrop-blur-sm text-[#1E3C90] px-4 py-2 rounded-full text-sm font-semibold">
                              {events[currentEventIndex].category}
                            </span>
                          </div>
                          
                          {/* Event Price */}
                          <div className="absolute top-6 right-6">
                            <span className="bg-[#12AE9E] text-white px-4 py-2 rounded-full text-sm font-semibold">
                              {events[currentEventIndex].price}
                            </span>
                          </div>
                        </div>

                        {/* Event Details */}
                        <div className="bg-white p-8 lg:p-12 flex flex-col justify-center">
                          <div className="space-y-6">
                            <div>
                              <h3 className="text-2xl lg:text-3xl font-bold text-gray-800 mb-3">
                                {events[currentEventIndex].title}
                              </h3>
                              <p className="text-gray-600 leading-relaxed">
                                {events[currentEventIndex].description}
                              </p>
                            </div>

                            <div className="space-y-4">
                              <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                                  <Calendar className="h-5 w-5 text-[#1E3C90]" />
                                </div>
                                <div>
                                  <p className="font-semibold text-gray-800">{events[currentEventIndex].date}</p>
                                  <p className="text-sm text-gray-600">{events[currentEventIndex].time}</p>
                                </div>
                              </div>

                              <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                                  <MapPinIcon className="h-5 w-5 text-green-600" />
                                </div>
                                <div>
                                  <p className="font-semibold text-gray-800">Location</p>
                                  <p className="text-sm text-gray-600">{events[currentEventIndex].location}</p>
                                </div>
                              </div>

                              <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center">
                                  <Users className="h-5 w-5 text-purple-600" />
                                </div>
                                <div>
                                  <p className="font-semibold text-gray-800">Expected Attendees</p>
                                  <p className="text-sm text-gray-600">{events[currentEventIndex].attendees}</p>
                                </div>
                              </div>
                            </div>

                            <div className="pt-4">
                              <button className="bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] text-white px-8 py-3 rounded-full font-semibold hover:shadow-lg transition-all duration-300 hover:scale-105">
                                Register for Event
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </motion.div>
                  </AnimatePresence>
                </div>

                {/* Event Indicators */}
                <div className="flex justify-center mt-8 gap-2">
                  {events.map((_, index) => (
                    <button
                      key={index}
                      onClick={() => goToEvent(index)}
                      className={`w-3 h-3 rounded-full transition-all duration-300 ${
                        index === currentEventIndex
                          ? 'bg-[#1E3C90] scale-125'
                          : 'bg-gray-300 hover:bg-gray-400'
                      }`}
                    />
                  ))}
                </div>

                {/* Event Counter */}
                <div className="text-center mt-4">
                  <p className="text-sm text-gray-600">
                    Event {currentEventIndex + 1} of {events.length}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* CTA Section - Only visible for customers (role 0) */}
        {role === 0 && (
          <section className="py-16 bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] text-white">
            <div className="container mx-auto px-4 text-center">
              <h2 className="text-3xl md:text-4xl font-bold mb-4">Ready to Invest in Your Future?</h2>
              <p className="text-xl text-blue-100 mb-8 max-w-2xl mx-auto">
                Join thousands of satisfied investors who have made DHA Marketplace their trusted property partner
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <a
                  href="/dashboard"
                  className="bg-white text-[#1E3C90] px-8 py-3 rounded-full font-semibold hover:bg-gray-100 transition-colors duration-300 inline-block"
                >
                  Explore Properties
                </a>
                <a
                  href="/register"
                  className="border-2 border-white text-white px-8 py-3 rounded-full font-semibold hover:bg-gray-100 hover:text-[#1E3C90] transition-colors duration-300 inline-block"
                >
                  Get Started Today
                </a>
              </div>
            </div>
          </section>
        )}
      </main>
    </div>
  )
}
