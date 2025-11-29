# AI Rules for Monynha Fun Development

This document outlines the core technologies and best practices for developing the Monynha Fun application. Adhering to these guidelines ensures consistency, maintainability, and optimal performance.

## Tech Stack Overview

The Monynha Fun application is built using a modern web development stack, focusing on performance, developer experience, and scalability.

*   **Frontend Framework**: React.js for building dynamic user interfaces.
*   **Language**: TypeScript for type safety and improved code quality.
*   **Build Tool**: Vite for a fast development server and optimized builds.
*   **Styling**: Tailwind CSS for utility-first styling and responsive design.
*   **UI Components**: shadcn/ui, a collection of reusable components built on Radix UI and styled with Tailwind CSS.
*   **Routing**: React Router DOM for client-side navigation.
*   **Data Management**: React Query for server state management, caching, and synchronization.
*   **Backend & Authentication**: Supabase for database, authentication, and real-time capabilities.
*   **Form Handling**: React Hook Form for efficient form management, integrated with Zod for schema validation.
*   **Icons**: Lucide React for a comprehensive set of customizable SVG icons.

## Library Usage Rules

To maintain a consistent and efficient codebase, please follow these rules when implementing new features or modifying existing ones:

*   **UI Components**:
    *   Always prioritize `shadcn/ui` components for UI elements.
    *   If a `shadcn/ui` component doesn't fit the exact requirement, create a new component in `src/components/` rather than modifying existing `shadcn/ui` files.
*   **Styling**:
    *   Exclusively use `Tailwind CSS` classes for all styling. Avoid inline styles or custom CSS files unless absolutely necessary for complex animations or global overrides.
    *   Ensure designs are responsive by utilizing Tailwind's responsive utility classes.
*   **Icons**:
    *   Use icons from the `lucide-react` library.
*   **State Management & Data Fetching**:
    *   For server-side data fetching, caching, and synchronization, use `React Query`.
    *   For local component state, use React's `useState` and `useReducer` hooks.
*   **Routing**:
    *   Manage all application routes within `src/App.tsx` using `react-router-dom`.
*   **Form Handling**:
    *   Implement forms using `react-hook-form` for controlled inputs and validation.
    *   Define form schemas and validation rules using `zod`.
*   **Toasts/Notifications**:
    *   For displaying user notifications (e.g., success messages, errors), use the `sonner` library.
*   **Supabase Interactions**:
    *   Interact with the Supabase backend using the `supabase` client instance from `src/integrations/supabase/client.ts`.
*   **Utility Functions**:
    *   Use the `cn` utility function from `src/lib/utils.ts` for conditionally combining Tailwind CSS classes.
*   **File Structure**:
    *   Place all new components in `src/components/`.
    *   Place all new pages in `src/pages/`.
    *   Create a new file for every new component or hook, no matter how small.
    *   Keep directory names all lowercase.