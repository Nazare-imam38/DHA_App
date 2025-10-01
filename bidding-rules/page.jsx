import DashboardHeader from "@/components/dashboard/dashboard-header"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { AlertTriangle, CheckCircle, Clock, Info } from "lucide-react"

export const metadata = {
  title: "Bidding Rules | Plot Selling Dashboard",
  description: "Rules and guidelines for the plot bidding process",
}

export default function BiddingRulesPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <DashboardHeader />

      <main className="flex-1 container max-w-4xl py-10">
        <div className="space-y-6">
          <div className="flex items-center gap-4">
            <img src="/images/logo.png" alt="DHA Logo" className="h-16" />
            <div>
              <h1 className="text-3xl font-bold tracking-tight">Bidding Rules & Guidelines</h1>
              <p className="text-muted-foreground mt-2">
                Understanding the bidding process and rules for plot acquisition.
              </p>
            </div>
          </div>

          <Card>
            <CardHeader className="bg-blue-600/5">
              <CardTitle className="flex items-center">
                <Info className="mr-2 h-5 w-5 text-blue-600" />
                BIDDING & AUCTION RULES
              </CardTitle>
              <CardDescription>Key information about the bidding process</CardDescription>
            </CardHeader>
            <CardContent className="pt-6">
              <ul className="space-y-6">
                <li className="flex items-start">
                  <CheckCircle className="mr-2 h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="font-medium">1. Registration & Eligibility</p>
                    <ul className="text-sm text-muted-foreground mt-1 list-disc pl-5 space-y-1">
                      <li>
                        All participants must register on the platform and provide valid identification (CNIC, NICOP,
                        etc.).
                      </li>
                      <li>Only individuals above 18 years can place bids.</li>
                    </ul>
                  </div>
                </li>

                <li className="flex items-start">
                  <CheckCircle className="mr-2 h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="font-medium">2. Bidding Process</p>
                    <ul className="text-sm text-muted-foreground mt-1 list-disc pl-5 space-y-1">
                      <li>Auctions have a start and end time, and bids can only be placed within this period.</li>
                      <li>One registration fee is applicable for single bid only.</li>
                      <li>
                        Once a bid is placed, it cannot be withdrawn or canceled. 
                      </li>
                      <li>If two bidders place the same amount, the first bid recorded will be considered valid.</li>
                    </ul>
                  </div>
                </li>

                <li className="flex items-start">
                  <CheckCircle className="mr-2 h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="font-medium">3. Winning the Auction</p>
                    <ul className="text-sm text-muted-foreground mt-1 list-disc pl-5 space-y-1">
                      <li>The highest bidder at the auction's close wins the plot.</li>
                      <li>Winners will be notified via email and platform notifications.</li>
                      <li>
                        A confirmation payment (if applicable) must be paid within a specified time after winning.
                      </li>
                    </ul>
                  </div>
                </li>

                <li className="flex items-start">
                  <CheckCircle className="mr-2 h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="font-medium">4. Payment Terms</p>
                    <ul className="text-sm text-muted-foreground mt-1 list-disc pl-5 space-y-1">
                      <li>Full payment must be made within 30 Days after auction closing.</li>
                      <li>
                        Payments can be made via bank transfer, online payment gateways, or installment plans (if
                        offered).
                      </li>
                      <li>
                        Failure to pay within the deadline may result in bid cancellation and forfeiture of deposit.
                      </li>
                    </ul>
                  </div>
                </li>

                <li className="flex items-start">
                  <CheckCircle className="mr-2 h-5 w-5 text-green-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="font-medium">5. Legal & Documentation</p>
                    <ul className="text-sm text-muted-foreground mt-1 list-disc pl-5 space-y-1">
                      <li>The platform ensures that all plots are legally verified before listing.</li>
                      <li>After full payment, the ownership transfer process will begin.</li>
                      <li>Any taxes, registration fees, or legal charges are the winner's responsibility.</li>
                    </ul>
                  </div>
                </li>

                <li className="flex items-start">
                  <AlertTriangle className="mr-2 h-5 w-5 text-amber-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="font-medium">6. Auction Integrity & Fair Play</p>
                    <ul className="text-sm text-muted-foreground mt-1 list-disc pl-5 space-y-1">
                      <li>
                        Any attempt to manipulate bids, use fake accounts, or collude is strictly prohibited and will be
                        legally dealt with.
                      </li>
                      <li>
                        The auctioneer/platform has the right to reject bids or disqualify bidders violating rules.
                      </li>
                      <li>The platform reserves the right to cancel or reschedule auctions without prior notice.</li>
                    </ul>
                  </div>
                </li>

                <li className="flex items-start">
                  <Clock className="mr-2 h-5 w-5 text-blue-600 mt-0.5 flex-shrink-0" />
                  <div>
                    <p className="font-medium">7. Refund & Cancellation Policy</p>
                    <ul className="text-sm text-muted-foreground mt-1 list-disc pl-5 space-y-1">
                      <li>If an auction is canceled by the platform, all deposits will be refunded.</li>
                      <li>
                        If a winner fails to make payment, they may be banned from future auctions and their deposited
                        amount will be refunded after 20% Deduction.
                      </li>
                      <li>
                        If a bidder does not win, their security deposit (if any) will be refunded within a set period.
                      </li>
                    </ul>
                  </div>
                </li>
              </ul>
            </CardContent>
          </Card>
        </div>
      </main>
    </div>
  )
}
