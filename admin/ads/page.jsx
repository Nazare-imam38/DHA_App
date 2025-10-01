'use client'

import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
    Search,
    Filter,
    Eye,
    Check,
    X,
    Clock,
    Calendar,
    DollarSign,
    User,
    ExternalLink,
    Download
} from 'lucide-react'
import { Alert, AlertDescription } from '@/components/ui/alert'

// Mock data for admin dashboard
const mockPendingAds = [
    {
        id: 1,
        title: 'Premium DHA Property Listing',
        type: 'Featured Listing',
        company: 'Elite Properties',
        email: 'contact@eliteproperties.com',
        phone: '+92 300 1234567',
        price: 1500,
        duration: 3,
        targetPage: 'homepage',
        description: 'Promote our premium DHA properties to potential buyers',
        submittedAt: '2024-01-16T10:30:00Z',
        imageUrl: '/api/placeholder/300/250',
        redirectUrl: 'https://eliteproperties.com/dha-listings',
        status: 'pending'
    },
    {
        id: 2,
        title: 'New Year Property Sale Event',
        type: 'Homepage Banner',
        company: 'DHA Realty',
        email: 'marketing@dharealty.com',
        phone: '+92 321 9876543',
        price: 3000,
        duration: 7,
        targetPage: 'all',
        description: 'Special new year discount on all DHA properties',
        submittedAt: '2024-01-16T14:15:00Z',
        imageUrl: '/api/placeholder/728/90',
        redirectUrl: 'https://dharealty.com/new-year-sale',
        status: 'pending'
    }
]

const mockApprovedAds = [
    {
        id: 3,
        title: 'Luxury Apartments Showcase',
        type: 'Sponsored Event',
        company: 'Luxury Living',
        email: 'info@luxuryliving.com',
        phone: '+92 333 5555555',
        price: 5000,
        duration: 7,
        targetPage: 'properties',
        description: 'Showcase our luxury apartment collection',
        submittedAt: '2024-01-15T09:00:00Z',
        approvedAt: '2024-01-15T16:30:00Z',
        imageUrl: '/api/placeholder/320/480',
        redirectUrl: 'https://luxuryliving.com/apartments',
        status: 'approved',
        stats: {
            impressions: 15420,
            clicks: 234,
            ctr: 1.52
        }
    }
]

const getStatusColor = (status) => {
    switch (status) {
        case 'pending': return 'bg-yellow-100 text-yellow-800'
        case 'approved': return 'bg-green-100 text-green-800'
        case 'rejected': return 'bg-red-100 text-red-800'
        case 'active': return 'bg-blue-100 text-blue-800'
        default: return 'bg-gray-100 text-gray-800'
    }
}

