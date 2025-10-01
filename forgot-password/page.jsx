import ForgotPasswordForm from "@/components/auth/forgot-password-form"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import Image from "next/image"

export const metadata = {
  title: "Forgot Password | Digital Expo",
  description: "Reset your password to access the plot selling dashboard",
}

export default function ForgotPasswordPage() {
  return (
    <>
      <DashboardHeader />
      <main className="auth-page-container">
        {/* Mobile banner - only visible on mobile */}
        <div className="auth-mobile-banner lg:hidden">
          <Image
            src="/images/auction-banner-mobile1.png"
            alt="DHA Islamabad Digital Auction 2025"
            width={800}
            height={400}
            className="w-full h-auto object-contain"
            priority
          />
          {/* Spacer div to create separation between banner and form */}
          <div className="banner-form-spacer h-4 lg:hidden"></div>
        </div>

        <div className="container relative flex min-h-[calc(100vh-64px)] flex-col items-center justify-center md:grid lg:max-w-none lg:grid-cols-2 lg:px-0">
          <div className="relative hidden h-full flex-col bg-zinc-900 p-0 text-white lg:flex dark:border-r banner-container">
            {/* Desktop banner - only visible on desktop */}
            <div className="absolute inset-0 flex items-center justify-center">
              <Image
                src="/images/auction-banner-desktop1.jpg"
                alt="DHA Islamabad Digital Auction 2025"
                width={960}
                height={1080}
                className="w-full h-full object-contain"
                priority
              />
            </div>
          </div>
          <div className="lg:p-8 login-form-container flex flex-col">
            <div className="mx-auto flex w-full flex-col justify-center space-y-6 sm:w-[350px]">
              <ForgotPasswordForm />
            </div>
            {/* Add extra space to match register form height */}
            <div className="login-spacer mt-auto py-8 lg:py-16"></div>
          </div>
        </div>
      </main>
    </>
  )
}
