Absolutely. Based on the decisions we’ve established for **PulseHub**, here is a complete project brief you can use as the master specification for development, UI/UX planning, database design, and team task breakdown.

# PulseHub — Complete Project Brief

## 1. Project Overview

**PulseHub** is a mobile-first social and community platform designed for existing investors and members within the **BOT Chain and CaryPact ecosystem**.

The application combines:

* Social/community interaction
* Investor information
* CaryPact investment information
* BOT Chain blockchain information
* BOT token-based subscriptions
* Educational learning modules
* In-app messaging
* In-app live meetings
* Notifications
* Investor dashboard
* Secure account and wallet connectivity

The goal is to create a single application where users can **connect, learn, communicate, attend meetings, monitor their investment-related information, and interact with the BOT Chain ecosystem**.

PulseHub should feel primarily like a **modern social/community application**, rather than a traditional banking or financial application.

---

# 2. Core Product Concept

### PulseHub brings three major systems together:

**PulseHub**
→ Social, community, communication, learning, meetings and user experience.

**CaryPact**
→ Investment-related information, assets, rewards, activities and investor data.

**BOT Chain**
→ Blockchain infrastructure, BOT token, wallet transactions, smart contracts and on-chain information.

### High-level architecture

```text
                    ┌──────────────────────┐
                    │      PULSEHUB        │
                    │   Flutter Mobile App │
                    └──────────┬───────────┘
                               │
             ┌─────────────────┼─────────────────┐
             │                 │                 │
             ▼                 ▼                 ▼
        PulseHub Data     CaryPact Data     BOT Chain Data
             │                 │                 │
             └─────────────────┼─────────────────┘
                               │
                         Supabase Backend
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
             Database       Realtime       Storage
                               │
                ┌──────────────┼──────────────┐
                │                             │
                ▼                             ▼
          BOT Chain / Web3               LiveKit
          Smart Contracts               Live Meetings
```

---

# 3. Primary Goals

## Business Goals

1. Provide a central platform for existing CaryPact/BOT Chain investors and members.
2. Increase community engagement.
3. Provide investors with easy access to relevant information.
4. Educate users about BOT Chain, CaryPact and blockchain technology.
5. Enable communication between community members.
6. Provide live meetings directly inside the application.
7. Allow users to purchase subscriptions using **BOT tokens**.
8. Create a secure platform suitable for investor-related information.
9. Give administrators complete control through a separate web dashboard.
10. Create a foundation that can later support additional Web3 and investor features.

---

# 4. Target Users

## Investor / Member

The primary user.

Can:

* View dashboard
* View CaryPact information
* View BOT balance
* View assets
* View rewards
* View transactions
* Join communities
* Chat
* Attend meetings
* Learn
* Subscribe using BOT
* Manage profile

## Moderator

Responsible for community moderation.

Can:

* Review posts
* Remove inappropriate content
* Handle reports
* Moderate communities
* Restrict users where authorized

## Instructor / Content Manager

Responsible for learning content.

Can:

* Create courses
* Create modules
* Create lessons
* Add quizzes
* Monitor learning progress

## Community Manager

Responsible for engagement.

Can:

* Manage groups
* Publish announcements
* Schedule events
* Manage community content

## Admin

Responsible for platform operations.

Can:

* Manage users
* Manage subscriptions
* Manage meetings
* Manage learning content
* Manage community
* View reports
* Manage platform settings

## Super Admin

Full system access.

Can:

* Manage administrators
* Manage roles
* Manage security settings
* Manage smart-contract configuration
* Access audit logs
* Manage critical system configuration

---

# 5. Mobile Application

## Technology

Recommended stack:

### Frontend

* Flutter
* Dart
* Riverpod
* GoRouter
* Dio / HTTP client
* Web3-compatible libraries
* LiveKit Flutter SDK

### Backend

* Supabase
* PostgreSQL
* Supabase Auth
* Supabase Realtime
* Supabase Storage
* Supabase Edge Functions

### Blockchain

* BOT Chain
* BOT token
* Smart contracts
* EVM-compatible Web3 integration

### Video

* LiveKit

### Push Notifications

* Firebase Cloud Messaging / APNs-compatible architecture

---

# 6. Main Mobile Navigation

