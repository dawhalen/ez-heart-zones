# App Store listing — Heart Zones 1.0

Copy these into App Store Connect. Character limits are Apple's.

## App name (30)
Heart Zones: Weekly Cardio

If that's taken, try: `EZ Heart Zones` or `Heart Zones – Cardio Points`.

## Subtitle (30)
Points for every zone minute

## Category
Primary: Health & Fitness

## Promotional text (170)
See your week of cardio at a glance. Every minute in a heart rate zone earns points toward your weekly goal, with harder effort counting double.

## Description (4000)
Heart Zones turns the heart rate data your Apple Watch already records into one simple weekly cardio score.

Health guidelines recommend about 150 minutes of moderate activity a week, or less if it's vigorous. Heart Zones keeps that math for you:

• Zones 2–3 (light to moderate) earn 1 point per minute
• Zones 4–5 (hard to maximum) earn 2 points per minute
• Zone 1 (very light) doesn't count

WEEK AT A GLANCE
Your progress toward the weekly goal sits at the top, with a day-by-day breakdown underneath showing moderate and high-intensity points.

DAY AND WEEK DETAIL
Tap any day to see time in each zone, a zone ring, and an hour-by-hour chart of when you earned points.

YOUR ZONES, YOUR GOAL
Zones are calculated from your age in Apple Health, or you can set your own ranges. Set your own weekly goal and the day your week starts.

ALWAYS UP TO DATE
Heart Zones refreshes as new heart rate data arrives in Apple Health.

PRIVATE BY DESIGN
Your health data never leaves your iPhone. No accounts, no servers, no analytics, no ads.

Heart Zones needs heart rate data in Apple Health, typically from an Apple Watch. It is a general fitness tool, not a medical device, and doesn't provide medical advice.

## Keywords (100, comma-separated, no spaces needed)
heart rate,zones,cardio,workout,apple watch,fitness,training,zone 2,weekly goal,points,exercise

## URLs
- Support URL: https://dawhalen.github.io/ez-heart-zones/
- Privacy Policy URL: https://dawhalen.github.io/ez-heart-zones/privacy.html
- Marketing URL: (optional, leave blank)

## Screenshots
`appstore/screenshots/6.3in/` (1206×2622) for the 6.1"/6.3" slot; `appstore/screenshots/6.9in/` (1320×2868) for the 6.9" slot; `appstore/screenshots/6.5in/` (1284×2778) for the 6.5" slot if App Store Connect asks for it. No alpha channel — App Store Connect rejects screenshots with transparency.
Regenerate in the simulator by launching a Debug build with `-demoData YES` (see `Support/DemoData.swift`).

## Age rating
Answer "None" to every content question → 4+. Health/medical topics: "No" (the app gives no medical information or advice — it displays the user's own data).

## App Privacy ("nutrition label")
Data Not Collected. (Nothing leaves the device; HealthKit data read on-device doesn't count as "collected".)

## App Review notes
Heart Zones reads heart rate samples and date of birth from Apple Health (read-only; it never writes) and shows time spent in heart rate zones as weekly "points". All processing happens on-device; there is no account, login or server.

To see data, the device needs heart rate samples in Apple Health, e.g. from an Apple Watch workout. Points are only counted when samples are dense (≤ 60 seconds apart, as during a workout), so a device with only occasional background readings will show 0 points — that is expected, not a bug.

On first launch the app asks for Health access. If it's denied, the screens show empty weeks; access can be granted again in the Health app under Sharing → Apps → Heart Zones, or from the Heart Zones Settings screen.
