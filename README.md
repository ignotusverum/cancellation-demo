# Cancellation Demo

A SwiftUI iOS application demonstrating asynchronous task cancellation patterns using Swift's modern async/await concurrency model.

## What It Does

The app fetches a list of popular movies from The Movie Database (TMDb) API and displays them as cards. When a movie card becomes visible, it begins loading detail data in the background. When the card disappears — because the user scrolled away — the background task is cancelled immediately, and the card reflects a cancelled state rather than completing work that is no longer needed.

This makes the cancellation behavior explicit and visible: each card shows its current loading state with a color and symbol, so you can watch tasks start and cancel in real time.

## Architecture

The project uses MVVM with a reducer-based state management approach. The `PopularListViewModel` drives all state transitions through dispatched actions. UI-triggered events go through `ViewAction` and data-layer changes go through `ModelAction`. State flows from `.initial` through `.loading` to `.viewData([Movie])` or `.error`.

Movie-level loading states live on each `Movie` model instance as `LoadingState`: idle, loading, loaded, failed, or cancelled. Each card's background color reflects its current state — white for idle or in-progress, green for loaded, red for failed, yellow for cancelled.

Active fetch tasks are tracked in a dictionary keyed by movie ID (`fetchMovieDetailsTask`). When a card disappears, its task is cancelled via `task.cancel()`, and the error handling in `loadMovieDetails()` distinguishes `CancellationError` from real failures to set the right final state.

## Key Files

`PopularListViewModel.swift` contains the core logic: state reduction, side effect coordination, and task lifecycle management.

`Movie.swift` defines the data model and the `LoadingState` enum that drives per-card UI.

`PopularListView.swift` renders the list and wires up `onDisappear` to trigger cancellation.

`Discover.swift` implements the TMDb API calls for the popular movies list and individual movie details.

## Simulated Latency

Detail loading includes a random 2–4 second delay before the network request fires. This makes cancellation easy to trigger by scrolling quickly, which is useful when exploring or demonstrating the pattern.

## Requirements

Xcode 15 or later. iOS 17 or later. A valid TMDb API bearer token configured in `Discover.swift`.