The application should use a **mobile-first bottom navigation system**.

```text
┌──────────────────────────────┐
│                              │
│         PAGE CONTENT         │
│                              │
│                              │
├──────────────────────────────┤
│ Home │ Community │ Learn │   │
│ Dash │ Profile              │
└──────────────────────────────┘
```

### Navigation

1. **Home**
2. **Community**
3. **Learn**
4. **Dashboard**
5. **Profile**

---

# 7. Home

The Home page is the user's personalized PulseHub feed.

### Required features

* Welcome message
* User profile summary
* Community feed
* Latest announcements
* Upcoming meetings
* Learning recommendations
* Subscription status
* Important notifications
* CaryPact updates
* BOT Chain updates
* Quick actions

### Quick actions

Example:

```text
[ Community ]
[ Messages ]
[ Learn ]
[ Dashboard ]
[ Meetings ]
```

---

# 8. Community

The Community section should make PulseHub feel like a **social application**.

## Feed

Users can:

* Create posts
* View posts
* Like/react
* Comment
* Reply
* Share
* Save
* Report
* Delete their own posts
* Edit their own posts

### Post types

* Text
* Image
* Video
* Announcement
* Event
* Learning-related content

---

## User Profiles

Users should have:

* Profile photo
* Name
* Username
* Bio
* Role
* Joined date
* Posts
* Communities
* Achievements
* Learning progress

### Social features

* Follow
* Unfollow
* Followers
* Following
* Block
* Report

---

# 9. Communities / Groups

Users should be able to participate in topic-specific communities.

Examples:

* BOT Chain Community
* CaryPact Investors
* Beginner Blockchain
* Investor Discussions
* Announcements
* Technology
* Events

### Group features

* Group feed
* Members
* Posts
* Group chat
* Announcements
* Events
* Moderation
* Group settings

---

# 10. Chat System

PulseHub requires a complete real-time messaging system.

## One-to-One Chat

Users can:

* Send messages
* Receive messages in real time
* Reply
* Edit
* Delete
* React
* Send images
* Send files
* Search messages
* See read status
* See typing status
* See online status

---

## Group Chat

Required:

* Multiple participants
* Group name
* Group photo
* Admin/moderator controls
* Add/remove members
* Group messages
* Message reactions
* Reply
* Attachments
* Mentions
* Notifications

---

## Messaging UX

Example:

```text
Messages

┌────────────────────────────┐
│ 🔵 John                    │
│    Hey, are you joining... │
│                       10:32│
├────────────────────────────┤
│ 🟢 Sarah                   │
│    See you at the meeting │
│                       10:35│
└────────────────────────────┘
```

---

# 11. Live Meetings

Live meetings must happen **inside PulseHub**.

Recommended infrastructure:

**LiveKit**

This provides the WebRTC infrastructure required for real-time video/audio communication.

## Meeting features

### Participants

* Host
* Co-host
* Participants

### Video

* Camera on/off
* Microphone on/off
* Speaker controls
* Participant list
* Active speaker indication

### Screen sharing

* Share screen
* Stop sharing

### Meeting chat

Users can send messages while attending.

### Host controls

Host can:

* Mute participants
* Remove participants
* End meeting
* Lock meeting
* Manage speakers
* Control participant permissions

---

# 12. Meeting Scheduling

Users should be able to see:

* Upcoming meetings
* Meeting title
* Description
* Date
* Time
* Host
* Number of participants
* Meeting status

### RSVP

Users can:

* Join
* RSVP
* Cancel RSVP
* Receive reminders

### Meeting states

```text
Scheduled
    ↓
Starting Soon
    ↓
Live
    ↓
Ended
```

---

# 13. Learning Center

The Learn section should educate users about the ecosystem.

## Main learning categories

### Getting Started

* How PulseHub works
* Account setup
* Navigation
* Profile management

### BOT Chain

* What is BOT Chain?
* How BOT Chain works
* Network fundamentals
* Transactions
* Gas
* Wallets

### CaryPact

* What is CaryPact?
* How CaryPact works
* Investment information
* Rewards
* Assets
* Activities

### Blockchain Basics

* Blockchain
* Wallets
* Tokens
* Smart contracts
* Transactions
* Gas fees
* Security

### BOT Token

