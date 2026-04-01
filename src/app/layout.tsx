import type { Metadata, Viewport } from "next";
import { AuthProvider } from "@/context/AuthContext";
import "./globals.css";

export const metadata: Metadata = {
  title: "init.habits — Terminal Habit Tracker",
  description: "A terminal-aesthetic habit tracker for disciplined minds",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "init.habits",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#0A0A0F",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="h-full">
      <body className="h-full bg-bg-primary text-text-primary font-mono">
        <AuthProvider>
          <div className="mx-auto max-w-[480px] h-full flex flex-col relative">
            {children}
          </div>
        </AuthProvider>
      </body>
    </html>
  );
}
