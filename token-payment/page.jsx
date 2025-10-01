import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import Link from "next/link"
import ViewPaymentPlan from "../../components/payment/view-payment-plan"

export const metadata = {
  title: "Token Payment | Plot Selling Dashboard",
  description: "Complete your token payment to secure your residential plot",
}

export default function TokenPaymentPage() {
  return (
    <div className="flex flex-col min-h-screen">
      <DashboardHeader />

      <main className="flex-1 container py-10 flex items-center justify-center">
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle>Complete Token Payment</CardTitle>
            <CardDescription>Pay the token amount to secure your residential plot</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="p-4 bg-blue-50 rounded-md">
                <h3 className="font-semibold text-blue-700">Payment Details</h3>
                <p className="text-sm mt-2">
                  A token amount of <span className="font-bold">PKR 500,000</span> is required to secure your selected
                  residential plot. This amount will be adjusted in the final payment.
                </p>
              </div>

              <div className="space-y-2">
                <div className="flex justify-between">
                  <span>Token Amount:</span>
                  <span>PKR 500,000</span>
                </div>
                <div className="flex justify-between">
                  <span>Processing Fee:</span>
                  <span>PKR 5,000</span>
                </div>
                <div className="border-t pt-2 mt-2 flex justify-between font-bold">
                  <span>Total Amount:</span>
                  <span>PKR 505,000</span>
                </div>
              </div>

              <div className="bg-yellow-50 p-3 rounded-md text-sm text-yellow-800">
                <p>
                  <strong>Note:</strong> After payment, you will receive a confirmation email with further instructions
                  for completing the purchase.
                </p>
              </div>
              <ViewPaymentPlan />
            </div>
          </CardContent>
          <CardFooter className="flex flex-col gap-3">
            <Button className="w-full bg-blue-600 hover:bg-blue-700">Proceed to Payment Gateway</Button>
            <Link href="/" className="w-full">
              <Button variant="outline" className="w-full">
                Cancel and Return
              </Button>
            </Link>
          </CardFooter>
        </Card>
      </main>
    </div>
  )
}
