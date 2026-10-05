# EZ Heart Zones

## Application Purpose

Apple Health already records heart rate from sensors, but there isn't an intuitive interface for tracking how long you've been in target cardiac zones. This app helps you track your time in each zone, accumulating for the week, comparing yoru progress against your weekly goal.

## Requirements

1. Zones should be automatically calculated by default based on a standard formula:
  - Maximum Heart Rate = 220 - age of person (in years)
  - Zone 1: 50-59% of HRmax (Very Light)
  - Zone 2: 60-69% (Light)
  - Zone 3: 70-79% (Moderate)
  - Zone 4: 80-89% (Hard)
  - Zone 5: 90-100% (Maximum)
2. The app should read data from Apple Health, we are not worrying about connecting to health devices or recording data ourselves, just reading from what is already written to built-in Apple health data
3. The app should be optimized for showing you weekly progress toward an overall cardio goal: 150 minutes
  - This goal defaults to 150, but can be customized
  - Each zone has a multiplier toward this goal
  - Zone 1: Multiplier 0x (does not track towards goal)
  - Zone 2-3: 1x multiplier
  - Zone 4-5: 2x multiplier
4. The UI should be simple on the landing page
  - A week selector lets you choose current or previous weeks to examine
  - An overall widget at the top of the screen shows your aggregated progress towards goal, breaking down how many minutes you currently have vs target in a bar, and a callout for "X minutes left"
  - Underneath the main widget, we should display the day by day progress for the week. One row per day, bars showing how many minutes were logged (color bars based on multiplier)
  - Clicking on a day should show a breakdown of progress for each zone (how many minutes logged in each zone for that day). as a simple bar chart
5. The app should have some minimal configuration
  - Weekly minute goal (defaults to 150, but can be set)
  - Weeks start on (set the day of the week the week starts on, defaults to Monday)
  - Zones can be overridden, using custom definitions instead of default min.max



