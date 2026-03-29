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
- Flutter SDK is not currently installed on this machine, so the codebase can be prepared now and the generated platform runners can be added once Flutter is available

## Step 3: Mock-first mobile flows

- home/upcoming
- event detail
- following
- alerts
- settings
- paywall

Exit criteria:
- mobile navigation and UI shell are stable with mock data

## Step 4: Persistence and contracts

- create database schema
- wire organizations/events
- add favorites and alerts
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
- privacy/legal surfaces

Exit criteria:
- core release checklist is functionally complete

## Step 7: Quality and release prep

- loading, empty, and error states
- tests for time conversion and entitlements
- store metadata and policies

Exit criteria:
- internal beta candidate is ready