* What BOT is
* How BOT is used
* BOT transactions
* Subscription payments

### PulseHub

* Community
* Chat
* Meetings
* Dashboard
* Subscriptions

### Security

* Wallet safety
* Scam awareness
* Phishing
* Private keys
* Seed phrases
* Account security

---

# 14. Learning Content

Each course can contain:

```text
Course
 ├── Module 1
 │    ├── Lesson 1
 │    ├── Lesson 2
 │    └── Quiz
 │
 ├── Module 2
 │    ├── Lesson 1
 │    └── Lesson 2
 │
 └── Final Quiz
```

### Lesson formats

* Text
* Images
* Video
* Documents
* Links
* Quizzes

### Progress tracking

Track:

* Started
* Completed
* Percentage
* Last viewed lesson
* Quiz score
* Completion date

### Achievements

Examples:

* First Lesson
* Blockchain Beginner
* BOT Explorer
* Community Member
* Course Completed

---

# 15. Investor Dashboard

This is one of the most important parts of PulseHub.

The dashboard should combine:

### BOT Chain

### CaryPact

### PulseHub

These should be visually separated so users understand where each piece of information comes from.

---

## BOT Chain Overview

Display:

* Connected wallet
* BOT balance
* Other assets
* Recent transactions
* On-chain activity
* Network information

Example:

```text
BOT Chain

BOT Balance
1,250 BOT

Assets
3

Transactions
24

Recent Activity
+100 BOT
-50 BOT
+250 BOT
```

---

# 16. CaryPact Dashboard

Display:

### Investment

* Investment amount
* Investment status
* Investment history

### Assets

* Asset name
* Quantity
* Status
* Value where available

### Rewards

* Total rewards
* Pending rewards
* Distributed rewards
* Reward history

### ROI

* Current ROI
* ROI percentage
* Historical performance where available

### Activities

* Investment activity
* Reward activity
* Asset activity
* Other CaryPact events

---

# 17. PulseHub Dashboard

The dashboard should also show platform activity.

### Include:

* Subscription status
* Current plan
* Subscription expiration
* Learning progress
* Courses completed
* Community activity
* Upcoming meetings
* Notifications

---

# 18. Transaction History

Users should be able to view transactions.

### Information

* Transaction type
* Amount
* Token
* Status
* Date
* Wallet
* Transaction hash
* Network
* Related application action

### Status

```text
Pending
Confirmed
Failed
```

Where appropriate, users should be able to open the transaction on the BOT Chain explorer.

---

# 19. Wallet Integration

The wallet architecture should remain **wallet-agnostic**.

Do not hard-code PulseHub to a specific wallet at this stage.

Create a wallet abstraction such as:

```text
WalletService
    ├── connect()
    ├── disconnect()
    ├── getAddress()
    ├── getBalance()
    ├── signMessage()
    └── sendTransaction()
```

This allows future support for different wallets.

### Critical security rule

PulseHub must **never store**:

* Private keys
* Seed phrases
* Recovery phrases
* Wallet passwords

The application should request users to approve blockchain transactions through their wallet.

---

# 20. Subscription System

Subscription payments must use the **BOT token**.

No Stripe.

No PayPal.

The payment mechanism should use a **smart contract**.

---

## Subscription Flow

```text
User selects plan
       ↓
PulseHub displays price
       ↓
User confirms
       ↓
Wallet opens
       ↓
User approves BOT transaction
       ↓
Smart Contract receives payment
       ↓
BOT Chain confirms transaction
       ↓
PulseHub verifies transaction
       ↓
Subscription activated
```

---

# 21. Subscription Plans

Admin should be able to create plans.

Each plan can contain:

* Name
* Description
* BOT price
* Duration
* Features
* Status
* Start/end availability

Example:

```text
Basic
100 BOT / 30 days

Premium
250 BOT / 30 days

VIP
500 BOT / 30 days
```

Actual pricing should remain configurable by administrators.

---

# 22. Smart Contract Requirements

The subscription smart contract should handle:

* Subscription payment
* Plan identification
* BOT token transfer
* Subscription activation
* Expiration
* Renewal where applicable
* Transaction/event emission

The backend must independently verify:

* Correct network
* Correct BOT token
* Correct contract
* Correct amount
* Correct wallet
* Correct transaction
* Transaction success
* Subscription event
* No duplicate/replayed transaction

**Never activate a subscription solely because the mobile client says payment succeeded.**

---

# 23. CaryPact Integration

CaryPact should be treated as a separate business/domain layer from the core PulseHub social platform.

### CaryPact information may include:

* Investor profile
* Investments
* Assets
* Rewards
* ROI
* Activities
* Investment status
* History

The exact source of truth should be defined during implementation.

Possible sources:

```text
BOT Chain
     ↓
Smart Contracts
     ↓
Indexer/API
     ↓
PulseHub Backend
```

or:

```text
CaryPact Backend/API
        ↓
PulseHub Backend
        ↓
Mobile App
```

The architecture should allow either approach.

---

# 24. Notifications

PulseHub needs a complete notification system.

### Notification types

* New message
* New comment
* Post reaction
* Mention
* Follow
* Meeting reminder
* Meeting starting
* New announcement
* Course available
* Course completed
* Subscription expiring
* Subscription successful
* Blockchain transaction
* CaryPact update
* Reward received

### Notification preferences

Users should control notification categories.

---

# 25. Profile

Users should be able to manage:

* Profile photo
* Name
* Username
* Bio
* Email
* Password
* Notification settings
* Privacy settings
* Connected wallet
* Subscription
* Learning progress
* Account security

---

# 26. Security

Security is a major requirement because the platform handles investor-related information and blockchain transactions.

## Authentication

Use Supabase Auth.

Support:

* Email/password
* Email verification
* Password reset
* Session management
* Optional MFA

---

## Authorization

Implement:

**RBAC — Role-Based Access Control**

Example:

```text
Investor
Moderator
Instructor
Community Manager
Admin
Super Admin
```

---

## Database Security

Use Supabase Row Level Security.

Users should only be able to access data they are authorized to access.

For example:

```text
Investor A
     ↓
Can access Investor A's private data

Investor B
     ↓
Cannot access Investor A's private data
```

---

# 27. Audit Logging

Record sensitive administrative actions.

Examples:

* User role changed
* User suspended
* Subscription modified
* Investment record changed
* Smart-contract configuration changed
* Admin login
* Security setting changed

Audit record:

```text
Actor
Action
Resource
Timestamp
IP/device information where appropriate
Previous value
New value
```

---

# 28. KYC

**KYC is NOT required for the MVP.**

However, the architecture should be designed so KYC can be added later.

For example:

```text
Investor
   ↓
KYC Status
   ├── Not Required
   ├── Pending
   ├── Verified
   └── Rejected
```

Do not build a full KYC workflow into the MVP unless requirements change.

---

# 29. Admin Dashboard

PulseHub requires a **separate web-based Admin Dashboard**.

Recommended stack:

* Next.js
* TypeScript
* Tailwind CSS
* Supabase
* Recharts or similar visualization library

---

# 30. Admin Dashboard Navigation

```text
Dashboard
Users
Investors
Community
Chat
Meetings
Learning
Subscriptions
BOT Chain
CaryPact
Notifications
Reports
Security
Settings
```

---

# 31. Admin Overview Dashboard

Display:

### Users

* Total users
* Active users
* New users
* Suspended users

### Community

* Posts
* Comments
* Reports
* Active groups

### Meetings

* Upcoming meetings
* Live meetings
* Participants

### Learning

* Active learners
* Course completions
* Quiz statistics

### Subscriptions

* Active subscriptions
* Expiring subscriptions
* Subscription transactions
* BOT revenue

### Blockchain

* BOT transactions
* Failed transactions
* Pending transactions
* Smart-contract events

---

# 32. User Management

Admins can:

* Search users
* View profiles
* Edit profiles
* Suspend users
* Restore users
* Assign roles
* Remove roles
* View activity
* View security events

---

# 33. Community Administration

Admins/moderators can:

* Review posts
* Delete posts
* Review reports
* Manage groups
* Manage announcements
* Moderate comments
* Suspend abusive users

---

# 34. Learning Administration

Admins/instructors can:

* Create courses
* Edit courses
* Create modules
* Create lessons
* Upload videos/documents/images
* Create quizzes
* Manage questions
* View learner progress
* Publish/unpublish courses

