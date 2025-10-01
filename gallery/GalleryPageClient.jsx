"use client"
import { useState } from "react"
import { motion } from "framer-motion"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Camera, Video, MapPin, Clock, Eye, Star, Share2, X } from "lucide-react"
import { HorizontalBanner } from "@/components/ads/AdBanner"

const galleryImages = [
  {
    id: 1,
    src: "/images/gallery/dha-gate-night.jpg",
    alt: "DHA Phase 4 Entrance Gate at night",
    title: "DHA Phase 4 Entrance",
    description: "Iconic entrance gate with modern architecture",
    category: "Infrastructure",
    featured: true
  },
  {
    id: 2,
    src: "/images/gallery/dha-medical-center.jpg",
    alt: "DHA Medical Center",
    title: "DHA Medical Center",
    description: "State-of-the-art healthcare facility",
    category: "Healthcare",
    featured: false
  },
  {
    id: 3,
    src: "/images/gallery/dha-commercial-center.jpg",
    alt: "DHA Commercial Center",
    title: "Commercial Hub",
    description: "Aerial view of the circular commercial center",
    category: "Commercial",
    featured: true
  },
  {
    id: 4,
    src: "/images/gallery/dha-sports-facility.jpg",
    alt: "DHA Sports Facility",
    title: "Sports Complex",
    description: "Modern football grounds with night lighting",
    category: "Recreation",
    featured: false
  },
  {
    id: 5,
    src: "/images/gallery/dha-mosque-night.jpg",
    alt: "DHA Grand Mosque",
    title: "Grand Mosque",
    description: "Beautifully illuminated mosque with golden dome",
    category: "Religious",
    featured: true
  },
  {
    id: 6,
    src: "/images/gallery/imperial-hall.jpg",
    alt: "Imperial Hall",
    title: "Imperial Hall",
    description: "Modern community center and event venue",
    category: "Community",
    featured: false
  },
  {
    id: 7,
    src: "/images/gallery/dha-park-night.jpg",
    alt: "DHA Park at Night",
    title: "Community Park",
    description: "Illuminated recreational area with walking paths",
    category: "Recreation",
    featured: false
  },
]

const galleryVideos = [
  {
    id: 1,
    videoId: "UjG_Ez-7jU0",
    title: "DHA Downtown Stroll",
    description: "Serene streets, modern design — a calm walkthrough.",
    duration: "3:45",
    views: "12K",
    featured: true
  },
  {
    id: 2,
    videoId: "YD0rgR9czW4",
    title: "DHA Gandhara Overview",
    description: "A bird's-eye glimpse into the layout and key landmarks.",
    duration: "5:20",
    views: "8.5K",
    featured: false
  },
  {
    id: 3,
    videoId: "SYkkNcnXRqE",
    title: "DHA Islamabad | A Closer Look",
    description: "Exploring the structure, vision, and flow of DHA Islamabad.",
    duration: "7:15",
    views: "15K",
    featured: true
  },
  {
    id: 4,
    videoId: "VIrAK_972Ok",
    title: "DHA Phase VI & VII",
    description: "An overview of evolving spaces and thoughtful planning.",
    duration: "4:30",
    views: "6.2K",
    featured: false
  },
  {
    id: 5,
    videoId: "hiNgnpyL4WM",
    title: "Thank You, Margalla",
    description: "A quiet farewell through the greens of Margalla.",
    duration: "2:50",
    views: "9.8K",
    featured: false
  },
]

function YouTubeEmbed({ videoId, title }) {
  return (
    <div className="aspect-video relative overflow-hidden rounded-xl shadow-lg bg-gray-100 group">
      <iframe
        src={`https://www.youtube.com/embed/${videoId}?rel=0&modestbranding=1&showinfo=0`}
        title={title}
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        allowFullScreen
        className="absolute inset-0 w-full h-full border-0"
        style={{ border: 'none' }}
      />
    </div>
  )
}

