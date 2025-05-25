/**
 * The code defines a navigation stack for a React Native app with two screens, HomeScreen and
 * ShareScreen, using React Navigation.
 * @property Home - The code you provided sets up a basic navigation stack using React Navigation in a
 * React Native application.
 * @property Share - The `Share` property in the code snippet refers to a screen in the app navigation.
 * When the user navigates to the `Share` screen, the `ShareScreen` component will be rendered in the
 * app. This allows users to interact with the content or functionality specific to the `Share` screen
 */
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import CustomHeader from '../components/CustomHeader';
import HomeScreen from '../screens/HomeScreen';
import ShareScreen from '../screens/ShareScreen';
import SettingsScreen from '../screens/SettingsScreen';
import ProfileScreen from '../screens/ProfileScreen';
import LoginScreen from '../screens/LoginScreen';
import { theme } from '../styles/theme';

export type RootStackParamList = {
  Login: undefined;
  Home: undefined;
  Share: undefined;
  Settings: undefined;
  Profile: undefined;
};

const Stack = createStackNavigator<RootStackParamList>();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Login"
        screenOptions={{
          // Use custom headers for each screen
          cardStyle: { backgroundColor: theme.colors.background },
        }}
      >
        <Stack.Screen 
          name="Login" 
          component={LoginScreen} 
          options={{
            headerShown: false // Hide default header for login screen
          }}
        />
        <Stack.Screen 
          name="Home" 
          component={HomeScreen} 
          options={{
            // Custom header with no back button for home screen
            header: () => <CustomHeader/>
          }}
        />
        <Stack.Screen 
          name="Share" 
          component={ShareScreen} 
          options={{
            // Custom header with back button and title
            header: () => <CustomHeader title="Share Poem" showBackButton />
          }}
        />
        <Stack.Screen 
          name="Settings" 
          component={SettingsScreen} 
          options={{
            header: () => <CustomHeader title="Settings" showBackButton />
          }}
        />
        <Stack.Screen 
          name="Profile" 
          component={ProfileScreen} 
          options={{
            header: () => <CustomHeader title="Profile" showBackButton />
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
