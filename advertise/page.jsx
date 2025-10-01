'use client'

import { useState, useEffect } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Checkbox } from '@/components/ui/checkbox'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Alert, AlertDescription } from '@/components/ui/alert'
import DashboardHeader from '@/components/dashboard/dashboard-header'
import { 
  CheckCircle, 
  Megaphone, 
  Users, 
  Target, 
  TrendingUp, 
  Monitor,
  Smartphone,
  Calendar,
  MapPin,
  Eye,
  Clock,
  DollarSign,
  ArrowRight,
  Play,
  X,
  Maximize2,
  Minimize2,
  Star,
  Award,
  Building2,
  Globe,
  Zap,
  Shield,
  BarChart3,
  Users2,
  Target as TargetIcon,
  ArrowUpRight,
  ChevronLeft,
  ChevronRight,
  Sparkles,
  Upload,
  CreditCard,
  AlertCircle,
  FileText,
  Image,
  Settings,
  CheckCircle2,
  Circle,
  ArrowLeft,
  Save
} from 'lucide-react'
import { validateAdImage } from '@/utils/image-validation'

// Ad Types Configuration
const adTypes = {
  vertical: {
    id: 'vertical',
    title: 'Vertical Banner',
    subtitle: 'Sidebar Placement',
    description: 'Long banners displayed on the sides of pages',
    basePrice: 2000,
    duration: 7,
    dimensions: '300x600px',
    maxFileSize: '2MB',
    color: 'bg-blue-50 border-blue-200',
    icon: <Maximize2 className="w-6 h-6 text-blue-600" />,
    preview: {
      width: '300px',
      height: '600px',
      position: 'right',
      pages: ['FAQs Page']
    },
    features: [
      'Displayed on page sidebars',
      'High visibility placement',
      'Responsive design',
      'Desktop-only display'
    ]
  },
  horizontal: {
    id: 'horizontal',
    title: 'Horizontal Banner',
    subtitle: 'Top/Bottom Placement',
    description: 'Wide banners at the top or bottom of pages',
    basePrice: 3000,
    duration: 7,
    dimensions: '728x90px',
    maxFileSize: '2MB',
    color: 'bg-green-50 border-green-200',
    icon: <Minimize2 className="w-6 h-6 text-green-600" />,
    preview: {
      width: '728px',
      height: '90px',
      position: 'top',
      pages: ['Landing Page', 'Gallery Page', 'FAQs Page']
    },
    features: [
      'Top or bottom page placement',
      'Maximum exposure',
      'Responsive across devices',
      'Premium positioning'
    ]
  },
  splash: {
    id: 'splash',
    title: 'Splash/Overlay Ad',
    subtitle: 'Interstitial Placement',
    description: 'Professional overlay ads between page loads',
    basePrice: 5000,
    duration: 7,
    dimensions: '400x300px',
    maxFileSize: '3MB',
    color: 'bg-purple-50 border-purple-200',
    icon: <Play className="w-6 h-6 text-purple-600" />,
    preview: {
      width: '400px',
      height: '300px',
      position: 'center',
      pages: ['All Pages', 'Landing Page Only']
    },
    features: [
      'Interstitial overlay display',
      'High engagement rate',
      'Skip option after 2 seconds',
      'Auto-close functionality'
    ]
  },
  event: {
    id: 'event',
    title: 'Sponsored Event',
    subtitle: 'Events Section',
    description: 'Featured placement in the Events slider section',
    basePrice: 4000,
    duration: 7,
    dimensions: '320x200px',
    maxFileSize: '2MB',
    color: 'bg-orange-50 border-orange-200',
    icon: <Calendar className="w-6 h-6 text-orange-600" />,
    preview: {
      width: '320px',
      height: '200px',
      position: 'slider',
      pages: ['Landing Page Events Section', 'Contact Page Events Section']
    },
    features: [
      'Featured in Events slider',
      'High visibility on landing page',
      'Event promotion focus',
      'Premium section placement'
    ]
  },
  square: {
    id: 'square',
    title: 'Square Banner',
    subtitle: 'Compact Placement',
    description: 'Square format ads perfect for sidebar and content areas',
    basePrice: 2500,
    duration: 7,
    dimensions: '300x300px',
    maxFileSize: '2MB',
    color: 'bg-teal-50 border-teal-200',
    icon: <Maximize2 className="w-6 h-6 text-teal-600" />,
    preview: {
      width: '300px',
      height: '300px',
      position: 'sidebar',
      pages: ['FAQs Page', 'Gallery Page', 'How to Use Page', 'Contact Page']
    },
    features: [
      'Perfect square format',
      'Sidebar and content placement',
      'High engagement potential',
      'Responsive design'
    ]
  }
}

// Available pages for each ad type
const availablePages = {
  vertical: [
    { id: 'faqs', name: 'FAQs Page', description: 'Sidebar placement on FAQs page' }
  ],
  horizontal: [
    { id: 'landing', name: 'Landing Page', description: 'Top banner on main landing page' },
    { id: 'gallery', name: 'Gallery Page', description: 'Top banner on Gallery page' },
    { id: 'faqs', name: 'FAQs Page', description: 'Top banner on FAQs page (mobile only)' }
  ],
  splash: [
    { id: 'landing', name: 'Landing Page Only', description: 'Splash ad on landing page' },
    { id: 'all', name: 'All Pages', description: 'Splash ad on all pages' }
  ],
  event: [
    { id: 'landing-events', name: 'Landing Page Events Section', description: 'Featured in Events slider section' },
    { id: 'contact-events', name: 'Contact Page Events Section', description: 'Featured in Contact page events slider' }
  ],
  square: [
    { id: 'faqs', name: 'FAQs Page', description: 'Square ad placement on FAQs page' },
    { id: 'gallery', name: 'Gallery Page', description: 'Square ad placement on Gallery page' },
    { id: 'how-to-use', name: 'How to Use Page', description: 'Square ad placement on How to Use page' },
    { id: 'contact', name: 'Contact Page', description: 'Square ad placement on Contact page' }
  ]
}

// Page targeting options
const pageTargeting = {
  single: { multiplier: 1, label: 'Single Page', description: 'Ad appears on one specific page' },
  multiple: { multiplier: 1.5, label: 'Multiple Pages', description: 'Ad appears on 2-5 selected pages' },
  all: { multiplier: 2.5, label: 'All Pages', description: 'Ad appears across entire website' }
}

// Duration options
const durationOptions = [
  { days: 3, multiplier: 0.6, label: '3 Days' },
  { days: 7, multiplier: 1, label: '1 Week' },
  { days: 14, multiplier: 1.8, label: '2 Weeks' },
  { days: 30, multiplier: 3, label: '1 Month' }
]

