"use client"

import { useState } from "react"
import Link from "next/link"
import {
  UserPlus,
  LogIn,
  LayoutDashboard,
  Map,
  List,
  Filter,
  Info,
  Gavel,
  CreditCard,
  User,
  ChevronDown,
  ChevronUp,
  HelpCircle,
} from "lucide-react"
import DashboardHeader from "@/components/dashboard/dashboard-header"

export default function HowToUsePage() {
  const [expandedSection, setExpandedSection] = useState("registration")

  const toggleSection = (section) => {
    if (expandedSection === section) {
      setExpandedSection(null)
    } else {
      setExpandedSection(section)
    }
  }

  return (
    <div className="flex flex-col min-h-screen">
      <DashboardHeader />

      <div className="container mx-auto px-4 py-8 max-w-5xl">
        <h1 className="text-3xl font-bold text-center mb-8">How to use DHA MarketPlace</h1>

        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <p className="text-lg mb-4">
            Welcome to DHA MarketPlace! This guide will walk you through all the features and functionalities of our
            platform, helping you navigate from registration to successfully bidding on and purchasing plots.
          </p>

          <h3 className="text-xl font-semibold mt-6 mb-3">Video Tutorial</h3>
          <div className="max-w-3xl mx-auto mb-4">
            <h4 className="font-medium mb-2 text-center">How to Use DHA MarketPlace</h4>
            <div className="relative pb-[56.25%] h-0 overflow-hidden rounded-lg">
              <iframe
                className="absolute top-0 left-0 w-full h-full"
                src="https://www.youtube.com/embed/qTCo1tVaK7k"
                title="How to Use DHA MarketPlace"
                frameBorder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              ></iframe>
            </div>
          </div>
          <p className="text-sm text-gray-600 italic text-center">
            This video tutorial provides step-by-step guidance on how to navigate the DHA MarketPlace platform.
          </p>
        </div>

        {/* Table of Contents */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 className="text-xl font-semibold mb-4">Quick Navigation</h2>
          <ul className="grid grid-cols-1 md:grid-cols-2 gap-2">
            <li>
              <a href="#registration" className="flex items-center text-blue-600 hover:underline">
                <UserPlus className="w-4 h-4 mr-2" />
                Registration
              </a>
            </li>
            <li>
              <a href="#login" className="flex items-center text-blue-600 hover:underline">
                <LogIn className="w-4 h-4 mr-2" />
                Login
              </a>
            </li>
            <li>
              <a href="#dashboard" className="flex items-center text-blue-600 hover:underline">
                <LayoutDashboard className="w-4 h-4 mr-2" />
                Explore Plots Overview
              </a>
            </li>
            <li>
              <a href="#map-view" className="flex items-center text-blue-600 hover:underline">
                <Map className="w-4 h-4 mr-2" />
                Map View
              </a>
            </li>
            <li>
              <a href="#list-view" className="flex items-center text-blue-600 hover:underline">
                <List className="w-4 h-4 mr-2" />
                List View
              </a>
            </li>
            <li>
              <a href="#filters" className="flex items-center text-blue-600 hover:underline">
                <Filter className="w-4 h-4 mr-2" />
                Using Filters
              </a>
            </li>
            <li>
              <a href="#plot-details" className="flex items-center text-blue-600 hover:underline">
                <Info className="w-4 h-4 mr-2" />
                Plot Details
              </a>
            </li>
            <li>
              <a href="#bidding" className="flex items-center text-blue-600 hover:underline">
                <Gavel className="w-4 h-4 mr-2" />
                Bidding Process
              </a>
            </li>
            <li>
              <a href="#payment" className="flex items-center text-blue-600 hover:underline">
                <CreditCard className="w-4 h-4 mr-2" />
                Payment Process
              </a>
            </li>
            <li>
              <a href="#profile" className="flex items-center text-blue-600 hover:underline">
                <User className="w-4 h-4 mr-2" />
                My Bookings
              </a>
            </li>
          </ul>
        </div>

        {/* Registration Section */}
        <section id="registration" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("registration")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <UserPlus className="w-6 h-6 mr-2" />
              1. Registration
            </h2>
            {expandedSection === "registration" ? (
              <ChevronUp className="w-6 h-6" />
            ) : (
              <ChevronDown className="w-6 h-6" />
            )}
          </button>

          {expandedSection === "registration" && (
            <div className="mt-4">
              <p className="mb-4">
                To start using our platform, you need to create an account. Follow these steps to register:
              </p>
              <ol className="list-decimal pl-6 space-y-4">
                <li>
                  <p className="font-medium">Navigate to the Registration Page</p>
                  <p>
                    Click on the "Register" button in the top navigation bar or visit{" "}
                    <Link href="/register" className="text-blue-600 hover:underline">
                      /register
                    </Link>{" "}
                    directly.
                  </p>
                </li>
                <li>
                  <p className="font-medium">Fill in Your Personal Information</p>
                  <p>Enter your full name, email address, and create a secure password.</p>
                </li>
                <li>
                  <p className="font-medium">Provide Contact Details</p>
                  <p>Enter your phone number and CNIC (formatted as 12345-1234567-1).</p>
                </li>
                <li>
                  <p className="font-medium">Complete Registration</p>
                  <p>Click the "Create account" button to submit your registration.</p>
                </li>
                <li>
                  <p className="font-medium">OTP Verification</p>
                  <p>
                    After registration, you'll receive a One-Time Password (OTP) via email or SMS. Enter this code on
                    the verification screen to complete your account setup.
                  </p>
                  <p className="mt-2">
                    If you don't receive the OTP, you can request a new one after the countdown timer expires (60
                    seconds).
                  </p>
                </li>
                <li>
                  <p className="font-medium">Account Activation</p>
                  <p>
                    Once your OTP is verified, your account will be activated, and you'll be redirected to the dashboard
                    or login page.
                  </p>
                </li>
              </ol>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> Make sure to use a valid email address and phone number as the OTP will be sent
                  to verify your account. Your CNIC must be in the correct format (12345-1234567-1) and contain 13
                  digits.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* Login Section */}
        <section id="login" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button onClick={() => toggleSection("login")} className="flex items-center justify-between w-full text-left">
            <h2 className="text-2xl font-semibold flex items-center">
              <LogIn className="w-6 h-6 mr-2" />
              2. Login
            </h2>
            {expandedSection === "login" ? <ChevronUp className="w-6 h-6" /> : <ChevronDown className="w-6 h-6" />}
          </button>

          {expandedSection === "login" && (
            <div className="mt-4">
              <p className="mb-4">Once registered, you can log in to access the dashboard:</p>
              <ol className="list-decimal pl-6 space-y-4">
                <li>
                  <p className="font-medium">Go to the Login Page</p>
                  <p>
                    Click on the "Login" button in the navigation bar or visit{" "}
                    <Link href="/login" className="text-blue-600 hover:underline">
                      /login
                    </Link>{" "}
                    directly.
                  </p>
                </li>
                <li>
                  <p className="font-medium">Enter Your Credentials</p>
                  <p>Enter your registered email address and password.</p>
                </li>
                <li>
                  <p className="font-medium">Access Your Account</p>
                  <p>Click the "Login" button to access your dashboard.</p>
                </li>
              </ol>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> If you forget your password, use the "Forgot Password" link on the login page to
                  reset it.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* Dashboard Overview Section */}
        <section id="dashboard" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("dashboard")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <LayoutDashboard className="w-6 h-6 mr-2" />
              3. Explore Plots Overview
            </h2>
            {expandedSection === "dashboard" ? <ChevronUp className="w-6 h-6" /> : <ChevronDown className="w-6 h-6" />}
          </button>

          {expandedSection === "dashboard" && (
            <div className="mt-4">
              <p className="mb-4">The Explore Plots page is your central hub for exploring plots and managing your bids:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">Explore Plots Components:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Header:</strong> Contains navigation links and user account options.
                    </li>
                    <li>
                      <strong>Map View:</strong> Interactive map showing available plots.
                    </li>
                    <li>
                      <strong>List View:</strong> Tabular view of available plots with details.
                    </li>
                    <li>
                      <strong>Filter Panel:</strong> Tools to narrow down plot options.
                    </li>
                  </ul>
                </div>

                <div>
                  <h3 className="font-medium text-lg">Navigation:</h3>
                  <p>Use the navigation menu to access different sections of the application:</p>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Explore Plots:</strong> Return to the main Explore Plots page.
                    </li>
                    <li>
                      <strong>Gallery:</strong> View images of plots and developments.
                    </li>
                    <li>
                      <strong>FAQs:</strong> Find answers to common questions.
                    </li>
                    <li>
                      <strong>How to Use:</strong> Access this user guide.
                    </li>
                    <li>
                      <strong>Bidding Rules:</strong> Learn about the bidding process.
                    </li>
                    <li>
                      <strong>Contact:</strong> Get in touch with support.
                    </li>
                    <li>
                      <strong>My Bookings:</strong> View your plot reservations and bids.
                    </li>
                  </ul>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> Take some time to explore the Explore Plots page to familiarize yourself with all
                  available features before making any bids or reservations.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* Map View Section */}
        <section id="map-view" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("map-view")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <Map className="w-6 h-6 mr-2" />
              4. Map View
            </h2>
            {expandedSection === "map-view" ? <ChevronUp className="w-6 h-6" /> : <ChevronDown className="w-6 h-6" />}
          </button>

          {expandedSection === "map-view" && (
            <div className="mt-4">
              <p className="mb-4">The Map View provides a visual representation of all available plots:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">Map Features:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Plot Polygons:</strong> Each polygon represents an available plot.
                    </li>
                    <li>
                      <strong>Color Coding:</strong> Different colors indicate plot types - blue for commercial, yellow
                      for residential, and green for selected plots.
                    </li>
                    <li>
                      <strong>Zoom Controls:</strong> Use + and - buttons to zoom in and out.
                    </li>
                    <li>
                      <strong>Map Layers:</strong> Toggle between different map views (satellite, street).
                    </li>
                  </ul>
                </div>

                <div>
                  <h3 className="font-medium text-lg">Interacting with the Map:</h3>
                  <ol className="list-decimal pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Selecting a Plot:</strong> Click on any plot polygon to view its details and select it.
                    </li>
                    <li>
                      <strong>Panning:</strong> Click and drag to move around the map.
                    </li>
                    <li>
                      <strong>Plot Details:</strong> When you select a plot, a popup will appear showing key
                      information.
                    </li>
                  </ol>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> The map view is particularly useful for understanding the location and
                  surroundings of plots. Use the satellite view to see actual terrain and nearby features.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* List View Section */}
        <section id="list-view" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("list-view")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <List className="w-6 h-6 mr-2" />
              5. List View
            </h2>
            {expandedSection === "list-view" ? <ChevronUp className="w-6 h-6" /> : <ChevronDown className="w-6 h-6" />}
          </button>

          {expandedSection === "list-view" && (
            <div className="mt-4">
              <p className="mb-4">The List View displays plots in a list format with key information:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">List View Features:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Plot Number:</strong> Unique identifier for each plot.
                    </li>
                    <li>
                      <strong>Plot Type:</strong> Indicates whether the plot is residential or commercial.
                    </li>
                    <li>
                      <strong>Phase/Sector:</strong> Shows which phase and sector the plot belongs to.
                    </li>
                    <li>
                      <strong>Select Button:</strong> Click to select a plot and view its details on the map.
                    </li>
                  </ul>
                </div>

                <div>
                  <h3 className="font-medium text-lg">Using the List View:</h3>
                  <ol className="list-decimal pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Search:</strong> Use the search box to find specific plots by number or ID.
                    </li>
                    <li>
                      <strong>Select Plot:</strong> Click the "Select" button to highlight the plot on the map and view
                      its details.
                    </li>
                    <li>
                      <strong>View Details:</strong> When you select a plot, the map will zoom to that plot and display
                      its information.
                    </li>
                  </ol>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> The list view is excellent for quickly finding specific plots by their number or
                  browsing available plots in a particular sector.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* Filters Section */}
        <section id="filters" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("filters")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <Filter className="w-6 h-6 mr-2" />
              6. Using Filters
            </h2>
            {expandedSection === "filters" ? <ChevronUp className="w-6 h-6" /> : <ChevronDown className="w-6 h-6" />}
          </button>

          {expandedSection === "filters" && (
            <div className="mt-4">
              <p className="mb-4">Filters help you narrow down the available plots based on your preferences:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">Available Filters:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Phase Filter:</strong> Select a specific DHA phase (1-7) to view plots in that area.
                    </li>
                    <li>
                      <strong>Plot Type Filter:</strong> Choose between residential and commercial plots.
                    </li>
                    <li>
                      <strong>Plot Size Filter:</strong> Filter plots by size (e.g., 2275 sq ft, 4500 sq ft).
                    </li>
                  </ul>
                </div>

                <div>
                  <h3 className="font-medium text-lg">Using the Filter Panel:</h3>
                  <ol className="list-decimal pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Open Filters:</strong> The filter panel is typically displayed on the left side of the
                      dashboard.
                    </li>
                    <li>
                      <strong>Select Phase:</strong> Click on a phase number to filter plots in that phase.
                    </li>
                    <li>
                      <strong>Choose Plot Type:</strong> Check or uncheck residential or commercial to filter by type.
                    </li>
                    <li>
                      <strong>Select Plot Size:</strong> Check or uncheck specific plot sizes to filter by area.
                    </li>
                    <li>
                      <strong>Reset Filters:</strong> Use the "Reset" button at the bottom to clear all filters.
                    </li>
                  </ol>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> When you select a phase, the map will automatically zoom to that area, making it
                  easier to explore plots in that specific location.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* Plot Details Section */}
        <section id="plot-details" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("plot-details")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <Info className="w-6 h-6 mr-2" />
              7. Plot Details
            </h2>
            {expandedSection === "plot-details" ? (
              <ChevronUp className="w-6 h-6" />
            ) : (
              <ChevronDown className="w-6 h-6" />
            )}
          </button>

          {expandedSection === "plot-details" && (
            <div className="mt-4">
              <p className="mb-4">The Plot Details view provides key information about a specific plot:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">Information Available:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Plot ID and Number:</strong> Unique identifiers for the plot.
                    </li>
                    <li>
                      <strong>Sector and Phase:</strong> Location information.
                    </li>
                    <li>
                      <strong>Price:</strong> Base price or reserve price for the plot.
                    </li>
                    <li>
                      <strong>Token Amount:</strong> Required initial payment to reserve the plot.
                    </li>
                    <li>
                      <strong>Category:</strong> Whether the plot is residential or commercial.
                    </li>
                    <li>
                      <strong>Payment Plan:</strong> Link to view the payment plan if available.
                    </li>
                  </ul>
                </div>

                <div>
                  <h3 className="font-medium text-lg">Actions in Plot Details:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Reserve Plot:</strong> You can reserve both residential and commercial plots for 15
                      minutes until payment is confirmed.
                    </li>
                    <li>
                      <strong>Bid on Commercial:</strong> For commercial plots, you must pay the token amount first,
                      after which you can place bids in multiples of lacs.
                    </li>
                    <li>
                      <strong>View Payment Plan:</strong> Access the payment plan details if the plot is available in
                      installments.
                    </li>
                    <li>
                      <strong>Reservation Limit:</strong> You can reserve a maximum of 2 plots without payment
                      confirmation, and reservations expire after 15 minutes.
                    </li>
                  </ul>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> Always review all plot details carefully before placing a reservation or bid.
                  Remember that your reservation will expire after 15 minutes if payment is not confirmed.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* Bidding Process Section */}
        <section id="bidding" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("bidding")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <Gavel className="w-6 h-6 mr-2" />
              8. Bidding Process
            </h2>
            {expandedSection === "bidding" ? <ChevronUp className="w-6 h-6" /> : <ChevronDown className="w-6 h-6" />}
          </button>

          {expandedSection === "bidding" && (
            <div className="mt-4">
              <p className="mb-4">The bidding process applies to plots marked as "Bidding Available" and works as follows:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">Bidding Steps:</h3>
                  <ol className="list-decimal pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Select a Bidding Plot:</strong> Choose a plot marked with "Bidding Available" that you want to bid on.
                    </li>
                    <li>
                      <strong>Pay Token Amount:</strong> You must first pay the token amount to reserve the plot and
                      enable bidding.
                    </li>
                    <li>
                      <strong>Place Bid:</strong> After paying the token, you can place bids in multiples of lacs (e.g.,
                      100,000, 200,000).
                    </li>
                    <li>
                      <strong>Monitor Bid Status:</strong> Check your bid rank and status in the "My Bookings" section.
                    </li>
                    <li>
                      <strong>Update Bid:</strong> You can increase your bid amount if you're not the highest bidder.
                    </li>
                  </ol>
                </div>

                <div>
                  <h3 className="font-medium text-lg">Reservation Rules:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Reservation Time:</strong> Plots are reserved for 15 minutes until payment is confirmed.
                    </li>
                    <li>
                      <strong>Maximum Reservations:</strong> You can reserve up to 2 plots at a time without payment
                      confirmation.
                    </li>
                    <li>
                      <strong>Expiration:</strong> Reservations automatically expire after 15 minutes if payment is not
                      completed.
                    </li>
                  </ul>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> Remember that for commercial plots, you must pay the token amount first before
                  you can place any bids.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* Payment Process Section */}
        <section id="payment" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("payment")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <CreditCard className="w-6 h-6 mr-2" />
              9. Payment Process
            </h2>
            {expandedSection === "payment" ? <ChevronUp className="w-6 h-6" /> : <ChevronDown className="w-6 h-6" />}
          </button>

          {expandedSection === "payment" && (
            <div className="mt-4">
              <p className="mb-4">After selecting a plot, you'll need to complete the payment process:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">Payment Steps:</h3>
                  <ol className="list-decimal pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Pay Token Amount:</strong> First, pay the required token amount to secure your plot.
                    </li>
                    <li>
                      <strong>Choose Payment Method:</strong> Select between two available payment options:
                      <ul className="list-disc pl-6 mt-1">
                        <li>
                          <strong>KuickPay:</strong> Online payment method (includes a processing fee of PKR 22)
                        </li>
                        <li>
                          <strong>Credit/Debit Card:</strong> Direct card payment
                        </li>
                      </ul>
                    </li>
                    <li>
                      <strong>Complete Transaction:</strong> Follow the prompts to complete your payment.
                    </li>
                    <li>
                      <strong>Receive Receipt:</strong> A confirmation receipt will be provided after successful
                      payment.
                    </li>
                    <li>
                      <strong>View Payment Plan:</strong> If applicable, review the payment plan for future
                      installments.
                    </li>
                  </ol>
                </div>

                <div>
                  <h3 className="font-medium text-lg">After Payment:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Check Status:</strong> View your booking status in the "My Bookings" section.
                    </li>
                    <li>
                      <strong>Payment Confirmation:</strong> Your plot reservation becomes confirmed after successful
                      payment.
                    </li>
                  </ul>
                </div>

                <div className="bg-yellow-50 p-4 rounded-lg border border-yellow-200">
                  <h3 className="font-medium text-lg text-yellow-800">KuickPay Processing Fee</h3>
                  <p className="text-yellow-700">
                    When using the KuickPay payment method, a small processing fee of PKR 22 will be added to your total
                    payment amount. This fee covers the transaction costs associated with the KuickPay service This fee
                    covers the transaction costs associated with the KuickPay service.
                  </p>
                  <p className="text-yellow-700 mt-2">
                    For example, if your token amount is PKR 500,000, the total payment with KuickPay will be PKR
                    500,022.
                  </p>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> Always double-check the payment amount and selected payment method before
                  confirming the transaction. Keep the confirmation receipt for your records.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* My Bookings Section */}
        <section id="profile" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("profile")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <User className="w-6 h-6 mr-2" />
              10. My Bookings
            </h2>
            {expandedSection === "profile" ? <ChevronUp className="w-6 h-6" /> : <ChevronDown className="w-6 h-6" />}
          </button>

          {expandedSection === "profile" && (
            <div className="mt-4">
              <p className="mb-4">The "My Bookings" section allows you to manage your plot reservations and bids:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">Features:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>View Reservations:</strong> See all your reserved plots, including reservation time and
                      status.
                    </li>
                    <li>
                      <strong>View Bids:</strong> Track your bids on commercial plots, including bid amount and current
                      ranking.
                    </li>
                    <li>
                      <strong>Payment Status:</strong> Check the payment status of your reservations and bids.
                    </li>
                    <li>
                      <strong>Cancel Reservations:</strong> Cancel reservations before the payment deadline.
                    </li>
                  </ul>
                </div>

                <div>
                  <h3 className="font-medium text-lg">Managing Bookings:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <strong>Reservation Details:</strong> Click on a reservation to view detailed information.
                    </li>
                    <li>
                      <strong>Bid Details:</strong> Click on a bid to see your current ranking and options to increase
                      your bid.
                    </li>
                    <li>
                      <strong>Payment Options:</strong> Access payment options for confirmed reservations.
                    </li>
                  </ul>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> Regularly check the "My Bookings" section to stay updated on your reservations
                  and bids. Make sure to complete payments before the reservation expires to secure your plot.
                </p>
              </div>
            </div>
          )}
        </section>

        {/* Help and Support Section */}
        <section id="help-support" className="bg-white rounded-lg shadow-md p-6 mb-8">
          <button
            onClick={() => toggleSection("help-support")}
            className="flex items-center justify-between w-full text-left"
          >
            <h2 className="text-2xl font-semibold flex items-center">
              <HelpCircle className="w-6 h-6 mr-2" />
              11. Help and Support
            </h2>
            {expandedSection === "help-support" ? (
              <ChevronUp className="w-6 h-6" />
            ) : (
              <ChevronDown className="w-6 h-6" />
            )}
          </button>

          {expandedSection === "help-support" && (
            <div className="mt-4">
              <p className="mb-4">If you need assistance or have questions, here are some resources:</p>
              <div className="space-y-4">
                <div>
                  <h3 className="font-medium text-lg">Available Resources:</h3>
                  <ul className="list-disc pl-6 mt-2 space-y-2">
                    <li>
                      <Link href="/faqs" className="text-blue-600 hover:underline">
                        <strong>FAQs:</strong>
                      </Link>{" "}
                      Find answers to frequently asked questions.
                    </li>
                    <li>
                      <Link href="/contact" className="text-blue-600 hover:underline">
                        <strong>Contact Us:</strong>
                      </Link>{" "}
                      Get in touch with our support team for personalized assistance.
                    </li>
                    <li>
                      <Link href="/bidding-rules" className="text-blue-600 hover:underline">
                        <strong>Bidding Rules:</strong>
                      </Link>{" "}
                      Learn more about the bidding process and guidelines.
                    </li>
                  </ul>
                </div>

                <div>
                  <h3 className="font-medium text-lg">Contacting Support:</h3>
                  <p>
                    If you can't find the answer to your question in the FAQs, please reach out to our support team via
                    the contact form. We're here to help!
                  </p>
                </div>
              </div>
              <div className="mt-6 p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-800">
                  <strong>Tip:</strong> Before contacting support, please check the FAQs and Bidding Rules pages. You
                  may find the information you need there.
                </p>
              </div>
            </div>
          )}
        </section>
      </div>
    </div>
  )
}
