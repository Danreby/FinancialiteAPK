// Extend expo-router types to include our custom app routes
// This prevents TypeScript from complaining about route string literals
declare module 'expo-router' {
  // Re-export everything that expo-router normally exports
  export function useRouter(): {
    push(href: string): void;
    replace(href: string): void;
    back(): void;
    canGoBack(): boolean;
    navigate(href: string): void;
    dismiss(count?: number): void;
    dismissAll(): void;
  };

  export function useLocalSearchParams<T extends Record<string, string>>(): T;
  export function useGlobalSearchParams<T extends Record<string, string>>(): T;
  export function useSegments(): string[];
  export function usePathname(): string;
  export function useNavigation(): any;
  export function useFocusEffect(callback: () => void | (() => void)): void;
  export function useRootNavigationState(): any;

  export const Stack: React.ComponentType<any> & {
    Screen: React.ComponentType<any>;
  };

  export const Tabs: React.ComponentType<any> & {
    Screen: React.ComponentType<any>;
  };

  export const Link: React.ComponentType<any>;
  export const Redirect: React.ComponentType<{ href: string }>;
  export const Slot: React.ComponentType<any>;
  export const SplashScreen: { preventAutoHideAsync(): void; hideAsync(): void };

  export type Href = string | { pathname: string; params?: Record<string, string> };
}