// Image Modal Component
function ImageModal({ image, isOpen, onClose, getCategoryColor }) {
  if (!isOpen || !image) return null;

  return (
    <div 
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4"
      onClick={onClose}
    >
      <div className="relative w-full max-w-6xl max-h-[95vh] flex flex-col" onClick={(e) => e.stopPropagation()}>
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute -top-12 right-0 w-10 h-10 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-white/30 transition-colors z-10 md:block hidden"
        >
          <X className="h-6 w-6" />
        </button>
        
        {/* Mobile Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 w-10 h-10 bg-black/50 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-black/70 transition-colors z-10 md:hidden"
        >
          <X className="h-5 w-5" />
        </button>

        <div className="relative overflow-hidden rounded-2xl shadow-2xl bg-white flex flex-col max-h-full">
          {/* Image Container */}
          <div className="relative flex-1 flex items-center justify-center bg-gray-100 min-h-0">
            <img
              src={image.src}
              alt={image.alt}
              className="max-w-full max-h-full object-contain"
              style={{ maxHeight: 'calc(95vh - 200px)' }}
            />
          </div>
          
          {/* Content Section */}
          <div className="p-4 md:p-6 bg-white flex-shrink-0">
            <div className="flex flex-wrap items-center gap-2 md:gap-3 mb-3">
              <Badge className={`${getCategoryColor(image.category)} text-white border-0 text-xs md:text-sm`}>
                {image.category}
              </Badge>
              {image.featured && (
                <Badge className="bg-gradient-to-r from-yellow-400 to-orange-500 text-white border-0 text-xs md:text-sm">
                  <Star className="h-3 w-3 mr-1" />
                  Featured
                </Badge>
              )}
            </div>
            <h3 className="text-lg md:text-2xl font-bold text-gray-800 mb-2">{image.title}</h3>
            <p className="text-gray-600 leading-relaxed text-sm md:text-base">{image.description}</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function GalleryPageClient() {
  const [activeTab, setActiveTab] = useState("images")
  const [selectedImage, setSelectedImage] = useState(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  const openImageModal = (image) => {
    setSelectedImage(image)
    setIsModalOpen(true)
  }

  const closeImageModal = () => {
    setIsModalOpen(false)
    setSelectedImage(null)
  }

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

  const getCategoryColor = (category) => {
    const colors = {
      Infrastructure: "bg-blue-500",
      Healthcare: "bg-green-500",
      Commercial: "bg-purple-500",
      Recreation: "bg-orange-500",
      Religious: "bg-teal-500",
      Community: "bg-pink-500"
    }
    return colors[category] || "bg-gray-500"
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
            Media Gallery
          </motion.h1>
          
          <motion.p 
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.4 }}
            className="text-xl md:text-2xl text-blue-100 max-w-3xl mx-auto"
          >
            Explore stunning visuals of DHA developments, facilities, and community spaces
          </motion.p>

          
        </div>
      </section>

      <main className="flex-1 py-16 px-4">
        <div className="flex justify-center">
          <motion.div
            variants={containerVariants}
            initial="hidden"
            animate="visible"
            className="w-full max-w-7xl space-y-12"
          >
            {/* Horizontal Banner Ad - Top (All devices) */}
            <div className="w-full mb-8">
              <HorizontalBanner className="mb-0" />
            </div>
            {/* Enhanced Tabs - Only Tab Controls */}
            <div className="flex justify-center mb-12">
              <div className="w-full max-w-2xl">
                <div className="grid w-full grid-cols-2 h-14 bg-white/80 backdrop-blur-sm border border-gray-200 rounded-2xl p-2">
                  <button
                    onClick={() => setActiveTab("images")}
                    className={`flex items-center justify-center gap-3 rounded-xl font-semibold text-base transition-all duration-300 ${
                      activeTab === "images"
                        ? "bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] text-white"
                        : "text-gray-600 hover:text-gray-800"
                    }`}
                  >
                    <Camera className="h-5 w-5" />
                    Images ({galleryImages.length})
                  </button>
                  <button
                    onClick={() => setActiveTab("videos")}
                    className={`flex items-center justify-center gap-3 rounded-xl font-semibold text-base transition-all duration-300 ${
                      activeTab === "videos"
                        ? "bg-gradient-to-r from-[#1E3C90] to-[#12AE9E] text-white"
                        : "text-gray-600 hover:text-gray-800"
                    }`}
                  >
                    <Video className="h-5 w-5" />
                    Videos ({galleryVideos.length})
                  </button>
                </div>
              </div>
            </div>

            {/* Images Content - Full Width */}
            {activeTab === "images" && (
              <motion.div
                variants={containerVariants}
                initial="hidden"
                animate="visible"
                className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
              >
                {galleryImages.map((image) => (
                  <motion.div
                    key={image.id}
                    variants={itemVariants}
                    whileHover={{ y: -8 }}
                    className="group cursor-pointer"
                    onClick={() => openImageModal(image)}
                  >
                    <Card className="overflow-hidden shadow-xl border-0 bg-white/80 backdrop-blur-sm hover:shadow-2xl transition-all duration-500">
                      <div className="relative">
                        <div className="aspect-[16/10] relative overflow-hidden rounded-xl">
                          <img
                            src={image.src}
                            alt={image.alt}
                            className="object-contain w-full h-full bg-gray-50 group-hover:scale-105 transition-transform duration-500"
                          />
                          <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                          
                          {/* Featured Badge */}
                          {image.featured && (
                            <div className="absolute top-4 left-4">
                              <Badge className="bg-gradient-to-r from-yellow-400 to-orange-500 text-white border-0 shadow-lg">
                                <Star className="h-3 w-3 mr-1" />
                                Featured
                              </Badge>
                            </div>
                          )}

                          {/* Category Badge */}
                          <div className="absolute top-4 right-4">
                            <Badge className={`${getCategoryColor(image.category)} text-white border-0 shadow-lg`}>
                              {image.category}
                            </Badge>
                          </div>

                          {/* Hover Actions */}
                          <div className="absolute bottom-4 right-4 flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                            <button 
                              onClick={(e) => {
                                e.stopPropagation()
                                openImageModal(image)
                              }}
                              className="w-10 h-10 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-white/30 transition-colors"
                              title="View Image"
                            >
                              <Eye className="h-4 w-4" />
                            </button>
                            <button 
                              onClick={(e) => {
                                e.stopPropagation()
                                navigator.share?.({ 
                                  title: image.title, 
                                  text: image.description, 
                                  url: window.location.href 
                                }) || navigator.clipboard?.writeText(window.location.href)
                              }}
                              className="w-10 h-10 bg-white/20 backdrop-blur-sm rounded-full flex items-center justify-center text-white hover:bg-white/30 transition-colors"
                              title="Share Image"
                            >
                              <Share2 className="h-4 w-4" />
                            </button>
                          </div>
                        </div>
                      </div>
                      <CardContent className="p-6">
                        <h3 className="font-bold text-xl text-gray-800 mb-2 group-hover:text-[#1E3C90] transition-colors duration-300">
                          {image.title}
                        </h3>
                        <p className="text-gray-600 leading-relaxed text-sm">
                          {image.description}
                        </p>
                      </CardContent>
                    </Card>
                  </motion.div>
                ))}
              </motion.div>
            )}

            {/* Videos Content - Full Width */}
            {activeTab === "videos" && (
              <motion.div
                variants={containerVariants}
                initial="hidden"
                animate="visible"
                className="grid grid-cols-1 lg:grid-cols-2 gap-8"
              >
                {galleryVideos.map((video) => (
                  <motion.div
                    key={video.id}
                    variants={itemVariants}
                    whileHover={{ y: -8 }}
                    className="group w-full"
                  >
                    <Card className="overflow-hidden shadow-xl border-0 bg-white/80 backdrop-blur-sm hover:shadow-2xl transition-all duration-500">
                      <div className="relative">
                        <div className="aspect-video relative overflow-hidden rounded-t-xl">
                          <iframe
                            src={`https://www.youtube.com/embed/${video.videoId}?rel=0&modestbranding=1&showinfo=0`}
                            title={video.title}
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                            allowFullScreen
                            className="absolute inset-0 w-full h-full border-0"
                            style={{ border: 'none' }}
                          />
                        </div>
                        
                        {/* Featured Badge */}
                        {video.featured && (
                          <div className="absolute top-4 left-4 z-10">
                            <Badge className="bg-gradient-to-r from-yellow-400 to-orange-500 text-white border-0 shadow-lg">
                              <Star className="h-3 w-3 mr-1" />
                              Featured
                            </Badge>
                          </div>
                        )}

                        {/* Video Stats */}
                        <div className="absolute top-4 right-4 z-10 flex gap-2">
                          <Badge className="bg-black/50 text-white border-0 backdrop-blur-sm">
                            <Clock className="h-3 w-3 mr-1" />
                            {video.duration}
                          </Badge>
                          <Badge className="bg-black/50 text-white border-0 backdrop-blur-sm">
                            <Eye className="h-3 w-3 mr-1" />
                            {video.views}
                          </Badge>
                        </div>
                      </div>
                      <CardContent className="p-6">
                        <h3 className="font-bold text-xl text-gray-800 mb-2 group-hover:text-[#1E3C90] transition-colors duration-300">
                          {video.title}
                        </h3>
                        <p className="text-gray-600 leading-relaxed text-sm">
                          {video.description}
                        </p>
                      </CardContent>
                    </Card>
                  </motion.div>
                ))}
              </motion.div>
            )}

            

            {/* Copyright */}
            <div className="text-center pt-8 border-t border-gray-200">
              <p className="text-sm text-gray-500">© 2025 Defence Housing Authority. All rights reserved.</p>
            </div>
          </motion.div>
        </div>
      </main>

      {/* Image Modal */}
      <ImageModal 
        image={selectedImage} 
        isOpen={isModalOpen} 
        onClose={closeImageModal}
        getCategoryColor={getCategoryColor}
      />
    </div>
  )
}