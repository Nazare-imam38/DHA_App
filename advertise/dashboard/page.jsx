'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { 
  Eye, 
  MousePointer, 
  TrendingUp, 
  Calendar,
  DollarSign,
  BarChart3,
  Clock,
  CheckCircle,
  XCircle,
  Plus,
  ExternalLink,
  Maximize2,
  Minimize2,
  Play,
  Calendar as CalendarIcon
} from 'lucide-react'

// Mock data for demo
const mockAds = [
  {
    id: 1,
    title: 'Premium DHA Property Listing',
    type: 'vertical',
    typeLabel: 'Vertical Banner',
    status: 'active',
    startDate: '2024-01-15',
    endDate: '2024-01-22',
    price: 2000,
    pageTargeting: 'single',
    duration: 7,
    stats: {
      impressions: 15420,
      clicks: 234,
      ctr: 1.52,
      spent: 2000
    },
    placement: 'FAQs Page Sidebar',
    dimensions: '300x600px'
  },
  {
    id: 2,
    title: 'New Year Property Sale Event',
    type: 'horizontal',
    typeLabel: 'Horizontal Banner',
    status: 'pending',
    startDate: '2024-01-20',
    endDate: '2024-01-27',
    price: 3000,
    pageTargeting: 'all',
    duration: 7,
    stats: {
      impressions: 0,
      clicks: 0,
      ctr: 0,
      spent: 0
    },
    placement: 'All Pages Top',
    dimensions: '728x90px'
  },
  {
    id: 3,
    title: 'Luxury Apartments Showcase',
    type: 'splash',
    typeLabel: 'Splash Ad',
    status: 'active',
    startDate: '2024-01-08',
    endDate: '2024-01-15',
    price: 5000,
    pageTargeting: 'all',
    duration: 7,
    stats: {
      impressions: 28750,
      clicks: 892,
      ctr: 3.10,
      spent: 5000
    },
    placement: 'All Pages Interstitial',
    dimensions: '400x300px'
  },
  {
    id: 4,
    title: 'DHA Property Expo 2024',
    type: 'event',
    typeLabel: 'Sponsored Event',
    status: 'completed',
    startDate: '2024-01-01',
    endDate: '2024-01-08',
    price: 4000,
    pageTargeting: 'single',
    duration: 7,
    stats: {
      impressions: 12500,
      clicks: 456,
      ctr: 3.65,
      spent: 4000
    },
    placement: 'Landing Page Events Section',
    dimensions: '320x200px'
  }
]

const getStatusColor = (status) => {
  switch (status) {
    case 'active': return 'bg-green-100 text-green-800'
    case 'pending': return 'bg-yellow-100 text-yellow-800'
    case 'completed': return 'bg-blue-100 text-blue-800'
    case 'rejected': return 'bg-red-100 text-red-800'
    default: return 'bg-gray-100 text-gray-800'
  }
}

const getStatusIcon = (status) => {
  switch (status) {
    case 'active': return <CheckCircle className="w-4 h-4" />
    case 'pending': return <Clock className="w-4 h-4" />
    case 'completed': return <CheckCircle className="w-4 h-4" />
    case 'rejected': return <XCircle className="w-4 h-4" />
    default: return <Clock className="w-4 h-4" />
  }
}

const getAdTypeIcon = (type) => {
  switch (type) {
    case 'vertical': return <Maximize2 className="w-4 h-4" />
    case 'horizontal': return <Minimize2 className="w-4 h-4" />
    case 'splash': return <Play className="w-4 h-4" />
    case 'event': return <CalendarIcon className="w-4 h-4" />
    default: return <BarChart3 className="w-4 h-4" />
  }
}