export default function AdvertisePage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  
  // Wizard state
  const [currentStep, setCurrentStep] = useState(1)
  const [isWizardOpen, setIsWizardOpen] = useState(false)
  
  // Campaign configuration
  const [selectedAdType, setSelectedAdType] = useState('vertical')
  const [selectedDuration, setSelectedDuration] = useState(7)
  
  // Form data
  const [formData, setFormData] = useState({
    adTitle: '',
    companyName: '',
    description: '',
    linkRedirect: '',
    email: '',
    contactNumber: '',
    uploadedImage: null
  })
  
  // UI state
  const [dragActive, setDragActive] = useState(false)
  const [imagePreview, setImagePreview] = useState(null)
  const [errors, setErrors] = useState({})
  const [isValidatingImage, setIsValidatingImage] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  
  // Payment state
  const [paymentMethod, setPaymentMethod] = useState('card')
  const [paymentData, setPaymentData] = useState({
    cardNumber: '',
    expiryDate: '',
    cvv: '',
    cardName: '',
    phoneNumber: '',
    psid: ''
  })
  const [isProcessingPayment, setIsProcessingPayment] = useState(false)
  const [showSuccessPopup, setShowSuccessPopup] = useState(false)
  const [successData, setSuccessData] = useState(null)

  const currentAdType = adTypes[selectedAdType]
  const currentDuration = durationOptions.find(d => d.days === selectedDuration)

  // Calculate pricing
  const calculatePrice = () => {
    const basePrice = currentAdType.basePrice
    const durationMultiplier = currentDuration.multiplier
    return Math.round(basePrice * durationMultiplier)
  }

  const finalPrice = calculatePrice()

  // Wizard steps configuration
  const wizardSteps = [
    {
      id: 1,
      title: 'Choose Format',
      description: 'Select your ad format',
      icon: <Target className="w-5 h-5" />,
      completed: selectedAdType !== 'vertical'
    },
    {
      id: 2,
      title: 'Configure',
      description: 'Set duration & details',
      icon: <Settings className="w-5 h-5" />,
      completed: selectedDuration !== 7
    },
    {
      id: 3,
      title: 'Content',
      description: 'Upload & details',
      icon: <FileText className="w-5 h-5" />,
      completed: formData.adTitle && formData.companyName && formData.email
    },
    {
      id: 4,
      title: 'Review',
      description: 'Final review',
      icon: <CheckCircle2 className="w-5 h-5" />,
      completed: false
    },
    {
      id: 5,
      title: 'Payment',
      description: 'Complete payment',
      icon: <CreditCard className="w-5 h-5" />,
      completed: false
    }
  ]

  // URL parameter handling functions
  const updateURL = (params) => {
    const url = new URL(window.location)
    Object.keys(params).forEach(key => {
      if (params[key]) {
        url.searchParams.set(key, params[key])
      } else {
        url.searchParams.delete(key)
      }
    })
    router.replace(url.pathname + url.search, { scroll: false })
  }

  const getURLParams = () => {
    return {
      step: searchParams.get('step'),
      adType: searchParams.get('adType'),
      duration: searchParams.get('duration'),
      paymentMethod: searchParams.get('paymentMethod'),
      wizard: searchParams.get('wizard')
    }
  }

  // Load state from URL parameters on mount
  useEffect(() => {
    const urlParams = getURLParams()
    
    if (urlParams.step) {
      setCurrentStep(parseInt(urlParams.step))
    }
    
    if (urlParams.adType) {
      setSelectedAdType(urlParams.adType)
    }
    
    if (urlParams.duration) {
      setSelectedDuration(parseInt(urlParams.duration))
    }
    
    if (urlParams.paymentMethod) {
      setPaymentMethod(urlParams.paymentMethod)
    }
    
    if (urlParams.wizard === 'true') {
      setIsWizardOpen(true)
    }
  }, [])

  // Update URL when state changes
  useEffect(() => {
    if (isWizardOpen) {
      updateURL({
        wizard: 'true',
        step: currentStep.toString(),
        adType: selectedAdType,
        duration: selectedDuration.toString(),
        paymentMethod: paymentMethod
      })
    } else {
      updateURL({
        wizard: null,
        step: null,
        adType: null,
        duration: null,
        paymentMethod: null
      })
    }
  }, [isWizardOpen, currentStep, selectedAdType, selectedDuration, paymentMethod])

  // Auto-save form data
  useEffect(() => {
    if (isWizardOpen) {
      const savedData = localStorage.getItem('adCampaignData')
      if (savedData) {
        const parsed = JSON.parse(savedData)
        setFormData(prev => ({ ...prev, ...parsed.formData }))
        setSelectedAdType(parsed.selectedAdType || 'vertical')
        setSelectedDuration(parsed.selectedDuration || 7)
      }
    }
  }, [isWizardOpen])

  // Save data on change
  useEffect(() => {
    if (isWizardOpen) {
      localStorage.setItem('adCampaignData', JSON.stringify({
        formData,
        selectedAdType,
        selectedDuration
      }))
    }
  }, [formData, selectedAdType, selectedDuration, isWizardOpen])

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }))
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({
        ...prev,
        [field]: ''
      }))
    }
  }

  const handleImageUpload = async (file) => {
    if (file) {
      setIsValidatingImage(true)
      try {
        const validation = await validateAdImage(file, selectedAdType)
        
        if (!validation.valid) {
          setErrors(prev => ({
            ...prev,
            uploadedImage: validation.errors.join(', ')
          }))
          return
        }

        setFormData(prev => ({
          ...prev,
          uploadedImage: file
        }))

        const reader = new FileReader()
        reader.onload = (e) => {
          setImagePreview(e.target.result)
        }
        reader.readAsDataURL(file)

        if (errors.uploadedImage) {
          setErrors(prev => ({
            ...prev,
            uploadedImage: ''
          }))
        }
      } catch (error) {
        setErrors(prev => ({
          ...prev,
          uploadedImage: 'Error validating image. Please try again.'
        }))
      } finally {
        setIsValidatingImage(false)
      }
    }
  }

  const handleDrag = (e) => {
    e.preventDefault()
    e.stopPropagation()
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true)
    } else if (e.type === "dragleave") {
      setDragActive(false)
    }
  }

  const handleDrop = (e) => {
    e.preventDefault()
    e.stopPropagation()
    setDragActive(false)
    
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      handleImageUpload(e.dataTransfer.files[0])
    }
  }

  const validateForm = () => {
    const newErrors = {}

    if (!formData.adTitle.trim()) {
      newErrors.adTitle = 'Please enter an ad title'
    }
    if (!formData.companyName.trim()) {
      newErrors.companyName = 'Please enter your company name'
    }
    if (!formData.email.trim()) {
      newErrors.email = 'Please enter your email'
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email address'
    }
    if (!formData.contactNumber.trim()) {
      newErrors.contactNumber = 'Please enter your contact number'
    } else if (!/^[\+]?[1-9][\d]{0,15}$/.test(formData.contactNumber.replace(/\s/g, ''))) {
      newErrors.contactNumber = 'Please enter a valid phone number'
    }
    if (!formData.uploadedImage) {
      newErrors.uploadedImage = 'Please upload an ad image'
    }
    if (!formData.linkRedirect.trim()) {
      newErrors.linkRedirect = 'Please enter a redirect URL'
    } else if (!/^https?:\/\/.+/.test(formData.linkRedirect)) {
      newErrors.linkRedirect = 'Please enter a valid URL starting with http:// or https://'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = () => {
    if (validateForm() && finalPrice > 0) {
      setIsLoading(true)

      // Store form data in localStorage for payment page
      localStorage.setItem('adFormData', JSON.stringify({
        ...formData,
        adType: selectedAdType,
        duration: selectedDuration,
        price: finalPrice,
        basePrice: currentAdType.basePrice,
        durationMultiplier: currentDuration.multiplier
      }))

      setTimeout(() => {
        window.location.href = '/advertise/payment'
      }, 500)
    }
  }

  const handlePayment = async () => {
    setIsProcessingPayment(true)

    try {
      if (paymentMethod === 'kuickpay') {
        // Generate PSID for Kuickpay
        const psid = `PSID-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`
        
        // Store complete campaign data with PSID
        const campaignData = {
          ...formData,
          adType: selectedAdType,
          duration: selectedDuration,
          price: finalPrice,
          basePrice: currentAdType.basePrice,
          durationMultiplier: currentDuration.multiplier,
          paymentMethod,
          paymentData: { ...paymentData, psid },
          status: 'pending_payment',
          createdAt: new Date().toISOString(),
          campaignId: `AD-${Date.now()}`
        }

        localStorage.setItem('campaignData', JSON.stringify(campaignData))

        // Show success popup with PSID
        setSuccessData({
          type: 'kuickpay',
          psid: psid,
          campaignId: campaignData.campaignId,
          amount: finalPrice
        })
        setShowSuccessPopup(true)
        
      } else {
        // Simulate card payment processing
        await new Promise(resolve => setTimeout(resolve, 3000))

        // Store complete campaign data
        const campaignData = {
          ...formData,
          adType: selectedAdType,
          duration: selectedDuration,
          price: finalPrice,
          basePrice: currentAdType.basePrice,
          durationMultiplier: currentDuration.multiplier,
          paymentMethod,
          paymentData,
          status: 'pending_approval',
          createdAt: new Date().toISOString(),
          campaignId: `AD-${Date.now()}`
        }

        localStorage.setItem('campaignData', JSON.stringify(campaignData))

        // Show success popup for card payment
        setSuccessData({
          type: 'card',
          campaignId: campaignData.campaignId,
          amount: finalPrice
        })
        setShowSuccessPopup(true)
      }
      
    } catch (error) {
      console.error('Payment failed:', error)
      alert('Payment failed. Please try again.')
    } finally {
      setIsProcessingPayment(false)
    }
  }

  const openWizard = () => {
    setIsWizardOpen(true)
    setCurrentStep(1)
  }

  const closeWizard = () => {
    setIsWizardOpen(false)
    setCurrentStep(1)
  }

  const nextStep = () => {
    if (currentStep < 5) {
      setCurrentStep(currentStep + 1)
    }
  }

  const prevStep = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1)
    }
  }

  const goToStep = (step) => {
    setCurrentStep(step)
  }

  return (
    <>
      <DashboardHeader />
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
        {/* Hero Section */}
      <div className="relative bg-gradient-to-r from-teal-900 via-teal-800 to-teal-700 text-white overflow-hidden">
        {/* Background Pattern */}
        <div className="absolute inset-0 opacity-20">
          <div className="absolute inset-0" style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Ccircle cx='30' cy='30' r='2'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
            backgroundSize: '60px 60px'
          }}></div>
        </div>
        
        <div className="relative py-20 px-4">
          <div className="container mx-auto max-w-7xl">
            <div className="grid lg:grid-cols-2 gap-12 items-center">
              <div className="space-y-8">
                <div className="space-y-4">
                  <Badge className="bg-blue-600 text-white px-4 py-2 text-sm font-medium">
                    <Star className="w-4 h-4 mr-2" />
                    Premium Advertising Platform
                  </Badge>
                  <h1 className="text-5xl lg:text-6xl font-bold leading-tight">
                    Advertise on{' '}
                    <span className="text-transparent bg-clip-text bg-gradient-to-r from-teal-400 to-cyan-400">
                      DHA Marketplace
                    </span>
                  </h1>
                  <p className="text-xl text-teal-100 leading-relaxed">
                    Reach thousands of property buyers, investors, and real estate professionals. 
                    Our premium advertising platform connects you with the most engaged audience in Pakistan's real estate market.
                  </p>
                </div>

                <div className="grid grid-cols-3 gap-6">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-blue-300">10K+</div>
                    <div className="text-sm text-blue-200">Monthly Visitors</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-blue-300">95%</div>
                    <div className="text-sm text-blue-200">Engagement Rate</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-blue-300">24/7</div>
                    <div className="text-sm text-blue-200">Ad Visibility</div>
                  </div>
                </div>

                <div className="flex flex-col sm:flex-row gap-4">
                  <Button 
                    size="lg" 
                    className="bg-white text-blue-900 hover:bg-blue-50 px-8 py-4 text-lg font-semibold"
                    onClick={() => document.getElementById('ad-types').scrollIntoView({ behavior: 'smooth' })}
                  >
                    Start Your Campaign
                    <ArrowRight className="w-5 h-5 ml-2" />
                  </Button>
                  <Button 
                    size="lg" 
                    variant="outline" 
                    className="border-white text-white hover:bg-white hover:text-blue-900 px-8 py-4 text-lg font-semibold bg-transparent"
                    onClick={() => document.getElementById('features').scrollIntoView({ behavior: 'smooth' })}
                  >
                    Learn More
                  </Button>
                </div>
              </div>

              <div className="relative">
                <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 border border-white/20">
                  <div className="flex items-center justify-between mb-6">
                    <div className="flex items-center space-x-3">
                      <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center">
                        <Megaphone className="w-6 h-6 text-white" />
                      </div>
                      <div>
                        <h3 className="text-xl font-semibold">Campaign Preview</h3>
                        <p className="text-blue-200">Live pricing calculator</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-2xl font-bold text-blue-300">PKR {finalPrice.toLocaleString()}</div>
                      <div className="text-sm text-blue-200">Starting Price</div>
                    </div>
                  </div>
                  
                  <div className="space-y-4">
                    <div className="flex justify-between text-sm">
                      <span className="text-blue-200">Ad Type:</span>
                      <span className="text-white font-medium">{currentAdType.title}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-blue-200">Duration:</span>
                      <span className="text-white font-medium">{currentDuration.label}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-blue-200">Targeting:</span>
                      <span className="text-white font-medium">Managed by Admin</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Why Advertise Section */}
      <section id="features" className="py-20 bg-white">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-6">Why Choose DHA Marketplace Advertising?</h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Join hundreds of successful advertisers who trust our platform to reach their target audience 
              and achieve remarkable results in Pakistan's premier real estate marketplace.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              {
                icon: <Users2 className="w-8 h-8" />,
                title: "Premium Audience",
                description: "Connect with high-value property buyers, investors, and real estate professionals actively seeking opportunities."
              },
              {
                icon: <TargetIcon className="w-8 h-8" />,
                title: "Precise Targeting",
                description: "Reach your ideal audience with page-specific targeting and advanced demographic controls."
              },
              {
                icon: <BarChart3 className="w-8 h-8" />,
                title: "Real-time Analytics",
                description: "Track performance with detailed insights on impressions, clicks, and engagement metrics."
              },
              {
                icon: <Shield className="w-8 h-8" />,
                title: "Brand Safety",
                description: "Your ads appear in a trusted, professional environment alongside premium real estate content."
              },
              {
                icon: <Zap className="w-8 h-8" />,
                title: "Instant Setup",
                description: "Launch your campaign in minutes with our streamlined approval and activation process."
              },
              {
                icon: <Award className="w-8 h-8" />,
                title: "Proven Results",
                description: "Join successful advertisers who have achieved significant ROI and brand visibility."
              }
            ].map((feature, index) => (
              <Card key={index} className="border-0 shadow-lg hover:shadow-xl transition-all duration-300 group">
                <CardContent className="p-8">
                  <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300">
                    <div className="text-white">{feature.icon}</div>
                  </div>
                  <h3 className="text-xl font-semibold mb-4">{feature.title}</h3>
                  <p className="text-gray-600 leading-relaxed">{feature.description}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Success Stories */}
      <section className="py-20 bg-gradient-to-r from-gray-50 to-blue-50">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-6">Success Stories</h2>
            <p className="text-xl text-gray-600">See how our advertisers achieve remarkable results</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {[
              {
                company: "Elite Properties",
                result: "300% increase in leads",
                description: "Our vertical banner campaign generated 3x more qualified leads compared to other platforms.",
                rating: 5
              },
              {
                company: "Luxury Developers",
                result: "500+ property views",
                description: "The splash ad campaign drove unprecedented traffic to our premium property listings.",
                rating: 5
              },
              {
                company: "Real Estate Consultants",
                result: "95% engagement rate",
                description: "Our targeted horizontal banners achieved exceptional engagement and conversion rates.",
                rating: 5
              }
            ].map((story, index) => (
              <Card key={index} className="bg-white border-0 shadow-lg">
                <CardContent className="p-8">
                  <div className="flex items-center mb-4">
                    {[...Array(story.rating)].map((_, i) => (
                      <Star key={i} className="w-5 h-5 text-yellow-400 fill-current" />
                    ))}
                  </div>
                  <h3 className="text-xl font-semibold mb-2">{story.company}</h3>
                  <div className="text-2xl font-bold text-blue-600 mb-4">{story.result}</div>
                  <p className="text-gray-600">{story.description}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Ad Types Section */}
      <section id="ad-types" className="py-20 bg-white">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-6">Choose Your Perfect Ad Format</h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto mb-12">
              Select from our premium ad formats designed to maximize visibility and engagement 
              across the DHA Marketplace platform.
            </p>
            
            {/* CTA Button */}
            <div className="flex justify-center">
              <Button 
                onClick={openWizard}
                size="lg"
                className="bg-gradient-to-r from-teal-600 to-teal-700 hover:from-teal-700 hover:to-teal-800 text-white px-12 py-6 text-xl font-semibold rounded-2xl shadow-2xl hover:shadow-3xl transition-all duration-300 transform hover:scale-105"
              >
                <Sparkles className="w-6 h-6 mr-3" />
                Create Your Campaign
                <ArrowRight className="w-6 h-6 ml-3" />
              </Button>
          </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 bg-gradient-to-r from-gray-50 to-blue-50">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-6">How It Works</h2>
            <p className="text-xl text-gray-600">Get your campaign live in just 3 simple steps</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {[
              {
                step: "01",
                icon: <Target className="w-10 h-10" />,
                title: "Choose Your Format",
                description: "Select from our premium ad formats and configure targeting options to reach your ideal audience."
              },
              {
                step: "02",
                icon: <Calendar className="w-10 h-10" />,
                title: "Set Campaign Details",
                description: "Upload your creative assets, set duration, and configure your campaign parameters."
              },
              {
                step: "03",
                icon: <TrendingUp className="w-10 h-10" />,
                title: "Launch & Monitor",
                description: "Your ad goes live after approval and you can track performance in real-time."
              }
            ].map((step, index) => (
              <Card key={index} className="text-center border-0 shadow-xl bg-white">
                <CardContent className="pt-8 pb-8">
                  <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-full flex items-center justify-center mx-auto mb-6">
                    <div className="text-white font-bold text-xl">{step.step}</div>
                  </div>
                  <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-6">
                    <div className="text-blue-600">{step.icon}</div>
                  </div>
                  <h3 className="text-xl font-semibold mb-4">{step.title}</h3>
                  <p className="text-gray-600 leading-relaxed">{step.description}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-r from-teal-900 to-teal-700 text-white">
        <div className="container mx-auto px-4 text-center max-w-4xl">
          <h2 className="text-4xl font-bold mb-6">Ready to Reach Your Target Audience?</h2>
          <p className="text-xl mb-8 text-teal-100 leading-relaxed">
            Join successful advertisers who trust DHA Marketplace to connect with Pakistan's most engaged 
            real estate audience. Start your campaign today and see the difference.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button 
              size="lg" 
              className="bg-white text-blue-900 hover:bg-blue-50 px-8 py-4 text-lg font-semibold rounded-xl"
              onClick={() => window.location.href = '/advertise/submit'}
            >
              Start Your Campaign
              <ArrowUpRight className="w-5 h-5 ml-2" />
            </Button>
            <Button 
              size="lg" 
              variant="outline" 
              className="border-white text-white hover:bg-white hover:text-blue-900 px-8 py-4 text-lg font-semibold rounded-xl bg-transparent"
              onClick={() => window.location.href = '/advertise/dashboard'}
            >
              View Dashboard
            </Button>
          </div>
                 </div>
       </section>
     </div>

     {/* Campaign Creation Wizard */}
     {isWizardOpen && (
       <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex">
         <div className="bg-white w-full max-w-7xl mx-auto my-0 lg:my-4 rounded-none lg:rounded-2xl shadow-2xl overflow-hidden flex flex-col h-full lg:h-[calc(100vh-2rem)]">
           {/* Wizard Header */}
           <div className="bg-gradient-to-r from-teal-600 to-teal-700 text-white p-3 lg:p-4 flex-shrink-0">
             <div className="flex items-center justify-between">
               <div>
                 <h2 className="text-lg lg:text-xl font-bold">Create Your Campaign</h2>
                 <p className="text-teal-100 text-xs lg:text-sm mt-0.5">Step {currentStep} of 5</p>
               </div>
               <Button
                 variant="ghost"
                 size="sm"
                 onClick={closeWizard}
                 className="text-white hover:bg-white/20 rounded-full p-2"
               >
                 <X className="w-5 h-5" />
               </Button>
             </div>
             
             {/* Progress Bar */}
             <div className="mt-3 lg:mt-4">
               <div className="flex items-center justify-center space-x-1 lg:space-x-2">
                 {wizardSteps.map((step, index) => (
                   <div key={step.id} className="flex items-center">
                     <div 
                       className={`w-6 h-6 lg:w-7 lg:h-7 rounded-full flex items-center justify-center text-xs font-semibold cursor-pointer transition-all duration-300 ${
                         step.id === currentStep 
                           ? 'bg-white text-teal-600 scale-110' 
                           : step.completed 
                             ? 'bg-green-500 text-white' 
                             : 'bg-white/20 text-white hover:bg-white/30'
                       }`}
                       onClick={() => goToStep(step.id)}
                     >
                       {step.completed ? <CheckCircle2 className="w-2.5 h-2.5 lg:w-3 lg:h-3" /> : step.id}
                     </div>
                     {index < wizardSteps.length - 1 && (
                       <div className={`w-6 lg:w-10 h-1 mx-1 lg:mx-1.5 rounded-full transition-all duration-300 ${
                         step.id < currentStep ? 'bg-white' : 'bg-white/20'
                       }`} />
                     )}
                   </div>
                 ))}
               </div>
             </div>
           </div>

           {/* Wizard Content */}
           <div className="flex-1 flex overflow-hidden">
             {/* Sidebar Navigation - Hidden on mobile */}
             <div className="hidden lg:flex w-80 bg-gray-50 border-r border-gray-200 flex-shrink-0">
               <div className="p-6">
                 <h3 className="text-lg font-semibold mb-4">Campaign Steps</h3>
                 <div className="space-y-2">
                   {wizardSteps.map((step) => (
                     <div
                       key={step.id}
                       className={`p-3 rounded-lg cursor-pointer transition-all duration-200 ${
                         step.id === currentStep
                           ? 'bg-teal-100 border-l-4 border-teal-600 text-teal-900'
                           : step.completed
                             ? 'bg-green-50 text-green-800 hover:bg-green-100'
                             : 'text-gray-600 hover:bg-gray-100'
                       }`}
                       onClick={() => goToStep(step.id)}
                     >
                       <div className="flex items-center gap-3">
                         <div className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-semibold ${
                           step.id === currentStep
                             ? 'bg-teal-600 text-white'
                             : step.completed
                               ? 'bg-green-500 text-white'
                               : 'bg-gray-300 text-gray-600'
                         }`}>
                           {step.completed ? <CheckCircle2 className="w-3 h-3" /> : step.id}
                         </div>
                         <div>
                           <div className="font-medium text-sm">{step.title}</div>
                           <div className="text-xs opacity-75">{step.description}</div>
                         </div>
                       </div>
                     </div>
                   ))}
                 </div>
                 
                 {/* Pricing Summary */}
                 <div className="mt-8 p-4 bg-white rounded-lg border border-gray-200">
                   <h4 className="font-semibold mb-3">Pricing Summary</h4>
                   <div className="space-y-2 text-sm">
                     <div className="flex justify-between">
                       <span>Base Price:</span>
                       <span>PKR {currentAdType.basePrice.toLocaleString()}</span>
                     </div>
                     <div className="flex justify-between">
                       <span>Duration ({currentDuration.label}):</span>
                       <span>{currentDuration.multiplier}x</span>
                     </div>
                     <div className="border-t pt-2 flex justify-between font-bold">
                       <span>Total:</span>
                       <span className="text-teal-600">PKR {finalPrice.toLocaleString()}</span>
                     </div>
                   </div>
                 </div>
               </div>
             </div>

             {/* Main Content Area */}
             <div className="flex-1 overflow-y-auto p-3 lg:p-6">
               {currentStep === 1 && (
                 <div className="space-y-4 lg:space-y-8">
                   <div className="text-center mb-4 lg:mb-8">
                     <h3 className="text-xl lg:text-2xl font-bold mb-2">Choose Your Ad Format</h3>
                     <p className="text-gray-600 text-sm lg:text-base">Select the perfect format for your campaign</p>
                   </div>
                 
                 <div className="grid grid-cols-1 gap-3 lg:gap-6">
                   {Object.values(adTypes).map((adType) => (
                     <Card 
                       key={adType.id}
                       className={`cursor-pointer transition-all duration-300 hover:shadow-xl ${
                         selectedAdType === adType.id 
                           ? 'ring-2 ring-blue-500 shadow-xl' 
                           : 'hover:shadow-lg'
                       }`}
                       onClick={() => setSelectedAdType(adType.id)}
                     >
                       <CardContent className="p-4 lg:p-6">
                         <div className="flex items-center gap-3 mb-3 lg:mb-4">
                           <div className={`p-2 lg:p-3 rounded-xl ${adType.color} flex-shrink-0`}>
                             {adType.icon}
                              </div>
                           <div className="min-w-0 flex-1">
                             <h4 className="text-base lg:text-xl font-semibold">{adType.title}</h4>
                             <p className="text-gray-600 text-sm lg:text-base">{adType.subtitle}</p>
                            </div>
                              </div>
                         <p className="text-gray-700 mb-3 lg:mb-4 text-sm lg:text-base">{adType.description}</p>
                         
                         <div className="bg-gray-50 rounded-lg p-3 lg:p-4 mb-3 lg:mb-4">
                           <div className="text-xs lg:text-sm font-semibold text-gray-700 mb-2">Preview</div>
                           <div className="flex justify-center">
                             <div className="relative bg-gradient-to-br from-gray-100 to-gray-200 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center overflow-hidden"
                                  style={{ 
                                    width: adType.id === 'vertical' ? '60px' : adType.id === 'horizontal' ? '120px' : adType.id === 'splash' ? '80px' : '80px',
                                    height: adType.id === 'vertical' ? '120px' : adType.id === 'horizontal' ? '30px' : adType.id === 'splash' ? '60px' : '50px',
                                    maxWidth: '100%'
                                  }}>
                               <div className="text-center text-gray-500">
                                 <div className="text-xs font-medium">{adType.dimensions}</div>
                            </div>
                          </div>
                          </div>
                        </div>

                         <div className="flex justify-between items-center">
                           <div className="text-xs lg:text-sm text-gray-600">
                             Starting from PKR {adType.basePrice.toLocaleString()}
                              </div>
                           {selectedAdType === adType.id && (
                             <CheckCircle className="w-5 h-5 lg:w-6 lg:h-6 text-green-600 flex-shrink-0" />
                           )}
                        </div>
                      </CardContent>
                    </Card>
                   ))}
                  </div>
               </div>
             )}

               {currentStep === 2 && (
                 <div className="space-y-4 lg:space-y-8">
                   <div className="text-center mb-4 lg:mb-8">
                     <h3 className="text-xl lg:text-2xl font-bold mb-2">Configure Your Campaign</h3>
                     <p className="text-gray-600 text-sm lg:text-base">Set campaign duration and targeting options</p>
                   </div>
                 
                   <div className="max-w-4xl mx-auto">
                     <div className="grid lg:grid-cols-2 gap-4 lg:gap-8">
                       {/* Duration Selection */}
                       <Card className="shadow-lg">
                         <CardHeader>
                           <CardTitle className="flex items-center gap-2">
                             <Calendar className="w-5 h-5 text-teal-600" />
                             Campaign Duration
                           </CardTitle>
                           <CardDescription>How long should your campaign run?</CardDescription>
                         </CardHeader>
                         <CardContent>
                           <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                             {durationOptions.map((option) => (
                               <div
                                 key={option.days}
                                 className={`p-3 lg:p-4 rounded-xl border-2 cursor-pointer transition-all text-center group ${
                                   selectedDuration === option.days
                                     ? 'border-teal-500 bg-teal-50 shadow-md'
                                     : 'border-gray-200 hover:border-teal-300 hover:shadow-sm hover:bg-teal-25'
                                 }`}
                                 onClick={() => setSelectedDuration(option.days)}
                               >
                                 <div className="font-semibold text-base mb-1">{option.label}</div>
                                 <div className="text-sm text-gray-600">{option.multiplier}x multiplier</div>
                                 <div className="text-xs text-gray-500 mt-1">
                                   PKR {Math.round(currentAdType.basePrice * option.multiplier).toLocaleString()}
                                 </div>
                               </div>
                             ))}
                           </div>
                         </CardContent>
                       </Card>

                       {/* Campaign Info */}
                       <Card className="shadow-lg">
                         <CardHeader>
                           <CardTitle className="flex items-center gap-2">
                             <Target className="w-5 h-5 text-teal-600" />
                             Campaign Details
                           </CardTitle>
                           <CardDescription>Your selected configuration</CardDescription>
                         </CardHeader>
                         <CardContent className="space-y-3 lg:space-y-4">
                           <div className="flex items-center gap-3 lg:gap-4 p-3 lg:p-4 bg-gray-50 rounded-lg">
                             <div className={`p-2 lg:p-3 rounded-xl ${currentAdType.color} flex-shrink-0`}>
                               {currentAdType.icon}
                             </div>
                             <div className="min-w-0 flex-1">
                               <h4 className="font-semibold text-sm lg:text-base">{currentAdType.title}</h4>
                               <p className="text-xs lg:text-sm text-gray-600">{currentAdType.subtitle}</p>
                             </div>
                           </div>

                           <div className="space-y-2 lg:space-y-3">
                             <div className="flex justify-between items-center py-2 border-b border-gray-100">
                               <span className="text-gray-600 text-sm lg:text-base">Duration:</span>
                               <span className="font-semibold text-sm lg:text-base">{currentDuration.label}</span>
                             </div>
                             <div className="flex justify-between items-center py-2 border-b border-gray-100">
                               <span className="text-gray-600 text-sm lg:text-base">Page Targeting:</span>
                               <span className="font-semibold text-sm lg:text-base">Managed by Admin</span>
                             </div>
                             <div className="flex justify-between items-center py-2">
                               <span className="text-gray-600 text-sm lg:text-base">Base Price:</span>
                               <span className="font-semibold text-sm lg:text-base">PKR {currentAdType.basePrice.toLocaleString()}</span>
                             </div>
                           </div>

                           <div className="bg-teal-50 border border-teal-200 rounded-lg p-3 lg:p-4">
                             <div className="flex justify-between items-center">
                               <span className="font-semibold text-teal-900 text-sm lg:text-base">Total Price:</span>
                               <span className="text-lg lg:text-xl font-bold text-teal-600">PKR {finalPrice.toLocaleString()}</span>
                             </div>
                           </div>
                         </CardContent>
                       </Card>
                     </div>
                   </div>
                 </div>
               )}

               {currentStep === 3 && (
                 <div className="space-y-4 lg:space-y-8">
                   <div className="text-center mb-4 lg:mb-8">
                     <h3 className="text-xl lg:text-2xl font-bold mb-2">Create Your Ad Content</h3>
                     <p className="text-gray-600 text-sm lg:text-base">Upload your creative assets and provide campaign details</p>
                   </div>
                 
                   <div className="grid lg:grid-cols-2 gap-4 lg:gap-8">
                     {/* Left Column - Form */}
                     <div className="space-y-4 lg:space-y-6">
                       {/* Ad Content Form */}
                       <Card>
                         <CardHeader>
                           <CardTitle>Ad Content</CardTitle>
                         </CardHeader>
                         <CardContent className="space-y-3 lg:space-y-4">
                           <div>
                             <Label htmlFor="adTitle">Ad Title *</Label>
                             <Input
                               id="adTitle"
                               value={formData.adTitle}
                               onChange={(e) => handleInputChange('adTitle', e.target.value)}
                               placeholder="Enter your ad title"
                               className={errors.adTitle ? 'border-red-500' : ''}
                             />
                             {errors.adTitle && <p className="text-red-500 text-sm mt-1">{errors.adTitle}</p>}
                           </div>

                           <div>
                             <Label htmlFor="companyName">Company Name *</Label>
                             <Input
                               id="companyName"
                               value={formData.companyName}
                               onChange={(e) => handleInputChange('companyName', e.target.value)}
                               placeholder="Your company name"
                               className={errors.companyName ? 'border-red-500' : ''}
                             />
                             {errors.companyName && <p className="text-red-500 text-sm mt-1">{errors.companyName}</p>}
                           </div>

                           <div>
                             <Label htmlFor="description">Ad Description</Label>
                             <Textarea
                               id="description"
                               value={formData.description}
                               onChange={(e) => handleInputChange('description', e.target.value)}
                               placeholder="Brief description of your ad"
                               rows={3}
                             />
                           </div>

                           <div>
                             <Label htmlFor="linkRedirect">Redirect URL *</Label>
                             <Input
                               id="linkRedirect"
                               value={formData.linkRedirect}
                               onChange={(e) => handleInputChange('linkRedirect', e.target.value)}
                               placeholder="https://your-website.com"
                               className={errors.linkRedirect ? 'border-red-500' : ''}
                             />
                             {errors.linkRedirect && <p className="text-red-500 text-sm mt-1">{errors.linkRedirect}</p>}
                           </div>
                         </CardContent>
                       </Card>

                       {/* Contact Information */}
                       <Card>
                         <CardHeader>
                           <CardTitle>Contact Information</CardTitle>
                         </CardHeader>
                         <CardContent className="space-y-3 lg:space-y-4">
                           <div>
                             <Label htmlFor="email">Email Address *</Label>
                             <Input
                               id="email"
                               type="email"
                               value={formData.email}
                               onChange={(e) => handleInputChange('email', e.target.value)}
                               placeholder="your@email.com"
                               className={errors.email ? 'border-red-500' : ''}
                             />
                             {errors.email && <p className="text-red-500 text-sm mt-1">{errors.email}</p>}
                           </div>

                           <div>
                             <Label htmlFor="contactNumber">Contact Number *</Label>
                             <Input
                               id="contactNumber"
                               value={formData.contactNumber}
                               onChange={(e) => handleInputChange('contactNumber', e.target.value)}
                               placeholder="+92 300 1234567"
                               className={errors.contactNumber ? 'border-red-500' : ''}
                             />
                             {errors.contactNumber && <p className="text-red-500 text-sm mt-1">{errors.contactNumber}</p>}
                           </div>
                         </CardContent>
                       </Card>
                     </div>

                     {/* Right Column - Image Upload */}
                     <div className="space-y-4 lg:space-y-6">
                       {/* Image Upload */}
                       <Card>
                         <CardHeader>
                           <CardTitle>Upload Ad Image</CardTitle>
                           <CardDescription>
                             Upload your {currentAdType.dimensions} ad image (Max: {currentAdType.maxFileSize})
                           </CardDescription>
                         </CardHeader>
                         <CardContent>
                           {/* Dimension Guide */}
                           <div className="mb-3 lg:mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                             <div className="flex items-center gap-2 mb-2">
                               <AlertCircle className="w-4 h-4 text-blue-600" />
                               <span className="font-medium text-blue-800 text-sm lg:text-base">Required Dimensions</span>
                             </div>
                             <div className="text-xs lg:text-sm text-blue-700">
                               <div className="flex items-center justify-between">
                                 <span>Width:</span>
                                 <span className="font-mono font-bold">{currentAdType.dimensions.split('x')[0]}px</span>
                               </div>
                               <div className="flex items-center justify-between">
                                 <span>Height:</span>
                                 <span className="font-mono font-bold">{currentAdType.dimensions.split('x')[1]}px</span>
                               </div>
                             </div>
                           </div>

                           <div
                             className={`border-2 border-dashed rounded-lg p-4 lg:p-6 text-center transition-colors ${
                               dragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'
                             } ${errors.uploadedImage ? 'border-red-500' : ''}`}
                             onDragEnter={handleDrag}
                             onDragLeave={handleDrag}
                             onDragOver={handleDrag}
                             onDrop={handleDrop}
                           >
                             {isValidatingImage ? (
                               <div className="space-y-4">
                                 <div className="flex items-center justify-center">
                                   <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                                 </div>
                                 <p className="text-sm text-gray-600">Validating image dimensions...</p>
                               </div>
                             ) : imagePreview ? (
                               <div className="space-y-4">
                                 <img 
                                   src={imagePreview} 
                                   alt="Preview" 
                                   className="w-full h-32 object-cover rounded mx-auto"
                                 />
                                 <Button
                                   variant="outline"
                                   onClick={() => {
                                     setFormData(prev => ({ ...prev, uploadedImage: null }))
                                     setImagePreview(null)
                                   }}
                                 >
                                   Change Image
                                 </Button>
                               </div>
                             ) : (
                               <div>
                                 <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                                 <p className="text-gray-600 mb-2">
                                   Drag and drop your image here, or{' '}
                                   <label className="text-blue-600 hover:text-blue-700 cursor-pointer">
                                     browse
                                     <input
                                       type="file"
                                       className="hidden"
                                       accept="image/*"
                                       onChange={(e) => e.target.files?.[0] && handleImageUpload(e.target.files[0])}
                                     />
                                   </label>
                                 </p>
                                 <p className="text-sm text-gray-500">
                                   {currentAdType.dimensions} • Max {currentAdType.maxFileSize}
                                 </p>
                               </div>
                             )}
                           </div>
                           {errors.uploadedImage && (
                             <p className="text-red-500 text-sm mt-2">{errors.uploadedImage}</p>
                           )}
                         </CardContent>
                       </Card>

                       {/* Live Preview */}
                       <Card>
                         <CardHeader>
                           <CardTitle>Live Preview</CardTitle>
                           <CardDescription>See how your ad will appear</CardDescription>
                         </CardHeader>
                         <CardContent>
                           <div className="bg-gray-100 rounded-lg p-4 border-2 border-dashed border-gray-300 flex items-center justify-center"
                                style={{ 
                                  width: currentAdType.preview.width, 
                                  height: currentAdType.preview.height,
                                  maxWidth: '100%'
                                }}>
                             {imagePreview ? (
                               <img 
                                 src={imagePreview} 
                                 alt="Ad Preview"
                                 className="w-full h-full object-cover rounded"
                               />
                             ) : (
                               <div className="text-center text-gray-500">
                                 <Upload className="w-8 h-8 mx-auto mb-2" />
                                 <div className="text-sm">Upload image to see preview</div>
                                 <div className="text-xs">{currentAdType.dimensions}</div>
                               </div>
                             )}
                           </div>
                         </CardContent>
                       </Card>
                     </div>
                   </div>
                </div>
               )}

               {currentStep === 4 && (
                 <div className="space-y-8">
                   <div className="text-center mb-8">
                     <h3 className="text-2xl font-bold mb-2">Review & Launch</h3>
                     <p className="text-gray-600">Review your campaign details and pricing</p>
                   </div>
                   
                   <div className="grid lg:grid-cols-2 gap-8">
                     {/* Campaign Summary */}
                     <Card className="shadow-lg">
                       <CardHeader>
                         <CardTitle>Campaign Summary</CardTitle>
                       </CardHeader>
                       <CardContent className="space-y-4">
                         <div className="flex items-center gap-4 p-4 bg-gray-50 rounded-lg">
                           <div className={`p-3 rounded-xl ${currentAdType.color} flex-shrink-0`}>
                             {currentAdType.icon}
                           </div>
                           <div className="min-w-0 flex-1">
                             <h4 className="font-semibold">{currentAdType.title}</h4>
                             <p className="text-sm text-gray-600">{currentAdType.subtitle}</p>
                           </div>
                         </div>

                         <div className="space-y-3">
                           <div className="flex justify-between items-center">
                             <span className="text-gray-600">Duration:</span>
                             <span className="font-semibold">{currentDuration.label}</span>
                           </div>
                           <div className="flex justify-between items-center">
                             <span className="text-gray-600">Page Targeting:</span>
                             <span className="font-semibold">Managed by Admin</span>
                           </div>
                           <div className="flex justify-between items-center">
                             <span className="text-gray-600">Company:</span>
                             <span className="font-semibold">{formData.companyName || 'Not specified'}</span>
                           </div>
                           <div className="flex justify-between items-center">
                             <span className="text-gray-600">Ad Title:</span>
                             <span className="font-semibold">{formData.adTitle || 'Not specified'}</span>
                           </div>
                           <div className="flex justify-between items-center">
                             <span className="text-gray-600">Redirect URL:</span>
                             <span className="font-semibold text-blue-600 truncate max-w-48">
                               {formData.linkRedirect || 'Not specified'}
                             </span>
                           </div>
                           <div className="flex justify-between items-center">
                             <span className="text-gray-600">Email:</span>
                             <span className="font-semibold">{formData.email || 'Not specified'}</span>
                           </div>
                           <div className="flex justify-between items-center">
                             <span className="text-gray-600">Contact:</span>
                             <span className="font-semibold">{formData.contactNumber || 'Not specified'}</span>
                           </div>
                           <div className="flex justify-between items-center">
                             <span className="text-gray-600">Image Uploaded:</span>
                             <span className="font-semibold text-green-600">
                               {formData.uploadedImage ? '✓ Yes' : '✗ No'}
                             </span>
                           </div>
                         </div>
                       </CardContent>
                     </Card>

                     {/* Pricing */}
                     <Card className="shadow-lg">
                       <CardHeader>
                         <CardTitle>Pricing Breakdown</CardTitle>
                       </CardHeader>
                       <CardContent>
                         <div className="space-y-4">
                           <div className="flex justify-between items-center">
                             <span>Base Price:</span>
                             <span className="font-semibold">PKR {currentAdType.basePrice.toLocaleString()}</span>
                           </div>
                           <div className="flex justify-between items-center">
                             <span>Duration Multiplier ({currentDuration.label}):</span>
                             <span className="font-semibold">{currentDuration.multiplier}x</span>
                           </div>
                           <div className="border-t pt-4 flex justify-between items-center">
                             <span className="text-xl font-bold">Total Price:</span>
                             <span className="text-2xl font-bold text-blue-600">PKR {finalPrice.toLocaleString()}</span>
                           </div>
                         </div>
                       </CardContent>
                     </Card>
                   </div>
                 </div>
               )}

               {currentStep === 5 && (
                 <div className="space-y-8">
                   <div className="text-center mb-8">
                     <h3 className="text-2xl font-bold mb-2">Complete Your Payment</h3>
                     <p className="text-gray-600">Secure payment processing for your campaign</p>
                   </div>
                   
                   <div className="max-w-4xl mx-auto">
                     <div className="grid lg:grid-cols-2 gap-8">
                       {/* Payment Form */}
                       <Card className="shadow-lg">
                         <CardHeader>
                           <CardTitle className="flex items-center gap-2">
                             <CreditCard className="w-5 h-5 text-teal-600" />
                             Payment Information
                           </CardTitle>
                           <CardDescription>Enter your payment details securely</CardDescription>
                         </CardHeader>
                         <CardContent className="space-y-6">
                           {/* Payment Method Selection */}
                           <div>
                             <Label className="text-sm font-medium mb-3 block">Payment Method</Label>
                             <div className="grid grid-cols-2 gap-4">
                               <div
                                 className={`p-4 rounded-lg border-2 cursor-pointer transition-all text-center ${
                                   paymentMethod === 'card'
                                     ? 'border-teal-500 bg-teal-50'
                                     : 'border-gray-200 hover:border-gray-300'
                                 }`}
                                 onClick={() => setPaymentMethod('card')}
                               >
                                 <CreditCard className="w-8 h-8 mx-auto mb-3 text-teal-600" />
                                 <div className="text-base font-medium">Credit/Debit Card</div>
                                 <div className="text-xs text-gray-500 mt-1">Direct card payment</div>
                               </div>
                               <div
                                 className={`p-4 rounded-lg border-2 cursor-pointer transition-all text-center ${
                                   paymentMethod === 'kuickpay'
                                     ? 'border-teal-500 bg-teal-50'
                                     : 'border-gray-200 hover:border-gray-300'
                                 }`}
                                 onClick={() => setPaymentMethod('kuickpay')}
                               >
                                 <div className="w-8 h-8 mx-auto mb-3 bg-blue-600 rounded flex items-center justify-center">
                                   <span className="text-white text-sm font-bold">K</span>
                                 </div>
                                 <div className="text-base font-medium">Kuickpay</div>
                                 <div className="text-xs text-gray-500 mt-1">Generate PSID for banking apps</div>
                               </div>
                             </div>
                           </div>

                           {paymentMethod === 'card' ? (
                             <div className="space-y-4">
                               <div>
                                 <Label htmlFor="cardNumber">Card Number</Label>
                                 <Input
                                   id="cardNumber"
                                   value={paymentData.cardNumber}
                                   onChange={(e) => setPaymentData(prev => ({ ...prev, cardNumber: e.target.value }))}
                                   placeholder="1234 5678 9012 3456"
                                   maxLength={19}
                                 />
                               </div>
                               <div className="grid grid-cols-2 gap-4">
                                 <div>
                                   <Label htmlFor="expiryDate">Expiry Date</Label>
                                   <Input
                                     id="expiryDate"
                                     value={paymentData.expiryDate}
                                     onChange={(e) => setPaymentData(prev => ({ ...prev, expiryDate: e.target.value }))}
                                     placeholder="MM/YY"
                                     maxLength={5}
                                   />
                                 </div>
                                 <div>
                                   <Label htmlFor="cvv">CVV</Label>
                                   <Input
                                     id="cvv"
                                     value={paymentData.cvv}
                                     onChange={(e) => setPaymentData(prev => ({ ...prev, cvv: e.target.value }))}
                                     placeholder="123"
                                     maxLength={4}
                                   />
                                 </div>
                               </div>
                               <div>
                                 <Label htmlFor="cardName">Cardholder Name</Label>
                                 <Input
                                   id="cardName"
                                   value={paymentData.cardName}
                                   onChange={(e) => setPaymentData(prev => ({ ...prev, cardName: e.target.value }))}
                                   placeholder="John Doe"
                                 />
                               </div>
                             </div>
                           ) : (
                             <div className="space-y-4">
                               <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                                 <div className="flex items-center gap-2 mb-3">
                                   <div className="w-6 h-6 bg-blue-600 rounded flex items-center justify-center">
                                     <span className="text-white text-xs font-bold">K</span>
                                   </div>
                                   <span className="font-medium text-blue-800">Kuickpay PSID Payment</span>
                                 </div>
                                 <div className="space-y-3">
                                   <p className="text-sm text-blue-700">
                                     <strong>Step 1:</strong> We will generate a PSID (Payment Service Identifier) for your payment.
                                   </p>
                                   <p className="text-sm text-blue-700">
                                     <strong>Step 2:</strong> Use this PSID in your banking app or Kuickpay app to complete the payment.
                                   </p>
                                   <p className="text-sm text-blue-700">
                                     <strong>Step 3:</strong> Your payment will be processed automatically once confirmed.
                                   </p>
                                 </div>
                               </div>
                               
                               <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                                 <div className="flex items-center gap-2 mb-2">
                                   <CheckCircle className="w-4 h-4 text-green-600" />
                                   <span className="font-medium text-green-800">Supported Apps</span>
                                 </div>
                                 <div className="grid grid-cols-2 gap-2 text-sm text-green-700">
                                   <div>• Kuickpay App</div>
                                   <div>• HBL Mobile</div>
                                   <div>• MCB Mobile</div>
                                   <div>• UBL Omni</div>
                                   <div>• Allied Mobile</div>
                                   <div>• Askari Mobile</div>
                                   <div>• Bank Alfalah</div>
                                   <div>• And many more...</div>
                                 </div>
                               </div>

                               <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
                                 <div className="flex items-center gap-2 mb-2">
                                   <AlertCircle className="w-4 h-4 text-gray-600" />
                                   <span className="font-medium text-gray-800">How it works</span>
                                 </div>
                                 <ol className="text-sm text-gray-600 space-y-1">
                                   <li>1. Click "Complete Payment" to generate your PSID</li>
                                   <li>2. Copy the PSID and open your banking app</li>
                                   <li>3. Look for "Pay via PSID" or "Kuickpay" option</li>
                                   <li>4. Enter the PSID and confirm payment</li>
                                   <li>5. Your campaign will be activated automatically</li>
                                 </ol>
                               </div>
                             </div>
                           )}

                           <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
                             <div className="flex items-center gap-2 mb-2">
                               <Shield className="w-4 h-4 text-green-600" />
                               <span className="font-medium text-gray-800">Secure Payment</span>
                             </div>
                             <p className="text-sm text-gray-600">
                               Your payment information is encrypted and secure. We use industry-standard SSL encryption.
                             </p>
                           </div>
                         </CardContent>
                       </Card>

                       {/* Order Summary */}
                       <Card className="shadow-lg">
                         <CardHeader>
                           <CardTitle className="flex items-center gap-2">
                             <CheckCircle2 className="w-5 h-5 text-teal-600" />
                             Order Summary
                           </CardTitle>
                           <CardDescription>Review your campaign details</CardDescription>
                         </CardHeader>
                         <CardContent className="space-y-4">
                           <div className="flex items-center gap-4 p-4 bg-gray-50 rounded-lg">
                             <div className={`p-3 rounded-xl ${currentAdType.color} flex-shrink-0`}>
                               {currentAdType.icon}
                             </div>
                             <div className="min-w-0 flex-1">
                               <h4 className="font-semibold">{currentAdType.title}</h4>
                               <p className="text-sm text-gray-600">{currentAdType.subtitle}</p>
                             </div>
                           </div>

                           <div className="space-y-3">
                             <div className="flex justify-between items-center py-2 border-b border-gray-100">
                               <span className="text-gray-600">Campaign Duration:</span>
                               <span className="font-semibold">{currentDuration.label}</span>
                             </div>
                             <div className="flex justify-between items-center py-2 border-b border-gray-100">
                               <span className="text-gray-600">Ad Title:</span>
                               <span className="font-semibold text-right max-w-32 truncate">{formData.adTitle}</span>
                             </div>
                             <div className="flex justify-between items-center py-2 border-b border-gray-100">
                               <span className="text-gray-600">Company:</span>
                               <span className="font-semibold">{formData.companyName}</span>
                             </div>
                             <div className="flex justify-between items-center py-2">
                               <span className="text-gray-600">Base Price:</span>
                               <span className="font-semibold">PKR {currentAdType.basePrice.toLocaleString()}</span>
                             </div>
                             <div className="flex justify-between items-center py-2">
                               <span className="text-gray-600">Duration ({currentDuration.label}):</span>
                               <span className="font-semibold">{currentDuration.multiplier}x</span>
                             </div>
                           </div>

                           <div className="bg-teal-50 border border-teal-200 rounded-lg p-4">
                             <div className="flex justify-between items-center mb-2">
                               <span className="font-semibold text-teal-900">Subtotal:</span>
                               <span className="font-semibold text-teal-900">PKR {finalPrice.toLocaleString()}</span>
                             </div>
                             <div className="flex justify-between items-center mb-2">
                               <span className="text-teal-700">Processing Fee:</span>
                               <span className="text-teal-700">PKR 0</span>
                             </div>
                             <div className="border-t border-teal-300 pt-2 flex justify-between items-center">
                               <span className="text-lg font-bold text-teal-900">Total:</span>
                               <span className="text-xl font-bold text-teal-600">PKR {finalPrice.toLocaleString()}</span>
                             </div>
                           </div>

                           <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                             <div className="flex items-center gap-2 mb-2">
                               <CheckCircle className="w-4 h-4 text-green-600" />
                               <span className="font-medium text-green-800">What happens next?</span>
                             </div>
                             <ul className="text-sm text-green-700 space-y-1">
                               <li>• Your campaign will be reviewed by our team</li>
                               <li>• You'll receive confirmation within 24 hours</li>
                               <li>• Your ad will go live after approval</li>
                               <li>• Track performance in your dashboard</li>
                             </ul>
                           </div>
                         </CardContent>
                       </Card>
                     </div>
                   </div>
                 </div>
               )}
             </div>
           </div>

           {/* Wizard Footer */}
           <div className="bg-gray-50 px-3 lg:px-6 py-3 lg:py-4 flex-shrink-0 border-t">
             <div className="flex flex-col sm:flex-row justify-between items-center gap-3 sm:gap-0">
               <Button 
                 variant="outline"
                 onClick={prevStep}
                 disabled={currentStep === 1}
                 className="flex items-center gap-2 w-full sm:w-auto"
               >
                 <ChevronLeft className="w-4 h-4" />
                 Previous
               </Button>
               
               <div className="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
                 <Button 
                   variant="outline" 
                   onClick={closeWizard}
                   className="w-full sm:w-auto"
                 >
                   Cancel
                 </Button>
                 {currentStep < 4 ? (
                   <Button
                     onClick={nextStep}
                     className="flex items-center gap-2 bg-teal-600 hover:bg-teal-700 w-full sm:w-auto"
                   >
                     Next
                     <ChevronRight className="w-4 h-4" />
                   </Button>
                 ) : currentStep === 4 ? (
                   <Button
                     onClick={nextStep}
                     className="flex items-center gap-2 bg-teal-600 hover:bg-teal-700 w-full sm:w-auto"
                   >
                     Proceed to Payment
                     <CreditCard className="w-4 h-4" />
                   </Button>
                 ) : (
                   <Button
                     onClick={handlePayment}
                     disabled={isProcessingPayment}
                     className="bg-gradient-to-r from-teal-600 to-teal-700 hover:from-teal-700 hover:to-teal-800 flex items-center gap-2 w-full sm:w-auto"
                   >
                     {isProcessingPayment ? (
                       <>
                         <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                         Processing Payment...
                       </>
                     ) : (
                       <>
                         <CreditCard className="w-4 h-4" />
                         Complete Payment
                       </>
                     )}
                   </Button>
                 )}
               </div>
             </div>
           </div>
         </div>
       </div>
     )}

     {/* Success Popup */}
     {showSuccessPopup && (
       <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-[60] flex items-center justify-center p-3 lg:p-4">
         <div className="bg-white rounded-xl lg:rounded-2xl shadow-2xl w-full max-w-md mx-auto overflow-hidden">
           {/* Header */}
           <div className="bg-gradient-to-r from-green-500 to-green-600 text-white p-4 lg:p-6 text-center">
             <div className="w-12 h-12 lg:w-16 lg:h-16 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-3 lg:mb-4">
               <CheckCircle className="w-6 h-6 lg:w-8 lg:h-8 text-white" />
             </div>
             <h2 className="text-xl lg:text-2xl font-bold mb-2">Congratulations!</h2>
             <p className="text-green-100 text-sm lg:text-base">Your campaign has been submitted successfully</p>
           </div>

           {/* Content */}
           <div className="p-4 lg:p-6">
             {successData?.type === 'kuickpay' ? (
               <div className="space-y-4">
                 <div className="text-center">
                   <div className="w-10 h-10 lg:w-12 lg:h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-3">
                     <div className="w-6 h-6 lg:w-8 lg:h-8 bg-blue-600 rounded flex items-center justify-center">
                       <span className="text-white text-xs lg:text-sm font-bold">K</span>
                     </div>
                   </div>
                   <h3 className="text-base lg:text-lg font-semibold mb-2">PSID Generated Successfully</h3>
                   <p className="text-gray-600 text-xs lg:text-sm">Use this PSID to complete your payment</p>
                 </div>

                 <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 lg:p-4">
                   <div className="text-center">
                     <p className="text-xs lg:text-sm text-blue-700 mb-2">Your PSID:</p>
                     <div className="bg-white border border-blue-300 rounded-lg p-2 lg:p-3 mb-3">
                       <code className="text-sm lg:text-lg font-mono font-bold text-blue-800 break-all">
                         {successData.psid}
                       </code>
                     </div>
                     <button
                       onClick={() => navigator.clipboard.writeText(successData.psid)}
                       className="text-blue-600 hover:text-blue-700 text-xs lg:text-sm font-medium"
                     >
                       Click to copy PSID
                     </button>
                   </div>
                 </div>

                 <div className="bg-gray-50 rounded-lg p-3 lg:p-4">
                   <h4 className="font-semibold text-gray-800 mb-2 text-sm lg:text-base">Next Steps:</h4>
                   <ol className="text-xs lg:text-sm text-gray-600 space-y-1">
                     <li>1. Open your banking app or Kuickpay app</li>
                     <li>2. Look for "Pay via PSID" or "Kuickpay" option</li>
                     <li>3. Enter the PSID above</li>
                     <li>4. Confirm the payment (PKR {successData.amount.toLocaleString()})</li>
                     <li>5. Your campaign will be activated automatically</li>
                   </ol>
                 </div>
               </div>
             ) : (
               <div className="space-y-4">
                 <div className="text-center">
                   <div className="w-10 h-10 lg:w-12 lg:h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3">
                     <CreditCard className="w-5 h-5 lg:w-6 lg:h-6 text-green-600" />
                   </div>
                   <h3 className="text-base lg:text-lg font-semibold mb-2">Payment Successful!</h3>
                   <p className="text-gray-600 text-xs lg:text-sm">Your campaign has been submitted for review</p>
                 </div>

                 <div className="bg-green-50 border border-green-200 rounded-lg p-3 lg:p-4">
                   <div className="text-center">
                     <p className="text-xs lg:text-sm text-green-700 mb-2">Campaign ID:</p>
                     <div className="bg-white border border-green-300 rounded-lg p-2 lg:p-3">
                       <code className="text-xs lg:text-sm font-mono font-bold text-green-800">
                         {successData.campaignId}
                       </code>
                     </div>
                   </div>
                 </div>

                 <div className="bg-gray-50 rounded-lg p-3 lg:p-4">
                   <h4 className="font-semibold text-gray-800 mb-2 text-sm lg:text-base">What happens next:</h4>
                   <ul className="text-xs lg:text-sm text-gray-600 space-y-1">
                     <li>• Your campaign will be reviewed by our team</li>
                     <li>• You'll receive confirmation within 24 hours</li>
                     <li>• Your ad will go live after approval</li>
                     <li>• Track performance in your dashboard</li>
                   </ul>
                 </div>
               </div>
             )}

             <div className="mt-4 lg:mt-6 pt-3 lg:pt-4 border-t border-gray-200">
               <div className="flex flex-col sm:flex-row gap-3">
                 <Button
                   variant="outline"
                   onClick={() => {
                     setShowSuccessPopup(false)
                     closeWizard()
                   }}
                   className="flex-1 w-full sm:w-auto"
                 >
                   Close
                 </Button>
                 <Button
                   onClick={() => {
                     setShowSuccessPopup(false)
                     closeWizard()
                     window.location.href = '/advertise/dashboard'
                   }}
                   className="flex-1 w-full sm:w-auto bg-teal-600 hover:bg-teal-700"
                 >
                   View Dashboard
                 </Button>
               </div>
             </div>
           </div>
         </div>
       </div>
     )}
     </>
   )
 }