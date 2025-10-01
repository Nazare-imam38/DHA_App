'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { VerticalBanner, HorizontalBanner, SplashAd, EventAd } from '@/components/ads/AdBanner'
import { Maximize2, Minimize2, Play, Calendar, Eye, X } from 'lucide-react'

export default function AdTestPage() {
  const [showSplash, setShowSplash] = useState(false)

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-800 mb-4">Ad Testing Dashboard</h1>
          <p className="text-xl text-gray-600">Test all ad types and their placements</p>
        </div>

        {/* Splash Ad Trigger */}
        <div className="text-center mb-8">
          <Button 
            onClick={() => setShowSplash(true)}
            className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3"
          >
            Show Splash Ad
          </Button>
        </div>

        {/* Splash Ad */}
        {showSplash && (
          <SplashAd onClose={() => setShowSplash(false)} />
        )}

        {/* Ad Types Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12">
          {/* Vertical Banner Test */}
          <Card className="border-2 border-blue-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Maximize2 className="w-5 h-5 text-blue-600" />
                Vertical Banner (300x600px)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex justify-center">
                <VerticalBanner />
              </div>
              <div className="mt-4 text-sm text-gray-600">
                <p><strong>Placement:</strong> Integrated within FAQ content sections (Desktop)</p>
                <p><strong>Mobile:</strong> Horizontal banner at top</p>
                <p><strong>Features:</strong> Close, Pause/Play, Click tracking</p>
              </div>
            </CardContent>
          </Card>

          {/* Horizontal Banner Test */}
          <Card className="border-2 border-green-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Minimize2 className="w-5 h-5 text-green-600" />
                Horizontal Banner (728x90px)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex justify-center">
                <HorizontalBanner />
              </div>
              <div className="mt-4 text-sm text-gray-600">
                <p><strong>Placement:</strong> Top/Bottom of pages, Gallery page, Contact page</p>
                <p><strong>Mobile:</strong> Full width responsive</p>
                <p><strong>Features:</strong> Close, Pause/Play, Click tracking</p>
              </div>
            </CardContent>
          </Card>

          {/* Event Ad Test */}
          <Card className="border-2 border-orange-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Calendar className="w-5 h-5 text-orange-600" />
                Event Ad (320x200px)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex justify-center">
                <EventAd />
              </div>
              <div className="mt-4 text-sm text-gray-600">
                <p><strong>Placement:</strong> Events section on landing page</p>
                <p><strong>Features:</strong> Close, Pause/Play, Click tracking</p>
              </div>
            </CardContent>
          </Card>

          {/* Splash Ad Info */}
          <Card className="border-2 border-purple-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Play className="w-5 h-5 text-purple-600" />
                Splash Ad (400x300px)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="bg-purple-50 rounded-lg p-6 text-center">
                <p className="text-lg font-semibold text-purple-800 mb-2">Interstitial Overlay</p>
                <p className="text-sm text-purple-600 mb-4">
                  Click the button above to trigger the splash ad
                </p>
                <div className="text-xs text-purple-500 space-y-1">
                  <p><strong>Features:</strong></p>
                  <p>• Auto-close after 5 seconds</p>
                  <p>• Skip button after 2 seconds</p>
                  <p>• Manual close option</p>
                  <p>• Click tracking</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Live Page Examples */}
        <div className="space-y-8">
          <h2 className="text-2xl font-bold text-gray-800 text-center mb-8">Live Page Examples</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card className="text-center hover:shadow-lg transition-shadow">
              <CardContent className="p-6">
                <Eye className="w-8 h-8 text-blue-600 mx-auto mb-3" />
                <h3 className="font-semibold mb-2">Landing Page</h3>
                <p className="text-sm text-gray-600 mb-3">Horizontal banners (top/bottom) + Splash ad + Event ad</p>
                <Button size="sm" onClick={() => window.location.href = '/'}>
                  View Page
                </Button>
              </CardContent>
            </Card>

            <Card className="text-center hover:shadow-lg transition-shadow">
              <CardContent className="p-6">
                <Eye className="w-8 h-8 text-blue-600 mx-auto mb-3" />
                <h3 className="font-semibold mb-2">FAQs Page</h3>
                <p className="text-sm text-gray-600 mb-3">Vertical banner integrated in content (Desktop) / Horizontal (Mobile)</p>
                <Button size="sm" onClick={() => window.location.href = '/faqs'}>
                  View Page
                </Button>
              </CardContent>
            </Card>

            <Card className="text-center hover:shadow-lg transition-shadow">
              <CardContent className="p-6">
                <Eye className="w-8 h-8 text-blue-600 mx-auto mb-3" />
                <h3 className="font-semibold mb-2">Gallery Page</h3>
                <p className="text-sm text-gray-600 mb-3">Horizontal banner at top</p>
                <Button size="sm" onClick={() => window.location.href = '/gallery'}>
                  View Page
                </Button>
              </CardContent>
            </Card>

            <Card className="text-center hover:shadow-lg transition-shadow">
              <CardContent className="p-6">
                <Eye className="w-8 h-8 text-blue-600 mx-auto mb-3" />
                <h3 className="font-semibold mb-2">Contact Page</h3>
                <p className="text-sm text-gray-600 mb-3">Event ad (Desktop) / Horizontal banner (Mobile)</p>
                <Button size="sm" onClick={() => window.location.href = '/contact'}>
                  View Page
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Ad Specifications */}
        <div className="mt-12">
          <Card>
            <CardHeader>
              <CardTitle>Ad Specifications</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold mb-3">Image Requirements</h4>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span>Vertical Banner:</span>
                      <Badge variant="outline">300x600px</Badge>
                    </div>
                    <div className="flex justify-between">
                      <span>Horizontal Banner:</span>
                      <Badge variant="outline">728x90px</Badge>
                    </div>
                    <div className="flex justify-between">
                      <span>Splash Ad:</span>
                      <Badge variant="outline">400x300px</Badge>
                    </div>
                    <div className="flex justify-between">
                      <span>Event Ad:</span>
                      <Badge variant="outline">320x200px</Badge>
                    </div>
                  </div>
                </div>
                <div>
                  <h4 className="font-semibold mb-3">Features</h4>
                  <div className="space-y-2 text-sm">
                    <div className="flex items-center gap-2">
                      <X className="w-4 h-4 text-green-600" />
                      <span>Close button</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Play className="w-4 h-4 text-blue-600" />
                      <span>Pause/Play controls</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Eye className="w-4 h-4 text-purple-600" />
                      <span>Click tracking</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge className="w-4 h-4 text-orange-600" />
                      <span>Ad badges</span>
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}
