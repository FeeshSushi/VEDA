# VEDA
My personalized app meant to help me with anything and everything related to my life.

## Features

### Task & Chore Management
There are plenty of things I need to do everyday, and there are always new things to do. This part of the app tracks daily recurring tasks and one-off to-dos, as well as household chores on their own schedules.

- Daily tasks refresh at 5:00am every day
- One-off tasks can be manually entered and completed at any time
- Chores recur on a fixed interval (every N days) or on specific days of the week
- Overdue chore notifications fire at 9:00am on the day a chore is due

### Sleep Tracker: SleepyTime!
A sleep tracker to help me get the right amount of sleep to feel refreshed every day. Tracks when I go to sleep, when I wake up, and how I feel — then uses that data to suggest better sleep and wake times.

- Log sleep and wake with a button press, or directly from the home screen or lock screen widget (no need to open the app)
- Rate each night on a 5-level emoji scale: 😫 😴 😐 🙂 😄
- Predictions are quality-weighted: nights I feel great pull the target duration more strongly than nights I feel terrible, so suggestions converge toward what actually works
- "I need to wake up at X" → suggests when to go to sleep
- "I'm going to sleep now" → suggests when to set an alarm
- Edit or delete past entries directly from the history list
- Planned: upgrade the prediction engine to a Core ML / Create ML model once enough data is collected

### Water Reminders
8 push notifications evenly distributed from my wake-up time to 1:00 AM to remind me to drink water throughout the day.

- Schedule automatically adapts when I log my actual wake time in SleepyTime!
- Falls back to a configurable default wake time on days I don't log sleep
- Can be toggled on/off in Settings
