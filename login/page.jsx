'use client';
import { useState } from "react"
import LoginForm from "@/components/auth/login-form"
import DashboardHeader from "@/components/dashboard/dashboard-header"
import Image from "next/image"
import Link from "next/link"

const LOGIN_ENABLED = true; // Toggle this to true to re-enable login

export default function LoginPage() {
  return (
    <>
      <div className="w-full bg-gradient-to-r from-teal-600 to-teal-500 py-2.5 text-white text-center text-xs sm:text-sm font-semibold tracking-wide shadow-sm">
        <div className="container mx-auto px-4 flex items-center justify-center gap-2">
          <div className="w-2 h-2 bg-white/80 rounded-full animate-pulse"></div>
          <span>Official Plot Selling Portal of DHA Islamabad-Rawalpindi</span>
          <div className="w-2 h-2 bg-white/80 rounded-full animate-pulse"></div>
        </div>
      </div>
      <div className="lg:hidden min-h-[calc(100vh-64px)] bg-white">
        <main className="flex flex-col items-center justify-center px-4 py-8">
          <div className="w-full max-w-md mb-6">
            <Image
              src="/images/800 x 400.png"
              alt="DHA Login Banner"
              width={800}
              height={400}
              className="w-full h-auto object-cover rounded-lg shadow-md"
              priority
            />
          </div>
          <div className="w-full max-w-md">
            <div className="bg-white rounded-xl shadow-lg border border-gray-100 p-6">
              <div className="text-center mb-6">
                <div className="flex items-center justify-center space-x-3 mb-4">
                  <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center">
                    <Image
                      src="/images/logo.png"
                      alt="DHA Logo"
                      width={24}
                      height={24}
                      className="w-6 h-6 object-contain"
                    />
                  </div>
                  <h1 className="text-xl font-bold text-gray-900">DHA Market Place</h1>
                </div>
                <h2 className="text-lg text-gray-600">
                  Sign into your account
                </h2>
              </div>
              {!LOGIN_ENABLED && (
                <div className="mb-4 p-3 bg-yellow-100 text-yellow-800 rounded text-center font-semibold">
                  Login is currently disabled.
                </div>
              )}
              <div className="space-y-4">
                <LoginForm disabled={!LOGIN_ENABLED} />
              </div>
              <div className="text-center space-y-3 pt-4">
                <div className="text-sm text-gray-500">
                  <Link href="/forgot-password" className="hover:text-gray-700 transition-colors">
                    Forgot password?
                  </Link>
                </div>
                <div className="text-sm text-blue-600">
                  Don't have an account?{" "}
                  <Link
                    href="/register"
                    className="font-medium hover:text-blue-800 transition-colors"
                  >
                    Register here
                  </Link>
                </div>
                <div className="flex items-center justify-center space-x-4 text-xs text-gray-400 pt-2">
                  <Link href="/contact" className="hover:text-gray-600 transition-colors">
                    Contact Support
                  </Link>
                  <span>•</span>
                  <Link href="/faqs" className="hover:text-gray-600 transition-colors">
                    Help & FAQs
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
      <div className="hidden lg:block min-h-[calc(100vh-64px)] bg-white">
        <div className="flex items-center justify-center p-1 lg:p-2 xl:p-3 min-h-[calc(100vh-64px)]">
          <div className="w-full max-w-7xl h-[calc(100vh-70px)] lg:h-[calc(100vh-76px)] xl:h-[calc(100vh-86px)] bg-white rounded-xl lg:rounded-2xl xl:rounded-3xl shadow-xl lg:shadow-2xl overflow-hidden border border-gray-200">
            <div className="flex h-full">
              <div className="w-1/2 xl:w-3/5 2xl:w-2/3 relative overflow-hidden">
                <Image
                  src="/images/2560 x 1080.png"
                  alt="DHA Login"
                  fill
                  className="object-cover object-center hidden 2xl:block"
                  priority
                  sizes="60vw"
                />
                <Image
                  src="/images/1200 x 800.png"
                  alt="DHA Login"
                  fill
                  className="object-cover object-center hidden xl:block 2xl:hidden"
                  priority
                  sizes="60vw"
                />
                <Image
                  src="/images/1200 x 800.png"
                  alt="DHA Login"
                  fill
                  className="object-cover object-center block xl:hidden"
                  priority
                  sizes="50vw"
                />
              </div>
              <div className="w-1/2 xl:w-2/5 2xl:w-1/3 flex flex-col bg-white border-l-2 border-l-[#F2F2F2]">
                <div className="flex-1 overflow-y-auto px-3 lg:px-4 xl:px-6 py-2 lg:py-3 xl:py-4">
                  <div className="flex flex-col justify-center min-h-full">
                    <div className="w-full max-w-sm mx-auto space-y-2 lg:space-y-3 xl:space-y-4">
                      <div className="text-center space-y-1 lg:space-y-1.5 xl:space-y-2">
                        <div className="flex items-center justify-center space-x-1.5 lg:space-x-2 xl:space-x-3">
                          <div className="w-6 h-6 lg:w-7 lg:h-7 xl:w-8 xl:h-8 bg-primary/10 rounded-md lg:rounded-lg flex items-center justify-center">
                            <Image
                              src="/images/logo.png"
                              alt="DHA Logo"
                              width={16}
                              height={16}
                              className="w-4 h-4 lg:w-4.5 lg:h-4.5 xl:w-5 xl:h-5 object-contain"
                            />
                          </div>
                          <h1 className="text-sm lg:text-base xl:text-lg font-bold text-gray-900">DHA Market Place</h1>
                        </div>
                        <h2 className="text-xs lg:text-sm xl:text-base text-gray-600">
                          Sign into your account
                        </h2>
                      </div>
                      {!LOGIN_ENABLED && (
                        <div className="mb-4 p-3 bg-yellow-100 text-yellow-800 rounded text-center font-semibold">
                          Login is currently disabled.
                        </div>
                      )}
                      <div className="space-y-2 lg:space-y-3 xl:space-y-4">
                        <LoginForm disabled={!LOGIN_ENABLED} />
                      </div>
                      <div className="text-center space-y-0.5 lg:space-y-1 xl:space-y-1.5 pt-1 lg:pt-2 xl:pt-3">
                        <div className="text-xs text-gray-500">
                          <Link href="/forgot-password" className="hover:text-gray-700 transition-colors">
                            Forgot password?
                          </Link>
                        </div>
                        <div className="text-xs text-blue-600">
                          Don't have an account?{" "}
                          <Link
                            href="/register"
                            className="font-medium hover:text-blue-800 transition-colors"
                          >
                            Register here
                          </Link>
                        </div>
                        <div className="flex items-center justify-center space-x-2 text-xs text-gray-400 pt-0.5 lg:pt-1 xl:pt-1.5">
                          <Link href="/contact" className="hover:text-gray-600 transition-colors">
                            Support
                          </Link>
                          <span>•</span>
                          <Link href="/faqs" className="hover:text-gray-600 transition-colors">
                            FAQs
                          </Link>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}