---

# 35. Meeting Administration

Admins can:

* Create meetings
* Schedule meetings
* Edit meetings
* Cancel meetings
* Manage hosts
* View participants
* Manage recordings
* Review meeting history

---

# 36. Subscription Administration

Admins can:

* Create plans
* Edit plans
* Activate/deactivate plans
* Configure BOT price
* Configure duration
* View transactions
* View subscriptions
* View failed payments
* View expiring subscriptions

Smart-contract configuration should be protected by strict permissions.

---

# 37. BOT Chain Administration

Admin dashboard should provide blockchain monitoring rather than private-key custody.

Display:

* BOT transactions
* Contract events
* Subscription transactions
* Failed transactions
* Wallet activity
* Network information

Admins should **not** have access to user private keys or seed phrases.

---

# 38. CaryPact Administration

Admins should be able to view/manage appropriate CaryPact information:

* Investors
* Investments
* Assets
* Rewards
* Activities
* Status
* ROI information

Any data that originates from blockchain or an authoritative CaryPact service should not be casually overwritten by admins.

---

# 39. Database Structure

A starting PostgreSQL/Supabase schema:

### Authentication

```text
profiles
user_roles
investor_profiles
```

### Community

```text
posts
comments
reactions
groups
group_members
follows
reports
```

### Chat

```text
conversations
conversation_members
messages
message_reactions
message_attachments
```

### Meetings

```text
meetings
meeting_participants
meeting_messages
meeting_recordings
```

### Learning

```text
courses
modules
lessons
quizzes
quiz_questions
quiz_answers
user_progress
achievements
user_achievements
```

### BOT Chain

```text
wallets
transactions
assets
contract_events
```

### CaryPact

```text
carypact_profiles
carypact_investments
carypact_assets
carypact_rewards
carypact_activities
```

### Subscriptions

```text
subscription_plans
subscriptions
subscription_transactions
subscription_events
```

### Notifications

```text
notifications
notification_preferences
```

### Security

```text
audit_logs
security_events
login_sessions
```

---

# 40. Backend Architecture

Recommended architecture:

```text
Flutter
   │
   ▼
Application Services
   │
   ├── Auth Service
   ├── Community Service
   ├── Chat Service
   ├── Learning Service
   ├── Meeting Service
   ├── Subscription Service
   ├── Wallet Service
   ├── CaryPact Service
   └── BOT Chain Service
            │
            ▼
         Supabase
            │
     ┌──────┼──────┐
     ▼      ▼      ▼
 PostgreSQL Realtime Storage
            │
            ▼
       Edge Functions
            │
     ┌──────┴─────────┐
     ▼                ▼
 BOT Chain          LiveKit
```

---

# 41. Recommended Flutter Architecture

Use a feature-based architecture.

```text
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── router/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── community/
│   ├── chat/
│   ├── meetings/
│   ├── learning/
│   ├── dashboard/
│   ├── wallet/
│   ├── subscriptions/
│   ├── carypact/
│   ├── notifications/
│   └── profile/
│
├── services/
│   ├── auth/
│   ├── supabase/
│   ├── wallet/
│   ├── botchain/
│   ├── carypact/
│   ├── livekit/
│   └── notifications/
│
└── main.dart
```

This keeps blockchain, CaryPact and social features from becoming tightly coupled.

---

# 42. UI/UX Direction

PulseHub should look like a **premium social/community app**.

### Design characteristics

* Mobile-first
* Clean
* Modern
* Minimal
* Highly readable
* Card-based content
* Rounded components
* Strong visual hierarchy
* Smooth animations
* Bottom navigation
* Dark/light theme support
* Responsive layouts
* Clear loading states
* Empty states
* Error states

### Important principle

Don't make every screen look like a financial dashboard.

The **Community, Home and Learn** sections should feel social and approachable.

The **Dashboard** can become more data-oriented.

---

# 43. Core MVP Features

For the first release, prioritize:

### Authentication

* Sign up
* Login
* Email verification
* Password reset
* Profile

### Community

* Feed
* Posts
* Comments
* Reactions
* Profiles
* Groups
* Reports

### Chat

* 1-to-1
* Group chat
* Realtime messaging
* Attachments
* Read status
* Typing indicator