export default function AdminAdsPage() {
    const [pendingAds, setPendingAds] = useState(mockPendingAds)
    const [approvedAds, setApprovedAds] = useState(mockApprovedAds)
    const [selectedAd, setSelectedAd] = useState(null)
    const [searchTerm, setSearchTerm] = useState('')
    const [showApprovalModal, setShowApprovalModal] = useState(false)

    const handleApproveAd = (adId) => {
        const ad = pendingAds.find(a => a.id === adId)
        if (ad) {
            const approvedAd = {
                ...ad,
                status: 'approved',
                approvedAt: new Date().toISOString()
            }

            setPendingAds(prev => prev.filter(a => a.id !== adId))
            setApprovedAds(prev => [...prev, approvedAd])
            setSelectedAd(null)

            // Here you would typically make an API call to update the backend
            console.log('Ad approved:', approvedAd)
        }
    }

    const handleRejectAd = (adId, reason = 'Does not meet guidelines') => {
        const ad = pendingAds.find(a => a.id === adId)
        if (ad) {
            setPendingAds(prev => prev.filter(a => a.id !== adId))
            setSelectedAd(null)

            // Here you would typically make an API call to update the backend
            console.log('Ad rejected:', { adId, reason })
        }
    }

    const filteredPendingAds = pendingAds.filter(ad =>
        ad.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        ad.company.toLowerCase().includes(searchTerm.toLowerCase())
    )

    const filteredApprovedAds = approvedAds.filter(ad =>
        ad.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        ad.company.toLowerCase().includes(searchTerm.toLowerCase())
    )

    return (
        <div className="min-h-screen bg-gray-50 py-8">
            <div className="container mx-auto px-4 max-w-7xl">
                {/* Header */}
                <div className="flex justify-between items-center mb-8">
                    <div>
                        <h1 className="text-3xl font-bold mb-2">Ad Management</h1>
                        <p className="text-gray-600">Review and manage advertising campaigns</p>
                    </div>
                    <div className="flex gap-4">
                        <div className="relative">
                            <Search className="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                            <Input
                                placeholder="Search ads..."
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                                className="pl-10 w-64"
                            />
                        </div>
                        <Button variant="outline">
                            <Filter className="w-4 h-4 mr-2" />
                            Filter
                        </Button>
                    </div>
                </div>

                {/* Stats Overview */}
                <div className="grid md:grid-cols-4 gap-6 mb-8">
                    <Card>
                        <CardContent className="p-6">
                            <div className="flex items-center justify-between">
                                <div>
                                    <p className="text-sm text-gray-600 mb-1">Pending Review</p>
                                    <p className="text-2xl font-bold text-yellow-600">{pendingAds.length}</p>
                                </div>
                                <Clock className="w-8 h-8 text-yellow-600" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6">
                            <div className="flex items-center justify-between">
                                <div>
                                    <p className="text-sm text-gray-600 mb-1">Active Campaigns</p>
                                    <p className="text-2xl font-bold text-green-600">{approvedAds.length}</p>
                                </div>
                                <Check className="w-8 h-8 text-green-600" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6">
                            <div className="flex items-center justify-between">
                                <div>
                                    <p className="text-sm text-gray-600 mb-1">Total Revenue</p>
                                    <p className="text-2xl font-bold text-blue-600">
                                        Rs. {[...pendingAds, ...approvedAds].reduce((sum, ad) => sum + ad.price, 0).toLocaleString()}
                                    </p>
                                </div>
                                <DollarSign className="w-8 h-8 text-blue-600" />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardContent className="p-6">
                            <div className="flex items-center justify-between">
                                <div>
                                    <p className="text-sm text-gray-600 mb-1">This Month</p>
                                    <p className="text-2xl font-bold text-purple-600">
                                        Rs. {[...pendingAds, ...approvedAds].reduce((sum, ad) => sum + ad.price, 0).toLocaleString()}
                                    </p>
                                </div>
                                <Calendar className="w-8 h-8 text-purple-600" />
                            </div>
                        </CardContent>
                    </Card>
                </div>

                <div className="grid lg:grid-cols-3 gap-8">
                    {/* Ads List */}
                    <div className="lg:col-span-2">
                        <Tabs defaultValue="pending" className="space-y-6">
                            <TabsList className="grid w-full grid-cols-2">
                                <TabsTrigger value="pending" className="flex items-center gap-2">
                                    <Clock className="w-4 h-4" />
                                    Pending ({pendingAds.length})
                                </TabsTrigger>
                                <TabsTrigger value="approved" className="flex items-center gap-2">
                                    <Check className="w-4 h-4" />
                                    Approved ({approvedAds.length})
                                </TabsTrigger>
                            </TabsList>

                            <TabsContent value="pending">
                                <Card>
                                    <CardHeader>
                                        <CardTitle>Pending Approval</CardTitle>
                                        <CardDescription>Ads waiting for your review</CardDescription>
                                    </CardHeader>
                                    <CardContent className="p-0">
                                        {filteredPendingAds.length === 0 ? (
                                            <div className="p-8 text-center text-gray-500">
                                                <Clock className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                                                <p>No pending ads to review</p>
                                            </div>
                                        ) : (
                                            <div className="space-y-0">
                                                {filteredPendingAds.map((ad) => (
                                                    <div
                                                        key={ad.id}
                                                        className={`p-4 border-b cursor-pointer hover:bg-gray-50 transition-colors ${selectedAd?.id === ad.id ? 'bg-blue-50 border-l-4 border-l-blue-600' : ''
                                                            }`}
                                                        onClick={() => setSelectedAd(ad)}
                                                    >
                                                        <div className="flex items-start justify-between mb-2">
                                                            <div className="flex-1">
                                                                <h3 className="font-medium mb-1">{ad.title}</h3>
                                                                <p className="text-sm text-gray-600 mb-2">{ad.company} • {ad.type}</p>
                                                                <div className="flex items-center gap-4 text-xs text-gray-500">
                                                                    <span>Rs. {ad.price.toLocaleString()}</span>
                                                                    <span>{ad.duration} days</span>
                                                                    <span>{new Date(ad.submittedAt).toLocaleDateString()}</span>
                                                                </div>
                                                            </div>
                                                            <div className="flex items-center gap-3">
                                                                <Badge className={getStatusColor(ad.status)}>
                                                                    <Clock className="w-3 h-3 mr-1" />
                                                                    Pending
                                                                </Badge>
                                                                <div className="flex gap-2">
                                                                    <Button
                                                                        size="sm"
                                                                        className="bg-green-600 hover:bg-green-700 text-white"
                                                                        onClick={(e) => {
                                                                            e.stopPropagation()
                                                                            handleApproveAd(ad.id)
                                                                        }}
                                                                    >
                                                                        <Check className="w-4 h-4 mr-1" />
                                                                        Approve
                                                                    </Button>
                                                                    <Button
                                                                        size="sm"
                                                                        variant="outline"
                                                                        className="border-red-300 text-red-600 hover:bg-red-50"
                                                                        onClick={(e) => {
                                                                            e.stopPropagation()
                                                                            handleRejectAd(ad.id)
                                                                        }}
                                                                    >
                                                                        <X className="w-4 h-4 mr-1" />
                                                                        Reject
                                                                    </Button>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>
                                        )}
                                    </CardContent>
                                </Card>
                            </TabsContent>

                            <TabsContent value="approved">
                                <Card>
                                    <CardHeader>
                                        <CardTitle>Approved Campaigns</CardTitle>
                                        <CardDescription>Active and completed ad campaigns</CardDescription>
                                    </CardHeader>
                                    <CardContent className="p-0">
                                        {filteredApprovedAds.length === 0 ? (
                                            <div className="p-8 text-center text-gray-500">
                                                <Check className="w-12 h-12 mx-auto mb-4 text-gray-300" />
                                                <p>No approved ads yet</p>
                                            </div>
                                        ) : (
                                            <div className="space-y-0">
                                                {filteredApprovedAds.map((ad) => (
                                                    <div
                                                        key={ad.id}
                                                        className={`p-4 border-b cursor-pointer hover:bg-gray-50 transition-colors ${selectedAd?.id === ad.id ? 'bg-blue-50 border-l-4 border-l-blue-600' : ''
                                                            }`}
                                                        onClick={() => setSelectedAd(ad)}
                                                    >
                                                        <div className="flex items-start justify-between mb-2">
                                                            <div className="flex-1">
                                                                <h3 className="font-medium mb-1">{ad.title}</h3>
                                                                <p className="text-sm text-gray-600 mb-2">{ad.company} • {ad.type}</p>
                                                                <div className="flex items-center gap-4 text-xs text-gray-500">
                                                                    <span>Rs. {ad.price.toLocaleString()}</span>
                                                                    <span>{ad.duration} days</span>
                                                                    {ad.stats && (
                                                                        <>
                                                                            <span>{ad.stats.impressions.toLocaleString()} views</span>
                                                                            <span>{ad.stats.clicks} clicks</span>
                                                                        </>
                                                                    )}
                                                                </div>
                                                            </div>
                                                            <Badge className={getStatusColor(ad.status)}>
                                                                <Check className="w-3 h-3 mr-1" />
                                                                Approved
                                                            </Badge>
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>
                                        )}
                                    </CardContent>
                                </Card>
                            </TabsContent>
                        </Tabs>
                    </div>

                    {/* Ad Details Panel */}
                    <div className="lg:col-span-1">
                        {selectedAd ? (
                            <Card className="sticky top-8">
                                <CardHeader>
                                    <div className="flex items-start justify-between">
                                        <div>
                                            <CardTitle className="text-lg">{selectedAd.title}</CardTitle>
                                            <CardDescription>{selectedAd.company}</CardDescription>
                                        </div>
                                        <Badge className={getStatusColor(selectedAd.status)}>
                                            {selectedAd.status === 'pending' && <Clock className="w-3 h-3 mr-1" />}
                                            {selectedAd.status === 'approved' && <Check className="w-3 h-3 mr-1" />}
                                            <span className="capitalize">{selectedAd.status}</span>
                                        </Badge>
                                    </div>
                                </CardHeader>
                                <CardContent className="space-y-4">
                                    {/* Ad Preview */}
                                    <div>
                                        <p className="text-sm font-medium mb-2">Ad Preview</p>
                                        <div className="border rounded-lg p-2 bg-gray-50">
                                            <img
                                                src={selectedAd.imageUrl}
                                                alt="Ad preview"
                                                className="w-full h-32 object-cover rounded"
                                            />
                                        </div>
                                    </div>

                                    {/* Basic Info */}
                                    <div className="space-y-3">
                                        <div>
                                            <p className="text-sm text-gray-600">Ad Type</p>
                                            <p className="font-medium">{selectedAd.type}</p>
                                        </div>
                                        <div>
                                            <p className="text-sm text-gray-600">Target Page</p>
                                            <p className="font-medium capitalize">{selectedAd.targetPage}</p>
                                        </div>
                                        <div>
                                            <p className="text-sm text-gray-600">Duration & Price</p>
                                            <p className="font-medium">{selectedAd.duration} days • Rs. {selectedAd.price.toLocaleString()}</p>
                                        </div>
                                    </div>

                                    {/* Contact Info */}
                                    <div className="space-y-3">
                                        <div>
                                            <p className="text-sm text-gray-600">Contact Email</p>
                                            <p className="font-medium text-sm">{selectedAd.email}</p>
                                        </div>
                                        <div>
                                            <p className="text-sm text-gray-600">Phone</p>
                                            <p className="font-medium">{selectedAd.phone}</p>
                                        </div>
                                    </div>

                                    {/* Description */}
                                    <div>
                                        <p className="text-sm text-gray-600 mb-2">Description</p>
                                        <p className="text-sm bg-gray-50 p-3 rounded">{selectedAd.description}</p>
                                    </div>

                                    {/* Redirect URL */}
                                    <div>
                                        <p className="text-sm text-gray-600 mb-2">Redirect URL</p>
                                        <div className="flex items-center gap-2">
                                            <p className="text-sm font-mono bg-gray-50 p-2 rounded flex-1 truncate">
                                                {selectedAd.redirectUrl}
                                            </p>
                                            <Button variant="outline" size="sm">
                                                <ExternalLink className="w-4 h-4" />
                                            </Button>
                                        </div>
                                    </div>

                                    {/* Performance Stats (if approved) */}
                                    {selectedAd.stats && (
                                        <div>
                                            <p className="text-sm text-gray-600 mb-2">Performance</p>
                                            <div className="grid grid-cols-2 gap-2 text-sm">
                                                <div className="bg-blue-50 p-2 rounded text-center">
                                                    <p className="font-bold text-blue-600">{selectedAd.stats.impressions.toLocaleString()}</p>
                                                    <p className="text-xs text-gray-600">Impressions</p>
                                                </div>
                                                <div className="bg-green-50 p-2 rounded text-center">
                                                    <p className="font-bold text-green-600">{selectedAd.stats.clicks}</p>
                                                    <p className="text-xs text-gray-600">Clicks</p>
                                                </div>
                                            </div>
                                        </div>
                                    )}

                                    {/* Action Buttons */}
                                    {selectedAd.status === 'pending' && (
                                        <div className="flex gap-2 pt-4">
                                            <Button
                                                className="flex-1 bg-green-600 hover:bg-green-700"
                                                onClick={() => handleApproveAd(selectedAd.id)}
                                            >
                                                <Check className="w-4 h-4 mr-2" />
                                                Approve
                                            </Button>
                                            <Button
                                                variant="outline"
                                                className="flex-1 border-red-300 text-red-600 hover:bg-red-50"
                                                onClick={() => handleRejectAd(selectedAd.id)}
                                            >
                                                <X className="w-4 h-4 mr-2" />
                                                Reject
                                            </Button>
                                        </div>
                                    )}

                                    <div className="pt-4 border-t">
                                        <p className="text-xs text-gray-500">
                                            Submitted: {new Date(selectedAd.submittedAt).toLocaleString()}
                                        </p>
                                        {selectedAd.approvedAt && (
                                            <p className="text-xs text-gray-500">
                                                Approved: {new Date(selectedAd.approvedAt).toLocaleString()}
                                            </p>
                                        )}
                                    </div>
                                </CardContent>
                            </Card>
                        ) : (
                            <Card className="sticky top-8">
                                <CardContent className="p-8 text-center">
                                    <Eye className="w-12 h-12 text-gray-300 mx-auto mb-4" />
                                    <p className="text-gray-500">Select an ad to view details</p>
                                </CardContent>
                            </Card>
                        )}
                    </div>
                </div>
            </div>
        </div>
    )
}