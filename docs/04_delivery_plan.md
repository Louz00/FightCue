# Delivery Plan

## Step 1: Product baseline

- lock app name and positioning
- confirm MVP scope
- list owner decisions and unknowns

Exit criteria:
- product direction is clear enough to scaffold without rework

## Step 2: Technical scaffold

- create Flutter app shell for Android and iOS
- create backend shell
- add local Docker services
- set environment variable strategy

Exit criteria:
- app and API both boot locally

Current note:
- Flutter SDK is installed
- Android tooling is configured
- Xcode still needs full installation and initialization

## Step 3: Mock-first mobile flows

- home/upcoming
- followed fighters on startup
- event detail
- expandable event cards
- following
- alerts
- settings
- paywall
- watch by country
- quiet free-tier ads

Exit criteria:
- mobile navigation and UI shell are stable with mock data

## Step 4: Persistence and contracts

- create database schema
- wire organizations/events
- add anonymous user profile model
- add optional account-linking model
- add fighter follows
- add favorites and alerts
- add watch availability storage
- add subscription status shape

Exit criteria:
- mobile app can read and persist core MVP state

## Step 5: Source ingestion

- adapter contract
- first launch source
- normalization
- ingestion logs and parser failure handling

Exit criteria:
- at least one reliable source feeds the app end to end

## Step 6: Release features

- notifications
- ICS export
- billing verification
- free-tier ad integration
- privacy/legal surfaces
- country override for watch availability
- consent management

Exit criteria:
- core release checklist is functionally complete

## Step 7: Quality and release prep

- loading, empty, and error states
- tests for time conversion and entitlements
- tests for follow-state persistence and country-specific watch info
- store metadata and policies

Exit criteria:
- internal beta candidate is ready