export default function AdDashboard() {
  const [ads, setAds] = useState(mockAds)
  const [selectedAd, setSelectedAd] = useState(mockAds[0])
  const [activeTab, setActiveTab] = useState('overview')

  // Calculate totals
  const totalStats = ads.reduce((acc, ad) => ({
    impressions: acc.impressions + ad.stats.impressions,
    clicks: acc.clicks + ad.stats.clicks,
    spent: acc.spent + ad.stats.spent
  }), { impressions: 0, clicks: 0, spent: 0 })

  const avgCTR = totalStats.impressions > 0 ? (totalStats.clicks / totalStats.impressions * 100).toFixed(2) : 0


  const filteredAds = ads.filter(ad => {
    if (activeTab === 'overview') return true
    return ad.status === activeTab
  })

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="container mx-auto px-4 max-w-7xl">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold mb-2">Ad Campaign Dashboard</h1>
            <p className="text-gray-600">Monitor your advertising campaigns and performance</p>
          </div>
          <Button 
            className="bg-blue-600 hover:bg-blue-700"
            onClick={() => window.location.href = '/advertise'}
          >
            <Plus className="w-4 h-4 mr-2" />
            Create New Campaign
          </Button>
        </div>

        {/* Overview Stats */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Total Impressions</p>
                  <p className="text-2xl font-bold">{totalStats.impressions.toLocaleString()}</p>
                </div>
                <Eye className="w-8 h-8 text-blue-600" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Total Clicks</p>
                  <p className="text-2xl font-bold">{totalStats.clicks.toLocaleString()}</p>
                </div>
                <MousePointer className="w-8 h-8 text-green-600" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Avg. CTR</p>
                  <p className="text-2xl font-bold">{avgCTR}%</p>
                </div>
                <TrendingUp className="w-8 h-8 text-purple-600" />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Total Spent</p>
                  <p className="text-2xl font-bold">PKR{totalStats.spent.toLocaleString()}</p>
                </div>
                <DollarSign className="w-8 h-8 text-orange-600" />
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Campaigns */}
        <Card>
          <CardHeader>
            <CardTitle>Your Campaigns</CardTitle>
            <CardDescription>Manage and monitor your advertising campaigns</CardDescription>
          </CardHeader>
          <CardContent>
            <Tabs value={activeTab} onValueChange={setActiveTab}>
              <TabsList className="grid w-full grid-cols-4">
                <TabsTrigger value="overview">All Campaigns</TabsTrigger>
                <TabsTrigger value="active">Active</TabsTrigger>
                <TabsTrigger value="pending">Pending</TabsTrigger>
                <TabsTrigger value="completed">Completed</TabsTrigger>
              </TabsList>

              <TabsContent value={activeTab} className="mt-6">
                <div className="space-y-4">
                  {filteredAds.map((ad) => (
                    <div key={ad.id} className="border rounded-lg p-4 hover:bg-gray-50 transition-colors">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-4">
                          <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                            {getAdTypeIcon(ad.type)}
                          </div>
                          <div>
                            <h3 className="font-semibold">{ad.title}</h3>
                            <div className="flex items-center gap-2 text-sm text-gray-600">
                              <span>{ad.typeLabel}</span>
                              <span>•</span>
                              <span>{ad.placement}</span>
                              <span>•</span>
                              <span>{ad.dimensions}</span>
                            </div>
                          </div>
                        </div>

                        <div className="flex items-center gap-4">
                          <div className="text-right">
                            <div className="flex items-center gap-2">
                              <Badge className={getStatusColor(ad.status)}>
                                {getStatusIcon(ad.status)}
                                {ad.status}
                              </Badge>
                            </div>
                            <p className="text-sm text-gray-600 mt-1">
                              {new Date(ad.startDate).toLocaleDateString()} - {new Date(ad.endDate).toLocaleDateString()}
                            </p>
                          </div>

                          <div className="text-right">
                            <p className="font-semibold">PKR {ad.price.toLocaleString()}</p>
                            <p className="text-sm text-gray-600">
                              {ad.stats.impressions.toLocaleString()} impressions
                            </p>
                          </div>

                          <div className="flex items-center gap-2">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => setSelectedAd(ad)}
                            >
                              <BarChart3 className="w-4 h-4 mr-1" />
                              Details
                            </Button>
                          </div>
                        </div>
                      </div>

                      {/* Performance Stats */}
                      <div className="mt-4 grid grid-cols-4 gap-4 text-sm">
                        <div>
                          <span className="text-gray-600">Impressions:</span>
                          <span className="ml-2 font-medium">{ad.stats.impressions.toLocaleString()}</span>
                        </div>
                        <div>
                          <span className="text-gray-600">Clicks:</span>
                          <span className="ml-2 font-medium">{ad.stats.clicks.toLocaleString()}</span>
                        </div>
                        <div>
                          <span className="text-gray-600">CTR:</span>
                          <span className="ml-2 font-medium">{ad.stats.ctr}%</span>
                        </div>
                        <div>
                          <span className="text-gray-600">Spent:</span>
                          <span className="ml-2 font-medium">PKR {ad.stats.spent.toLocaleString()}</span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>

        {/* Campaign Details Modal */}
        {selectedAd && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-bold">Campaign Details</h2>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setSelectedAd(null)}
                >
                  <XCircle className="w-4 h-4" />
                </Button>
              </div>

              <div className="space-y-4">
                <div>
                  <h3 className="font-semibold">{selectedAd.title}</h3>
                  <p className="text-gray-600">{selectedAd.typeLabel}</p>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-600">Status</p>
                    <Badge className={getStatusColor(selectedAd.status)}>
                      {selectedAd.status}
                    </Badge>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Duration</p>
                    <p className="font-medium">{selectedAd.duration} days</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Placement</p>
                    <p className="font-medium">{selectedAd.placement}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Dimensions</p>
                    <p className="font-medium">{selectedAd.dimensions}</p>
                  </div>
                </div>

                <div>
                  <h4 className="font-semibold mb-2">Performance</h4>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="bg-gray-50 p-3 rounded">
                      <p className="text-sm text-gray-600">Impressions</p>
                      <p className="text-lg font-bold">{selectedAd.stats.impressions.toLocaleString()}</p>
                    </div>
                    <div className="bg-gray-50 p-3 rounded">
                      <p className="text-sm text-gray-600">Clicks</p>
                      <p className="text-lg font-bold">{selectedAd.stats.clicks.toLocaleString()}</p>
                    </div>
                    <div className="bg-gray-50 p-3 rounded">
                      <p className="text-sm text-gray-600">CTR</p>
                      <p className="text-lg font-bold">{selectedAd.stats.ctr}%</p>
                    </div>
                    <div className="bg-gray-50 p-3 rounded">
                      <p className="text-sm text-gray-600">Spent</p>
                      <p className="text-lg font-bold">PKR {selectedAd.stats.spent.toLocaleString()}</p>
                    </div>
                  </div>
                </div>

                <div className="flex justify-end gap-2">
                  <Button
                    variant="outline"
                    onClick={() => setSelectedAd(null)}
                  >
                    Close
                  </Button>
                  <Button>
                    <ExternalLink className="w-4 h-4 mr-2" />
                    View Full Report
                  </Button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}