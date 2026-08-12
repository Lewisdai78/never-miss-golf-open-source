import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Never Miss Golf",
    template: "%s · Never Miss Golf",
  },
  description: "A private, user-confirmed golf reminder for iPhone and Apple Watch.",
  applicationName: "Never Miss Golf",
  referrer: "strict-origin-when-cross-origin",
  robots: { index: true, follow: true },
  icons: { icon: "/favicon.svg", shortcut: "/favicon.svg" },
  openGraph: {
    title: "Never Miss Golf",
    description: "Arrive at the course. Remember the workout.",
    type: "website",
  },
  twitter: {
    card: "summary",
    title: "Never Miss Golf",
    description: "A private wrist reminder for your round.",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#071d17",
  colorScheme: "dark light",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
