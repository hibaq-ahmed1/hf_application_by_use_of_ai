# House Finder

A modern Flutter app for discovering rental homes near you — with AI-style match scores, smart analytics, and role-based workspaces for seekers, owners/agents, and admins.

## System flow

```
HOUSE FINDER BY USE OF AI
        │
 ┌──────┼──────┐
 ▼      ▼      ▼
Seeker  Owner  Admin
   │      │      │
   └──────┼──────┘
          ▼
     SQL DATABASE
          ▼
     AI RECOMMENDER
          ▼
   MATCHING / RANKING → best houses for user
```

## Features

- **Seekers**: Home · Search · Map · Favorites · Profile; preferences; GPS nearby; map markers with preview; house details (images → AI match → amenities → map → owner); Call / WhatsApp / Inquiry / Favorite; similar houses; recently viewed; AI smart search (“describe the house”)
- **AI recommendation (core)**: Budget 25% + Location/distance 20% + Type 15% + Bedrooms 15% + Amenities 15% + Behaviour 10% → match % + “Why this house matches you”; interactions stored for ranking
- **Owners / Agents**: Dashboard · My properties · Add · Inquiries · Profile
- **Admin**: Total users/houses/available/rented/inquiries; most viewed & favorited; most-searched towns; popular houses; reports & categories

## Demo accounts

Tap a role chip on the login screen to sign in instantly:

| Role   | Email                   | Password   |
|--------|-------------------------|------------|
| Seeker | seeker@housefinder.com  | seeker123  |
| Owner  | owner@housefinder.com   | owner123   |
| Admin  | admin@housefinder.com   | admin123   |

All roles can change password and toggle dark theme from Profile / Reports.

## Run

```bash
flutter pub get
flutter run
```

## Database schema

See `database/schema.sql` for AI-ready SQL tables.
