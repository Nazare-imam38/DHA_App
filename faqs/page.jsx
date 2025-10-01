"use client"

import Link from "next/link"
import { motion } from "framer-motion"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { HelpCircle, MessageCircle, Phone, Mail, Clock, CheckCircle, Users, Shield } from "lucide-react"
import { VerticalBanner, HorizontalBanner, SquareBannerStack, SquareBanner } from "@/components/ads/AdBanner"

// Responsive Square Ads Component - Mobile Only
const ResponsiveSquareAds = ({ className = '' }) => {
  const squareImages = [
    '/images/square-banner-test-1.png',
    '/images/square-banner-test-2.png',
    '/images/square-banner-test-3.png',
    '/images/square-banner-test-4.png'
  ]

  return (
    <div className={`w-full ${className}`}>
      {/* Mobile Only: Single column */}
      <div className="block md:hidden space-y-4">
        {squareImages.slice(0, 2).map((imageSrc, index) => (
          <div key={index} className="flex justify-center">
            <SquareBanner 
              imageSrc={imageSrc}
              className="w-full max-w-[280px]"
            />
          </div>
        ))}
      </div>
    </div>
  )
}

export default function FAQsPage() {
  const faqCategories = [
    {
      title: "Getting Started",
      icon: <Users className="h-5 w-5" />,
      color: "bg-blue-500",
      questions: [
        {
          id: "item-1",
          question: "Do I need to create an account to use the Marketplace?",
          answer: "You can browse plots and use filters without an account. However, to reserve or purchase a plot, you must be logged in to your registered account. This ensures a secure and personalized experience, including access to your dashboard, payment, and documents."
        },
        {
          id: "item-2",
          question: "What types of plots are available on the Marketplace?",
          answer: "The Marketplace offers both commercial and residential plots. You can use the filters to view the type of plots you're interested in."
        }
      ]
    },
    {
      title: "Plot Search & Filtering",
      icon: <HelpCircle className="h-5 w-5" />,
      color: "bg-teal-500",
      questions: [
        {
          id: "item-3",
          question: "Can I filter plots by size and location?",
          answer: "Yes, the Marketplace allows you to filter plots by DHA Phase, plot type (residential/commercial), and plot size (e.g., 7 Marla). This helps narrow down options based on your preferences."
        },
        {
          id: "item-4",
          question: "Can I filter plots by price range?",
          answer: "Yes! You can use the Price Range filter to view plots that match your budget."
        },
        {
          id: "item-5",
          question: "How often is the listing updated?",
          answer: "The Marketplace listings are updated in real-time to reflect the latest availability. You always see the updated map with available plots."
        }
      ]
    },
    {
      title: "Booking & Payment",
      icon: <CheckCircle className="h-5 w-5" />,
      color: "bg-green-500",
      questions: [
        {
          id: "item-6",
          question: "How do I reserve a plot?",
          answer: "Once you select a plot, you'll get a 15-minute window to complete the payment via Kuickpay. A unique PSID (Payment Slip ID) will be generated. You can use it to pay through your bank's app, ATM, or internet banking. After successful payment, the plot will be officially reserved in your name."
        },
        {
          id: "item-7",
          question: "What payment methods are accepted?",
          answer: "All payments are processed securely through Kuickpay or via Debit/Credit Card. You can use a range of banking options supported by Kuickpay."
        },
        {
          id: "item-8",
          question: "What happens after I make a payment?",
          answer: "You'll receive a confirmation email with a reservation letter attached. Your booking details will also appear on Your Booking Dashboard, and you'll be directly connected to DHA for the next steps and formal documentation."
        },
        {
          id: "item-9",
          question: "What if my payment session expires?",
          answer: "If the payment is not completed within 15 minutes, the plot will become available again to other users. You'll need to start the reservation process again if you're still interested."
        }
      ]
    },
    {
      title: "General Information",
      icon: <Shield className="h-5 w-5" />,
      color: "bg-purple-500",
      questions: [
        {
          id: "item-10",
          question: "Is there any priority system for plot allocation?",
          answer: "No. All plots are allocated strictly on a first-come, first-served basis. We recommend acting quickly once you've made your decision."
        },
        {
          id: "item-11",
          question: "How can I contact support if something goes wrong?",
          answer: "Use the Support link in the dashboard header or within your reservation email to reach our team, typically, we respond within a few hours."
        }
      ]
    }
  ]

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.5
      }
    }
  }

  return (
    <div className="flex flex-col min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      <DashboardHeader />

      {/* Hero Section */}
      <section className="relative bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] text-white py-16 md:py-20">
        <div className="absolute inset-0 bg-black/10"></div>
        <div className="relative container mx-auto px-4 text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            className="flex justify-center mb-6"
          >
            <div className="w-20 h-20 bg-white/10 backdrop-blur-sm rounded-full flex items-center justify-center">
              <img src="/images/logo.png" alt="DHA Logo" className="h-12 w-12 object-contain" />
            </div>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="text-4xl md:text-5xl font-bold mb-4"
          >
            Frequently Asked Questions
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.4 }}
            className="text-xl md:text-2xl text-blue-100 max-w-3xl mx-auto"
          >
            Find answers to common questions about DHA Marketplace and plot investments
          </motion.p>


        </div>
      </section>

      <main className="flex-1 py-16 px-4">
        {/* FAQ Questions Section with Side Banners */}
        <div className="relative">
          {/* Main Content with Side Margins for Banners */}
          <div className="lg:ml-80 lg:mr-80">
            {/* Horizontal Banner Ad - Top (Mobile) */}
            <div className="lg:hidden w-full mb-8">
              <HorizontalBanner className="mb-0" />
            </div>

            {/* FAQ Categories - Centered */}
            <div className="flex justify-center">
              <motion.div
                variants={containerVariants}
                initial="hidden"
                animate="visible"
                className="w-full max-w-4xl lg:max-w-5xl space-y-12"
              >
                {faqCategories.map((category, categoryIndex) => (
                  <motion.div
                    key={category.title}
                    variants={itemVariants}
                    className="space-y-6"
                  >
                    {/* Category Header */}
                    <div className="text-center mb-8">
                      <div className="flex items-center justify-center gap-3 mb-4">
                        <div className={`w-12 h-12 ${category.color} rounded-full flex items-center justify-center text-white shadow-lg`}>
                          {category.icon}
                        </div>
                        <h2 className="text-2xl md:text-3xl font-bold text-gray-800">{category.title}</h2>
                      </div>
                      <div className="w-24 h-1 bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] rounded-full mx-auto"></div>
                    </div>

                    {/* FAQ Cards - Centered */}
                    <div className="flex flex-col items-center gap-4">
                      {category.questions.map((faq, index) => (
                        <motion.div
                          key={faq.id}
                          initial={{ opacity: 0, y: 20 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: categoryIndex * 0.1 + index * 0.05 }}
                          className="w-full max-w-3xl"
                        >
                          <Card className="group hover:shadow-xl transition-all duration-300 border-0 shadow-lg bg-white/80 backdrop-blur-sm mx-auto">
                            <CardContent className="p-0">
                              <Accordion type="single" collapsible className="w-full">
                                <AccordionItem value={faq.id} className="border-none">
                                  <AccordionTrigger className="px-4 md:px-6 py-4 hover:no-underline group-hover:bg-gray-50/50 transition-colors duration-200 text-center justify-center">
                                    <div className="flex items-center justify-center gap-3 md:gap-4 w-full">
                                      <div className={`w-7 h-7 md:w-8 md:h-8 ${category.color} rounded-full flex items-center justify-center text-white text-xs md:text-sm font-bold flex-shrink-0`}>
                                        {index + 1}
                                      </div>
                                      <span className="font-semibold text-gray-800 group-hover:text-[#1E3C90] transition-colors duration-200 text-center flex-1 text-sm md:text-base leading-relaxed">
                                        {faq.question}
                                      </span>
                                    </div>
                                  </AccordionTrigger>
                                  <AccordionContent className="px-4 md:px-6 pb-6">
                                    <div className="ml-8 md:ml-12 text-gray-600 leading-relaxed bg-gray-50/50 rounded-lg p-3 md:p-4 border-l-4 border-[#12AE9E] text-sm md:text-base">
                                      {faq.answer}
                                    </div>
                                  </AccordionContent>
                                </AccordionItem>
                              </Accordion>
                            </CardContent>
                          </Card>
                        </motion.div>
                      ))}
                    </div>

                    {/* Square Ads Section Divider - After first and third categories */}
                    {(categoryIndex === 0 || categoryIndex === 2) && (
                      <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: (categoryIndex + 1) * 0.1 + 0.3 }}
                        className="my-12"
                      >
                        <ResponsiveSquareAds />
                      </motion.div>
                    )}
                  </motion.div>
                ))}
              </motion.div>
            </div>
          </div>

          {/* Left Vertical Banner (Desktop) - Only in this section */}
          <div className="hidden lg:block absolute left-6 top-0 z-20">
            <VerticalBanner className="mb-4" />
          </div>

          {/* Right Square Banner Stack (Desktop) - Only in this section */}
          <div className="hidden lg:block absolute right-6 top-0 z-20">
            <SquareBannerStack className="mb-4" />
          </div>
        </div>
      </main>
    </div>
  )
}