/**
 * The App component renders the StatusBar component with a dark style and background color from the
 * theme, along with the AppNavigator component.
 * @returns The `App` function is being returned, which contains the StatusBar component with style set
 * to "dark" and backgroundColor set to the background color from the theme, as well as the
 * AppNavigator component.
 */
import 'react-native-gesture-handler';
import React from 'react';
import { StatusBar } from 'expo-status-bar';
import AppNavigator from './src/navigation/AppNavigator';
import { theme } from './src/styles/theme';

export default function App() {
  return (
    <>
      <StatusBar style="dark" backgroundColor={theme.colors.background} />
      <AppNavigator />
    </>
  );
}