### Learning

* Courses
* Modules
* Lessons
* Progress
* Quizzes

### Meetings

* Schedule
* Join
* Video
* Audio
* Screen share
* Meeting chat

### Dashboard

* BOT balance
* Wallet
* Transactions
* CaryPact investments
* Assets
* Rewards
* ROI
* Activity

### Subscription

* Plans
* BOT token payment
* Smart contract
* Transaction verification
* Subscription status

### Notifications

* Push
* In-app notifications

### Admin

* User management
* Community moderation
* Learning management
* Meetings
* Subscriptions
* Investor information
* Reports
* Security logs

---

# 44. MVP Exclusions

The following should **not** be required for the first MVP:

* Full KYC system
* Custodial wallet
* Storing private keys
* Seed phrase storage
* Traditional payment gateways
* Stripe
* PayPal
* Complex trading platform
* Full DeFi exchange
* Advanced portfolio trading
* Complex financial advisory functionality

PulseHub is primarily an **information, community, communication and investor-support platform**.

---

# 45. Development Phases

## Phase 1 — Foundation

* Flutter project
* Architecture
* Theme
* Routing
* Supabase
* Environment configuration
* Error handling
* Logging

## Phase 2 — Authentication

* Registration
* Login
* Verification
* Password reset
* Profile

## Phase 3 — Core UI

* Bottom navigation
* Home
* Community
* Learn
* Dashboard
* Profile

## Phase 4 — Community

* Feed
* Posts
* Comments
* Reactions
* Profiles
* Groups
* Reports

## Phase 5 — Chat

* Conversations
* Realtime messaging
* Group chat
* Attachments
* Notifications

## Phase 6 — Learning

* Courses
* Modules
* Lessons
* Quizzes
* Progress
* Achievements

## Phase 7 — Meetings

* Scheduling
* RSVP
* LiveKit
* Video/audio
* Screen sharing
* Meeting chat

## Phase 8 — BOT Chain

* Wallet abstraction
* Wallet connection
* BOT balance
* Transaction history
* Blockchain verification

## Phase 9 — CaryPact

* Investor data
* Investments
* Assets
* Rewards
* ROI
* Activities

## Phase 10 — Subscription

* Plans
* BOT token payments
* Smart contract
* Transaction verification
* Subscription activation

## Phase 11 — Admin Dashboard

* Next.js web application
* User management
* Community
* Learning
* Meetings
* Subscriptions
* BOT Chain
* CaryPact
* Reports

## Phase 12 — Security & Production

* RLS review
* RBAC review
* Audit logs
* Rate limiting
* Security testing
* Transaction testing
* Performance testing
* Crash monitoring
* Production deployment

---

# 46. Final Product Architecture

The final ecosystem should look approximately like this:

```text
                         PULSEHUB ECOSYSTEM
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
       Flutter Mobile App               Web Admin Dashboard
                │                               │
                └───────────────┬───────────────┘
                                │
                                ▼
                         Supabase Backend
                                │
             ┌──────────────────┼──────────────────┐
             │                  │                  │
             ▼                  ▼                  ▼
        Social Layer       Investor Layer     Platform Layer
             │                  │                  │
        Community            CaryPact          Subscriptions
        Chat                  Investments       Learning
        Groups                Assets             Meetings
        Profiles              Rewards            Notifications
                              ROI
                                │
                ┌───────────────┴───────────────┐
                ▼                               ▼
             BOT Chain                       LiveKit
                │                               │
          BOT Token                         Video/Audio
          Smart Contracts                   Meetings
          Transactions
          Wallets
```

# 47. Product Principle

The most important architectural principle for the project is:

> **PulseHub should be the user experience layer, while BOT Chain and CaryPact remain distinct underlying domains.**

In practical terms:

* **PulseHub** → community, communication, learning and user experience
* **CaryPact** → investment/business functionality
* **BOT Chain** → blockchain infrastructure
* **BOT Token** → subscription/payment utility
* **Smart Contract** → trustless subscription payment mechanism
* **Supabase** → application backend and data layer
* **LiveKit** → in-app real-time meetings
* **Admin Web** → platform management and operations

This structure will make the application much easier to maintain and expand later without turning the Flutter app into one tightly coupled codebase.
